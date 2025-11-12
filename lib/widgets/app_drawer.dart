import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // 🔹 Cambiamos las rutas a .jpg
  final List<String> _avatarOptions = [
    'assets/avatars/avatar1.jpg',
    'assets/avatars/avatar2.jpg',
    'assets/avatars/avatar3.jpg',
  ];

  String _selectedAvatar = 'assets/avatars/avatar1.jpg';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Usuario'),
            accountEmail: const Text('correo@ejemplo.com'),
            currentAccountPicture: GestureDetector(
              onTap: _showAvatarSelector,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(_selectedAvatar),
                onBackgroundImageError: (_, __) {}, // Evita error si falta imagen
                child: Image.asset(
                  _selectedAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // 🔹 Selector de avatar con GridView limitado en tamaño
  void _showAvatarSelector() async {
    final selectedAvatar = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar avatar'),
          content: SizedBox(
            height: 220, // Evita error de "no size"
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _avatarOptions.length,
              itemBuilder: (context, index) {
                final avatar = _avatarOptions[index];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, avatar),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(avatar),
                    onBackgroundImageError: (_, __) {}, // Evita error visual
                    child: Image.asset(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedAvatar != null && mounted) {
      setState(() {
        _selectedAvatar = selectedAvatar;
      });
    }
  }
}
