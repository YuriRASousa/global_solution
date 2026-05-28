class FireFocus {
  final String id;
  final double latitude;
  final double longitude;
  final double temperature;
  final double areaHectares;
  final String satellite;
  final String biome;
  final String state;
  final DateTime detectedAt;
  final FireRisk riskLevel;
  final bool isActive;

  const FireFocus({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.areaHectares,
    required this.satellite,
    required this.biome,
    required this.state,
    required this.detectedAt,
    required this.riskLevel,
    this.isActive = true,
  });

  factory FireFocus.fromJson(Map<String, dynamic> json) {
    return FireFocus(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      areaHectares: (json['area_ha'] as num).toDouble(),
      satellite: json['satellite'] as String,
      biome: json['biome'] as String,
      state: json['state'] as String,
      detectedAt: DateTime.parse(json['detected_at'] as String),
      riskLevel: FireRisk.values.firstWhere(
        (e) => e.name == json['risk_level'],
        orElse: () => FireRisk.medium,
      ),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'temperature': temperature,
        'area_ha': areaHectares,
        'satellite': satellite,
        'biome': biome,
        'state': state,
        'detected_at': detectedAt.toIso8601String(),
        'risk_level': riskLevel.name,
        'is_active': isActive,
      };

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(4)}° ${latitude >= 0 ? 'N' : 'S'}, '
      '${longitude.toStringAsFixed(4)}° ${longitude >= 0 ? 'E' : 'W'}';

  String get formattedTime {
    final diff = DateTime.now().difference(detectedAt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}

enum FireRisk { low, medium, high, critical }

extension FireRiskExtension on FireRisk {
  String get label {
    switch (this) {
      case FireRisk.low: return 'BAIXO';
      case FireRisk.medium: return 'MÉDIO';
      case FireRisk.high: return 'ALTO';
      case FireRisk.critical: return 'CRÍTICO';
    }
  }
}
