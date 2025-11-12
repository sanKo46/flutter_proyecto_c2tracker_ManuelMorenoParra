import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/match_service.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MatchService _matchService = MatchService();

  Future<void> _deleteMatch(String id) async {
    await FirebaseFirestore.instance.collection('matches').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partida eliminada')),
    );
  }

  Future<void> _editMatch(String id, Map<String, dynamic> match) async {
    final mapController = TextEditingController(text: match['map']);
    final scoreController = TextEditingController(text: match['score']);
    final killsController = TextEditingController(text: match['kills'].toString());
    final deathsController = TextEditingController(text: match['deaths'].toString());

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Partida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: mapController, decoration: const InputDecoration(labelText: 'Mapa')),
            TextField(controller: scoreController, decoration: const InputDecoration(labelText: 'Score')),
            TextField(controller: killsController, decoration: const InputDecoration(labelText: 'Kills')),
            TextField(controller: deathsController, decoration: const InputDecoration(labelText: 'Deaths')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('matches').doc(id).update({
                'map': mapController.text,
                'score': scoreController.text,
                'kills': int.tryParse(killsController.text) ?? 0,
                'deaths': int.tryParse(deathsController.text) ?? 0,
              });
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CS2 Match Tracker')),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _matchService.getMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay partidas registradas.'));
          }

          final matches = snapshot.data!.docs;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final doc = matches[index];
              final match = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.sports_esports, color: Colors.orangeAccent),
                  title: Text(match['map'] ?? 'Desconocido'),
                  subtitle: Text(
                    'Score: ${match['score'] ?? 'N/A'} | '
                    'Kills: ${match['kills'] ?? 0} | '
                    'Deaths: ${match['deaths'] ?? 0}',
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.orangeAccent),
                    onSelected: (value) {
                      if (value == 'edit') _editMatch(doc.id, match);
                      if (value == 'delete') _deleteMatch(doc.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
