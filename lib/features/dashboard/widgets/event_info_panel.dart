import 'package:flutter/material.dart';
import '../models/historical_event.dart';
import 'package:peta_waktu/main.dart'; // Impor tema warna

class EventInfoPanel extends StatelessWidget {
  final HistoricalEvent event;

  const EventInfoPanel({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              event.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              // Indikator loading saat gambar dimuat
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 180,
                  color: fieldColor,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
              // Indikator error jika gambar gagal dimuat
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: fieldColor,
                  child: const Icon(Icons.broken_image, color: textColor),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Judul
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // Penjelasan
          Text(
            event.description,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}