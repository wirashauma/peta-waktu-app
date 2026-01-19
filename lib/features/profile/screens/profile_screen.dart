import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';
import 'package:peta_waktu/features/profile/services/cloudinary_service.dart';
import 'package:peta_waktu/features/profile/services/profile_service.dart';
import 'package:peta_waktu/main.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  String? _localPhotoUrl;
  late TextEditingController _namaController;
  late TextEditingController _nisnController;
  late TextEditingController _usernameController;

  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _nisnController = TextEditingController(text: widget.user.nisn);
    _usernameController = TextEditingController(text: widget.user.username);
    _localPhotoUrl =
        widget.user.photoUrl.isNotEmpty ? widget.user.photoUrl : null;
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 60);
      if (picked == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      final File file = File(picked.path);
      final uploadedUrl = await _cloudinaryService.uploadProfilePicture(file);

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          _localPhotoUrl = uploadedUrl;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Foto berhasil diunggah. Klik Simpan untuk menerapkan.'),
                backgroundColor: Colors.green),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Gagal mengunggah gambar.'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.isEmpty || _usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama dan Username wajib diisi!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.user.role == 'user' && _nisnController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('NISN wajib diisi untuk siswa!'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> dataToUpdate = {
        'nama': _namaController.text,
        'username': _usernameController.text,
      };

      if (widget.user.role == 'user') {
        dataToUpdate['nisn'] = _nisnController.text;
      }

      if (_localPhotoUrl != null && _localPhotoUrl!.isNotEmpty) {
        dataToUpdate['photoUrl'] = _localPhotoUrl!;
      }

      await _profileService.updateUserData(widget.user.uid, dataToUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menyimpan data: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nisnController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isStudent = widget.user.role == 'user';

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildProfilePicture(),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: TextEditingController(text: widget.user.email),
                    label: 'Email (Tidak dapat diubah)',
                    icon: Icons.email_outlined,
                    isReadOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Nama Pengguna',
                    icon: Icons.alternate_email,
                  ),
                  if (isStudent) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nisnController,
                      label: 'NISN',
                      icon: Icons.badge_outlined,
                      inputType: TextInputType.number,
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildSaveButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              const Text(
                "Edit Profil",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _localPhotoUrl != null
                  ? Image.network(
                      _localPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/profile_icon.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/profile_icon.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (_isUploadingImage)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(color: _tealGradientStart),
              ),
            ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Material(
              color: _tealGradientStart,
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isUploadingImage ? null : _pickAndUploadImage,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isReadOnly = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: isReadOnly,
      keyboardType: inputType,
      style: TextStyle(
        color: isReadOnly ? Colors.grey.shade600 : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: isReadOnly ? Colors.grey : _tealGradientStart),
        filled: true,
        fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _tealGradientStart, width: 2),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: _tealGradientStart,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}