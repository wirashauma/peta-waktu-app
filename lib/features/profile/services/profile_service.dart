import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengupdate data user di Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Kita gunakan 'merge: true' agar hanya field yang ada di 'data' yang diupdate
      // dan tidak menghapus field lain seperti 'email' atau 'role'.
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      print("Error updating user data: $e");
      rethrow; // Lempar error agar bisa ditangani di UI
    }
  }
}