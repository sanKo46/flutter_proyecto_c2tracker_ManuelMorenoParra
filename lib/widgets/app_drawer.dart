import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/auth_service.dart';
import '../pages/admin_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();

    setState(() {
      _userData = doc.data() ?? {};
      _loading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      // Subir la imagen
      await storageRef.putFile(file);

      // Obtener URL de descarga
      final downloadUrl = await storageRef.getDownloadURL();

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({'imageURL': downloadUrl});

      // Actualizar la interfaz
      setState(() {
        _userData?['imageURL'] = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada correctamente')),
        );
      }
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir la imagen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Drawer(
        backgroundColor: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final username = _userData?['username'] ?? 'Usuario';
    final imageURL = _userData?['imageURL'] ?? '';
    final role = _userData?['role'] ?? 'user';

    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
            ),
            currentAccountPicture: GestureDetector(
              onTap: _pickAndUploadImage, // 👉 al pulsar, abrir galería
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

          // 🏠 Inicio
          ListTile(
            leading: const Icon(Icons.home, color: Colors.orangeAccent),
            title: const Text('Inicio'),
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),

          // ➕ Agregar Partida
          ListTile(
            leading:
                const Icon(Icons.add_circle_outline, color: Colors.orangeAccent),
            title: const Text('Agregar Partida'),
            onTap: () => Navigator.pushReplacementNamed(context, '/add'),
          ),

          // 📊 Estadísticas
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.orangeAccent),
            title: const Text('Estadísticas'),
            onTap: () => Navigator.pushReplacementNamed(context, '/stats'),
          ),

          if (role == 'admin') ...[
            const Divider(color: Colors.orangeAccent),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings,
                  color: Colors.orangeAccent),
              title: const Text('Panel de Administración'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanel()),
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
      ),
    );
  }
}
