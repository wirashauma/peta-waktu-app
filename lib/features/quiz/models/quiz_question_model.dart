import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestionModel {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final int timeLimit;
  final String explanation;

  QuizQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.timeLimit,
    required this.explanation,
  });

  factory QuizQuestionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return QuizQuestionModel(
      id: doc.id,
      questionText: data['questionText'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
      timeLimit: data['timeLimit'] ?? 30,
      explanation: data['explanation'] ?? '',
    );
  }
}