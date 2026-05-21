import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:peta_waktu/features/auth/screens/register_screen.dart';
import 'package:peta_waktu/features/auth/services/auth_service.dart';
import 'package:peta_waktu/features/auth/widgets/custom_button.dart';
import 'package:peta_waktu/features/auth/widgets/custom_textfield.dart';
import 'package:peta_waktu/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceAll("Exception: ", ""),
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Mohon lengkapi email dan password Anda.");
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await GoogleSignIn().signOut();
      await _authService.signInWithGoogle();
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleQuickLogin({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    setState(() => _isLoading = true);
    try {
      // 1. Coba login terlebih dahulu
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      // Jika error, kemungkinan besar user belum ada di Auth (belum di-seed)
      String errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('user-not-found') || 
          errorMsg.contains('invalid-credential') || 
          errorMsg.contains('wrong-password') ||
          errorMsg.contains('tidak ditemukan') ||
          errorMsg.contains('salah')) {
        // Buat akun baru secara otomatis (Seed Data)
        try {
          await _authService.signUp(
            email: email,
            password: password,
            nisn: role == 'user' ? '1234567890' : '-',
            nama: name,
            username: name.toLowerCase().replaceAll(' ', ''),
            role: role,
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Akun $name berhasil disiapkan & masuk!',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (signUpErr) {
          _showError("Gagal menyiapkan akun: $signUpErr");
        }
      } else {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildQuickLoginButton({
    required IconData icon,
    required String label,
    required Color color,
    required String email,
    required String password,
    required String role,
    required String name,
  }) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => _handleQuickLogin(
                email: email,
                password: password,
                role: role,
                name: name,
              ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: 16, color: primaryColor),
            const SizedBox(width: 6),
            Text(
              "Masuk Cepat (Quick Login)",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickLoginButton(
              icon: Icons.admin_panel_settings_outlined,
              label: 'Admin',
              color: Colors.red.shade700,
              email: 'admin@petawaktu.com',
              password: 'password123',
              role: 'admin',
              name: 'Admin Peta Waktu',
            ),
            _buildQuickLoginButton(
              icon: Icons.school_outlined,
              label: 'Guru',
              color: Colors.orange.shade800,
              email: 'guru@petawaktu.com',
              password: 'password123',
              role: 'guru',
              name: 'Guru Sejarah',
            ),
            _buildQuickLoginButton(
              icon: Icons.person_outline,
              label: 'Siswa',
              color: primaryColor,
              email: 'siswa@petawaktu.com',
              password: 'password123',
              role: 'user',
              name: 'Siswa Peta Waktu',
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(), 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_outlined,
                    size: 48, color: primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'PETA WAKTU',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jelajahi jejak sejarah Indonesia dalam genggaman Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Masuk Akun",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                  controller: _emailController, label: 'Alamat Email'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Kata Sandi',
                obscureText: true,
              ),
              
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: 'Masuk Sekarang',
                        onPressed: _handleLogin,
                      ),
                    ),
              const SizedBox(height: 20),
              _buildQuickLoginSection(),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "atau lanjutkan dengan",
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: Text(
                    "Masuk dengan Google",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum memiliki akun? ",
                      style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Daftar",
                      style: GoogleFonts.poppins(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(), 
              
              Column(
                children: [
                  Text(
                    "Peta Waktu App v1.0.0",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "© 2025 Peta Waktu Inc. All rights reserved.",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
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