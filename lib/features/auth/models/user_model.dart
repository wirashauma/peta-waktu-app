import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nisn;
  final String role;
  final String nama;
  final String photoUrl;
  final String username;

  UserModel({
    required this.uid,
    required this.email,
    required this.nisn,
    required this.role,
    required this.nama,
    required this.photoUrl,
    required this.username,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    String dbUsername = data['username'] ?? '';
    if (dbUsername.isEmpty) {
      dbUsername = (data['nama'] ?? '').isNotEmpty
          ? (data['nama'] ?? '').toString().toLowerCase().replaceAll(' ', '')
          : 'user-${uid.substring(0, 4)}';
    }

    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      nisn: data['nisn'] ?? '',
      role: data['role'] ?? 'user',
      nama: data['nama'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      username: dbUsername,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    return UserModel.fromMap(
      doc.data() as Map<String, dynamic>? ?? {}, 
      doc.id
    );
  }

  UserModel copyWith({
    String? nama,
    String? nisn,
    String? photoUrl,
    String? username,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      role: role,
      nama: nama ?? this.nama,
      nisn: nisn ?? this.nisn,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
    );
  }
}