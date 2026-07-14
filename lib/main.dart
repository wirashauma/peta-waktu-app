// LOKASI: main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/services/auth_service.dart';

// --- TEMA WARNA BARU (Teal & Abu-abu Profesional) ---
const Color primaryTeal = Color(0xFF00796B); // Teal Dark (Warna Aksen Utama)
const Color scaffoldColor = Color(0xFFF9F9F9); // Latar belakang sangat terang
const Color primaryColor = primaryTeal; // Menjadikan Teal sebagai primaryColor
const Color fieldColor =
    Color(0xFFEFEFEF); // Warna input field yang sangat terang
const Color textColor = Color(0xFF3A4F41); // Warna teks gelap (pertahankan)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi pendengar status autentikasi mock/gabungan
  AuthService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peta Waktu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: scaffoldColor,
        primaryColor: primaryColor,
        // Mengatur warna aksen utama (digunakan oleh ProgressIndicator, Radio, dll.)
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryTeal,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: textColor),

        // Tema untuk input field (Outlined/Filled yang Rapi)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: fieldColor,
          labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
          hintStyle: TextStyle(color: Colors.grey.shade500),

          // Menggunakan OutlineInputBorder sebagai base theme yang lebih rapi
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          // Border saat tidak fokus
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          // Border saat fokus (menggunakan warna primary/Teal)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryColor, width: 2.0),
          ),
        ),

        // Tema untuk tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(8), // Disesuaikan dengan field
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
