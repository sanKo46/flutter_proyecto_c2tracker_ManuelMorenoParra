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

  // 🔥 ELIMINAR PARTIDA
  Future<void> _deleteMatch(String id) async {
    await _firestore.collection('matches').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partida eliminada ✅')),
    );
  }

  // 🔥 ELIMINAR USUARIO
  Future<void> _deleteUser(String id) async {
    await _firestore.collection('usuarios').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario eliminado ❌')),
    );
  }

  // 🔥 CAMBIAR ROL (admin/user)
  Future<void> _toggleRole(String id, String currentRole) async {
    final newRole = currentRole == "admin" ? "user" : "admin";

    await _firestore.collection("usuarios").doc(id).update({
      "role": newRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rol actualizado a: $newRole')),
    );
  }

  // 🔥 BANEAR / DESBANEAR USUARIO
  Future<void> _toggleBan(String id, bool banned) async {
    await _firestore.collection("usuarios").doc(id).update({
      "banned": !banned,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(banned ? 'Usuario desbaneado 🟢' : 'Usuario baneado 🔴'),
      ),
    );
  }

  // 🔥 LISTA DE PARTIDAS
  Widget _buildMatchesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('matches').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final matches = snapshot.data!.docs;
        if (matches.isEmpty) return const Center(child: Text('No hay partidas registradas.'));

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
                  'Score: ${match['score']}  |  '
                  'Kills: ${match['kills']}  |  '
                  'Deaths: ${match['deaths']}',
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

  // 🔥 LISTA DE USUARIOS
  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;
        if (users.isEmpty) return const Center(child: Text('No hay usuarios registrados.'));

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final isAdmin = user['role'] == 'admin';
            final banned = user['banned'] ?? false;

            return Card(
              color: isAdmin ? Colors.deepPurple[800] : Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(
                    isAdmin ? Icons.star : Icons.person,
                    color: Colors.black,
                  ),
                ),
                title: Text("${user['username']} ${isAdmin ? '(ADMIN)' : ''}"),
                subtitle: Text(
                  'Email: ${user['email']}\n'
                  'Rol: ${user['role']}\n'
                  'Baneado: ${banned ? "Sí 🔴" : "No 🟢"}',
                ),

                // 🔥 BOTONES DE ADMIN
                trailing: Wrap(
                  spacing: 10,
                  children: [
                    // Cambiar rol
                    IconButton(
                      icon: Icon(
                        Icons.admin_panel_settings,
                        color: isAdmin ? Colors.green : Colors.orangeAccent,
                      ),
                      onPressed: () =>
                          _toggleRole(users[index].id, user["role"]),
                    ),

                    // Banear/desbanear
                    IconButton(
                      icon: Icon(
                        banned ? Icons.lock_open : Icons.lock,
                        color: banned ? Colors.greenAccent : Colors.redAccent,
                      ),
                      onPressed: () =>
                          _toggleBan(users[index].id, banned),
                    ),

                    // Eliminar usuario
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _deleteUser(users[index].id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🔥 UI PRINCIPAL DEL PANEL
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
