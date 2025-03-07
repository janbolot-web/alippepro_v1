import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:chatgpt_completions/chatgpt_completions.dart';

streamGptPrompt() async {
  ChatGPTCompletions.instance
      .initialize(apiKey: 'ghu_flwC3qPtwVTXX6VkxSLaxqJX3xIU1W2QexTG');
  String responseWithStream = "";
  StreamSubscription? responseSubscription;

  await ChatGPTCompletions.instance.textCompletions(
    TextCompletionsParams(
      // prompt: "What's Flutter?",
      messagesTurbo: [
        MessageTurbo(
          role: TurboRole.user,
          content: "Where is the tallest building in the world?",
        ),
      ],
      model: GPTModel.gpt3p5turbo,
    ),
    onStreamValue: (characters) {
      responseWithStream += characters;
      print(characters);
    },
    onStreamCreated: (subscription) {
      responseSubscription = subscription;
    },
    // Debounce 100ms for receive next value
    debounce: const Duration(milliseconds: 100),
  );
}

String sanitizeJsonString(String input) {
  // Убираем недопустимые символы, включая не отображаемые и обрезанные строки
  return input.replaceAll(RegExp(r'[\u0000-\u001F]'), '').trim();
}

List<Map<String, dynamic>> updateSelectedQuestionTimer(
    List<Map<String, dynamic>> questions, newTimerValue) {
  for (var question in questions) {
    question['time'] = newTimerValue;
  }
  return questions;
}

final dio = Dio();

Future<bool> checkSubscription(String userId) async {
  try {
    final response = await dio.post(
      '${Constants.uri}/checkSubscription',
      data: {'userId': userId},
    );
    print(response.data['hasValidSubscription'] as bool);
    return response.data['hasValidSubscription'] as bool;
  } catch (e) {
    throw Exception('Failed to check subscription: $e');
  }
}

saveResponse({
  required userId,
  required response,
}) async {
  try {
    final savedResponse = await dio.post(
      '${Constants.uri}/saveAiQuiz',
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

Future<int> sendMessageToChatGPT(BuildContext context, String message,
    socketMethods, selectedQuestionTimer, userId) async {
  const apiUrl =
      'https://workers-playground-shiny-haze-2f78jjjj.janbolotcode.workers.dev/v1/chat/completions';
  const bearerToken = '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';
  var header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $bearerToken', // Добавляем токен
  };
  try {
    final hasValidSubscription = await checkSubscription(userId);

    if (!hasValidSubscription) {
      throw Exception('Недостаточно AI-токенов');
    }
    // Отправка сообщения на сервер
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: header,
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": message}
        ],
        // "temperature": 0.7
      }),
    );
    // Проверка успешного ответа
    if (response.statusCode == 200) {
      // final rawData = jsonDecode(utf8.decode(response.bodyBytes));
      // Сырой ответ
      var rawData = utf8.decode(response.bodyBytes);

      // Парсинг JSON с проверкой
      dynamic data;
      try {
        data = jsonDecode(rawData);

        final savedResponse = await saveResponse(
          userId: userId,
          response: jsonDecode(rawData),
        );
        saveDataToLocalStorage('user', jsonEncode(savedResponse['userData']));
        print('response[userData] ${savedResponse['userData']}');

        data = data['choices']?[0]?['message']?['content'];
      } catch (e) {
        print('Ошибка парсинга JSON: $e');
        throw Exception('Некорректные данные JSON: $rawData');
      }

      List<Map<String, dynamic>> questions;

      // Проверяем формат данных
      if (data.trim().startsWith('`')) {
        final parsed = jsonDecode(
          data.trim().substring(7, data.trim().length - 3),
        );
        if (parsed is Map && parsed.containsKey('questions')) {
          questions = List<Map<String, dynamic>>.from(parsed['questions']);
        } else {
          throw Exception("Parsed data does not contain questions: $parsed");
        }
      } else {
        final parsed = jsonDecode(data.trim());
        if (parsed is Map && parsed.containsKey('questions')) {
          questions = List<Map<String, dynamic>>.from(parsed['questions']);
        } else {
          throw Exception("Parsed data does not contain questions: $parsed");
        }
      }

      questions = updateSelectedQuestionTimer(questions, selectedQuestionTimer);
      // Перемешивание ответов
      void shuffleAnswers(List<Map<String, dynamic>> questions) {
        final random = Random();

        for (var question in questions) {
          if (question["answers"] is List) {
            List<Map<String, dynamic>> answers =
                List<Map<String, dynamic>>.from(question["answers"]);
            answers.shuffle(random);
            question["answers"] = answers;
          } else {
            throw Exception("Invalid answers format: ${question["answers"]}");
          }
        }
      }

      shuffleAnswers(questions);

      print('Данные после перемешивания: $questions');

      // try {
      //   final responseGpt = await http.post(
      //     Uri.parse('${Constants.uri}/gptRequest'),
      //     headers: <String, String>{
      //       'Content-Type': 'application/json; charset=UTF-8',
      //     },
      //     body: jsonEncode({"questions": questions, "userId": userId}),
      //   );
      //   final responseData = jsonDecode(responseGpt.body);

      //   setState() {
      //     saveDataToLocalStorage('user', responseData);
      //   }
      // } catch (e) {
      //   print(e);
      // }
      // Передаем данные в RoomDataProvider
      Provider.of<RoomDataProvider>(context, listen: false)
          .updateChatGPTData({"questions": questions});

      return 200;
    } else {
      print('Ошибка сервера: ${response.statusCode}');
      return 400;
    }
  } catch (e) {
    print('Ошибка: $e');
    return 500;
  }
}

// Future sendMessageToChatGPT(BuildContext context, String message, socketMethods,
//     selectedQuestionTimer, userId) async {
//   try {
//     final responseGpt = await http.post(
//       Uri.parse('${Constants.uri}/sendMessageToChatGPT'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode({"message": message, "userId": userId}),
//     );
//     final responseData = jsonDecode(responseGpt.body);
//     // print(responseData['user']['subscription'][0]);
//     if (responseGpt.statusCode == 200) {
//       Provider.of<RoomDataProvider>(context, listen: false)
//           .updateChatGPTData({"questions": responseData['questions']});

//       print(responseData['UserData']);
//       saveDataToLocalStorage('user', jsonEncode(responseData['UserData']));

//       return responseGpt.statusCode;
//     }
//     //   // print();
//     //   var response = {
//     //     'statusCode': responseGpt.statusCode,
//     //     'message': responseData['message']
//     //   };
//     //   return response;
//     // }
//     // var response = await getDataFromLocalStorage('user');
//     // print(response);
//   } catch (e) {
//     print(e);
//   }
// }

addToChatHistory(String data) {
  if (data.contains("content")) {
    ContentResponse contentResponse =
        ContentResponse.fromJson(jsonDecode(data));

    if (contentResponse.choices != null &&
        contentResponse.choices![0].delta != null &&
        contentResponse.choices![0].delta!.content != null) {
      String content = contentResponse.choices![0].delta!.content!;
      print(content);
      // FFAppState().updateChatHistoryAtIndex(FFAppState().chatHistory.length - 1,
      //     (e) {
      //   return e..content = "${e.content}$content";
      // });
      // callbackAction();
    }
  }
}

class ContentResponse {
  String? id;
  String? object;
  int? created;
  String? model;
  List<Choices>? choices;

  ContentResponse(
      {this.id, this.object, this.created, this.model, this.choices});

  ContentResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    object = json['object'];
    created = json['created'];
    model = json['model'];
    if (json['choices'] != null) {
      choices = <Choices>[];
      json['choices'].forEach((dynamic v) {
        choices!.add(Choices.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['object'] = object;
    data['created'] = created;
    data['model'] = model;
    if (choices != null) {
      data['choices'] = choices!
          .map<Map<String, dynamic>>((Choices choice) => choice.toJson())
          .toList(); // Added .toList() and correct mapping
    }
    return data;
  }
}

class Choices {
  int? index;
  Delta? delta;
  String? finishReason;

  Choices({this.index, this.delta, this.finishReason});

  Choices.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    delta = json['delta'] != null ? Delta.fromJson(json['delta']) : null;
    finishReason = json['finish_reason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    if (delta != null) {
      data['delta'] = delta!.toJson();
    }
    data['finish_reason'] = finishReason;
    return data;
  }
}

class Delta {
  String? content;

  Delta({this.content});

  Delta.fromJson(Map<String, dynamic> json) {
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    return data;
  }
}
