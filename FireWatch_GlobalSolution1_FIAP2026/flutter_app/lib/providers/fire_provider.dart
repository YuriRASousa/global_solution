import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/fire_focus.dart';
import '../models/fire_alert.dart';
import '../services/firewatch_service.dart';

class FireProvider with ChangeNotifier {
  final FireWatchService _service = FireWatchService();
  
  List<FireFocus> _foci = [];
  List<FireAlert> _alerts = [];
  DashboardStats? _stats;
  AirQualityData? _airQuality;
  bool _isLoading = false;
  Position? _userPosition;
  String _selectedFilter = 'Todos';
  DateTime? _lastSync;

  int _currentTabIndex = 0;
  String? _prefilledReportType;
  String? _prefilledReportDescription;

  List<FireFocus> get foci => _foci;
  List<FireAlert> get alerts => _alerts;
  DashboardStats? get stats => _stats;
  AirQualityData? get airQuality => _airQuality;
  bool get isLoading => _isLoading;
  Position? get userPosition => _userPosition;
  String get selectedFilter => _selectedFilter;
  DateTime? get lastSync => _lastSync;
  int get currentTabIndex => _currentTabIndex;
  String? get prefilledReportType => _prefilledReportType;
  String? get prefilledReportDescription => _prefilledReportDescription;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void prepareReport({String? type, String? description}) {
    _prefilledReportType = type;
    _prefilledReportDescription = description;
    _currentTabIndex = 3; // Index da aba de Report
    notifyListeners();
  }

  void clearPrefilledReport() {
    _prefilledReportType = null;
    _prefilledReportDescription = null;
  }

  List<FireFocus> get filteredFoci {
    if (_selectedFilter == 'Todos') return _foci;
    return _foci.where((f) => f.riskLevel.label == _selectedFilter).toList();
  }

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    notifyListeners();
    debugPrint(' [FireWatch] Conectando aos satélites NASA FIRMS...');

    try {
      // 1. Localização
      await _determinePosition();
      
      // 2. Buscar focos reais da NASA
      _foci = await _service.fetchActiveFoci();
      debugPrint(' [FireWatch] ${_foci.length} focos detectados em território brasileiro.');

      // 3. Processar dados derivados
      final results = await Future.wait<dynamic>([
        _service.calculateStats(_foci),
        _service.generateAlerts(_foci),
        (_userPosition != null)
            ? _service.fetchAirQuality(
                lat: _userPosition!.latitude,
                lon: _userPosition!.longitude,
              )
            : Future.value(null),
      ]);

      _stats = results[0] as DashboardStats;
      _alerts = results[1] as List<FireAlert>;
      _airQuality = results[2] as AirQualityData?;
      _lastSync = DateTime.now();

    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFoci() async => fetchAllData();

  Future<bool> submitReport({
    required String type,
    required String description,
    String? imagePath,
  }) async {
    if (_userPosition == null) return false;
    
    return await _service.submitFireReport(
      type: type,
      description: description,
      lat: _userPosition!.latitude,
      lon: _userPosition!.longitude,
      imagePath: imagePath,
    );
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      _userPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Erro ao obter posição: $e');
    }
  }
}
