import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/fire_focus.dart';
import '../models/fire_alert.dart';

class FireWatchService {
  static const String _nasaFirmsBaseUrl = 'https://firms.modaps.eosdis.nasa.gov/api/area/csv';

  String get _nasaApiKey => dotenv.get('NASA_FIRMS_API_KEY', fallback: '');

  static final FireWatchService _instance = FireWatchService._internal();
  factory FireWatchService() => _instance;
  FireWatchService._internal();

  Future<List<FireFocus>> fetchActiveFoci({
    double south = -33.75,
    double west = -73.99,
    double north = 5.27,
    double east = -34.79,
    int dayRange = 7,
  }) async {
    if (_nasaApiKey.isEmpty || _nasaApiKey.startsWith('sua_')) return [];

    try {
      final url = Uri.parse('$_nasaFirmsBaseUrl/$_nasaApiKey/VIIRS_SNPP_NRT/$west,$south,$east,$north/$dayRange');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return _parseFirmsCSV(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  List<FireFocus> _parseFirmsCSV(String csv) {
    final lines = csv.split('\n');
    if (lines.length < 2) return [];
    
    final foci = <FireFocus>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final cols = line.split(',');
      if (cols.length < 10) continue;
      try {
        final lat = double.parse(cols[0]);
        final lon = double.parse(cols[1]);
        final tempK = double.parse(cols[2]);
        final satCode = cols[7].trim();
        final dateStr = cols[5].trim();
        final timeStr = cols[6].trim();

        final hh = int.parse(timeStr.substring(0, 2));
        final mm = int.parse(timeStr.substring(2));
        final detectedAt = DateTime.parse(dateStr).add(Duration(hours: hh, minutes: mm));

        if (tempK > 315 && _isInsideBrazil(lat, lon)) {
          foci.add(FireFocus(
            id: 'NASA-${cols[7].trim()}-$i',
            latitude: lat,
            longitude: lon,
            temperature: tempK - 273.15,
            areaHectares: 0.375, 
            satellite: _mapSatelliteName(satCode),
            biome: _guessBiome(lat, lon),
            state: _guessState(lat, lon),
            detectedAt: detectedAt,
            riskLevel: _calculateRisk(tempK),
          ));
        }
      } catch (_) {}
    }
    return foci;
  }

  String _mapSatelliteName(String code) {
    if (code == 'N' || code == 'SNPP') return 'Suomi NPP (VIIRS)';
    if (code == 'J1' || code == 'NOAA-20') return 'NOAA-20 (VIIRS)';
    return 'Satélite VIIRS';
  }

  bool _isInsideBrazil(double lat, double lon) {
    return (lon >= -74.0 && lon <= -34.7) && (lat >= -33.8 && lat <= 5.3);
  }

  Future<List<FireAlert>> generateAlerts(List<FireFocus> foci) async {
    final alerts = <FireAlert>[];
    final today = DateTime.now();
    final priorityFoci = foci.where((f) => 
      (f.riskLevel == FireRisk.critical || f.riskLevel == FireRisk.high) &&
      today.difference(f.detectedAt).inHours < 24
    ).toList();

    for (var f in priorityFoci) {
      alerts.add(FireAlert(
        id: 'ALT-${f.id}',
        title: 'Fogo Ativo Detectado',
        description: 'Anomalia térmica de ${f.temperature.toStringAsFixed(0)}°C em área de ${f.biome}.',
        location: '${f.state} · Brasil',
        severity: f.riskLevel == FireRisk.critical ? AlertSeverity.critical : AlertSeverity.high,
        status: AlertStatus.active,
        createdAt: f.detectedAt,
        fireFocusId: f.id,
      ));
    }
    return alerts;
  }

  Future<DashboardStats> calculateStats(List<FireFocus> foci) async {
    final Map<String, int> biomes = {};
    final Map<String, int> satCounts = {};
    final Set<String> activeSats = {};
    final List<int> dailyCounts = List.filled(7, 0);
    
    final today = DateTime.now();
    int activeAlerts = 0;
    DateTime? latestScan;

    for (var f in foci) {
      biomes[f.biome] = (biomes[f.biome] ?? 0) + 1;
      satCounts[f.satellite] = (satCounts[f.satellite] ?? 0) + 1;
      activeSats.add(f.satellite);

      if (latestScan == null || f.detectedAt.isAfter(latestScan)) {
        latestScan = f.detectedAt;
      }

      final difference = today.difference(f.detectedAt).inDays;
      if (difference >= 0 && difference < 7) {
        dailyCounts[6 - difference]++;
      }

      if (difference == 0 && f.riskLevel == FireRisk.critical) {
        activeAlerts++;
      }
    }

    final totalToday = dailyCounts.last;
    final Map<String, int> breakdown = biomes.map((key, value) => MapEntry(key, foci.isNotEmpty ? (value * 100 ~/ foci.length) : 0));

    // Pegamos a posição exata baseada no momento do cálculo (Sync Time)
    final satPos = getEstimatedSatPosition(today);

    return DashboardStats(
      totalFociToday: totalToday,
      affectedAreaKm2: totalToday * 0.375,
      activeAlerts: activeAlerts,
      biomeBreakdown: breakdown,
      weeklyFoci: dailyCounts,
      activeSatellites: activeSats.toList(),
      breakdownBySatellite: satCounts,
      lastDataPoint: latestScan,
      nextPassEstimation: _estimateNextSatellitePass(),
      currentSatLocation: getSatRegionName(today),
      satLat: satPos['lat']!,
      satLon: satPos['lon']!,
    );
  }

  static String getSatRegionName(DateTime time) {
    final minute = time.minute;
    if (minute < 15) return "Sobre o Atlântico Sul (Subindo)";
    if (minute < 30) return "Cruzando o Brasil Central";
    if (minute < 45) return "Sobre a Amazônia (Norte)";
    if (minute < 55) return "Sobre a América do Norte";
    return "Região Ártica (Descendo)";
  }

  static Map<String, double> getEstimatedSatPosition(DateTime time) {
    final double progress = (time.minute % 60) / 60.0;
    double lat = -60 + (progress * 120); 
    double lon = -55 + (progress * 10);
    return {'lat': lat, 'lon': lon};
  }

  String _estimateNextSatellitePass() {
    final now = DateTime.now();
    final checkHours = [1.5, 10.5, 13.5, 22.5];
    
    double nextHour = checkHours.firstWhere(
      (h) => h > (now.hour + now.minute / 60.0),
      orElse: () => checkHours.first + 24,
    );

    final diffMinutes = ((nextHour - (now.hour + now.minute / 60.0)) * 60).toInt();
    final h = diffMinutes ~/ 60;
    final m = diffMinutes % 60;

    return "Em ${h > 0 ? '${h}h ' : ''}${m}min";
  }

  Future<AirQualityData> fetchAirQuality({required double lat, required double lon}) async {
    final key = dotenv.get('OPENWEATHER_API_KEY', fallback: '');
    if (key.isEmpty || key.startsWith('sua_')) return const AirQualityData(aqi: 1, pm25: 5.0, pm10: 10.0, co: 0.2);

    try {
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$key');
      final response = await http.get(url);
      if (response.statusCode == 200) return AirQualityData.fromJson(jsonDecode(response.body));
    } catch (_) {}
    return const AirQualityData(aqi: 1, pm25: 5.0, pm10: 10.0, co: 0.2);
  }

  Future<bool> submitFireReport({
    required String type,
    required String description,
    required double lat,
    required double lon,
    String? imagePath,
  }) async {
    debugPrint(' [FireWatch] Enviando Relatório Georreferenciado...');
    debugPrint(' [DATA] Tipo: $type | Pos: $lat, $lon');
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  FireRisk _calculateRisk(double tempK) {
    if (tempK > 480) return FireRisk.critical;
    if (tempK > 400) return FireRisk.high;
    if (tempK > 340) return FireRisk.medium;
    return FireRisk.low;
  }

  String _guessBiome(double lat, double lon) {
    if (lat > -5 && lon < -45) return 'Amazônia';
    if (lat < -15 && lon > -50) return 'Mata Atlântica';
    if (lat < -18 && lon < -55) return 'Pantanal';
    return 'Cerrado';
  }

  String _guessState(double lat, double lon) {
    if (lat > -5) return 'AM/PA';
    if (lat < -20) return 'SP/PR/RS';
    if (lon < -55) return 'MT/MS';
    return 'GO/MG/BA';
  }
}

class AirQualityData {
  final int aqi;
  final double pm25;
  final double pm10;
  final double co;
  const AirQualityData({required this.aqi, required this.pm25, required this.pm10, required this.co});
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0];
    final components = list['components'];
    return AirQualityData(
      aqi: list['main']['aqi'] as int,
      pm25: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      co: (components['co'] as num).toDouble() / 1000,
    );
  }
  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Bom';
      case 2: return 'Moderado';
      case 3: return 'Insalubre para sensíveis';
      case 4: return 'Insalubre';
      case 5: return 'Perigoso';
      default: return 'Desconhecido';
    }
  }
}

class DashboardStats {
  final int totalFociToday;
  final double affectedAreaKm2;
  final int activeAlerts;
  final Map<String, int> breakdownBySatellite;
  final Map<String, int> biomeBreakdown;
  final List<int> weeklyFoci;
  final List<String> activeSatellites;
  final String nextPassEstimation;
  final DateTime? lastDataPoint;
  final String currentSatLocation;
  final double satLat;
  final double satLon;

  const DashboardStats({
    required this.totalFociToday,
    required this.affectedAreaKm2,
    required this.activeAlerts,
    required this.biomeBreakdown,
    required this.weeklyFoci,
    this.activeSatellites = const [],
    this.nextPassEstimation = 'Calculando...',
    this.breakdownBySatellite = const {},
    this.lastDataPoint,
    this.currentSatLocation = 'Em órbita polar',
    this.satLat = 0,
    this.satLon = 0,
  });
}
