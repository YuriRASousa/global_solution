import 'package:flutter/material.dart';

class FireAlert {
  final String id;
  final String title;
  final String description;
  final String location;
  final AlertSeverity severity;
  final AlertStatus status;
  final DateTime createdAt;
  final double? distanceKm;
  final String? fireFocusId;

  const FireAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.distanceKm,
    this.fireFocusId,
  });

  String get formattedTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}

enum AlertSeverity { info, medium, high, critical }

enum AlertStatus { active, resolved, acknowledged }

extension AlertSeverityExtension on AlertSeverity {
  String get label {
    switch (this) {
      case AlertSeverity.info: return 'INFORMATIVO';
      case AlertSeverity.medium: return 'MÉDIO';
      case AlertSeverity.high: return 'ALTO';
      case AlertSeverity.critical: return 'CRÍTICO';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.info: return const Color(0xFF3377FF);
      case AlertSeverity.medium: return const Color(0xFFFFCC00);
      case AlertSeverity.high: return const Color(0xFFFF8800);
      case AlertSeverity.critical: return const Color(0xFFFF3333);
    }
  }

  Color get bgColor {
    switch (this) {
      case AlertSeverity.info: return const Color(0xFF1A2535);
      case AlertSeverity.medium: return const Color(0xFF2D2A10);
      case AlertSeverity.high: return const Color(0xFF2D2410);
      case AlertSeverity.critical: return const Color(0xFF2D1A1A);
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.info: return Icons.info_outline;
      case AlertSeverity.medium: return Icons.warning_amber_outlined;
      case AlertSeverity.high: return Icons.warning_outlined;
      case AlertSeverity.critical: return Icons.local_fire_department;
    }
  }
}
