import 'package:flutter/material.dart';
import '../services/match_service.dart';

class AddMatchPage extends StatefulWidget {
  const AddMatchPage({super.key});

  @override
  State<AddMatchPage> createState() => _AddMatchPageState();
}

class _AddMatchPageState extends State<AddMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = TextEditingController();
  final _killsController = TextEditingController();
  final _deathsController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await MatchService().addMatch({
      'map': _mapController.text,
      'kills': int.parse(_killsController.text),
      'deaths': int.parse(_deathsController.text),
      'score': _scoreController.text,
    });

    setState(() => _isSubmitting = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Partida')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mapController,
                decoration: const InputDecoration(labelText: 'Mapa'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _killsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kills'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _deathsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Deaths'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _scoreController,
                decoration:
                    const InputDecoration(labelText: 'Resultado (ej: 16-10)'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Guardar partida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
