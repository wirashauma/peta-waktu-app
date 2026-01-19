import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';
import 'package:peta_waktu/features/profile/services/profile_service.dart';
import 'package:peta_waktu/features/profile/services/cloudinary_service.dart';
import 'package:peta_waktu/main.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  bool _isUploadingImage = false;
  String? _localPhotoUrl;

  late TextEditingController _namaController;
  late TextEditingController _nisnController;
  late TextEditingController _usernameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.user.nama);
    _nisnController = TextEditingController(text: widget.user.nisn);
    _usernameController = TextEditingController(text: widget.user.username);
    _localPhotoUrl =
        widget.user.photoUrl.isNotEmpty ? widget.user.photoUrl : null;
  }

  Future<void> _showConfirmationDialog() async {
    print("FUNGSI POP-UP 1 DIPANGGIL!");

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Simpan Perubahan'),
          content:
              const Text('anda yakin ingin mengubah data profil  sebelumnya ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Yakin'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _saveProfile();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessDialog(UserModel updatedUser) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sukses'),
          content: const Text('edit profil berhasil :)'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  Navigator.pop(context, updatedUser);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.isEmpty ||
        _nisnController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Nama, NISN, dan Username tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> dataToUpdate = {
        'nama': _namaController.text,
        'nisn': _nisnController.text,
        'username': _usernameController.text,
      };

      // Jika user telah mengupload foto baru secara lokal, sertakan pada update
      if (_localPhotoUrl != null && _localPhotoUrl!.isNotEmpty) {
        dataToUpdate['photoUrl'] = _localPhotoUrl!;
      }

      await _profileService.updateUserData(widget.user.uid, dataToUpdate);

      UserModel updatedUser = widget.user.copyWith(
        nama: _namaController.text,
        nisn: _nisnController.text,
        username: _usernameController.text,
        photoUrl: _localPhotoUrl ?? widget.user.photoUrl,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await _showSuccessDialog(updatedUser);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Pengguna',
            style: TextStyle(color: textColor)),
        backgroundColor: scaffoldColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Modern editable avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: fieldColor,
                  child: ClipOval(
                    child: _localPhotoUrl != null
                        ? Image.network(
                            _localPhotoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/profile_icon.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/profile_icon.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _pickAndUploadImage,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isUploadingImage
                            ? const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: TextEditingController(text: widget.user.email),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Email (Tidak bisa diubah)',
              ),
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nisnController,
              decoration: const InputDecoration(labelText: 'NISN'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      child: const Text('Save'),
                    ),
                  ),
          ],
        ),
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Upload gambar berhasil.'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mengupload gambar.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Terjadi kesalahan saat upload: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }
}
