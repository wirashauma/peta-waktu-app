import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'q': 'Apa fungsi utama aplikasi Peta Waktu?',
        'a': 'Peta Waktu adalah media pembelajaran sejarah interaktif berbasis peta. Anda dapat melihat lokasi kerajaan dan peristiwa sejarah berdasarkan lini masa (tahun) yang dipilih.'
      },
      {
        'q': 'Bagaimana cara mengganti Foto Profil?',
        'a': 'Masuk ke menu Pengaturan > pilih "Edit Profil". Klik ikon kamera pada foto profil Anda, pilih gambar dari galeri, lalu tekan tombol Simpan.'
      },
      {
        'q': 'Bagaimana cara melihat riwayat nilai kuis?',
        'a': 'Riwayat nilai Anda tersimpan otomatis. Buka menu Pengaturan, lalu lihat pada bagian "Aktivitas" dan pilih menu "Riwayat Kuis".'
      },
      {
        'q': 'Bagaimana cara mengganti Kata Sandi?',
        'a': 'Buka menu Pengaturan > pilih "Ganti Kata Sandi". Anda perlu memasukkan kata sandi lama sebelum membuat kata sandi baru demi keamanan.'
      },
      {
        'q': 'Apakah aplikasi ini membutuhkan koneksi internet?',
        'a': 'Ya, Peta Waktu membutuhkan koneksi internet untuk memuat data peta terbaru, soal kuis, dan menyimpan progres profil Anda ke server.'
      },
    ];

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: faqs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildFaqItem(
                  faqs[index]['q']!,
                  faqs[index]['a']!,
                );
              },
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
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
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
                "Bantuan & FAQ",
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

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          iconColor: _tealGradientStart,
          collapsedIconColor: Colors.grey,
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}