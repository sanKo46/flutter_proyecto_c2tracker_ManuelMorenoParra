import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerUser(String email, String password, String username) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('usuarios').doc(cred.user!.uid).set({
        'email': email,
        'username': username,
        'role': 'usuario',
        'imageURL': '',
      });
    } on FirebaseAuthException catch (e) {
      throw Exception('Error registrando usuario: [${e.code}] ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al registrar: $e');
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception('Error iniciando sesión: [${e.code}] ${e.message}');
    } catch (e) {
      throw Exception('Error desconocido al iniciar sesión: $e');
    }
  }

  Future<void> logoutUser() async => await _auth.signOut();
}
