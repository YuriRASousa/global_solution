import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/fire_focus.dart';

class FocusDetailScreen extends StatelessWidget {
  final FireFocus focus;
  const FocusDetailScreen({super.key, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        elevation: 0,
        title: Text('Foco #${focus.id}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMiniMap(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 16),
            _buildCoordinatesCard(),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A4A2A)),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(focus.latitude, focus.longitude),
          initialZoom: 10,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
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
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(focus.latitude, focus.longitude),
                child: const Icon(Icons.local_fire_department, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _DetailTile('Temperatura', '${focus.temperature.toStringAsFixed(1)}°C', const Color(0xFFFF6B35)),
        _DetailTile('Risco', focus.riskLevel.label, _getRiskColor(focus.riskLevel)),
        _DetailTile('Bioma', focus.biome, const Color(0xFF66CC88)),
        _DetailTile('Satélite', focus.satellite, const Color(0xFF6699FF)),
      ],
    );
  }

  Widget _buildCoordinatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Localização', style: TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
              Text(focus.formattedCoordinates, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(focus.state, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alerta enviado para autoridades locais')),
              );
            },
            icon: const Icon(Icons.warning_amber_rounded),
            label: const Text('NOTIFICAR AUTORIDADES'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(FireRisk risk) {
    switch (risk) {
      case FireRisk.critical: return Colors.red;
      case FireRisk.high: return Colors.orange;
      case FireRisk.medium: return Colors.yellow;
      case FireRisk.low: return Colors.green;
    }
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DetailTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
