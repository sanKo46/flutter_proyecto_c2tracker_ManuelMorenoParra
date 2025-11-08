import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/match_service.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final matchService = MatchService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Partidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: matchService.getUserMatches(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final matches = snapshot.data!.docs;
          if (matches.isEmpty) {
            return const Center(child: Text('Aún no hay partidas registradas.'));
          }

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index].data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(match['map'] ?? 'Desconocido'),
                  subtitle: Text(
                      'Kills: ${match['kills']} - Deaths: ${match['deaths']}'),
                  trailing: Text(match['score'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
