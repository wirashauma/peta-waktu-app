import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/groq_service.dart';
import 'package:peta_waktu/main.dart';

const Color primaryTeal = Color(0xFF00796B);
const Color textColor = Colors.black87;
const Color cardBackground = Colors.white;

class QuestionFormModel {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController explanationController = TextEditingController(); 
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  int correctAnswerIndex = 0;
  int timeLimitSeconds = 30;
  String? questionId;
}

class CreateQuizScreen extends StatefulWidget {
  final QueryDocumentSnapshot? quizToEdit;

  const CreateQuizScreen({super.key, this.quizToEdit});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quizTitleController = TextEditingController();
  final GroqService _groqService = GroqService();

  int _selectedPeriod = 500;
  bool _isLoading = false;
  bool _isDataLoading = false;
  bool _isGeneratingAI = false;
  bool get _isEditMode => widget.quizToEdit != null;

  final List<QuestionFormModel> _questions =
      List.generate(10, (index) => QuestionFormModel());

  InputDecoration _inputDecoration(String hint, {bool isDense = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500),
      isDense: isDense,
      filled: true,
      fillColor: cardBackground,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryTeal, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadDataForEdit();
    }
  }

  Future<void> _showAiDialog() async {
    final topicController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Generate Soal Otomatis ✨"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "Masukkan topik sejarah, AI (Groq) akan membuatkan 10 soal untuk Anda."),
            const SizedBox(height: 16),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: "Topik (Misal: Perang Diponegoro)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (topicController.text.isNotEmpty) {
                _generateQuestionsWithAI(topicController.text);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal),
            child: const Text("Generate", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuestionsWithAI(String topic) async {
    setState(() => _isGeneratingAI = true);

    try {
      final generatedData = await _groqService.generateQuizQuestions(topic);

      setState(() {
        if (_quizTitleController.text.isEmpty) {
          _quizTitleController.text = "Kuis: $topic";
        }

        for (int i = 0; i < 10 && i < generatedData.length; i++) {
          final data = generatedData[i];
          final model = _questions[i];

          model.questionController.text = data['questionText'] ?? '';
          model.explanationController.text = data['explanation'] ?? '';

          List options = data['options'] ?? ['', '', '', ''];
          model.optionAController.text =
              options.isNotEmpty ? options[0].toString() : '';
          model.optionBController.text =
              options.length > 1 ? options[1].toString() : '';
          model.optionCController.text =
              options.length > 2 ? options[2].toString() : '';
          model.optionDController.text =
              options.length > 3 ? options[3].toString() : '';

          model.correctAnswerIndex = data['correctAnswerIndex'] ?? 0;
          model.timeLimitSeconds = data['timeLimit'] ?? 30;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Soal berhasil dibuat oleh AI! Silakan periksa kembali.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingAI = false);
    }
  }

  Future<void> _loadDataForEdit() async {
    setState(() {
      _isDataLoading = true;
    });

    try {
      final quizData = widget.quizToEdit!.data() as Map<String, dynamic>;
      _quizTitleController.text = quizData['title'] ?? '';
      _selectedPeriod = quizData['timePeriod'] ?? 500;

      final questionsSnapshot =
          await widget.quizToEdit!.reference.collection('questions').get();

      for (int i = 0; i < questionsSnapshot.docs.length; i++) {
        if (i >= 10) break;

        var questionDoc = questionsSnapshot.docs[i];
        var questionData = questionDoc.data();
        var model = _questions[i];

        model.questionId = questionDoc.id;
        model.questionController.text = questionData['questionText'] ?? '';
        model.explanationController.text = questionData['explanation'] ?? '';
        model.optionAController.text =
            (questionData['options'] as List)[0] ?? '';
        model.optionBController.text =
            (questionData['options'] as List)[1] ?? '';
        model.optionCController.text =
            (questionData['options'] as List)[2] ?? '';
        model.optionDController.text =
            (questionData['options'] as List)[3] ?? '';
        model.correctAnswerIndex = questionData['correctAnswerIndex'] ?? 0;
        model.timeLimitSeconds = questionData['timeLimit'] ?? 30;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data kuis: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
    }
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode) {
        DocumentReference quizDoc = widget.quizToEdit!.reference;

        await quizDoc.update({
          'title': _quizTitleController.text,
          'timePeriod': _selectedPeriod,
        });

        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var questionForm in _questions) {
          if (questionForm.questionId != null) {
            var questionRef =
                quizDoc.collection('questions').doc(questionForm.questionId);
            batch.update(questionRef, {
              'questionText': questionForm.questionController.text,
              'explanation': questionForm.explanationController.text,
              'options': [
                questionForm.optionAController.text,
                questionForm.optionBController.text,
                questionForm.optionCController.text,
                questionForm.optionDController.text,
              ],
              'correctAnswerIndex': questionForm.correctAnswerIndex,
              'timeLimit': questionForm.timeLimitSeconds,
            });
          }
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kuis berhasil diperbarui!')),
          );
          Navigator.pop(context);
        }
      } else {
        DocumentReference quizDoc =
            await FirebaseFirestore.instance.collection('quizzes').add({
          'title': _quizTitleController.text,
          'timePeriod': _selectedPeriod,
          'questionCount': 10,
          'createdAt': FieldValue.serverTimestamp(),
        });

        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var questionForm in _questions) {
          var questionRef = quizDoc.collection('questions').doc();
          batch.set(questionRef, {
            'questionText': questionForm.questionController.text,
            'explanation': questionForm.explanationController.text,
            'options': [
              questionForm.optionAController.text,
              questionForm.optionBController.text,
              questionForm.optionCController.text,
              questionForm.optionDController.text,
            ],
            'correctAnswerIndex': questionForm.correctAnswerIndex,
            'timeLimit': questionForm.timeLimitSeconds,
          });
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kuis berhasil disimpan!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Kuis' : 'Buat Kuis Baru',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryTeal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        actions: [
          if (!_isEditMode)
            IconButton(
              onPressed: _showAiDialog,
              icon: const Icon(Icons.auto_awesome, color: Colors.yellowAccent),
              tooltip: "Generate dengan AI",
            )
        ],
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (!_isEditMode)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200)),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Tips: Klik ikon petir (✨) di pojok kanan atas untuk membuat soal otomatis dengan AI.",
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Text('Detail Kuis',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quizTitleController,
                  decoration: _inputDecoration('Masukkan Judul Kuis'),
                  validator: (val) =>
                      val!.isEmpty ? 'Judul tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedPeriod,
                  decoration: _inputDecoration('Pilih Periode Tahun'),
                  items: const [
                    DropdownMenuItem(value: 500, child: Text('< 500 M')),
                    DropdownMenuItem(value: 1000, child: Text('< 1000 M')),
                    DropdownMenuItem(value: 1500, child: Text('< 1500 M')),
                    DropdownMenuItem(value: 1700, child: Text('< 1700 M')),
                    DropdownMenuItem(value: 2000, child: Text('< 2000 M')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedPeriod = val!;
                    });
                  },
                ),
                const Divider(height: 40, color: primaryTeal),
                const Text('Detail Pertanyaan (10 Soal)',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTeal)),
                ...List.generate(10, (index) {
                  return _buildQuestionEditor(index + 1, _questions[index]);
                }),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: primaryTeal))
                    : ElevatedButton(
                        onPressed: _saveQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                            _isEditMode ? 'Simpan Perubahan' : 'Simpan Kuis',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
          if (_isDataLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          if (_isGeneratingAI)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.yellowAccent),
                    const SizedBox(height: 20),
                    const Text(
                      "Sedang meracik soal sejarah...",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Mohon tunggu sebentar",
                      style:
                          TextStyle(color: Colors.grey.shade300, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionEditor(int questionNumber, QuestionFormModel model) {
    return StatefulBuilder(builder: (context, setCardState) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        color: cardBackground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Soal $questionNumber',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryTeal)),
                  SizedBox(
                    width: 140,
                    child: DropdownButtonFormField<int>(
                      value: model.timeLimitSeconds,
                      isExpanded: true,
                      decoration: _inputDecoration('Waktu', isDense: true),
                      items: [10, 15, 30, 45, 60, 90, 120]
                          .map((time) => DropdownMenuItem(
                                value: time,
                                child: Text('$time Detik',
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setCardState(() {
                          model.timeLimitSeconds = val!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, color: Colors.grey),
              TextFormField(
                controller: model.questionController,
                decoration:
                    _inputDecoration('Tuliskan Teks Pertanyaan', isDense: true),
                maxLines: 3,
                minLines: 1,
                validator: (val) =>
                    val!.isEmpty ? 'Pertanyaan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: model.explanationController,
                decoration: _inputDecoration(
                    'Penjelasan / Pembahasan (Opsional)',
                    isDense: true),
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 16),
              Text('Pilihan Jawaban (Pilih 1 jawaban benar)',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.8))),
              const SizedBox(height: 8),
              _buildOptionRow(
                  model, 0, 'A', model.optionAController, setCardState),
              _buildOptionRow(
                  model, 1, 'B', model.optionBController, setCardState),
              _buildOptionRow(
                  model, 2, 'C', model.optionCController, setCardState),
              _buildOptionRow(
                  model, 3, 'D', model.optionDController, setCardState),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOptionRow(QuestionFormModel model, int index, String label,
      TextEditingController controller, Function(VoidCallback) setCardState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: model.correctAnswerIndex,
            activeColor: primaryTeal,
            onChanged: (val) {
              setCardState(() {
                model.correctAnswerIndex = val!;
              });
            },
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: _inputDecoration('Pilihan $label', isDense: true),
              validator: (val) =>
                  val!.isEmpty ? 'Pilihan tidak boleh kosong' : null,
            ),
          ),
        ],
      ),
    );
  }
}