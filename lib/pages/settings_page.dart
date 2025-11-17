import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  String username = "";
  String email = "";
  String avatar = "assets/avatars/avatar1.jpg";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _firestore.collection("usuarios").doc(uid).get();

    final data = doc.data()!;

    setState(() {
      username = data["username"];
      email = data["email"];
      avatar = data["avatar"] ?? "assets/avatars/avatar1.jpg";
      _phoneController.text = data["phone"] ?? "";
      loading = false;
    });
  }

  Future<void> _savePhone() async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("usuarios").doc(uid).update({
      "phone": _phoneController.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Número de teléfono actualizado")),
    );
  }

  Future<void> _sendContactMessage() async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("contact_messages").add({
      "userId": uid,
      "email": email,
      "message": _contactController.text,
      "date": DateTime.now(),
    });

    _contactController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mensaje enviado correctamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage(avatar),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    username,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // 📱 PHONE TEXTFIELD
                  TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Número de teléfono",
                      labelStyle: const TextStyle(color: Colors.orangeAccent),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orangeAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton(
                    onPressed: _savePhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Guardar número"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔶 CONTACT SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reportes y Contacto",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _contactController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Escribe tu mensaje...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orangeAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: _sendContactMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Enviar mensaje"),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
