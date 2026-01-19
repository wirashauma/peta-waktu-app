import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricalEvent {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int year;
  final String locationId; // Pengganti alignX & alignY

  HistoricalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.year,
    required this.locationId,
  });

  factory HistoricalEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HistoricalEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      year: data['year'] ?? 0,
      // Ambil ID lokasi dari Firebase (default ke 'jakarta' jika kosong)
      locationId: data['location_id'] ?? 'jakarta',
    );
  }
}