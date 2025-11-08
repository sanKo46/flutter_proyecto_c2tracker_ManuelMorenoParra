import 'package:flutter/material.dart';
import '../services/match_service.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final MatchService _matchService = MatchService();
  final TextEditingController _mapController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _killsController = TextEditingController();
  final TextEditingController _deathsController = TextEditingController();

  Future<void> _saveMatch() async {
    await _matchService.addMatch({
      'map': _mapController.text,
      'score': _scoreController.text,
      'kills': int.tryParse(_killsController.text) ?? 0,
      'deaths': int.tryParse(_deathsController.text) ?? 0,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar partida')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _mapController, decoration: const InputDecoration(labelText: 'Mapa')),
            TextField(controller: _scoreController, decoration: const InputDecoration(labelText: 'Marcador')),
            TextField(controller: _killsController, decoration: const InputDecoration(labelText: 'Kills'), keyboardType: TextInputType.number),
            TextField(controller: _deathsController, decoration: const InputDecoration(labelText: 'Deaths'), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMatch,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.black),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
