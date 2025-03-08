// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String password;
  final String phoneNumber;
  final courses;
  final String? avatarUrl;
  final List<dynamic>? roles;
  final List<dynamic>? subscription; // Добавляем поле для подписок

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.token,
    required this.password,
    this.courses,
    this.avatarUrl,
    this.roles,
    this.subscription, // Добавляем параметр в конструктор
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      'password': password,
      'courses': courses,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'subscription': subscription, // Добавляем в map
    };
  }

  // Модель User должна правильно парсить ID из API
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      // Проверьте, что ваш API возвращает id или _id
      id: map['id'] ?? map['_id'] ?? '', // Ищем как id, так и _id
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      password: map['password'] ?? '',
      courses: map['courses'] ?? '',
      roles: map['roles'] ?? [],
      phoneNumber: map['phoneNumber'] ?? '',
      subscription: map['subscription'] is List ? map['subscription'] : [],
    );
  }
  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  // Вспомогательные методы для работы с подписками
  bool get hasActiveAiSubscription {
    if (subscription == null || subscription!.isEmpty) return false;
    return subscription!
        .any((sub) => sub['title'] == 'ai' && sub['isActive'] == true);
  }

  Map<String, dynamic>? get aiSubscription {
    if (subscription == null || subscription!.isEmpty) return null;
    try {
      final aiSubs =
          subscription!.where((sub) => sub['title'] == 'ai').toList();
      return aiSubs.isNotEmpty ? aiSubs.first : null;
    } catch (_) {
      return null;
    }
  }
}

class Users {
  final List<User> users;
  Users({
    required this.users,
  });

  Map<String, dynamic> toMap() {
    return {
      'users': users.map((u) => u.toMap()).toList(),
    };
  }

  factory Users.fromMap(Map<String, dynamic> map) {
    final List<dynamic> usersJson = map['users'] ?? [];
    return Users(
      users: usersJson.map((u) => User.fromMap(u)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Users.fromJson(String source) => Users.fromMap(json.decode(source));
}

// Добавим новый класс для ответа API с пагинацией
class AdminUsersResponse {
  final List<User> users;
  final int totalPages;
  final int currentPage;
  final int totalUsers;

  AdminUsersResponse({
    required this.users,
    required this.totalPages,
    required this.currentPage,
    required this.totalUsers,
  });

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> usersJson = json['users'] ?? [];
    return AdminUsersResponse(
      users: usersJson.map((u) => User.fromMap(u)).toList(),
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
      totalUsers: json['totalUsers'] ?? 0,
    );
  }
}
