import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fire_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FireProvider>(context);
    final stats = provider.stats;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: provider.isLoading && stats == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : RefreshIndicator(
                onRefresh: provider.fetchAllData,
                color: const Color(0xFFFF6B35),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(provider),
                      const SizedBox(height: 16),
                      if (stats != null) ...[
                        _buildKpiRow(stats),
                        const SizedBox(height: 12),
                        _buildWeeklyChart(stats),
                        const SizedBox(height: 12),
                        _buildAirQuality(provider),
                        const SizedBox(height: 12),
                        _buildBiomeBreakdown(stats),
                        const SizedBox(height: 12),
                        _buildSatelliteInfo(stats),
                      ] else
                        const Center(child: Text("Sem dados estatísticos", style: TextStyle(color: Colors.white))),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(FireProvider provider) {
    final syncTime = provider.lastSync != null 
        ? "${provider.lastSync!.hour.toString().padLeft(2, '0')}:${provider.lastSync!.minute.toString().padLeft(2, '0')}"
        : "--:--";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFFF4444), width: 0.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFFFF4444), size: 6),
                      SizedBox(width: 4),
                      Text('LIVE', style: TextStyle(color: Color(0xFFFF4444), fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const Text('Monitoramento Estratégico · Brasil',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('ÚLTIMA ATUALIZAÇÃO', 
              style: TextStyle(color: Color(0xFFFF6B35), fontSize: 8, fontWeight: FontWeight.w800)),
            Text(syncTime, 
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow(dynamic stats) {
    return Row(
      children: [
        _KpiCard(label: 'Focos (Hoje)', value: '${stats.totalFociToday}', color: const Color(0xFFFF6B35)),
        const SizedBox(width: 8),
        _KpiCard(label: 'Área Estimada', value: '${stats.affectedAreaKm2.toStringAsFixed(1)}km²', color: const Color(0xFFFFAA00)),
        const SizedBox(width: 8),
        _KpiCard(label: 'Riscos Críticos', value: '${stats.activeAlerts}', color: const Color(0xFFFF4444)),
      ],
    );
  }

  Widget _buildWeeklyChart(dynamic stats) {
    final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final List<int> weeklyFoci = stats.weeklyFoci;
    final maxVal = weeklyFoci.reduce((a, b) => a > b ? a : b).toDouble();

    return _Card(
      title: 'Focos por dia (semana)',
      child: Container(
        height: 110,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(weeklyFoci.length, (i) {
            final val = weeklyFoci[i];
            final double heightPercent = maxVal > 0 ? (val / maxVal) : 0.0;
            final isToday = i == weeklyFoci.length - 1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$val',
                        style: TextStyle(
                            fontSize: 8,
                            color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF8899AA))),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 2, maxHeight: 80),
                        height: 80 * heightPercent,
                        decoration: BoxDecoration(
                          color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF334455),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(days[i % 7],
                        style: const TextStyle(fontSize: 9, color: Color(0xFF8899AA))),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAirQuality(FireProvider provider) {
    final aqi = provider.airQuality;
    final label = aqi?.aqiLabel ?? 'Moderado';
    final value = aqi?.aqi ?? 2;
    // Map value to approximate 0-300 scale for UI
    final displayValue = value * 40 + 20; 

    return _Card(
      title: 'Qualidade do Ar (IQAr)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 12, fontWeight: FontWeight.w600)),
              Text('IQAr: $displayValue', style: const TextStyle(color: Color(0xFFFFCC00), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: displayValue / 300,
              minHeight: 10,
              backgroundColor: const Color(0xFF111E2D),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AqiLabel('Bom', Color(0xFF44CC44)),
              _AqiLabel('Moderado', Color(0xFFFFCC00)),
              _AqiLabel('Ruim', Color(0xFFFF8800)),
              _AqiLabel('Perigoso', Color(0xFFFF3333)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AqiMetric('PM2.5', '${aqi?.pm25 ?? 18.4} μg/m³'),
              _AqiMetric('PM10', '${aqi?.pm10 ?? 32.1} μg/m³'),
              _AqiMetric('CO', '${aqi?.co ?? 0.8} mg/m³'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiomeBreakdown(dynamic stats) {
    final Map<String, int> breakdown = stats.biomeBreakdown;
    return _Card(
      title: 'Focos por bioma',
      child: Column(
        children: breakdown.entries.map((e) {
          final pct = e.value / 100;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 90,
                    child: Text(e.key,
                        style: const TextStyle(
                            color: Color(0xFFAABBDD), fontSize: 11))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 7,
                      backgroundColor: const Color(0xFF111E2D),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6600)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${e.value}%',
                    style: const TextStyle(
                        color: Color(0xFF8899AA), fontSize: 11)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSatelliteInfo(dynamic stats) {
    final List<String> satellites = stats.activeSatellites;
    final Map<String, int> counts = stats.breakdownBySatellite;
    final lastScan = stats.lastDataPoint;
    final scanLabel = lastScan != null 
        ? "Última captura: ${lastScan.hour.toString().padLeft(2, '0')}:${lastScan.minute.toString().padLeft(2, '0')} UTC"
        : "Aguardando varredura...";
    
    return Column(
      children: [
        _Card(
          title: 'Centro de Comando Orbital',
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.satellite_alt, color: Color(0xFFFF6B35), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats.currentSatLocation.toUpperCase(), 
                          style: const TextStyle(color: Color(0xFF44CC66), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const Text('Posição Estimada em Tempo Real', 
                          style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334455)),
                ),
                child: Column(
                  children: [
                    _TelemetryLine('CON: NASA-GSFC LINK', 'ESTABLISHED'),
                    _TelemetryLine('DOWNLINK STATUS', 'SYNCHRONIZED'),
                    _TelemetryLine('NEXT SCAN WINDOW', stats.nextPassEstimation),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          title: 'Dados da Carga Útil (VIIRS/MODIS)',
          child: Column(
            children: [
              Text(scanLabel, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (satellites.isEmpty)
                const Text("Analisando ruído térmico... Nenhuma anomalia crítica.", style: TextStyle(color: Color(0xFF8899AA), fontSize: 11))
              else
                ...satellites.map((sat) => _SatRow(
                  sat, 
                  '${counts[sat] ?? 0} focos térmicos validados', 
                  'Ativo',
                  const Color(0xFF44CC66)
                )).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TelemetryLine extends StatelessWidget {
  final String label;
  final String status;
  const _TelemetryLine(this.label, this.status);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('> $label', style: const TextStyle(color: Color(0xFF44CC66), fontSize: 9, fontFamily: 'monospace')),
          Text(status, style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares do Dashboard
// ---------------------------------------------------------------------------

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _KpiCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 9)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2535),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

class _AqiLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _AqiLabel(this.label, this.color);

  @override
  Widget build(BuildContext context) =>
      Text(label, style: TextStyle(color: color, fontSize: 9));
}

class _AqiMetric extends StatelessWidget {
  final String label;
  final String value;
  const _AqiMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 9)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      );
}

class _SatRow extends StatelessWidget {
  final String name;
  final String sensor;
  final String status;
  final Color statusColor;
  const _SatRow(this.name, this.sensor, this.status, this.statusColor);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            const Icon(Icons.satellite_alt, color: Color(0xFF6699FF), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(sensor, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
