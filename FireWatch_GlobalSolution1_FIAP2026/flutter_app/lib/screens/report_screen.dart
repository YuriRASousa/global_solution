import 'package:flutter/material.dart';
import '../models/fire_focus.dart';

// =============================================================================
// FocusDetailScreen
// =============================================================================

class FocusDetailScreen extends StatelessWidget {
  final FireFocus focus;
  const FocusDetailScreen({super.key, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1923),
        title: Text('Foco #${focus.id}',
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF8899AA)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSatelliteImagePlaceholder(),
            const SizedBox(height: 12),
            _buildInfoGrid(),
            const SizedBox(height: 12),
            _buildCoordinates(),
            const SizedBox(height: 12),
            _buildTrendChart(),
            const SizedBox(height: 16),
            _buildReportButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSatelliteImagePlaceholder() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF162016),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A4A2A)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.satellite_alt, size: 60, color: Color(0xFF2A4A2A)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4400).withOpacity(0.5),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFFF00),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Imagem ${focus.satellite}',
                style: const TextStyle(color: Color(0xFF88AA88), fontSize: 11),
              ),
              const Text(
                'Fonte: NASA FIRMS',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 9),
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
      childAspectRatio: 2.8,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _InfoTile('Temperatura', '${focus.temperature.toStringAsFixed(0)}°C',
            const Color(0xFFFF6B35)),
        _InfoTile('Área estimada',
            '${focus.areaHectares.toStringAsFixed(1)} ha',
            const Color(0xFFFFAA00)),
        _InfoTile('Satélite', focus.satellite.split(' ').first,
            const Color(0xFF6699FF)),
        _InfoTile('Bioma', focus.biome, const Color(0xFF66CC88)),
        _InfoTile('Estado', focus.state, Colors.white),
        _InfoTile('Risco', focus.riskLevel.label, focus.riskLevel.color),
      ],
    );
  }

  Widget _buildCoordinates() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF6699FF), size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coordenadas',
                  style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
              Text(
                focus.formattedCoordinates,
                style: const TextStyle(
                  color: Color(0xFFAABBDD),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tendência de intensidade (6h)',
              style: TextStyle(color: Color(0xFF8899AA), fontSize: 10)),
          const SizedBox(height: 8),
          CustomPaint(
            painter: _TrendChartPainter(),
            size: const Size(double.infinity, 50),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relatório enviado à Defesa Civil'),
              backgroundColor: Color(0xFF44CC66),
            ),
          );
        },
        icon: const Icon(Icons.send),
        label: const Text('REPORTAR À DEFESA CIVIL'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoTile(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2535),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF8899AA), fontSize: 9)),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [0.8, 0.75, 0.82, 0.6, 0.55, 0.4, 0.3];
    final paint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = points[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..color = const Color(0xFFFF6B35).withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on FireRisk {
  Color get color {
    switch (this) {
      case FireRisk.low: return const Color(0xFF44CC66);
      case FireRisk.medium: return const Color(0xFFFFCC00);
      case FireRisk.high: return const Color(0xFFFF8800);
      case FireRisk.critical: return const Color(0xFFFF3333);
    }
  }
}

// =============================================================================
// ReportScreen
// =============================================================================

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descController = TextEditingController();
  String _selectedType = 'Queimada';
  bool _submitted = false;

  final List<String> _types = [
    'Queimada',
    'Fumaça suspeita',
    'Desmatamento',
    'Outro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reportar ocorrência',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const Text(
                'Contribua com o monitoramento colaborativo',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (_submitted) _buildSuccessMessage() else _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Tipo de ocorrência'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _types.map((t) {
            final sel = _selectedType == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = t),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFFF6B35) : const Color(0xFF1A2535),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel ? const Color(0xFFFF6B35) : const Color(0xFF334455),
                  ),
                ),
                child: Text(t,
                    style: TextStyle(
                        color: sel ? Colors.white : const Color(0xFF8899AA),
                        fontSize: 12)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _Label('Localização'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334455)),
          ),
          child: Row(
            children: const [
              Icon(Icons.my_location, color: Color(0xFF6699FF), size: 16),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Usar localização atual',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Text('-23.5505°, -46.6333°',
                      style: TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Label('Descrição'),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Descreva o que está vendo...',
            hintStyle: const TextStyle(color: Color(0xFF8899AA)),
            filled: true,
            fillColor: const Color(0xFF1A2535),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334455)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334455)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Label('Foto (opcional)'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {},
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2535),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF334455), style: BorderStyle.solid),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Color(0xFF8899AA), size: 28),
                  Text('Toque para adicionar foto',
                      style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _submitted = true),
            icon: const Icon(Icons.send),
            label: const Text('ENVIAR RELATÓRIO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF44CC66).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF44CC66), size: 48),
          const SizedBox(height: 12),
          const Text('Relatório enviado!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'Obrigado! Seu relatório foi enviado à equipe de monitoramento '
            'e à Defesa Civil local.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() => _submitted = false),
            child: const Text('Enviar outro relatório',
                style: TextStyle(color: Color(0xFFFF6B35))),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: Color(0xFFAABBDD),
          fontSize: 12,
          fontWeight: FontWeight.w600));
}
