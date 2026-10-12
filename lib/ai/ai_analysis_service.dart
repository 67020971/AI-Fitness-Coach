import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/workout_summary.dart';

class AiAnalysisService {
  AiAnalysisService({http.Client? client}) : _client = client ?? http.Client();

  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  final http.Client _client;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> analyze(WorkoutSummary summary) async {
    if (!isConfigured) {
      throw StateError(
        'ยังไม่ได้ตั้งค่า GEMINI_API_KEY ให้รันด้วย --dart-define',
      );
    }

    final endpoint = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );
    final prompt = '''
คุณเป็นโค้ชฟิตเนสที่ให้คำแนะนำอย่างปลอดภัยและเป็นมิตร ตอบเป็นภาษาไทยเท่านั้น
วิเคราะห์ข้อมูลการออกกำลังกาย Squat นี้:
- จำนวนทั้งหมด: ${summary.totalReps}
- ทำถูก: ${summary.correctReps}
- ทำผิด: ${summary.incorrectReps}
- ความถูกต้อง: ${summary.accuracyPercent}%

จัดคำตอบเป็น 4 หัวข้อ: สรุปผล, จุดที่ทำได้ดี, จุดที่ควรปรับปรุง, คำแนะนำครั้งต่อไป
อย่าวินิจฉัยอาการบาดเจ็บ และเตือนให้หยุดหากรู้สึกเจ็บหรือเวียนศีรษะ
''';
    final response = await _client
        .post(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 700}
          }),
        )
        .timeout(const Duration(seconds: 30));

    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? ((decoded['error'] as Map<String, dynamic>?)?['message'] as String?)
          : null;
      throw Exception(message ?? 'AI request failed (${response.statusCode})');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('รูปแบบคำตอบจาก AI ไม่ถูกต้อง');
    }
    final candidates = decoded['candidates'] as List<dynamic>? ?? const [];
    final content = candidates.isEmpty
        ? null
        : (candidates.first as Map<String, dynamic>)['content'];
    final parts = content is Map<String, dynamic>
        ? content['parts'] as List<dynamic>? ?? const []
        : const <dynamic>[];
    final text = parts
        .whereType<Map<String, dynamic>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join('\n')
        .trim();
    if (text.isEmpty) throw const FormatException('AI ไม่ได้ส่งข้อความกลับมา');
    return text;
  }

  void close() => _client.close();
}