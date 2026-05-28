import 'package:flutter/material.dart';
import '../models/fire_focus.dart';
import 'risk_badge.dart';

// ---------------------------------------------------------------------------
// FocusCard
// ---------------------------------------------------------------------------

class FocusCard extends StatelessWidget {
  final FireFocus focus;
  final VoidCallback? onTap;

  const FocusCard({super.key, required this.focus, this.onTap});

  Color get _riskColor {
    switch (focus.riskLevel) {
      case FireRisk.low: return const Color(0xFF44CC66);
      case FireRisk.medium: return const Color(0xFFFFCC00);
      case FireRisk.high: return const Color(0xFFFF8800);
      case FireRisk.critical: return const Color(0xFFFF3333);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2535),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: _riskColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _riskColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.local_fire_department,
                  color: _riskColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Foco #${focus.id}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      RiskBadge(
                          label: focus.riskLevel.label,
                          riskLevel: focus.riskLevel),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${focus.biome} · ${focus.state}',
                    style: const TextStyle(
                        color: Color(0xFF8899AA), fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Tag('${focus.temperature.toStringAsFixed(0)}°C',
                          const Color(0xFFFF6B35)),
                      const SizedBox(width: 6),
                      _Tag('${focus.areaHectares.toStringAsFixed(1)} ha',
                          const Color(0xFFFFAA00)),
                      const SizedBox(width: 6),
                      _Tag(focus.satellite.split(' ').first,
                          const Color(0xFF6699FF)),
                      const Spacer(),
                      Text(
                        focus.formattedTime,
                        style: const TextStyle(
                            color: Color(0xFF8899AA), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF8899AA)),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
      );
}
