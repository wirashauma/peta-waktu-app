// LOKASI: lib/core/constants/map_coordinates.dart

import 'package:flutter/material.dart';

class MapCoordinates {
  /// DATA PUSAT (KAMUS)
  /// Format: 'id_wilayah': Alignment(x, y)
  /// Range: -1.0 (Kiri/Atas) s/d 1.0 (Kanan/Bawah), 0.0 adalah Tengah.
  static const Map<String, Alignment> _locations = {
    // --- SUMATERA ---
    'aceh': Alignment(-0.93, -0.85),
    'sumatera_utara': Alignment(-0.86, -0.70),
    'sumatera_barat': Alignment(-0.65, -0.21),
    'riau': Alignment(-0.78, -0.60),
    'jambi': Alignment(-0.75, -0.45),
    'sumatera_selatan': Alignment(-0.53, -0.08),
    'lampung': Alignment(-0.65, -0.25),

    // --- JAWA ---
    'banten': Alignment(-0.60, 0.85),
    'jakarta': Alignment(-0.55, 0.82),
    'jawa_barat': Alignment(-0.33, 0.11),
    'jawa_tengah': Alignment(-0.25, 0.13),
    'yogyakarta': Alignment(-0.28, 0.14),
    'jawa_timur': Alignment(-0.15, 0.13), 

    // --- BALI & NUSA TENGGARA ---
    'bali': Alignment(0.28, 0.95),
    'ntb': Alignment(0.40, 0.95),
    'ntt': Alignment(0.60, 1.00),

    // --- KALIMANTAN ---
    'kalimantan_barat': Alignment(-0.30, -0.10),
    'kalimantan_tengah': Alignment(-0.15, -0.15),
    'kalimantan_selatan': Alignment(-0.10, -0.05),
    'kalimantan_timur': Alignment(-0.09, -0.20), // Area Kutai
    'kalimantan_utara': Alignment(-0.05, -0.40),

    // --- SULAWESI ---
    'sulawesi_selatan': Alignment(0.05, 0.0), // Area Gowa Tallo
    'sulawesi_tengah': Alignment(0.40, -0.10),
    'sulawesi_utara': Alignment(0.55, -0.30),
    'sulawesi_tenggara': Alignment(0.45, 0.15),
    'gorontalo': Alignment(0.48, -0.25),

    // --- MALUKU & PAPUA ---
    'maluku': Alignment(0.35, -0.25),
    'maluku_utara': Alignment(0.68, -0.20),
    'papua_barat': Alignment(0.80, -0.10),
    'papua': Alignment(0.92, -0.05),
  };

  /// 1. FUNGSI UNTUK MENGAMBIL KOORDINAT (Dipakai di DashboardScreen)
  /// Jika ID tidak ditemukan, pin akan muncul di tengah (0,0) sebagai fallback.
  static Alignment getAlign(String? locationId) {
    if (locationId == null || locationId.isEmpty) {
      return Alignment.center;
    }
    // Menggunakan toLowerCase agar tidak sensitif huruf besar/kecil
    return _locations[locationId.toLowerCase()] ?? Alignment.center;
  }

  /// 2. FUNGSI UNTUK LIST DROPDOWN (Dipakai di Form Input Guru)
  /// Mengembalikan list ID wilayah yang tersedia.
  static List<String> getAvailableRegions() {
    // Mengurutkan nama wilayah secara abjad agar rapi di dropdown
    List<String> keys = _locations.keys.toList();
    keys.sort(); 
    return keys;
  }

  /// 3. FUNGSI HELPER FORMAT JUDUL (Opsional)
  /// Mengubah "jawa_timur" menjadi "Jawa Timur" agar bagus dilihat di UI.
  static String formatRegionName(String id) {
    if (id.isEmpty) return '';
    return id
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}