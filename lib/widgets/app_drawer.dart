import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/settings_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String username = "";
  String email = "";
  String avatar = "assets/avatars/avatar1.jpg";
  String role = "user"; // DEFAULT
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc =
        await _firestore.collection("usuarios").doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        username = data["username"];
        email = data["email"];
        avatar = data["imageURL"] == "" 
            ? "assets/avatars/avatar1.jpg"
            : data["imageURL"];        
        role = data["role"] ?? "user"; // CARGA EL ROL
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
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

                // HOME
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text("Inicio",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/home");
                  },
                ),

                // ADD MATCH
                ListTile(
                  leading:
                      const Icon(Icons.add_circle, color: Colors.white),
                  title: const Text("Agregar Partida",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/add");
                  },
                ),

                // STATS
                ListTile(
                  leading:
                      const Icon(Icons.bar_chart, color: Colors.white),
                  title: const Text("Estadísticas",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/stats");
                  },
                ),

                // SOLO SI ES ADMIN
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

                // SETTINGS
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text("Configuración",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsPage()));
                  },
                ),

                const Divider(color: Colors.white30),

                // LOGOUT
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
