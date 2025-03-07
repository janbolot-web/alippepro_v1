// import 'dart:convert';
// import 'dart:math';
// import 'package:alippepro_v1/providers/room_data_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// String sanitizeJsonString(String input) {
//   // Убираем недопустимые символы, включая не отображаемые и обрезанные строки
//   return input.replaceAll(RegExp(r'[\u0000-\u001F]'), '').trim();
// }

// Future<int> sendMessageToChatGPT(
//     BuildContext context, String message, socketMethods) async {
//   const apiUrl = 'http://meet.alippepro.ru/messages';

//   try {
//     // Отправка сообщения на сервер
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode({"text": message}),
//     );

//     // Проверка успешного ответа
//     if (response.statusCode == 200) {
//       // Сырой ответ
//       final rawData = utf8.decode(response.bodyBytes);

//       // Очищаем строку
//       final sanitizedData = sanitizeJsonString(rawData);

//       // Парсинг JSON с проверкой
//       dynamic data;
//       try {
//         data = jsonDecode(sanitizedData);
//       } catch (e) {
//         print('Ошибка парсинга JSON: $e');
//         throw Exception('Некорректные данные JSON: $sanitizedData');
//       }

//       List<Map<String, dynamic>> questions;

//       // Проверяем формат данных
//       if (data['data'].trim().startsWith('`')) {
//         final parsed = jsonDecode(
//           data['data'].trim().substring(7, data['data'].trim().length - 3),
//         );
//         if (parsed is Map && parsed.containsKey('questions')) {
//           questions = List<Map<String, dynamic>>.from(parsed['questions']);
//         } else {
//           throw Exception("Parsed data does not contain questions: $parsed");
//         }
//       } else {
//         final parsed = jsonDecode(data['data'].trim());
//         if (parsed is Map && parsed.containsKey('questions')) {
//           questions = List<Map<String, dynamic>>.from(parsed['questions']);
//         } else {
//           throw Exception("Parsed data does not contain questions: $parsed");
//         }
//       }

//       print('Данные до перемешивания: $questions');

//       // Перемешивание ответов
//       void shuffleAnswers(List<Map<String, dynamic>> questions) {
//         final random = Random();

//         for (var question in questions) {
//           if (question["answers"] is List) {
//             List<Map<String, dynamic>> answers =
//                 List<Map<String, dynamic>>.from(question["answers"]);
//             answers.shuffle(random);
//             question["answers"] = answers;
//           } else {
//             throw Exception("Invalid answers format: ${question["answers"]}");
//           }
//         }
//       }

//       shuffleAnswers(questions);

//       print('Данные после перемешивания: $questions');

//       // Передаем данные в RoomDataProvider
//       Provider.of<RoomDataProvider>(context, listen: false)
//           .updateChatGPTData({"questions": questions});

//       return 200;
//     } else {
//       print('Ошибка сервера: ${response.statusCode}');
//       return 400;
//     }
//   } catch (e) {
//     print('Ошибка: $e');
//     return 500;
//   }
// }
