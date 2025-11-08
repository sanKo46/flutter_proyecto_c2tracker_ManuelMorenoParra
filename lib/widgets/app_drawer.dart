import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

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
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data ?? {};
          final username = userData['username'] ?? 'Usuario';
          final imageURL = userData['imageURL'] ?? '';

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                ),
                currentAccountPicture: GestureDetector(
                  onTap: () {
                    // si no hay imagen, opción para añadir una
                    if (imageURL.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidad para subir foto próximamente 📸',
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage:
                        imageURL.isNotEmpty ? NetworkImage(imageURL) : null,
                    child: imageURL.isEmpty
                        ? const Icon(Icons.add_a_photo,
                            color: Colors.orangeAccent, size: 30)
                        : null,
                  ),
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
              ListTile(
                leading: const Icon(Icons.home, color: Colors.orangeAccent),
                title: const Text('Inicio'),
                onTap: () => Navigator.pushReplacementNamed(context, '/home'),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline,
                    color: Colors.orangeAccent),
                title: const Text('Agregar Partida'),
                onTap: () => Navigator.pushReplacementNamed(context, '/add'),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.orangeAccent),
                title: const Text('Estadísticas'),
                onTap: () => Navigator.pushReplacementNamed(context, '/stats'),
              ),
              const Divider(color: Colors.orangeAccent),
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
