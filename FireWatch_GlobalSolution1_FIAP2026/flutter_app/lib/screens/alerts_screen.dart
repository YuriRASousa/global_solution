import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fire_alert.dart';
import '../providers/fire_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FireProvider>(context);
    final alerts = provider.alerts;
    final activeAlerts = alerts.where((a) => a.status == AlertStatus.active).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alertas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '$activeAlerts alertas ativos',
                        style: const TextStyle(
                          color: Color(0xFF8899AA), fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: provider.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)))
                      : const Icon(Icons.refresh, color: Color(0xFF8899AA)),
                    onPressed: provider.fetchAllData,
                  ),
                ],
              ),
            ),
            if (provider.isLoading && alerts.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFFFF6B35)),
                ),
              )
            else if (alerts.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Nenhum alerta no momento', style: TextStyle(color: Color(0xFF8899AA))),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _AlertTile(alert: alerts[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final FireAlert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isResolved = alert.status == AlertStatus.resolved;
    final borderColor = isResolved
        ? const Color(0xFF448844)
        : alert.severity.color;

    return Container(
      decoration: BoxDecoration(
        color: isResolved
            ? const Color(0xFF1A2535)
            : alert.severity.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isResolved
                        ? Icons.check_circle_outline
                        : alert.severity.icon,
                    color: isResolved
                        ? const Color(0xFF66CC66)
                        : alert.severity.color,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isResolved ? 'RESOLVIDO' : alert.severity.label,
                    style: TextStyle(
                      color: isResolved
                          ? const Color(0xFF66CC66)
                          : alert.severity.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                alert.formattedTime,
                style: const TextStyle(
                    color: Color(0xFF8899AA), fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            alert.title,
            style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            alert.description,
            style: const TextStyle(
                color: Color(0xFFAABBDD), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Color(0xFF8899AA), size: 11),
              const SizedBox(width: 2),
              Text(
                alert.location,
                style: const TextStyle(
                    color: Color(0xFF8899AA), fontSize: 10),
              ),
              if (alert.distanceKm != null) ...[
                const Text(' · ',
                    style: TextStyle(color: Color(0xFF8899AA))),
                Text(
                  '${alert.distanceKm!.toStringAsFixed(0)}km de você',
                  style: const TextStyle(
                      color: Color(0xFF8899AA), fontSize: 10),
                ),
              ],
            ],
          ),
          if (alert.status == AlertStatus.active) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionButton(
                  label: 'Ver no mapa',
                  color: alert.severity.color,
                  onTap: () {
                    context.read<FireProvider>().setTabIndex(0);
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Reportar',
                  color: const Color(0xFF1A2535),
                  textColor: const Color(0xFF8899AA),
                  onTap: () {
                    context.read<FireProvider>().prepareReport(
                      type: 'Queimada',
                      description: 'Alerta confirmado: ${alert.title}. Local: ${alert.location}',
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
