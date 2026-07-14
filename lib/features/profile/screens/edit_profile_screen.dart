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
  final _formKey = GlobalKey<FormState>();

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
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Simpan Perubahan'),
          content:
              const Text('Apakah Anda yakin ingin mengubah data profil Anda?'),
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
          content: const Text('Profil berhasil diperbarui.'),
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> dataToUpdate = {
        'nama': _namaController.text.trim(),
        'nisn': _nisnController.text.trim(),
        'username': _usernameController.text.trim(),
      };

      if (_localPhotoUrl != null && _localPhotoUrl!.isNotEmpty) {
        dataToUpdate['photoUrl'] = _localPhotoUrl!;
      }

      await _profileService.updateUserData(widget.user.uid, dataToUpdate);

      UserModel updatedUser = widget.user.copyWith(
        nama: _namaController.text.trim(),
        nisn: _nisnController.text.trim(),
        username: _usernameController.text.trim(),
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
        child: Form(
          key: _formKey,
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (val.trim().length < 3) {
                    return 'Nama minimal terdiri dari 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.email,
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
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  if (val.contains(' ')) {
                    return 'Username tidak boleh menggunakan spasi';
                  }
                  if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^-%$#@!]').hasMatch(val)) {
                    return 'Username tidak boleh mengandung karakter spesial';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nisnController,
                decoration: const InputDecoration(labelText: 'NISN'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (widget.user.role == 'user') {
                    if (val == null || val.trim().isEmpty || val.trim() == '-') {
                      return 'NISN wajib diisi untuk siswa';
                    }
                    if (val.trim().length != 10 || int.tryParse(val.trim()) == null) {
                      return 'NISN harus berupa 10 digit angka';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showConfirmationDialog();
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
            ],
          ),
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
