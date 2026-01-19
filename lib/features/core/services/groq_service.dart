import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<List<Map<String, dynamic>>> generateQuizQuestions(String topic) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  "Anda adalah asisten guru sejarah yang membantu membuat soal ujian. Output WAJIB format JSON."
            },
            {
              "role": "user",
              "content": '''
                Buatkan 10 soal pilihan ganda tentang topik: "$topic" untuk siswa Indonesia.
                
                Sangat Penting:
                1. Output HANYA JSON murni (List of Objects). 
                2. Jangan ada teks pembuka/penutup.
                3. Format JSON harus persis seperti ini:
                [
                  {
                    "questionText": "Pertanyaan?",
                    "options": ["A", "B", "C", "D"],
                    "correctAnswerIndex": 0, 
                    "timeLimit": 30,
                    "explanation": "Penjelasan singkat mengapa jawaban tersebut benar."
                  }
                ]
                4. correctAnswerIndex adalah angka 0-3 (0=A, 1=B, dst).
              '''
            }
          ],
          "temperature": 0.5,
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        content =
            content.replaceAll('```json', '').replaceAll('```', '').trim();

        var parsedJson = jsonDecode(content);

        if (parsedJson is Map<String, dynamic>) {
          if (parsedJson.isNotEmpty) {
            var firstKey = parsedJson.keys.first;
            if (parsedJson[firstKey] is List) {
              return List<Map<String, dynamic>>.from(parsedJson[firstKey]);
            }
          }
        } else if (parsedJson is List) {
          return List<Map<String, dynamic>>.from(parsedJson);
        }

        throw Exception(
            "Format JSON dari AI tidak sesuai struktur yang diharapkan.");
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']['message'] ?? response.body;
        throw Exception('Groq API Error: $errorMessage');
      }
    } catch (e) {
      throw Exception('Gagal generate soal: $e');
    }
  }
}
