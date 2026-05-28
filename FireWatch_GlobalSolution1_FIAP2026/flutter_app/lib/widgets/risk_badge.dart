import 'package:flutter/material.dart';
import '../models/fire_focus.dart';

class RiskBadge extends StatelessWidget {
  final String label;
  final FireRisk riskLevel;

  const RiskBadge({super.key, required this.label, required this.riskLevel});

  Color get _color {
    switch (riskLevel) {
      case FireRisk.low: return const Color(0xFF44CC66);
      case FireRisk.medium: return const Color(0xFFFFCC00);
      case FireRisk.high: return const Color(0xFFFF8800);
      case FireRisk.critical: return const Color(0xFFFF3333);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _color.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: _color, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
}
