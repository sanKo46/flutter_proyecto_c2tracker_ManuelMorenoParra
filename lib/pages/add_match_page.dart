import 'package:flutter/material.dart';
import '../services/match_service.dart';
import '../widgets/app_drawer.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final MatchService _matchService = MatchService();

  // Controladores
  final TextEditingController _killsController = TextEditingController();
  final TextEditingController _deathsController = TextEditingController();

  // Campos de selección
  String? _selectedMap;
  String? _selectedMode;
  String? _selectedScore;

  // Listas de opciones
  final List<String> _maps = [
    'Mirage',
    'Inferno',
    'Nuke',
    'Dust2',
    'Overpass',
    'Vertigo',
    'Ancient',
    'Anubis'
  ];

  final List<String> _modes = [
    'Competitivo',
    'Casual',
    'Deathmatch',
    'Wingman'
  ];

  final List<String> _scores = [
    'Victoria',
    'Derrota'
  ];

  Future<void> _saveMatch() async {
    // Validación simple
    if (_selectedMap == null || _selectedMode == null || _selectedScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    await _matchService.addMatch({
      'map': _selectedMap,
      'mode': _selectedMode,
      'score': _selectedScore,
      'kills': int.tryParse(_killsController.text) ?? 0,
      'deaths': int.tryParse(_deathsController.text) ?? 0,
    });

    if (mounted) {
      Navigator.pop(context); // 👈 Regresa sin dejar pantalla en blanco
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida guardada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar partida')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMap,
              decoration: const InputDecoration(labelText: 'Mapa'),
              items: _maps.map((map) {
                return DropdownMenuItem(value: map, child: Text(map));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMap = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedMode,
              decoration: const InputDecoration(labelText: 'Modalidad'),
              items: _modes.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMode = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedScore,
              decoration: const InputDecoration(labelText: 'Marcador'),
              items: _scores.map((score) {
                return DropdownMenuItem(value: score, child: Text(score));
              }).toList(),
              onChanged: (value) => setState(() => _selectedScore = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _killsController,
              decoration: const InputDecoration(labelText: 'Kills'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _deathsController,
              decoration: const InputDecoration(labelText: 'Deaths'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 173, 65),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
