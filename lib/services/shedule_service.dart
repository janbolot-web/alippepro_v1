// lib/screens/calendar/service/shedule.dart

import 'dart:convert';
import 'package:alippepro_v1/models/calendar-models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleService {
  // Базовый URL для API
  static const String baseUrl =
      'http://localhost:5001/api'; // Для Android эмулятора
  // static const String baseUrl = 'http://localhost:3000/api'; // Для iOS симулятора или веб

  // Заголовки для запросов
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Получение userId из localStorage
   Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final response = prefs.getString('user');
    var responseData = jsonDecode(response!);

    return responseData['id'];
  }

  // Получить все элементы расписания
  Future<List<ScheduleItem>> getAllScheduleItems() async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/schedules?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> itemsData = data['data'];

        return List<ScheduleItem>.from(
            itemsData.map((item) => _parseScheduleItem(item)));
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось загрузить расписание. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении расписания: $e');
      throw Exception('Ошибка при получении расписания: $e');
    }
  }

  // Получить расписание по дате
  Future<List<ScheduleItem>> getScheduleByDate(DateTime date) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final String formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final response = await http.get(
        Uri.parse('$baseUrl/schedules/date/$formattedDate?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> itemsData = data['data'];

        return List<ScheduleItem>.from(
            itemsData.map((item) => _parseScheduleItem(item)));
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось загрузить расписание на дату. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении расписания по дате: $e');
      throw Exception('Ошибка при получении расписания по дате: $e');
    }
  }

  // Добавить элемент расписания
  Future<ScheduleItem> addScheduleItem({
    required String subject,
    required String classInfo,
    required String timeRange,
    required DateTime date,
    String? sectionId,
  }) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/schedules'),
        headers: headers,
        body: json.encode({
          'subject': subject,
          'classInfo': classInfo,
          'timeRange': timeRange,
          'date': date.toIso8601String(),
          'sectionId': sectionId,
          'type': 'lesson',
          'completed': false, // Initialize as not completed
          'userId': userId, // Добавляем userId
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseScheduleItem(data['data']);
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось добавить расписание. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при добавлении расписания: $e');
      throw Exception('Ошибка при добавлении расписания: $e');
    }
  }

  // Обновить элемент расписания
  Future<ScheduleItem> updateScheduleItem({
    required String id,
    required String subject,
    required String classInfo,
    required String timeRange,
    required DateTime date,
    bool isTask = false,
    bool isUrgent = false,
  }) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      // Prepare the request data
      final Map<String, dynamic> data = {
        'subject': subject,
        'classInfo': classInfo,
        'timeRange': timeRange,
        'date': date.toIso8601String(),
        'isTask': isTask,
        'isUrgent': isUrgent,
        'userId': userId, // Добавляем userId
      };

      // Make the API call
      final response = await http.put(
        Uri.parse('$baseUrl/schedules/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        print('API ответ: ${response.body}');
        throw Exception('Failed to update schedule item: ${response.body}');
      }

      // Parse and return the updated item
      final responseData = jsonDecode(response.body);
      return ScheduleItem.fromJson(responseData['data']);
    } catch (e) {
      print('Error updating schedule item: $e');
      throw Exception('Failed to update schedule item: $e');
    }
  }

  // Обновить статус выполнения для элемента расписания
  Future<ScheduleItem> updateScheduleItemCompletionStatus(
      String id, bool completed) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/schedules/$id/complete'),
        headers: headers,
        body: json.encode({
          'completed': completed,
          'userId': userId, // Добавляем userId
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseScheduleItem(data['data']);
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось обновить статус задачи. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при обновлении статуса задачи: $e');
      throw Exception('Ошибка при обновлении статуса задачи: $e');
    }
  }

  // Удалить элемент расписания
  Future<bool> deleteScheduleItem(String id) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/schedules/$id?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Ошибка при удалении элемента расписания: ${response.body}');
        throw Exception(
            'Не удалось удалить элемент расписания. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Исключение при удалении элемента расписания: $e');
      throw Exception('Ошибка при удалении элемента расписания: $e');
    }
  }

  // Вспомогательный метод для преобразования JSON в объект ScheduleItem
  ScheduleItem _parseScheduleItem(Map<String, dynamic> data) {
    return ScheduleItem(
      id: data['_id'] ?? data['id'],
      subject: data['subject'],
      classInfo: data['classInfo'],
      time: data['timeRange'],
      date: DateTime.parse(data['date']),
      isTask: data['type'] == 'task',
      completed: data['completed'] ?? false,
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'])
          : null,
      sectionId: data['sectionId'],
    );
  }

  // Вспомогательный метод с обработкой ошибок и UI-обратной связью
  Future<bool> deleteScheduleItemWithFeedback(
    BuildContext context,
    String id,
    String subject,
  ) async {
    try {
      // Показываем диалог с индикатором загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Удаление предмета..."),
              ],
            ),
          );
        },
      );

      // Выполняем запрос к API
      final result = await deleteScheduleItem(id);

      // Закрываем диалог с индикатором загрузки
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Предмет "$subject" успешно удален из расписания'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return result;
    } catch (e) {
      // Закрываем диалог с индикатором загрузки, если он открыт
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при удалении предмета: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return false;
    }
  }

  // Преобразование цвета из строки в объект Color
  Color _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      return Color(int.parse('0xFF${colorString.substring(1)}'));
    } else if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    }
    return Colors.blue; // Цвет по умолчанию
  }
}