// lib/screens/calendar/models/calendar_models.dart
import 'package:flutter/material.dart';

class Section {
  final String id;
  final String title;
  final String letter;
  final Color color;
  final List<Task> tasks;

  Section({
    required this.id,
    required this.title,
    required this.letter,
    required this.color,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];
  
  // Метод для обновления задачи в списке
  Section copyWithUpdatedTask(Task updatedTask) {
    final newTasks = tasks.map((task) {
      if (task.id == updatedTask.id) {
        return updatedTask;
      }
      return task;
    }).toList();
    
    return Section(
      id: id,
      title: title,
      letter: letter,
      color: color,
      tasks: newTasks,
    );
  }
}

class Task {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final bool isUrgent;
  final bool completed;
  final DateTime? completedAt;
  final String sectionId;
  final String sectionTitle;
  final Color sectionColor;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.isUrgent,
    this.completed = false,
    this.completedAt,
    required this.sectionId,
    required this.sectionTitle,
    required this.sectionColor,
  });

  // Метод для обновления статуса выполнения
  Task copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? time,
    bool? isUrgent,
    bool? completed,
    DateTime? completedAt,
    String? sectionId,
    String? sectionTitle,
    Color? sectionColor,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      isUrgent: isUrgent ?? this.isUrgent,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      sectionId: sectionId ?? this.sectionId,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      sectionColor: sectionColor ?? this.sectionColor,
    );
  }

  // Метод для получения DateTime из строки времени
  DateTime getDateTime() {
    // Проверяем, содержит ли строка формат с диапазоном (например, "00 - 00")
    if (time.contains('-')) {
      // Разбиваем строку по дефису и берем первую часть (начало времени)
      final timeParts = time.split('-');
      final startTimePart = timeParts[0].trim();

      // Теперь разбиваем время на часы и минуты
      final parts = startTimePart.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } else {
      // Стандартный формат без диапазона
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    }
  }
  
  // Фабричный метод для создания из JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      isUrgent: json['isUrgent'] ?? false,
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      sectionId: json['sectionId'],
      sectionTitle: json['sectionTitle'],
      sectionColor: _parseColor(json['sectionColor']),
    );
  }
  
  // Вспомогательный метод для преобразования цвета
  static Color _parseColor(String colorString) {
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
}

class ScheduleItem {
  final String id;
  final String time;
  final String subject;
  final String classInfo;
  final DateTime date;
  final bool isTask; // Определяет, является ли это задачей или предметом расписания
  final bool completed; // Статус выполнения
  final DateTime? completedAt; // Время выполнения
  final String? sectionId; // Связь с разделом

  ScheduleItem({
    required this.id,
    required this.time,
    required this.subject,
    required this.classInfo,
    required this.date,
    this.isTask = false,
    this.completed = false,
    this.completedAt,
    this.sectionId,
  });

  // Метод для получения DateTime из строки времени
  DateTime getDateTime() {
    final parts = time.split(' - ')[0].split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  // Статический метод для сортировки по времени
  static List<ScheduleItem> sortByTime(List<ScheduleItem> items) {
    items.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
    return items;
  }

  // Преобразование Task в ScheduleItem
  static ScheduleItem fromTask(Task task) {
    return ScheduleItem(
      id: task.id,
      time: task.time,
      subject: task.title,
      classInfo: task.sectionTitle,
      date: task.date,
      isTask: true,
      completed: task.completed,
      completedAt: task.completedAt,
      sectionId: task.sectionId,
    );
  }
  
  // Метод для обновления статуса
  ScheduleItem copyWith({
    String? id,
    String? time,
    String? subject,
    String? classInfo,
    DateTime? date,
    bool? isTask,
    bool? completed,
    DateTime? completedAt,
    String? sectionId,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      time: time ?? this.time,
      subject: subject ?? this.subject,
      classInfo: classInfo ?? this.classInfo,
      date: date ?? this.date,
      isTask: isTask ?? this.isTask,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      sectionId: sectionId ?? this.sectionId,
    );
  }
  
  // Фабричный метод для создания из JSON
  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['_id'] ?? json['id'],
      time: json['timeRange'] ?? json['time'],
      subject: json['subject'],
      classInfo: json['classInfo'] ?? '',
      date: DateTime.parse(json['date']),
      isTask: json['type'] == 'task',
      completed: json['completed'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      sectionId: json['sectionId'],
    );
  }
}
