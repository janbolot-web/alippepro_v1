import 'dart:convert';
import 'package:alippepro_v1/models/calendar-models.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SectionService {
  // Базовый URL API
  static const String baseUrl =
      'http://localhost:5001/api'; // Для эмулятора Android
  // final String baseUrl = 'http://localhost:5000/api'; // Для веб или iOS симулятора

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

  // Получить все разделы с учетом userId
  Future<List<Section>> getAllSections() async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/diary?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> sectionsData = data['data'];

        List<Section> sections = sectionsData.map((sectionData) {
          // Преобразуем цвет из строки в объект Color
          Color sectionColor = _parseColor(sectionData['color']);

          // Преобразуем задачи
          List<Task> tasks = [];
          if (sectionData['tasks'] != null) {
            tasks = List<Task>.from(sectionData['tasks'].map((taskData) {
              return Task(
                id: taskData['id'],
                title: taskData['title'],
                date: DateTime.parse(taskData['date']),
                time: taskData['time'],
                isUrgent: taskData['isUrgent'] ?? false,
                completed: taskData['completed'] ?? false,
                completedAt: taskData['completedAt'] != null
                    ? DateTime.parse(taskData['completedAt'])
                    : null,
                sectionId: taskData['sectionId'],
                sectionTitle: taskData['sectionTitle'],
                sectionColor: _parseColor(taskData['sectionColor']),
              );
            }));
          }

          return Section(
            id: sectionData['id'],
            title: sectionData['title'],
            letter: sectionData['letter'],
            color: sectionColor,
            tasks: tasks,
          );
        }).toList();

        return sections;
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось загрузить разделы. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при получении разделов: $e');
      throw Exception('Ошибка при получении разделов: $e');
    }
  }

  // Получить раздел по ID
  Future<Section> getSectionById(String id) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/diary/$id?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> sectionData = data['data'];

        // Преобразуем цвет из строки в объект Color
        Color sectionColor = _parseColor(sectionData['color']);

        // Преобразуем задачи
        List<Task> tasks = [];
        if (sectionData['tasks'] != null) {
          tasks = List<Task>.from(sectionData['tasks'].map((taskData) {
            return Task(
              id: taskData['id'],
              title: taskData['title'],
              date: DateTime.parse(taskData['date']),
              time: taskData['time'],
              isUrgent: taskData['isUrgent'] ?? false,
              completed: taskData['completed'] ?? false,
              completedAt: taskData['completedAt'] != null
                  ? DateTime.parse(taskData['completedAt'])
                  : null,
              sectionId: taskData['sectionId'],
              sectionTitle: taskData['sectionTitle'],
              sectionColor: _parseColor(taskData['sectionColor']),
            );
          }));
        }

        return Section(
          id: sectionData['id'],
          title: sectionData['title'],
          letter: sectionData['letter'],
          color: sectionColor,
          tasks: tasks,
        );
      } else {
        throw Exception(
            'Не удалось загрузить раздел. Код: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении раздела: $e');
    }
  }

  // Создать новый раздел
  Future<Section> createSection(
      String title, String letter, Color color) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/diary/createSection'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'letter': letter,
          'color': _colorToHex(color),
          'userId': userId, // Добавляем userId
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> sectionData = data['data'];

        return Section(
          id: sectionData['id'],
          title: sectionData['title'],
          letter: sectionData['letter'],
          color: _parseColor(sectionData['color']),
          tasks: [],
        );
      } else {
        print('API ответ: ${response.body}');
        throw Exception(
            'Не удалось создать раздел. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при создании раздела: $e');
      throw Exception('Ошибка при создании раздела: $e');
    }
  }

  // Обновить задачу в разделе
  Future<Section> updateTask(
    String sectionId,
    String taskId,
    String title,
    DateTime date,
    String time,
    bool isUrgent,
  ) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Prepare the request data
      final Map<String, dynamic> data = {
        'title': title,
        'date': date.toIso8601String(),
        'time': time,
        'isUrgent': isUrgent,
        'userId': userId, // Добавляем userId
      };

      // Make the API call
      final response = await http.put(
        Uri.parse('$baseUrl/sections/$sectionId/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('API response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.body}');
      }

      // Parse the response and return the updated section
      final responseData = jsonDecode(response.body);

      // Since we can't use fromJson directly, we'll manually convert the section
      return _convertToSection(responseData['data']);
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  Section _convertToSection(Map<String, dynamic> json) {
    // Extract tasks and convert them to Task objects
    List<Task> tasks = [];
    if (json['tasks'] != null) {
      for (var taskJson in json['tasks']) {
        tasks.add(Task(
          id: taskJson['id'],
          title: taskJson['title'],
          date: taskJson['date'] != null
              ? DateTime.parse(taskJson['date'])
              : DateTime.now(),
          time: taskJson['time'] ?? '',
          isUrgent: taskJson['isUrgent'] ?? false,
          sectionId: json['id'],
          sectionTitle: json['title'],
          sectionColor: Color(
              int.parse(json['color'].toString().replaceAll('#', '0xff'))),
          completed: taskJson['completed'] ?? false,
        ));
      }
    }

    // Create and return a Section object
    return Section(
      id: json['id'],
      title: json['title'],
      letter: json['letter'],
      color: Color(int.parse(json['color'].toString().replaceAll('#', '0xff'))),
      tasks: tasks,
    );
  }

  // Удалить раздел
  Future<bool> deleteSection(String id) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      print('Deleting section with ID: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/diary/$id?userId=$userId'),
        headers: headers,
      );
      print('API response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка при удалении раздела: $e');
      throw Exception('Ошибка при удалении раздела: $e');
    }
  }

  // Добавить задачу в раздел
  Future<Section> addTaskToSection(
    String sectionId,
    String title,
    DateTime date,
    String time,
    bool isUrgent,
    String type,
  ) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/diary/$sectionId/tasks'),
        headers: headers,
        body: json.encode({
          'title': title,
          'type': type,
          'date': date.toIso8601String(),
          'time': time,
          'isUrgent': isUrgent,
          'completed': false, // Инициализируем как невыполненную
          'userId': userId, // Добавляем userId
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> sectionData = data['data'];

        // Преобразуем цвет из строки в объект Color
        Color sectionColor = _parseColor(sectionData['color']);

        // Преобразуем задачи
        List<Task> tasks = [];
        if (sectionData['tasks'] != null) {
          tasks = List<Task>.from(sectionData['tasks'].map((taskData) {
            return Task(
              id: taskData['id'],
              title: taskData['title'],
              date: DateTime.parse(taskData['date']),
              time: taskData['time'],
              isUrgent: taskData['isUrgent'] ?? false,
              completed: taskData['completed'] ?? false,
              completedAt: taskData['completedAt'] != null
                  ? DateTime.parse(taskData['completedAt'])
                  : null,
              sectionId: taskData['sectionId'],
              sectionTitle: taskData['sectionTitle'],
              sectionColor: _parseColor(taskData['sectionColor']),
            );
          }));
        }

        return Section(
          id: sectionData['id'],
          title: sectionData['title'],
          letter: sectionData['letter'],
          color: sectionColor,
          tasks: tasks,
        );
      } else {
        print('API response: ${response.body}');
        throw Exception(
            'Не удалось добавить задачу. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при добавлении задачи: $e');
      throw Exception('Ошибка при добавлении задачи: $e');
    }
  }

  // Обновить статус выполнения задачи
  Future<Task> updateTaskCompletionStatus(
    String sectionId,
    String taskId,
    bool completed,
  ) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/diary/$sectionId/tasks/$taskId/complete'),
        headers: headers,
        body: json.encode({
          'completed': completed,
          'userId': userId, // Добавляем userId
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> taskData = data['data'];

        return Task(
          id: taskData['id'],
          title: taskData['title'],
          date: DateTime.parse(taskData['date']),
          time: taskData['time'],
          isUrgent: taskData['isUrgent'] ?? false,
          completed: taskData['completed'] ?? false,
          completedAt: taskData['completedAt'] != null
              ? DateTime.parse(taskData['completedAt'])
              : null,
          sectionId: taskData['sectionId'],
          sectionTitle: taskData['sectionTitle'],
          sectionColor: _parseColor(taskData['sectionColor']),
        );
      } else {
        print('Ошибка API: ${response.body}');
        throw Exception(
            'Не удалось обновить статус задачи. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Исключение при обновлении статуса задачи: $e');
      throw Exception('Ошибка при обновлении статуса задачи: $e');
    }
  }

  // Метод для получения списка задач по дате
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      // Получаем все разделы для пользователя
      final sections = await getAllSections();

      // Список для хранения всех задач на указанную дату
      List<Task> tasksForDate = [];

      // Перебираем разделы и собираем все задачи на указанную дату
      for (var section in sections) {
        final tasksOnDate = section.tasks
            .where((task) =>
                task.date.year == date.year &&
                task.date.month == date.month &&
                task.date.day == date.day)
            .toList();

        tasksForDate.addAll(tasksOnDate);
      }

      // Сортируем задачи по времени
      tasksForDate.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));

      return tasksForDate;
    } catch (e) {
      print('Ошибка при получении задач по дате: $e');
      throw Exception('Ошибка при получении задач по дате: $e');
    }
  }

  // Вспомогательный метод для преобразования HEX цвета в объект Color
  Color _parseColor(String colorString) {
    // Если цвет уже в формате #RRGGBB или #AARRGGBB
    if (colorString.startsWith('#')) {
      return Color(int.parse('0xFF' + colorString.substring(1)));
    }

    // Если цвет в формате MaterialColor.value
    if (colorString.startsWith('0x')) {
      return Color(int.parse(colorString));
    }

    // По умолчанию возвращаем синий цвет
    return Colors.blue;
  }

  // Вспомогательный метод для преобразования Color в HEX строку
  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  // Удалить задачу из раздела
  Future<bool> deleteTask(String sectionId, String taskId) async {
    try {
      // Получаем userId
      final String? userId = await _getUserId();
      if (userId == null) {
        throw Exception('Пользователь не авторизован');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/diary/$sectionId/tasks/$taskId?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Ошибка при удалении задачи: ${response.body}');
        throw Exception(
            'Не удалось удалить задачу. Код: ${response.statusCode}');
      }
    } catch (e) {
      print('Исключение при удалении задачи: $e');
      throw Exception('Ошибка при удалении задачи: $e');
    }
  }

  // Вспомогательный метод для удаления задачи с обработкой ошибок и UI-обратной связью
  Future<bool> deleteTaskWithFeedback(
    BuildContext context,
    String sectionId,
    String taskId,
    String taskTitle,
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
                Text("Удаление задачи..."),
              ],
            ),
          );
        },
      );

      // Выполняем запрос к API
      final result = await deleteTask(sectionId, taskId);

      // Закрываем диалог с индикатором загрузки
      Navigator.of(context, rootNavigator: true).pop();

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Задача "$taskTitle" успешно удалена'),
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
          content: Text('Ошибка при удалении задачи: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return false;
    }
  }
}
