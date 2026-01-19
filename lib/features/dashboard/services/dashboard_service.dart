import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/historical_event.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mendapatkan stream data event berdasarkan tahun maksimal
  Stream<List<HistoricalEvent>> getEventsStream(int maxYear) {
    int minYear = 0;


    if (maxYear == 500) minYear = 0;
    if (maxYear == 1000) minYear = 501;
    if (maxYear == 1500) minYear = 1001;
    if (maxYear == 1700) minYear = 1501;
    if (maxYear == 2000) minYear = 1701;

    return _firestore
        .collection('historical_events')
        .where('year', isGreaterThanOrEqualTo: minYear)
        .where('year', isLessThanOrEqualTo: maxYear)
        .snapshots()
        .map((snapshot) {
      // Ubah setiap dokumen snapshot menjadi objek HistoricalEvent
      return snapshot.docs
          .map((doc) => HistoricalEvent.fromFirestore(doc))
          .toList();
    });
  }
}