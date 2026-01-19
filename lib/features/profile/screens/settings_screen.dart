import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';
import 'package:peta_waktu/main.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'history_quiz_screen.dart';
import 'faq_screen.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);
const Color _menuIconBg = Color(0xFFE0F2F1);

class SettingsScreen extends StatefulWidget {
  final UserModel user;

  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  Future<void> _handleRefresh() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && mounted) {
        setState(() {
          _currentUser =
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        });
      }
    } catch (e) {
      debugPrint("Gagal merefresh data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isStudent = _currentUser.role == 'user';

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: _tealGradientStart,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildSectionTitle("UMUM"),
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: "Edit Profil",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: _currentUser),
                        ),
                      );
                      _handleRefresh();
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.lock_outline_rounded,
                    title: "Ganti Kata Sandi",
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ChangePasswordScreen(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isStudent) ...[
                    _buildSectionTitle("AKTIVITAS"),
                    _buildMenuItem(
                      context,
                      icon: Icons.history_edu_rounded,
                      title: "Riwayat Kuis",
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryQuizScreen())),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionTitle("DUKUNGAN"),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    title: "Bantuan & FAQ",
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FaqScreen())),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildLogoutButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tealGradientStart, _tealGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Pengaturan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUser.nama.isNotEmpty
                              ? _currentUser.nama
                              : 'Pengguna',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentUser.email.isNotEmpty
                              ? _currentUser.email
                              : 'Tidak ada Email',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            _currentUser.role.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _currentUser.photoUrl.isNotEmpty
                            ? NetworkImage(_currentUser.photoUrl)
                            : const AssetImage(
                                    'assets/images/profile_icon.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: _menuIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _tealGradientStart, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade100),
          ),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Konfirmasi Keluar"),
              content:
                  const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child:
                      const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text("Ya, Keluar",
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        child: const Text("Keluar",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}