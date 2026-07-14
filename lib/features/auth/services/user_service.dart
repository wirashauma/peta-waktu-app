// LOKASI: lib/features/auth/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> fetchCurrentUser() async {
    try {
      if (AuthService.mockUser != null) {
        _currentUser = AuthService.mockUser;
        return _currentUser;
      }
      User? user = _auth.currentUser;
      
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          _currentUser = UserModel.fromFirestore(doc);
          return _currentUser;
        } else {
          // --- PERBAIKAN DI SINI ---
          // HAPUS atau KOMENTARI baris logout ini.
          // Jangan logout otomatis, karena mungkin data sedang proses dibuat (Race Condition).
          
          // await _auth.signOut(); // <--- INI PENYEBABNYA, HAPUS BARIS INI
          
          print("Data user belum tersedia di Firestore (Mungkin akun baru).");
          return null; 
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}