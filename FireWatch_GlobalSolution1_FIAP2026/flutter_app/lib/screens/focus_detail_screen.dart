import 'package:flutter/material.dart';
import '../models/fire_focus.dart';

class FocusDetailScreen extends StatelessWidget {
  final FireFocus focus;

  const FocusDetailScreen({super.key, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foco #${focus.id}'),
        backgroundColor: const Color(0xFF1A2535),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Detalhes do Foco em ${focus.state}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Bioma: ${focus.biome}'),
            Text('Temperatura: ${focus.temperature}°C'),
          ],
        ),
      ),
    );
  }
}
