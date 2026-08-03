import 'package:dio/dio.dart';
import 'dart:convert';

// أسماء النماذج المعتمدة في التطبيق
enum AIModel { deepseek, gemini, claude, gpt }

class AIService {
  final Dio _dio = Dio();

  // الرابط الخاص بخادمك في Vercel
  static const String _apiUrl = 'https://student-bot-ecru.vercel.app/api/chat';

  // دالة إرسال الرسائل مع السجل، الصور، وموجه النظام لزيادة الذكاء
  Future<String> getChatResponseWithHistory({
    required List<Map<String, dynamic>> messages,
    required AIModel model,
    String? base64Image,
  }) async {
    try {
      String providerName = 'gemini';

      switch (model) {
        case AIModel.gemini:
          providerName = 'gemini';
          break;
        case AIModel.deepseek:
          providerName = 'sambanova';
          break;
        case AIModel.claude:
        case AIModel.gpt:
          providerName = 'openrouter';
          break;
      }

      // 1. إضافة موجه النظام (System Prompt) في البداية لكي يتصرف البوت كمحترف برمجة وأكاديمي
      List<Map<String, dynamic>> formattedMessages = [
        {
          'role': 'system',
          'content': 'أنت مساعد ذكاء اصطناعي خبير في البرمجة، تطوير تطبيقات فلاتر (Flutter)، وتحليل الصور البرمجية والأخطاء بدقة. مهمتك تقديم حلول برمجية نظيفة، شرح الأسباب، وتذكر دائماً سياق المحادثة والرد باللغة العربية بأسلوب احترافي ومباشر.'
        },
        ...messages.map((msg) {
          return {
            'role': msg['role'], // 'user' أو 'assistant'
            'content': msg['content'],
          };
        }).toList()
      ];

      // 2. تجهيز البيانات للإرسال
      Map<String, dynamic> requestData = {
        'messages': formattedMessages,
        'provider': providerName,
      };

      if (base64Image != null) {
        requestData['image'] = base64Image;
      }

      // 3. إرسال الطلب إلى الخادم
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        return response.data['reply'] ?? "عذراً، لم أتمكن من صياغة رد.";
      } else {
        return "عذراً، الخادم لا يستجيب حالياً (الكود: ${response.statusCode})";
      }
    } catch (e) {
      return 'خطأ في الاتصال: تأكد من اتصالك بالإنترنت أو من حالة الخادم.';
    }
  }

  // الدالة القديمة للتوافقية
  Future<String> getChatResponse(
      String message,
      AIModel model, {
        String? base64Image,
      }) async {
    return getChatResponseWithHistory(
      messages: [{'role': 'user', 'content': message}],
      model: model,
      base64Image: base64Image,
    );
  }
}

