import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/fire_focus.dart';
import '../providers/fire_provider.dart';
import '../services/firewatch_service.dart';
import '../widgets/risk_badge.dart';
import '../widgets/focus_card.dart';
import 'focus_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  LatLng _calculateSatPosition(FireProvider provider) {
    if (provider.stats != null) {
      return LatLng(provider.stats!.satLat, provider.stats!.satLon);
    }
    final pos = FireWatchService.getEstimatedSatPosition(DateTime.now());
    return LatLng(pos['lat']!, pos['lon']!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FireProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(provider),
            _buildMap(provider, context),
            _buildStatsRow(provider),
            _buildFilterRow(provider),
            Expanded(child: _buildFociList(provider)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.fetchFoci,
        backgroundColor: const Color(0xFFFF6B35),
        child: provider.isLoading 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildHeader(FireProvider provider) {
    final criticalCount = provider.foci.where((f) => f.riskLevel == FireRisk.critical).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIREWATCH',
                style: TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
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

  Widget _buildMap(FireProvider provider, BuildContext context) {
    // Se o usuário estiver fora do Brasil (ex: Los Angeles no emulador), 
    // centralizamos em Brasília para ver os dados reais do país.
    final bool isUserInBrazil = provider.userPosition != null && 
                                provider.userPosition!.latitude < 5.0 && 
                                provider.userPosition!.latitude > -34.0 &&
                                provider.userPosition!.longitude > -74.0 &&
                                provider.userPosition!.longitude < -34.0;

    final center = isUserInBrazil
        ? LatLng(provider.userPosition!.latitude, provider.userPosition!.longitude)
        : const LatLng(-15.7801, -47.9292); // Brasília

    return Stack(
      children: [
        Container(
          height: 250,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A4A2A)),
          ),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.fiap.firewatch',
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      0, 0, 0, 1, 0,
                    ]),
                    child: tileWidget,
                  );
                },
              ),
              if (provider.foci.isEmpty && !provider.isLoading)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: center,
                      radius: 500000,
                      useRadiusInMeter: true,
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.05),
                      borderColor: const Color(0xFFFF6B35).withValues(alpha: 0.2),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (provider.userPosition != null)
                    Marker(
                      point: LatLng(provider.userPosition!.latitude, provider.userPosition!.longitude),
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
                    ),
                  
                  // SATÉLITE EM ÓRBITA (SINCRONIZADO)
                  Marker(
                    point: _calculateSatPosition(provider),
                    width: 60,
                    height: 60,
                    child: _OrbitalSatellite(),
                  ),

                  ...provider.filteredFoci.map((f) => Marker(
                    point: LatLng(f.latitude, f.longitude),
                    width: 25,
                    height: 25,
                    child: GestureDetector(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FocusDetailScreen(focus: f),
                          ),
                        );
                      },
                      child: _HeatSpot(risk: f.riskLevel),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          left: 32,
          child: _SyncStatus(
            isLoading: provider.isLoading,
            lastSync: provider.lastSync,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(FireProvider provider) {
    final highRisk = provider.foci
        .where((f) =>
            f.riskLevel == FireRisk.high || f.riskLevel == FireRisk.critical)
        .length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Focos hoje',
            value: '${provider.foci.length}',
            color: const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 8),
          _StatCard(
            label: 'Alto risco',
            value: '$highRisk',
            color: const Color(0xFFFF4444),
          ),
          const SizedBox(width: 8),
          const _StatCard(
            label: 'Satélites',
            value: 'VIIRS/MODIS',
            color: Color(0xFF6699FF),
            isSmall: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(FireProvider provider) {
    final filters = ['Todos', 'CRÍTICO', 'ALTO', 'MÉDIO', 'BAIXO'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = provider.selectedFilter == filters[i];
          return GestureDetector(
            onTap: () => provider.setFilter(filters[i]),
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

  Widget _buildFociList(FireProvider provider) {
    if (provider.isLoading && provider.foci.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: const Color(0xFF1A2535),
          highlightColor: const Color(0xFF2A3545),
          child: Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    
    if (provider.filteredFoci.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum foco encontrado',
          style: TextStyle(color: Color(0xFF8899AA)),
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.filteredFoci.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final focus = provider.filteredFoci[index];
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
  final bool isSmall;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    this.isSmall = false,
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
                    fontSize: isSmall ? 14 : 20,
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
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color, blurRadius: 10, spreadRadius: 2)],
          ),
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  final bool isLoading;
  final DateTime? lastSync;
  const _SyncStatus({required this.isLoading, this.lastSync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1923).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334455), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF6B35)),
            )
          else
            const Icon(Icons.satellite_alt, color: Color(0xFF44CC66), size: 12),
          const SizedBox(width: 6),
          Text(
            isLoading ? "CONECTANDO NASA..." : "VIGILÂNCIA ATIVA",
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _OrbitalSatellite extends StatefulWidget {
  @override
  State<_OrbitalSatellite> createState() => _OrbitalSatelliteState();
}

class _OrbitalSatelliteState extends State<_OrbitalSatellite> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.0).animate(_controller),
          child: FadeTransition(
            opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6699FF), width: 1),
              ),
            ),
          ),
        ),
        const Icon(Icons.satellite_alt, color: Color(0xFF6699FF), size: 24),
      ],
    );
  }
}
