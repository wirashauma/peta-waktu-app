import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Kuis'),
      ),
      body: const Center(
        child: Text(
          'Ini adalah Halaman Kuis',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}