import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTRO DE USUARIO
  Future<User?> registerUser(String email, String password, String username) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'username': username,
          'email': email,
          'role': 'user',
          'imageURL': '',
        });
      }
      return user;
    } catch (e) {
      print('Error al registrar: $e');
      return null;
    }
  }

  // LOGIN DE USUARIO
  Future<User?> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // CERRAR SESIÓN
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
