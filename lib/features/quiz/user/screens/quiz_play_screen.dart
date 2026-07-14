import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peta_waktu/main.dart';
import 'package:peta_waktu/features/quiz/models/quiz_question_model.dart';
import 'quiz_result_screen.dart';

const Color primaryTeal = Color(0xFF00796B);
const Color _tealGradientStart = Color(0xFF00796B);
const Color _tealGradientEnd = Color(0xFF26A69A);

class QuizPlayScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const QuizPlayScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  List<QuizQuestionModel> _questions = [];
  final Map<int, int> _userAnswers = {};
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;

  Timer? _timer;
  int _timeLeft = 30;
  int _totalTimeForQuestion = 30;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .get();

      List<QuizQuestionModel> loadedQuestions = snapshot.docs
          .map((doc) => QuizQuestionModel.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() {
          _questions = loadedQuestions;
          _isLoading = false;
        });
        if (_questions.isNotEmpty) {
          _startTimer();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat soal: $e')),
        );
      }
    }
  }

  void _startTimer() {
    _stopTimer();
    
    // Asumsi: QuizQuestionModel memiliki properti timeLimit. 
    // Jika belum ada di model, tambahkan: final int timeLimit;
    // Dan ambil default 30 jika null.
    try {
       // Mengakses properti timeLimit secara dinamis jika model belum diupdate
       // atau gunakan _questions[_currentQuestionIndex].timeLimit jika sudah ada
       dynamic question = _questions[_currentQuestionIndex];
       // Menggunakan refleksi sederhana atau akses properti jika ada
       // Fallback ke 30 detik jika data tidak ditemukan
       _totalTimeForQuestion = (question.timeLimit is int) ? question.timeLimit : 30;
    } catch (e) {
      _totalTimeForQuestion = 30;
    }

    setState(() {
      _timeLeft = _totalTimeForQuestion;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _stopTimer();
        _goToNextQuestion(isTimeOut: true);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _goToNextQuestion({bool isTimeOut = false}) {
    if (!isTimeOut) {
      if (_selectedOptionIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih satu jawaban.'),
            duration: Duration(milliseconds: 1000),
          ),
        );
        // Jangan hentikan timer (timer berlanjut)
        return;
      }
      _userAnswers[_currentQuestionIndex] = _selectedOptionIndex!;
    } else {
      _userAnswers[_currentQuestionIndex] = -1; 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu habis!'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 1000),
          ),
        );
      }
    }

    _stopTimer();

    bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    if (isLastQuestion) {
      _finishQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
      });
      _startTimer();
    }
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Kuis?'),
        content: const Text('Apakah Anda yakin ingin keluar dari kuis? Seluruh jawaban dan kemajuan Anda pada kuis ini akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              _stopTimer();
              Navigator.of(context).pop(); // Keluar layar kuis
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _finishQuiz() async {
    if (_isSubmitting) return;
    _stopTimer();
    
    setState(() {
      _isSubmitting = true;
    });
    
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].correctAnswerIndex == _userAnswers[i]) {
        correctCount++;
      }
    }
    int score = _questions.isEmpty ? 0 : (correctCount * 100) ~/ _questions.length;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('quiz_results').add({
          'userId': userId,
          'quizId': widget.quizId,
          'score': score,
          'completedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Gagal menyimpan hasil kuis: $e");
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          score: score,
          questions: _questions,
          userAnswers: _userAnswers,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldColor,
        body: const Center(child: CircularProgressIndicator(color: primaryTeal)),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.quizTitle),
          backgroundColor: primaryTeal,
        ),
        body: const Center(child: Text('Kuis ini tidak memiliki soal.')),
      );
    }

    QuizQuestionModel currentQuestion = _questions[_currentQuestionIndex];
    bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmationDialog();
      },
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _showExitConfirmationDialog(),
          ),
          title: Text(widget.quizTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: primaryTeal,
          centerTitle: true,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Column(
              children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soal ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '$_timeLeft dtk',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _timeLeft / _totalTimeForQuestion,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.yellowAccent),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedOptionIndex == index;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _onOptionSelected(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? primaryTeal : Colors.white,
                        foregroundColor: isSelected ? Colors.white : textColor,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected ? primaryTeal : Colors.grey.shade200,
                            width: 1.5
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : primaryTeal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              currentQuestion.options[index],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _goToNextQuestion(isTimeOut: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    isLastQuestion ? 'Selesai Kuis' : 'Selanjutnya',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    ),
  ),
);
}
}