import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addMatch(Map<String, dynamic> data) async {
    final uid = _auth.currentUser!.uid;
    await _db
        .collection('usuarios')
        .doc(uid)
        .collection('partidas')
        .add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserMatches() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('usuarios')
        .doc(uid)
        .collection('partidas')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
