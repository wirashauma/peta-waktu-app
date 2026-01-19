import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';
import 'quiz_play_screen.dart';
import 'quiz_result_screen.dart';
import 'package:peta_waktu/features/quiz/models/quiz_question_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class UserQuizListScreen extends StatefulWidget {
  const UserQuizListScreen({super.key});

  @override
  State<UserQuizListScreen> createState() => _UserQuizListScreenState();
}

class _UserQuizListScreenState extends State<UserQuizListScreen> {
  Map<String, int> _quizScores = {};
  bool _isLoadingCompleted = true;

  @override
  void initState() {
    super.initState();
    _fetchCompletedQuizzes();
  }

  Future<void> _fetchCompletedQuizzes() async {
    setState(() {
      _isLoadingCompleted = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() => _isLoadingCompleted = false);
        return;
      }

      var snapshot = await FirebaseFirestore.instance
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, int> scores = {};
      for (var doc in snapshot.docs) {
        String quizId = doc['quizId'];
        int score = doc['score'];

        if (scores.containsKey(quizId)) {
          if (score > scores[quizId]!) {
            scores[quizId] = score;
          }
        } else {
          scores[quizId] = score;
        }
      }

      if (mounted) {
        setState(() {
          _quizScores = scores;
          _isLoadingCompleted = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCompleted = false);
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchCompletedQuizzes();
  }

  Future<void> _openQuizReview(String quizId, int score) async {
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Ambil soal-soal untuk pembahasan
      var snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      List<QuizQuestionModel> questions = snapshot.docs
          .map((doc) => QuizQuestionModel.fromFirestore(doc))
          .toList();

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizResultScreen(
              score: score,
              questions: questions,
              userAnswers: const {}, // Kosong karena review dari list (jawaban user tidak disimpan)
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat pembahasan: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quizzes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoadingCompleted) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: _tealGradientStart));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.quiz_outlined,
                                    size: 60, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada kuis yang tersedia.',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: _tealGradientStart,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      String quizId = doc.id;
                      String title =
                          (doc.data() as Map)['title'] ?? 'Kuis Tanpa Judul';
                      int questionCount =
                          (doc.data() as Map)['questionCount'] ?? 0;
                      int timePeriod = (doc.data() as Map)['timePeriod'] ?? 0;

                      int? score = _quizScores[quizId];

                      return _buildQuizCard(
                        title,
                        questionCount,
                        timePeriod,
                        score,
                        () {
                          if (score != null) {
                            // Jika sudah selesai, buka pembahasan
                            _openQuizReview(quizId, score);
                          } else {
                            // Jika belum, mulai kuis
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPlayScreen(
                                  quizId: quizId,
                                  quizTitle: title,
                                ),
                              ),
                            ).then((_) => _fetchCompletedQuizzes());
                          }
                        },
                      );
                    },
                  ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Daftar Kuis",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _buildQuizCard(String title, int count, int period, int? score,
      VoidCallback onTap) {
    bool isCompleted = score != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCompleted ? Border.all(color: Colors.green.shade200) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.shade100
                        : _tealGradientStart.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.emoji_events : Icons.quiz_rounded,
                    color: isCompleted ? Colors.green : _tealGradientStart,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCompleted ? Colors.green.shade800 : textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildInfoChip(Icons.list_alt, '$count Soal'),
                          _buildInfoChip(Icons.history_edu, 'Era $period M'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isCompleted)
                  Column(
                    children: [
                      const Text(
                        "Nilai",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$score",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _tealGradientStart,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}