import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';

/// Menú lateral (Drawer) que muestra información del usuario,
/// navegación entre pantallas y acceso al panel admin si tiene rol "admin".
class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  /// Instancias de Firebase
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Datos del usuario cargados desde Firestore
  String username = "";
  String email = "";
  String avatar = "assets/avatars/avatar1.jpg";
  String role = "user";

  /// Indica si la información sigue cargando
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Obtiene la información del usuario desde Firestore.
  /// También evita errores si el documento no existe.
  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final doc = await _firestore.collection("usuarios").doc(user.uid).get();

    if (!doc.exists) {
      setState(() {
        username = "Usuario";
        email = user.email ?? "";
        loading = false;
      });
      return;
    }

    final data = doc.data()!;

    setState(() {
      username = data["username"] ?? "Usuario";
      email = data["email"] ?? user.email ?? "";
      avatar = (data["imageURL"] == null || data["imageURL"].isEmpty)
          ? "assets/avatars/avatar1.jpg"
          : data["imageURL"];
      role = data["role"] ?? "user";
      loading = false;
    });
  }

  /// Construcción visual del Drawer.
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,

      /// Pantalla de carga
      child: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )

          /// Lista principal del menú
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                /// Encabezado con información del usuario
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                  ),
                  accountName: Text(
                    username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  accountEmail: Text(
                    email,
                    style: const TextStyle(fontSize: 14),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: AssetImage(avatar),
                  ),
                ),

                /// Botón para ir a Home
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text("Inicio",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/home");
                  },
                ),

                /// Botón para agregar partidas
                ListTile(
                  leading: const Icon(Icons.add_circle, color: Colors.white),
                  title: const Text("Agregar Partida",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/add");
                  },
                ),

                /// Botón para estadísticas
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.white),
                  title: const Text("Estadísticas",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/stats");
                  },
                ),

                /// Opción solo visible si el usuario es administrador
                if (role == "admin") ...[
                  const Divider(color: Colors.white30),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: Colors.orangeAccent),
                    title: const Text("Panel Admin",
                        style: TextStyle(color: Colors.orangeAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/adminpanel");
                    },
                  ),
                ],

                const Divider(color: Colors.white30),

                /// Botón para ir a configuración
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text("Configuración",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),

                const Divider(color: Colors.white30),

                /// Botón para cerrar sesión
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("Cerrar sesión",
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, "/login", (_) => false);
                  },
                ),
              ],
            ),
    );
  }
}
