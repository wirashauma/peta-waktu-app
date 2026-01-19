import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';
import 'package:peta_waktu/features/quiz/models/quiz_question_model.dart';

const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);
const Color _correctColor = Color(0xFF4CAF50);
const Color _wrongColor = Color(0xFFE53935);
const Color _unansweredColor = Color(0xFFFFA726);

class QuizResultScreen extends StatefulWidget {
  final int score;
  final List<QuizQuestionModel> questions;
  final Map<int, int> userAnswers;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _isReviewMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_isReviewMode ? 'Pembahasan Soal' : 'Hasil Kuis',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_tealGradientStart, _tealGradientEnd],
            ),
          ),
        ),
        leading: _isReviewMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _isReviewMode = false),
              )
            : null,
        elevation: 0,
      ),
      body: _isReviewMode ? _buildReviewList() : _buildScoreSummary(),
    );
  }

  Widget _buildScoreSummary() {
    int correctAnswers = 0;
    int wrongAnswers = 0;
    int unanswered = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      int? userAnswer = widget.userAnswers[i];
      if (userAnswer == -1 || userAnswer == null) {
        unanswered++;
      } else if (userAnswer == widget.questions[i].correctAnswerIndex) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_tealGradientStart, _tealGradientEnd],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5))
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.score}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _tealGradientStart,
                          ),
                        ),
                        Text(
                          'Skor Akhir',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(Icons.check_circle, 'Benar',
                        '$correctAnswers', _correctColor),
                    _buildStatItem(
                        Icons.cancel, 'Salah', '$wrongAnswers', _wrongColor),
                    _buildStatItem(
                        Icons.help, 'Kosong', '$unanswered', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rincian Jawaban',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _tealGradientStart),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.questions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    int? userAns = widget.userAnswers[index];
                    int correctAns = widget.questions[index].correctAnswerIndex;
                    Color bgColor;

                    if (userAns == -1 || userAns == null) {
                      bgColor = _unansweredColor;
                    } else if (userAns == correctAns) {
                      bgColor = _correctColor;
                    } else {
                      bgColor = _wrongColor;
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: bgColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isReviewMode = true),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Lihat Pembahasan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tealGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _tealGradientStart,
                    side: const BorderSide(color: _tealGradientStart),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color) {
    Color itemColor =
        (color == Colors.white) ? Colors.white.withOpacity(0.9) : Colors.white;
    return Column(
      children: [
        Icon(icon, color: itemColor, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: itemColor)),
        Text(label, style: TextStyle(fontSize: 12, color: itemColor)),
      ],
    );
  }

  Widget _buildReviewList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        final question = widget.questions[index];
        final userAnswer = widget.userAnswers[index] ?? -1;
        final isCorrect = userAnswer == question.correctAnswerIndex;
        final isSkipped = userAnswer == -1;

        final String explanation = question.explanation.isNotEmpty
            ? question.explanation
            : "Tidak ada pembahasan untuk soal ini.";

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSkipped
                            ? _unansweredColor
                            : (isCorrect ? _correctColor : _wrongColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'No. ${index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.questionText,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
                const SizedBox(height: 16),
                ...List.generate(question.options.length, (optIndex) {
                  bool isSelected = userAnswer == optIndex;
                  bool isRealAnswer = question.correctAnswerIndex == optIndex;

                  Color optionColor = Colors.grey.shade100;
                  Color borderColor = Colors.transparent;
                  Color iconColor = Colors.grey;
                  IconData icon = Icons.circle_outlined;

                  // Logika Warna Jawaban
                  if (isRealAnswer) {
                    // Jawaban Benar (Selalu Hijau)
                    optionColor = Colors.green.shade50;
                    borderColor = Colors.green;
                    iconColor = Colors.green;
                    icon = Icons.check_circle;
                  } else if (isSelected && !isRealAnswer) {
                    // Jawaban Salah yang dipilih user (Merah)
                    optionColor = Colors.red.shade50;
                    borderColor = Colors.red;
                    iconColor = Colors.red;
                    icon = Icons.cancel;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: optionColor,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: iconColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            question.options[optIndex],
                            style: TextStyle(
                              color: isRealAnswer || isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                              fontWeight: (isRealAnswer || isSelected)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tips_and_updates_outlined,
                              size: 18, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            "Pembahasan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        explanation,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}