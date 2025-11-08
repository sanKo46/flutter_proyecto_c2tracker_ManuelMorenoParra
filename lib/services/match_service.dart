import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addMatch(Map<String, dynamic> data) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await _db.collection('usuarios').doc(uid).collection('partidas').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMatches() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('partidas')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
