import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Future<void> addFavoriteCity(String city) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('favorites').add({
      'city': city,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getFavoriteCities() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(user.uid).collection('favorites').snapshots();
  }

  Future<void> deleteFavoriteCity(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('favorites').doc(docId).delete();
  }
}