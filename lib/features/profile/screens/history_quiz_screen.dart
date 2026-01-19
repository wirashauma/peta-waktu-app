import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class HistoryQuizScreen extends StatelessWidget {
  const HistoryQuizScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    DateTime d = timestamp.toDate();
    return "${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: userId == null
                ? const Center(child: Text("Silakan login terlebih dahulu."))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quiz_results')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: _tealGradientStart));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_edu_outlined,
                                  size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat kuis.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        );
                      }

                      List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                      docs.sort((a, b) {
                        int scoreA = (a.data() as Map)['score'] ?? 0;
                        int scoreB = (b.data() as Map)['score'] ?? 0;
                        return scoreB.compareTo(scoreA);
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: docs.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var data = docs[index].data() as Map<String, dynamic>;
                          String quizId = data['quizId'] ?? '';
                          int score = data['score'] ?? 0;
                          Timestamp? date = data['completedAt'];

                          return _QuizHistoryCard(
                            quizId: quizId,
                            score: score,
                            dateStr: _formatDate(date),
                          );
                        },
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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              const Text(
                "Riwayat Kuis",
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
}

class _QuizHistoryCard extends StatelessWidget {
  final String quizId;
  final int score;
  final String dateStr;

  const _QuizHistoryCard({
    required this.quizId,
    required this.score,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _tealGradientStart.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_outlined,
                  color: _tealGradientStart, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('quizzes')
                    .doc(quizId)
                    .get(),
                builder: (context, snapshot) {
                  String title = 'Memuat judul...';
                  if (snapshot.hasData && snapshot.data!.exists) {
                    title =
                        (snapshot.data!.data() as Map)['title'] ?? 'Judul Kuis';
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    title = 'Kuis Terhapus';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Nilai",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: score >= 75 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}