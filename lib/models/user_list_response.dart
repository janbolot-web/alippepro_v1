// models/user_list_response.dart
import 'package:alippepro_v1/models/user.dart';

class UserListResponse {
  final List<User> users;
  final int totalPages;
  final int currentPage;
  final int totalUsers;

  UserListResponse({
    required this.users,
    required this.totalPages,
    required this.currentPage,
    required this.totalUsers,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      users: (json['users'] as List).map((user) => User.fromJson(user)).toList(),
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      totalUsers: json['totalUsers'],
    );
  }
}

// Дополните существующую модель User, если необходимо