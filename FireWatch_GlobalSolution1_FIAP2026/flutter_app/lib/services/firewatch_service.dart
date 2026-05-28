import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fire_focus.dart';
import '../models/fire_alert.dart';

/// FireWatchService: Serviço principal de dados do FireWatch.
/// 
/// Integra com:
/// - NASA FIRMS (Fire Information for Resource Management System)
/// - INPE BDQueimadas API
/// - OpenWeatherMap (qualidade do ar)
///
/// Em produção, substitua as constantes de API key pelas chaves reais.
class FireWatchService {
  static const String _nasaFirmsBaseUrl =
      'https://firms.modaps.eosdis.nasa.gov/api/area/csv';
  static const String _inpeBaseUrl =
      'https://queimadas.dgi.inpe.br/api/focos';

  // Substitua com sua API key da NASA FIRMS em produção
  // Obtenha em: https://firms.modaps.eosdis.nasa.gov/api/
  static const String _nasaApiKey = '';

  // Singleton
  static final FireWatchService _instance = FireWatchService._internal();
  factory FireWatchService() => _instance;
  FireWatchService._internal();

  // -----------------------------------------------------------------------
  // Focos de Queimada
  // -----------------------------------------------------------------------

  /// Busca focos ativos via NASA FIRMS (VIIRS SNPP, resolução 375m)
  /// Área padrão: Brasil (-33.75 a 5.27 lat, -73.99 a -34.79 lon)
  Future<List<FireFocus>> fetchActiveFoci({
    double south = -33.75,
    double west = -73.99,
    double north = 5.27,
    double east = -34.79,
    int dayRange = 1,
  }) async {
    try {
      // Em produção: chamada real à NASA FIRMS
      // final url = Uri.parse(
      //   '$_nasaFirmsBaseUrl/$_nasaApiKey/VIIRS_SNPP_NRT/'
      //   '$west,$south,$east,$north/$dayRange',
      // );
      // final response = await http.get(url);
      // if (response.statusCode == 200) {
      //   return _parseFirmsCSV(response.body);
      // }
      
      // Dados mock representativos para demonstração
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockFoci();
    } catch (e) {
      // Fallback para dados mock em caso de erro de rede
      return _getMockFoci();
    }
  }

  /// Parse do CSV retornado pela NASA FIRMS
  List<FireFocus> _parseFirmsCSV(String csv) {
    final lines = csv.split('\n');
    if (lines.length < 2) return [];
    
    final foci = <FireFocus>[];
    for (var i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',');
      if (cols.length < 8) continue;
      try {
        foci.add(FireFocus(
          id: 'VIIRS-${cols[7].trim()}-$i',
          latitude: double.parse(cols[0]),
          longitude: double.parse(cols[1]),
          temperature: double.parse(cols[2]),
          areaHectares: 0.05, // VIIRS pixel = ~375m²
          satellite: 'NOAA-20 (VIIRS)',
          biome: _guessBiome(double.parse(cols[0]), double.parse(cols[1])),
          state: _guessState(double.parse(cols[0]), double.parse(cols[1])),
          detectedAt: DateTime.now().subtract(Duration(minutes: i * 15)),
          riskLevel: _calculateRisk(double.parse(cols[2])),
        ));
      } catch (_) {}
    }
    return foci;
  }

  // -----------------------------------------------------------------------
  // Alertas
  // -----------------------------------------------------------------------

  Future<List<FireAlert>> fetchAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockAlerts();
  }

  // -----------------------------------------------------------------------
  // Qualidade do Ar
  // -----------------------------------------------------------------------

  /// Busca IQAr via OpenWeatherMap Air Pollution API
  /// Documentação: https://openweathermap.org/api/air-pollution
  Future<AirQualityData> fetchAirQuality({
    required double lat,
    required double lon,
    String apiKey = '',
  }) async {
    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/air_pollution'
        '?lat=$lat&lon=$lon&appid=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return AirQualityData.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    // Mock fallback
    return const AirQualityData(aqi: 2, pm25: 18.4, pm10: 32.1, co: 0.8);
  }

  // -----------------------------------------------------------------------
  // Estatísticas
  // -----------------------------------------------------------------------

  Future<DashboardStats> fetchDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const DashboardStats(
      totalFociToday: 47,
      affectedAreaKm2: 12.3,
      activeAlerts: 3,
      biomeBreakdown: {
        'Cerrado': 78,
        'Amazônia': 14,
        'Mata Atlântica': 8,
      },
      weeklyFoci: [32, 25, 41, 18, 53, 29, 47],
    );
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  FireRisk _calculateRisk(double temperature) {
    if (temperature > 500) return FireRisk.critical;
    if (temperature > 380) return FireRisk.high;
    if (temperature > 280) return FireRisk.medium;
    return FireRisk.low;
  }

  String _guessBiome(double lat, double lon) {
    if (lat > -4 && lon < -44) return 'Amazônia';
    if (lat < -18 && lat > -34) return 'Mata Atlântica';
    return 'Cerrado';
  }

  String _guessState(double lat, double lon) {
    if (lat > -4) return 'Pará';
    if (lat < -22 && lon > -48) return 'São Paulo';
    if (lat < -15 && lat > -20) return 'Minas Gerais';
    return 'Goiás';
  }

  // -----------------------------------------------------------------------
  // Mock Data
  // -----------------------------------------------------------------------

  List<FireFocus> _getMockFoci() => [
        FireFocus(
          id: 'SP-2847',
          latitude: -23.5505,
          longitude: -46.6333,
          temperature: 423.0,
          areaHectares: 2.4,
          satellite: 'NOAA-20 (VIIRS)',
          biome: 'Mata Atlântica',
          state: 'São Paulo',
          detectedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          riskLevel: FireRisk.critical,
        ),
        FireFocus(
          id: 'GO-1153',
          latitude: -15.7801,
          longitude: -47.9292,
          temperature: 387.0,
          areaHectares: 8.1,
          satellite: 'Terra (MODIS)',
          biome: 'Cerrado',
          state: 'Goiás',
          detectedAt: DateTime.now().subtract(const Duration(minutes: 22)),
          riskLevel: FireRisk.high,
        ),
        FireFocus(
          id: 'MT-0891',
          latitude: -12.6818,
          longitude: -56.9211,
          temperature: 512.0,
          areaHectares: 45.6,
          satellite: 'NOAA-20 (VIIRS)',
          biome: 'Cerrado',
          state: 'Mato Grosso',
          detectedAt: DateTime.now().subtract(const Duration(hours: 1)),
          riskLevel: FireRisk.critical,
        ),
        FireFocus(
          id: 'PA-0342',
          latitude: -3.1190,
          longitude: -60.0217,
          temperature: 298.0,
          areaHectares: 12.3,
          satellite: 'Aqua (MODIS)',
          biome: 'Amazônia',
          state: 'Amazonas',
          detectedAt: DateTime.now().subtract(const Duration(hours: 3)),
          riskLevel: FireRisk.medium,
        ),
      ];

  List<FireAlert> _getMockAlerts() => [
        FireAlert(
          id: 'ALT-001',
          title: 'Foco detectado via VIIRS',
          description: 'Queimada de alta intensidade detectada por satélite',
          location: 'Mata Atlântica · SP',
          severity: AlertSeverity.critical,
          status: AlertStatus.active,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          distanceKm: 8.0,
          fireFocusId: 'SP-2847',
        ),
        FireAlert(
          id: 'ALT-002',
          title: 'Fumaça detectada via MODIS',
          description: 'Coluna de fumaça identificada em área rural',
          location: 'Zona rural · GO',
          severity: AlertSeverity.high,
          status: AlertStatus.active,
          createdAt: DateTime.now().subtract(const Duration(minutes: 22)),
          distanceKm: 15.0,
          fireFocusId: 'GO-1153',
        ),
        FireAlert(
          id: 'ALT-003',
          title: 'Qualidade do ar: Moderada',
          description: 'IQAr atingiu nível de atenção na sua região',
          location: 'Sua região',
          severity: AlertSeverity.info,
          status: AlertStatus.acknowledged,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        FireAlert(
          id: 'ALT-004',
          title: 'Foco extinto confirmado',
          description: 'Brigada de incêndio confirmou controle do foco',
          location: 'Parque Estadual · SP',
          severity: AlertSeverity.info,
          status: AlertStatus.resolved,
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];
}

class AirQualityData {
  final int aqi;
  final double pm25;
  final double pm10;
  final double co;

  const AirQualityData({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.co,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0];
    final components = list['components'];
    return AirQualityData(
      aqi: list['main']['aqi'] as int,
      pm25: (components['pm2_5'] as num).toDouble(),
      pm10: (components['pm10'] as num).toDouble(),
      co: (components['co'] as num).toDouble(),
    );
  }

  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Bom';
      case 2: return 'Moderado';
      case 3: return 'Não saudável (grupos sensíveis)';
      case 4: return 'Não saudável';
      case 5: return 'Muito não saudável';
      default: return 'Perigoso';
    }
  }
}

class DashboardStats {
  final int totalFociToday;
  final double affectedAreaKm2;
  final int activeAlerts;
  final Map<String, int> biomeBreakdown;
  final List<int> weeklyFoci;

  const DashboardStats({
    required this.totalFociToday,
    required this.affectedAreaKm2,
    required this.activeAlerts,
    required this.biomeBreakdown,
    required this.weeklyFoci,
  });
}
