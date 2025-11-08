import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Añadir partida
  Future<void> addMatch(Map<String, dynamic> data) async {
    await _db.collection('matches').add({
      ...data,
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtener partidas del usuario
  Stream<QuerySnapshot> getUserMatches() {
    return _db
        .collection('matches')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
