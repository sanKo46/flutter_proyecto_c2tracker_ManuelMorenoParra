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

  // FILTROS
  String _selectedResult = 'Todos';
  String _sortOrder = 'Más recientes';

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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
      appBar: AppBar(
        title: const Text('CS2 Match Tracker'),
        actions: [
          // FILTRO RESULTADO
          DropdownButton<String>(
            value: _selectedResult,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Todos', child: Text('Todos')),
              DropdownMenuItem(value: 'Victoria', child: Text('Victorias')),
              DropdownMenuItem(value: 'Derrota', child: Text('Derrotas')),
            ],
            onChanged: (v) => setState(() => _selectedResult = v!),
          ),

          // ORDENACIÓN
          DropdownButton<String>(
            value: _sortOrder,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'Más recientes', child: Text('Más recientes')),
              DropdownMenuItem(value: 'Más antiguas', child: Text('Más antiguas')),
              DropdownMenuItem(value: 'Más kills', child: Text('Más kills')),
              DropdownMenuItem(value: 'Menos kills', child: Text('Menos kills')),
            ],
            onChanged: (v) => setState(() => _sortOrder = v!),
          ),
        ],
      ),
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

          // Convertimos los datos
          List<QueryDocumentSnapshot> matches = snapshot.data!.docs;

          // APLICAR FILTRO
          if (_selectedResult != 'Todos') {
            matches = matches.where((doc) {
              final score = (doc['score'] ?? '').toString();
              return score == _selectedResult;
            }).toList();
          }

          // APLICAR ORDENACIÓN
          matches.sort((a, b) {
            final aKills = a['kills'] ?? 0;
            final bKills = b['kills'] ?? 0;

            switch (_sortOrder) {
              case 'Más recientes':
                return b['createdAt'].compareTo(a['createdAt']);
              case 'Más antiguas':
                return a['createdAt'].compareTo(b['createdAt']);
              case 'Más kills':
                return bKills.compareTo(aKills);
              case 'Menos kills':
                return aKills.compareTo(bKills);
              default:
                return 0;
            }
          });

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
                    'Score: ${match['score']} | '
                    'Kills: ${match['kills']} | '
                    'Deaths: ${match['deaths']}',
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.orangeAccent),
                    onSelected: (value) {
                      if (value == 'edit') _editMatch(doc.id, match);
                      if (value == 'delete') _deleteMatch(doc.id);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
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
