import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart'; // Impor tema warna dari main.dart

class YearFilterBar extends StatelessWidget {
  final int selectedYear;
  final Function(int) onYearSelected;

  const YearFilterBar({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> years = [
      {'label': '< 500 M', 'value': 500},
      {'label': '< 1000 M', 'value': 1000},
      {'label': '< 1500 M', 'value': 1500},
      {'label': '< 1700 M', 'value': 1700},
      {'label': '< 2000 M', 'value': 2000},
    ];

    return Container(
      // Kurangi padding vertikal container
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Row( // Pastikan ini adalah Row, BUKAN Wrap
        children: years.map((year) {
          bool isSelected = year['value'] == selectedYear;
          
          // --- INI PERBAIKANNYA ---
          // "Expanded" memaksa setiap tombol punya lebar yang sama
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // Jarak antar tombol
              child: ElevatedButton(
                onPressed: () => onYearSelected(year['value']),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? primaryColor : fieldColor,
                  foregroundColor: isSelected ? Colors.white : textColor,
                  
                  // --- PERUBAHAN UKURAN ---
                  // 1. Kurangi padding vertikal agar tombol tidak terlalu tinggi
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10), 
                  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  textStyle: const TextStyle(
                    // 2. Kurangi ukuran font agar muat 1 baris
                    fontSize: 11, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // 3. Pastikan teks tidak wrapping
                child: Text(
                  year['label'], 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
          // --- BATAS PERBAIKAN ---

        }).toList(),
      ),
    );
  }
}