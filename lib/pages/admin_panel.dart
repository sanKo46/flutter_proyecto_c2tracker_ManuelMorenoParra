import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Pantalla del Panel de Administración.
/// Permite gestionar usuarios (roles, baneos, edición, eliminación)
/// y partidas registradas en la base de datos.
class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Índice del menú inferior para alternar entre Usuarios y Partidas.
  int _selectedIndex = 0;


  /// Elimina por completo un usuario de la colección.
  Future<void> _deleteUser(String id) async {
    await _firestore.collection('usuarios').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Usuario eliminado")),
    );
  }

  /// Cambia el rol de un usuario: entre admin y user.
  Future<void> _toggleRole(String id, String currentRole) async {
    final newRole = currentRole == "admin" ? "user" : "admin";

    await _firestore.collection('usuarios').doc(id).update({
      "role": newRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nuevo rol: $newRole")),
    );
  }

  /// Banea o desbanea a un usuario.
  Future<void> _toggleBan(String id, bool banned) async {
    await _firestore.collection('usuarios').doc(id).update({
      "banned": !banned,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(banned ? "Usuario desbaneado" : "Usuario baneado")),
    );
  }

  /// Ventana emergente para editar usuario (username, email, rol, baneo).
  void _editUserPopup(String id, Map<String, dynamic> user) {
    final nameCtrl = TextEditingController(text: user["username"]);
    final emailCtrl = TextEditingController(text: user["email"]);

    String role = user["role"];
    bool banned = user["banned"] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Editar Usuario", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),

              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              DropdownButton<String>(
                dropdownColor: Colors.grey[900],
                value: role,
                items: const [
                  DropdownMenuItem(value: "user", child: Text("Usuario")),
                  DropdownMenuItem(value: "admin", child: Text("Administrador")),
                ],
                onChanged: (v) => setState(() => role = v!),
              ),

              SwitchListTile(
                title: const Text("Baneado", style: TextStyle(color: Colors.white)),
                value: banned,
                onChanged: (v) => setState(() => banned = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              child: const Text("Guardar"),
              onPressed: () async {
                await _firestore.collection("usuarios").doc(id).update({
                  "username": nameCtrl.text,
                  "email": emailCtrl.text,
                  "role": role,
                  "banned": banned,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Usuario actualizado")),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Muestra la lista de usuarios con opciones de administración.
  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("usuarios").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No hay usuarios"));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final id = users[index].id;

            final isAdmin = user["role"] == "admin";
            final banned = user["banned"] ?? false;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(isAdmin ? Icons.star : Icons.person, color: Colors.black),
                ),

                title: Text(user["username"], style: const TextStyle(color: Colors.white)),

                subtitle: Text(
                  "Email: ${user['email']}\nRol: ${user['role']}\nBaneado: ${banned ? 'Sí' : 'No'}",
                  style: const TextStyle(color: Colors.white70),
                ),

                trailing: Wrap(
                  spacing: 12,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editUserPopup(id, user),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.admin_panel_settings,
                        color: isAdmin ? Colors.green : Colors.orangeAccent,
                      ),
                      onPressed: () => _toggleRole(id, user["role"]),
                    ),

                    IconButton(
                      icon: Icon(
                        banned ? Icons.lock_open : Icons.lock,
                        color: banned ? Colors.greenAccent : Colors.redAccent,
                      ),
                      onPressed: () => _toggleBan(id, banned),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(id),
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

  /// Muestra la lista de partidas registradas.
  Widget _buildMatchesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection("matches").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final matches = snapshot.data!.docs;

        if (matches.isEmpty) {
          return const Center(child: Text("No hay partidas"));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index].data() as Map<String, dynamic>;
            final id = matches[index].id;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.sports_esports, color: Colors.orangeAccent),

                title: Text(
                  "${match['map']} | ${match['score']}",
                  style: const TextStyle(color: Colors.white),
                ),

                subtitle: Text(
                  "Kills: ${match['kills']}  Deaths: ${match['deaths']}",
                  style: const TextStyle(color: Colors.white70),
                ),

                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    _firestore.collection("matches").doc(id).delete();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Construcción principal de la pantalla del Panel Admin.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Panel de Administración"),
        backgroundColor: Colors.orangeAccent,
      ),

      /// Muestra usuarios o partidas según el índice seleccionado.
      body: _selectedIndex == 0 ? _buildUsersList() : _buildMatchesList(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Usuarios"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: "Partidas"),
        ],
      ),
    );
  }
}
