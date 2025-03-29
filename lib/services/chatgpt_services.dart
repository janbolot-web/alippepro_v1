// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/models/chatgpt.dart';
import 'package:alippepro_v1/providers/chatgpt_provider.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:chatgpt_completions/chatgpt_completions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Сделай Классический план урока, 9-класс, предмет - Химия, Тип урока - Стандартный,  Тема урока -H2O. На кыргызском языке, 4-5 лист

class ChatgptService {
  final dio = Dio();
  final String baseUrl = Constants.uri;

  Future<bool> checkSubscription(String userId) async {
    try {
      final response = await dio.post(
        '$baseUrl/checkSubscription',
        data: {'userId': userId},
      );
      print(response.data['hasValidSubscription'] as bool);
      return response.data['hasValidSubscription'] as bool;
    } catch (e) {
      throw Exception('Failed to check subscription: $e');
    }
  }

  fetchChatGptResponse({
    context,
    required message,
    required userId,
  }) async {
    try {
      // First check subscription
      var chatgptProvider =
          Provider.of<ChatgptProvider>(context, listen: false);

      var language = message['selectedLanguages'] == "Кыргызча"
          ? 'кыргыз'
          : message['selectedLanguages'] == "Русский"
              ? 'русском'
              : "английском";

      var selectedClass = message['selectedClass'];
      if (language == 'русском') {
        print(message['selectedClass'] == ('2-4 жаш'));
        if (message['selectedClass'] == ('0-2 жаш')) {
          selectedClass = '0-2 летних детей';
        } else if (message['selectedClass'] == ('2-4 жаш')) {
          selectedClass = '2-4 летних детей';
        } else if (message['selectedClass'] == ('4-6 жаш')) {
          selectedClass = '4-6 летних детей';
        }
      }

      Chatgpt chatgptmessage = language == 'русском'
          ? Chatgpt(
              response:
                  "Создай подробный, интересный и оригинальный классический план урока с таблицами для $selectedClass по предмету ${message['selectedSubject']} с использованием метода ${message['selectedMethod']} на тему ${message['subject']} на $language языке, только на $language языке, объемом 4-5 страниц, без лишних слов и текстов, только четкий и структурированный план.")
          : Chatgpt(
              response:
                  "$selectedClass үчүн ${message['selectedSubject']} сабагынан ${message['selectedMethod']} ыкмасын колдонуу менен ${message['subject']} темасында толук, кызыктуу жана оригиналдуу классикалык сабак планы түзүлсүн. Сабак планы $language тилинде гана болушу керек, 4-5 беттен турушу керек. Сабак планы так жана түзүмдөлгөн форматта берилсин: негизги бөлүмдөр ачык жана логикалык иретте болсун, таблицалар жана тизмектер колдонулсун, эгер алар маалыматты жакшыраак көрсөтсө, башкы бөлүмдөр жагымдуу жана көзгө көрүнүктүү форматта берилсин, калың шрифт, бөлүмдөр үчүн чоңураак шрифттер жана башка форматтоо колдонулсун, ар бир бөлүм так бөлүнүп, сапаттуу сабак планына ылайыктуу болсун. Бул сабак планы мектептерде колдонууга ылайыктуу болууга тийиш.");

      final hasValidSubscription = await checkSubscription(userId);

      if (!hasValidSubscription) {
        throw Exception('Недостаточно AI-токенов');
      }

      print('chatgptmessage.response ${chatgptmessage.response}');

      // Properly formatted request body for ChatGPT API
      final requestBody = {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'user',
            'content': chatgptmessage.response,
          }
        ],
      };

      // Make request to ChatGPT
      final chatGptResponse = await http.post(
        Uri.parse(
            'https://workers-playground-shiny-haze-2f78jjjj.janbolotcode.workers.dev/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ghu_gJy9EnyGfc0Qn7jfPXgcZMAKKbHxn24QgISz',
        },
        body: jsonEncode(requestBody),
      );

      if (chatGptResponse.statusCode != 200) {
        throw Exception(
          'API returned status code ${chatGptResponse.statusCode}: ${chatGptResponse.body}',
        );
      }

      final response = jsonDecode(utf8.decode(chatGptResponse.bodyBytes));
      // print('!!!!!!!!!!!! ${response['choices'][0]['message']['content']}');
      // Save response to database
      final savedResponse = await saveResponse(
        userId: userId,
        response: response,
      );

      Map<String, dynamic> ne = {};
      ne['response'] = response['choices'][0]['message']['content'];
      var responseData = jsonEncode(ne);
      chatgptProvider.setChatgpt(responseData);

      saveDataToLocalStorage('user', jsonEncode(savedResponse['userData']));
      print('response[userData] ${savedResponse['userData']}');
      return chatGptResponse.statusCode;

      // return {
      //   'response': responseData['choices'][0]['message']['content'],
      //   'userData': savedResponse['userData'],
      //   'statusCode': chatGptResponse.statusCode,
      // };
    } catch (e) {
      print('Error details: $e');
      throw Exception('Error fetching ChatGPT response: $e');
    }
  }

  Future<Map<String, dynamic>> saveResponse({
    required String userId,
    required Map<String, dynamic> response,
  }) async {
    try {
      final savedResponse = await dio.post(
        '$baseUrl/saveAiResponse',
        data: {
          'userId': userId,
          'response': response,
        },
      );

      return savedResponse.data;
    } catch (e) {
      throw Exception('Failed to save response: $e');
    }
  }

  clearLessonPlan({required BuildContext context}) async {
    try {
      var chatgptProvider =
          Provider.of<ChatgptProvider>(context, listen: false);
      Map<String, dynamic> ne = {};
      ne['response'] = '';
      var responseData = jsonEncode(ne);
      chatgptProvider.setChatgpt(responseData);
    } catch (e) {}
  }

  fetchLessonPlan({required BuildContext context, prompt, userId}) async {
    try {
      var chatgptProvider =
          Provider.of<ChatgptProvider>(context, listen: false);

      var language =
          prompt['selectedLanguages'] == "Кыргызча" ? 'кыргыз' : "русском";

      Chatgpt chatgptPrompt = language == 'русском'
          ? Chatgpt(
              response:
                  "Создай подробный, интересный и оригинальный классический план урока с таблицами для ${prompt['selectedClass']} по предмету ${prompt['selectedSubject']} с использованием метода ${prompt['selectedMethod']} на тему ${prompt['subject']} на $language языке, только на $language языке, объемом 4-5 страниц, без лишних слов и текстов, только четкий и структурированный план.")
          : Chatgpt(
              response:
                  "${prompt['selectedClass']} үчүн ${prompt['selectedSubject']} сабагынан ${prompt['selectedMethod']} ыкмасын колдонуу менен ${prompt['subject']} темасында толук, кызыктуу жана оригиналдуу классикалык сабак планы түзүлсүн. Сабак планы $language тилинде гана болушу керек, 4-5 беттен турушу керек. Сабак планы так жана түзүмдөлгөн форматта берилсин: негизги бөлүмдөр ачык жана логикалык иретте болсун, таблицалар жана тизмектер колдонулсун, эгер алар маалыматты жакшыраак көрсөтсө, башкы бөлүмдөр жагымдуу жана көзгө көрүнүктүү форматта берилсин, калың шрифт, бөлүмдөр үчүн чоңураак шрифттер жана башка форматтоо колдонулсун, ар бир бөлүм так бөлүнүп, сапаттуу сабак планына ылайыктуу болсун. Бул сабак планы мектептерде колдонууга ылайыктуу болууга тийиш.");

      var data = {'message': chatgptPrompt.response, 'userId': userId};
      var chatgpt = await http.post(Uri.parse('${Constants.uri}/fetchChatgpt'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(data));

      var response = jsonDecode(chatgpt.body);
      Map<String, dynamic> ne = {};
      ne['response'] = response['response'];
      var responseData = jsonEncode(ne);
      chatgptProvider.setChatgpt(responseData);
      // print('response ${response['userData']}');
      // print('response ${response['userData'].runtimeType}');
      // saveDataToLocalStorage('user', jsonEncode(responseData['UserData']));

      saveDataToLocalStorage('user', jsonEncode(response['userData']));

      return chatgpt.statusCode;
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  Future<String?> downloadFile(
      String format, String markdownText, BuildContext context,
      {required ValueNotifier<double> progressNotifier}) async {
    final Dio dio = Dio();

    try {
      print(format);
      final response = await http.post(
        Uri.parse('${Constants.uri}/$format'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'markdown': markdownText}),
      );

      var responseToJson = jsonDecode(response.body);

      print('responseToJson: $responseToJson');

      if (response.statusCode == 200) {
        var responseToJson = jsonDecode(response.body);
        String fileUrl = responseToJson['fileUrl'];
        String fileExtension =
            fileUrl.split('.').last; // Extracting file extension
        print('File URL: $fileUrl');

        final Directory dir = await getApplicationDocumentsDirectory();
        String formattedDate = DateTime.now().toString().replaceAll('.', '-');

        final String filePath =
            "${dir.path}/План-конспекты-$formattedDate.$fileExtension";

        await dio.download(
          fileUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              progressNotifier.value = received / total;
            }
          },
        );
        return filePath;

        // Show a success message after file download
      } else {
        print('Error downloading file: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint("Download error: $e");
      return null;
    }
    return null;
  }

  // Future<String?> downloadFile(
  //     String format, String markdownText, BuildContext context,
  //     {required ValueNotifier<double> progressNotifier}) async {
  //   final Dio dio = Dio();

  //   try {
  //     print(format);
  //     final response = await http.post(
  //       Uri.parse('${Constants.uri}/$format'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'markdown': markdownText}),
  //     );

  //     var responseToJson = jsonDecode(response.body);

  //     print('responseToJson: $responseToJson');

  //     if (response.statusCode == 200) {
  //       var responseToJson = jsonDecode(response.body);
  //       String fileUrl = responseToJson['fileUrl'];
  //       String fileExtension =
  //           fileUrl.split('.').last; // Extracting file extension
  //       print('File URL: $fileUrl');

  //       final Directory dir = await getApplicationDocumentsDirectory();
  //       String formattedDate = DateTime.now().toString().replaceAll('.', '-');

  //       final String filePath =
  //           "${dir.path}/План-конспекты-${formattedDate}.$fileExtension";

  //       await dio.download(
  //         fileUrl,
  //         filePath,
  //         onReceiveProgress: (received, total) {
  //           if (total != -1) {
  //             progressNotifier.value = received / total;
  //           }
  //         },
  //       );
  //       return filePath;

  //       // Show a success message after file download
  //     } else {
  //       print('Error downloading file: ${response.reasonPhrase}');
  //     }
  //   } catch (e) {
  //     debugPrint("Download error: $e");
  //     return null;
  //   }
  //   return null;
  // }

  fetchQuiz({required BuildContext context, prompt}) async {
    try {
      var quizProvider = Provider.of<QuizProvider>(context, listen: false);

      var language =
          prompt['selectedLanguages'] == "Кыргызча" ? 'кыргыз' : "русском";

      Chatgpt chatgptPrompt = language == 'русском'
          ? Chatgpt(
              response:
                  'Создай тест, предмет: математика, класс: 7, количество вопросов: 3,  на кыргызском языке. тема: Уравнение Верни как json, без лишних текстов , только тест и правильный ответ Формат: "questions": [ { "question": "//example question", "answers": [ {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct} ], "time": 20}]')
          : Chatgpt(
              response:
                  'Создай тест, предмет: математика, класс: 7, количество вопросов: 3,  на кыргызском языке. тема: Уравнение. Верни как json, без лишних текстов , только тест и правильный ответ Формат: "questions": [ { "question": "//example question", "answers": [ {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct} ], "time": 20}]');

      // var content = {"content": ""};
// http://10.0.2.2:5001/
      var quiz = await http.post(Uri.parse('${Constants.uri}/fetchChatgpt'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: chatgptPrompt.toJson());

      var response = jsonDecode(quiz.body);
      Map<String, dynamic> ne = {};
      ne['response'] = response['response'];
      var responseData = jsonEncode(ne);
      quizProvider.setQuiz(responseData);
      saveDataToLocalStorage('quiz', jsonEncode(responseData));
      return jsonDecode(response['response']);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  sendStreamMessage() async {
    // Text completions without stream response (stream: false)
    String? responseWithoutStream =
        await ChatGPTCompletions.instance.textCompletions(TextCompletionsParams(
      prompt: "What's Flutter?",
      model: GPTModel.gpt3p5turbo,
      stream: true,
    ));

    print("OpenAI: $responseWithoutStream");

    print("\n\n-> Generating answer with stream...");
    await Future.delayed(const Duration(seconds: 2));
  }
}
