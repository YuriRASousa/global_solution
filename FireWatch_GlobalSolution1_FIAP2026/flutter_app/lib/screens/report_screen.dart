import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/fire_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descController = TextEditingController();
  String _selectedType = 'Queimada';
  bool _submitted = false;
  bool _isSending = false;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = [
    'Queimada',
    'Fumaça suspeita',
    'Desmatamento',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FireProvider>(context, listen: false);
      if (provider.prefilledReportType != null) {
        setState(() {
          _selectedType = provider.prefilledReportType!;
        });
      }
      if (provider.prefilledReportDescription != null) {
        setState(() {
          _descController.text = provider.prefilledReportDescription!;
        });
      }
      provider.clearPrefilledReport();
    });
  }

  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(source: ImageSource.camera);
    if (selected != null) {
      setState(() => _image = selected);
    }
  }

  Future<void> _submit(FireProvider provider) async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, descreva a ocorrência.')),
      );
      return;
    }

    setState(() => _isSending = true);

    final success = await provider.submitReport(
      type: _selectedType,
      description: _descController.text,
      imagePath: _image?.path,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        if (success) _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FireProvider>(context);
    
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
                'Sua contribuição ajuda a salvar biomas.',
                style: TextStyle(color: Color(0xFF8899AA), fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (_submitted) _buildSuccessMessage() else _buildForm(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(FireProvider provider) {
    final userPos = provider.userPosition;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Tipo de ocorrência'),
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
        const _Label('Sua Localização'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF334455)),
          ),
          child: Row(
            children: [
              Icon(Icons.my_location, 
                  color: userPos != null ? const Color(0xFF44CC66) : const Color(0xFF6699FF), 
                  size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(userPos != null ? 'Localização Capturada' : 'Buscando GPS...',
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(
                      userPos != null 
                        ? '${userPos.latitude.toStringAsFixed(4)}, ${userPos.longitude.toStringAsFixed(4)}'
                        : 'Ative o GPS para maior precisão',
                      style: const TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 10,
                          fontFamily: 'monospace')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _Label('Descrição dos fatos'),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Ex: Fogo avistado próximo à rodovia...',
            hintStyle: const TextStyle(color: Color(0xFF8899AA)),
            filled: true,
            fillColor: const Color(0xFF1A2535),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334455)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _Label('Evidência Visual'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2535),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334455)),
              image: _image != null 
                ? DecorationImage(image: FileImage(File(_image!.path)), fit: BoxFit.cover)
                : null,
            ),
            child: _image == null ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Color(0xFF8899AA), size: 32),
                  SizedBox(height: 4),
                  Text('Tirar Foto da Ocorrência',
                      style: TextStyle(color: Color(0xFF8899AA), fontSize: 11)),
                ],
              ),
            ) : null,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSending ? null : () => _submit(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSending 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('ENVIAR PARA BRIGADA', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2D1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF44CC66).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user, color: Color(0xFF44CC66), size: 60),
          const SizedBox(height: 16),
          const Text('Relatório Enviado!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Sua denúncia foi georreferenciada e enviada para a Defesa Civil e brigadas voluntárias mais próximas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFAABBDD), fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() {
                _submitted = false;
                _descController.clear();
                _image = null;
              });
            },
            child: const Text('REALIZAR NOVO REPORTE', style: TextStyle(color: Color(0xFFFF6B35))),
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
