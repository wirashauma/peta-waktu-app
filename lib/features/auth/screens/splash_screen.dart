// LOKASI: lib/features/auth/screens/splash_screen.dart
// KODE SUDAH DIUBAH KE ANIMASI "BUBBLE" SATU-PER-SATU

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart'; // Impor untuk mengakses warna
import 'package:peta_waktu/features/core/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // --- PERUBAHAN 1: Kita butuh 2 animasi terpisah ---
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textScaleAnimation;
  // --- BATAS PERUBAHAN ---

  @override
  void initState() {
    super.initState();

    // --- PERUBAHAN 2: Tambah durasi total untuk 2 animasi ---
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // 2 detik total
    );

    // Animasi Ikon: Berjalan di paruh pertama (0.0s - 1.0s)
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0, // Mulai dari 0% durasi
          0.5, // Selesai di 50% durasi
          curve: Curves.easeOutBack, // Efek "bubble"
        ),
      ),
    );

    // Animasi Teks: Berjalan di paruh kedua (1.0s - 2.0s)
    _textScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5, // Mulai dari 50% durasi
          1.0, // Selesai di 100% durasi
          curve: Curves.easeOutBack, // Efek "bubble"
        ),
      ),
    );
    // --- BATAS PERUBAHAN ---

    // Mulai jalankan animasi
    _controller.forward();

    // Timer 3 detik Anda untuk pindah halaman (TIDAK BERUBAH)
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // Kita kembalikan ke Column
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- PERUBAHAN 3: Bungkus Icon secara individual ---
            ScaleTransition(
              scale: _iconScaleAnimation,
              child: Icon(
                Icons.location_on_outlined,
                size: 80,
                color: textColor,
              ),
            ),
            // --- BATAS PERUBAHAN ---

            const SizedBox(height: 20),

            // --- PERUBAHAN 4: Bungkus Teks secara individual ---
            ScaleTransition(
              scale: _textScaleAnimation,
              child: Text(
                'PETA WAKTU',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            // --- BATAS PERUBAHAN ---
          ],
        ),
      ),
    );
  }
}
