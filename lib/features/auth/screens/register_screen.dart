import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peta_waktu/features/auth/services/auth_service.dart';
import 'package:peta_waktu/features/auth/widgets/custom_button.dart';
import 'package:peta_waktu/features/auth/widgets/custom_textfield.dart';
import 'package:peta_waktu/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nisnController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nisnController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_usernameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        throw Exception("Semua kolom wajib diisi");
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        throw Exception("Konfirmasi kata sandi tidak cocok!");
      }

      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        nisn: _nisnController.text.trim(),
        nama: _usernameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil! Silakan Masuk.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_alt_1_outlined,
                    size: 32, color: primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                'BUAT AKUN BARU',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lengkapi data diri Anda untuk mulai.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Nama Pengguna',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Alamat Email',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _nisnController,
                      label: 'NISN',
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Kata Sandi',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Kata Sandi',
                      obscureText: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 56, 
                      child: CustomButton(
                        text: 'Daftar Sekarang',
                        onPressed: _handleRegister,
                      ),
                    ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sudah punya akun? ",
                      style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Masuk",
                      style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Column(
                children: [
                  Text(
                    "Peta Waktu App v1.0.0",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "© 2025 Peta Waktu Inc. All rights reserved.",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade400,
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
}