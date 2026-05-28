import 'package:flutter/material.dart';
import '../services/firewatch_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = FireWatchService();
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final stats = await _service.fetchDashboardStats();
    if (mounted) setState(() { _stats = stats; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildKpiRow(),
                    const SizedBox(height: 12),
                    _buildWeeklyChart(),
                    const SizedBox(height: 12),
                    _buildAirQuality(),
                    const SizedBox(height: 12),
                    _buildBiomeBreakdown(),
                    const SizedBox(height: 12),
                    _buildSatelliteInfo(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        Text('Maio 2026 · Brasil',
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        _KpiCard(label: 'Focos hoje', value: '${_stats!.totalFociToday}', color: const Color(0xFFFF6B35)),
        const SizedBox(width: 8),
        _KpiCard(label: 'Área afetada', value: '${_stats!.affectedAreaKm2}km²', color: const Color(0xFFFFAA00)),
        const SizedBox(width: 8),
        _KpiCard(label: 'Alertas', value: '${_stats!.activeAlerts}', color: const Color(0xFFFF4444)),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    final days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final maxVal = _stats!.weeklyFoci.reduce((a, b) => a > b ? a : b).toDouble();

    return _Card(
      title: 'Focos por dia (semana)',
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_stats!.weeklyFoci.length, (i) {
            final val = _stats!.weeklyFoci[i];
            final height = (val / maxVal) * 80;
            final isToday = i == _stats!.weeklyFoci.length - 1;
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
                    Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF334455),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(days[i],
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

  Widget _buildAirQuality() {
    const iqar = 68;
    const pct = iqar / 300;
    return _Card(
      title: 'Qualidade do Ar (IQAr)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Moderado', style: TextStyle(color: Color(0xFFFFCC00), fontSize: 12, fontWeight: FontWeight.w600)),
              Text('IQAr: 68', style: TextStyle(color: Color(0xFFFFCC00), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: const Color(0xFF111E2D),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AqiLabel('Bom', const Color(0xFF44CC44)),
              _AqiLabel('Moderado', const Color(0xFFFFCC00)),
              _AqiLabel('Ruim', const Color(0xFFFF8800)),
              _AqiLabel('Perigoso', const Color(0xFFFF3333)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AqiMetric('PM2.5', '18.4 μg/m³'),
              _AqiMetric('PM10', '32.1 μg/m³'),
              _AqiMetric('CO', '0.8 mg/m³'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBiomeBreakdown() {
    return _Card(
      title: 'Focos por bioma',
      child: Column(
        children: _stats!.biomeBreakdown.entries.map((e) {
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

  Widget _buildSatelliteInfo() {
    return _Card(
      title: 'Satélites Ativos',
      child: Column(
        children: [
          _SatRow('NOAA-20', 'VIIRS 375m', 'Ativo', const Color(0xFF44CC66)),
          _SatRow('Terra', 'MODIS 1km', 'Ativo', const Color(0xFF44CC66)),
          _SatRow('Aqua', 'MODIS 1km', 'Ativo', const Color(0xFF44CC66)),
          _SatRow('Sentinel-2', 'MSI 10m', 'Passagem em 2h', const Color(0xFFFFAA00)),
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
