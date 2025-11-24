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

  // Controladores para kills y deaths
  final TextEditingController _killsController = TextEditingController();
  final TextEditingController _deathsController = TextEditingController();

  // Campos seleccionados por el usuario
  String? _selectedMap;
  String? _selectedMode;
  String? _selectedScore;

  // Listas desplegables
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

  // Guardar partida
  Future<void> _saveMatch() async {
    // Validación
    if (_selectedMap == null || _selectedMode == null || _selectedScore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    // Llamada al servicio
    await _matchService.addMatch({
      'map': _selectedMap,
      'mode': _selectedMode,
      'score': _selectedScore,
      'kills': int.tryParse(_killsController.text) ?? 0,
      'deaths': int.tryParse(_deathsController.text) ?? 0,
      'createdAt': DateTime.now(), // IMPORTANTE PARA ORDENAR
    });

    // Volver a Home
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partida guardada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar partida')),

      // Drawer lateral
      drawer: const AppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Selección de mapa
            DropdownButtonFormField<String>(
              value: _selectedMap,
              decoration: const InputDecoration(labelText: 'Mapa'),
              items: _maps.map((map) {
                return DropdownMenuItem(value: map, child: Text(map));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMap = value),
            ),

            const SizedBox(height: 12),

            // Selección de modo
            DropdownButtonFormField<String>(
              value: _selectedMode,
              decoration: const InputDecoration(labelText: 'Modalidad'),
              items: _modes.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMode = value),
            ),

            const SizedBox(height: 12),

            // Selección de resultado
            DropdownButtonFormField<String>(
              value: _selectedScore,
              decoration: const InputDecoration(labelText: 'Marcador'),
              items: _scores.map((score) {
                return DropdownMenuItem(value: score, child: Text(score));
              }).toList(),
              onChanged: (value) => setState(() => _selectedScore = value),
            ),

            const SizedBox(height: 12),

            // Kills
            TextField(
              controller: _killsController,
              decoration: const InputDecoration(labelText: 'Kills'),
              keyboardType: TextInputType.number,
            ),

            // Deaths
            TextField(
              controller: _deathsController,
              decoration: const InputDecoration(labelText: 'Deaths'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // Botón guardar
            ElevatedButton(
              onPressed: _saveMatch,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 173, 65),
                foregroundColor: Colors.black,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
