import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static UserModel? mockUser;
  static final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  static Stream<UserModel?> get authStateChanges => _authStateController.stream;

  static void initialize() {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        if (mockUser == null) {
          _authStateController.add(null);
        }
      } else {
        if (mockUser != null && mockUser!.uid == firebaseUser.uid) {
          _authStateController.add(mockUser);
        } else {
          try {
            final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
            if (doc.exists) {
              final user = UserModel.fromFirestore(doc);
              mockUser = user;
              _authStateController.add(user);
            } else {
              _authStateController.add(null);
            }
          } catch (_) {
            _authStateController.add(null);
          }
        }
      }
    });
  }

  static void setMockUser(UserModel? user) {
    mockUser = user;
    _authStateController.add(user);
  }

  // ---------------------------------------------------------------------------
  // 1. SIGN UP EMAIL/PASSWORD (EXISTING)
  // ---------------------------------------------------------------------------
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String nisn,
    String? nama,
    String? username,
    String role = 'user',
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || nisn.isEmpty) {
        throw Exception("Semua kolom harus diisi");
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Simpan data lengkap ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nisn': nisn,
        'nama': nama ?? '',
        'username': username ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email sudah terdaftar.');
      } else if (e.code == 'weak-password') {
        throw Exception('Kata sandi terlalu lemah.');
      } else {
        throw Exception(e.message ?? 'Terjadi kesalahan saat pendaftaran.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 2. SIGN IN EMAIL/PASSWORD (EXISTING)
  // ---------------------------------------------------------------------------
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception("Email dan password harus diisi");
      }
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Email atau password salah');
      } else if (e.code == 'user-not-found') {
        throw Exception('Pengguna tidak ditemukan');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception(e.message ?? 'Terjadi kesalahan saat masuk');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // 3. RESET PASSWORD (EXISTING)
  // ---------------------------------------------------------------------------
  Future<void> resetPassword({required String email}) async {
    try {
      if (email.isEmpty) {
        throw Exception("Silakan isi email terlebih dahulu.");
      }
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email salah.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('Gagal mengirim email reset: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 4. GOOGLE LOGIN (NEW)
  // ---------------------------------------------------------------------------
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger flow autentikasi
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw Exception('Login Google dibatalkan.');
      }

      // Dapatkan detail auth
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Buat kredensial baru
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in ke Firebase
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // CEK & BUAT DATA DI FIRESTORE JIKA BELUM ADA
      await _createSocialUserInFirestore(userCredential.user);

      return userCredential;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER: BUAT DATA USER SOSIAL (PENTING!)
  // ---------------------------------------------------------------------------
  Future<void> _createSocialUserInFirestore(User? user) async {
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    // Jika dokumen user belum ada (Login Pertama kali), buatkan defaultnya
    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'nama': user.displayName ?? 'Pengguna Baru',
        'username': user.email!.split('@')[0], // Username diambil dari email
        'nisn': '-', // Default strip karena social login tidak punya NISN
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'photoURL': user.photoURL ?? '', // Simpan foto profil Google/FB
      });
    }
  }
}