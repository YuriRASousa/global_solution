import 'package:flutter/material.dart';
import '../models/fire_focus.dart';
import '../services/firewatch_service.dart';
import '../widgets/risk_badge.dart';
import '../widgets/focus_card.dart';
import 'focus_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = FireWatchService();
  List<FireFocus> _foci = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final foci = await _service.fetchActiveFoci();
    if (mounted) {
      setState(() {
        _foci = foci;
        _isLoading = false;
      });
    }
  }

  List<FireFocus> get _filteredFoci {
    if (_selectedFilter == 'Todos') return _foci;
    return _foci.where((f) => f.riskLevel.label == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildMapPlaceholder(),
            _buildStatsRow(),
            _buildFilterRow(),
            Expanded(child: _buildFociList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: const Color(0xFFFF6B35),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHeader() {
    final criticalCount = _foci.where((f) => f.riskLevel == FireRisk.critical).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FIREWATCH',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Brasil · Monitoramento em tempo real',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 11),
              ),
            ],
          ),
          if (criticalCount > 0)
            RiskBadge(
              label: '$criticalCount CRÍTICO${criticalCount > 1 ? 'S' : ''}',
              riskLevel: FireRisk.critical,
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    // Em produção: substituir por flutter_map com tiles OpenStreetMap
    // e markers dinâmicos dos focos via LatLng
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF162016),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A4A2A)),
      ),
      child: Stack(
        children: [
          // Grade simulando tiles de mapa
          CustomPaint(
            painter: _MapGridPainter(),
            size: const Size(double.infinity, 200),
          ),
          // Focos de calor
          ..._foci.take(4).toList().asMap().entries.map((entry) {
            final positions = [
              const Offset(0.4, 0.3),
              const Offset(0.65, 0.55),
              const Offset(0.2, 0.65),
              const Offset(0.82, 0.2),
            ];
            final pos = positions[entry.key % positions.length];
            return Positioned(
              left: pos.dx * 300,
              top: pos.dy * 200,
              child: _HeatSpot(risk: entry.value.riskLevel),
            );
          }),
          // Overlay info
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Color(0xFFFF6B35), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${_foci.length} focos ativos',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Sat: VIIRS · MODIS',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final highRisk = _foci
        .where((f) =>
            f.riskLevel == FireRisk.high || f.riskLevel == FireRisk.critical)
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Focos hoje',
            value: '${_foci.length}',
            color: const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Alto risco',
            value: '$highRisk',
            color: const Color(0xFFFF4444),
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Satélites',
            value: '3',
            color: const Color(0xFF6699FF),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final filters = ['Todos', 'CRÍTICO', 'ALTO', 'MÉDIO', 'BAIXO'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = _selectedFilter == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filters[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF1A2535),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8899AA),
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFociList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      );
    }
    if (_filteredFoci.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum foco encontrado',
          style: TextStyle(color: Color(0xFF8899AA)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFoci.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final focus = _filteredFoci[index];
        return FocusCard(
          focus: focus,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FocusDetailScreen(focus: focus),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares da HomeScreen
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2535),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF8899AA), fontSize: 10)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _HeatSpot extends StatelessWidget {
  final FireRisk risk;
  const _HeatSpot({required this.risk});

  Color get color {
    switch (risk) {
      case FireRisk.critical: return const Color(0xFFFF3300);
      case FireRisk.high: return const Color(0xFFFF6600);
      case FireRisk.medium: return const Color(0xFFFFAA00);
      case FireRisk.low: return const Color(0xFFFFCC44);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A4A2A)
      ..strokeWidth = 0.5;

    for (var x = 0.0; x < size.width; x += size.width / 3) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += size.height / 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
