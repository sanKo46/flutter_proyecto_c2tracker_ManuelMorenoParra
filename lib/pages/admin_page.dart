import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0; // 0 = Partidas, 1 = Usuarios

  Future<void> _deleteMatch(String id) async {
    await _firestore.collection('matches').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partida eliminada ✅')),
    );
  }

  Future<void> _deleteUser(String id) async {
    await _firestore.collection('usuarios').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado ✅')),
    );
  }

  Widget _buildMatchesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('matches').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matches = snapshot.data!.docs;

        if (matches.isEmpty) {
          return const Center(child: Text('No hay partidas registradas.'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index].data() as Map<String, dynamic>;
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteMatch(matches[index].id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('No hay usuarios registrados.'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.orangeAccent),
                title: Text(user['username'] ?? 'Sin nombre'),
                subtitle: Text(
                  'Email: ${user['email'] ?? 'N/A'}\nRol: ${user['role'] ?? 'user'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteUser(users[index].id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: _selectedIndex == 0 ? _buildMatchesList() : _buildUsersList(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Partidas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}
