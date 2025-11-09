import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/admin_page.dart'; // <--- Importamos el panel admin

class AppDrawer extends StatelessWidget {
  final AuthService _authService = AuthService();

  AppDrawer({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: FutureBuilder<Map<String, dynamic>?>( // <--- Esperamos datos del usuario
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {};
          final username = userData['username'] ?? 'Usuario';
          final imageURL = userData['imageURL'] ?? '';
          final role = userData['role'] ?? 'user'; // <--- Leemos el rol

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage:
                      imageURL.isNotEmpty ? NetworkImage(imageURL) : null,
                  child: imageURL.isEmpty
                      ? const Icon(Icons.add_a_photo,
                          color: Colors.orangeAccent, size: 30)
                      : null,
                ),
                accountName: Text(
                  username,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                accountEmail: Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),

              // 🏠 Inicio
              ListTile(
                leading: const Icon(Icons.home, color: Colors.orangeAccent),
                title: const Text('Inicio'),
                onTap: () => Navigator.pushReplacementNamed(context, '/home'),
              ),

              // ➕ Agregar Partida
              ListTile(
                leading: const Icon(Icons.add_circle_outline,
                    color: Colors.orangeAccent),
                title: const Text('Agregar Partida'),
                onTap: () => Navigator.pushReplacementNamed(context, '/add'),
              ),

              // 📊 Estadísticas
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.orangeAccent),
                title: const Text('Estadísticas'),
                onTap: () => Navigator.pushReplacementNamed(context, '/stats'),
              ),

              // 🧠 Si es ADMIN -> Mostrar Panel de Administración
              if (role == 'admin') ...[
                const Divider(color: Colors.orangeAccent),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings,
                      color: Colors.orangeAccent),
                  title: const Text('Panel de Administración'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPanel(),
                      ),
                    );
                  },
                ),
              ],

              const Divider(color: Colors.orangeAccent),

              // 🚪 Cerrar sesión
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await _authService.logoutUser();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
