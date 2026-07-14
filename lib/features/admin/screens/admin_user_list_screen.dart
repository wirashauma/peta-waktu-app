import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';
import 'package:peta_waktu/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_edit_user_screen.dart' hide scaffoldColor;

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'All';
  String _searchQuery = '';

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String nama) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Pengguna?'),
            content: Text(
                'Apakah Anda yakin ingin menghapus "$nama"?\nData tidak dapat dikembalikan.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteUser(
      BuildContext context, String docId, String nama) async {
    bool confirm = await _showDeleteConfirmationDialog(context, nama);

    if (confirm) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Profil $nama dihapus dari Firestore. Catatan: Hapus dari Firebase Console Auth untuk memblokir akses login sepenuhnya.'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal menghapus user: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _goToEditUser(BuildContext context, UserModel user) {
    if (user.uid == FirebaseAuth.instance.currentUser?.uid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Anda tidak bisa mengedit akun sendiri dari sini.'),
          backgroundColor: Colors.orange));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditUserScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAdminUid = FirebaseAuth.instance.currentUser?.uid;

    // Batasi & filter query di server untuk efisiensi biaya/performa read Firestore
    Query query = FirebaseFirestore.instance.collection('users');
    if (_selectedRoleFilter != 'All') {
      query = query.where('role', isEqualTo: _selectedRoleFilter);
    }
    query = query.limit(50); // limit 50 untuk mencegah pemuatan massal data

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _tealGradientStart));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var allDocs = snapshot.data!.docs;
                var filteredDocs = allDocs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['nama'] ?? '').toString().toLowerCase();
                  String email = (data['email'] ?? '').toString().toLowerCase();
                  String role = (data['role'] ?? 'user').toString();

                  bool matchesSearch = name.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                  bool matchesRole = _selectedRoleFilter == 'All' ||
                      role.toLowerCase() == _selectedRoleFilter.toLowerCase();

                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState(message: "User tidak ditemukan");
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 20),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    UserModel user = UserModel.fromFirestore(doc);
                    return _buildUserCard(user, currentAdminUid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tealGradientStart, _tealGradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manajemen Pengguna",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: "Cari nama atau email...",
              prefixIcon: const Icon(Icons.search, color: _tealGradientStart),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("Semua", "All"),
                const SizedBox(width: 8),
                _buildFilterChip("Siswa", "user"),
                const SizedBox(width: 8),
                _buildFilterChip("Guru", "guru"),
                const SizedBox(width: 8),
                _buildFilterChip("Admin", "admin"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String roleValue) {
    bool isSelected = _selectedRoleFilter == roleValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRoleFilter = roleValue;
        });
      },
      selectedColor: Colors.white,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? _tealGradientStart : Colors.grey[700],
        fontWeight: FontWeight.bold,
      ),
      checkmarkColor: _tealGradientStart,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildUserCard(UserModel user, String? currentAdminUid) {
    bool isMe = user.uid == currentAdminUid;
    String displayName = user.nama.isNotEmpty ? user.nama : user.username;

    Color roleColor;
    IconData roleIcon;
    if (user.role == 'admin') {
      roleColor = Colors.red;
      roleIcon = Icons.admin_panel_settings;
    } else if (user.role == 'guru') {
      roleColor = Colors.orange;
      roleIcon = Icons.school;
    } else {
      roleColor = _tealGradientStart;
      roleIcon = Icons.person;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isMe ? Border.all(color: _tealGradientStart, width: 1.5) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.1),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: roleColor),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "ANDA",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
        trailing: isMe
            ? const Icon(Icons.lock, color: Colors.grey)
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _goToEditUser(context, user);
                  } else if (value == 'delete') {
                    _deleteUser(context, user.uid, displayName);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text("Edit User"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text("Hapus User"),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState({String message = "Belum ada data user."}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }
}