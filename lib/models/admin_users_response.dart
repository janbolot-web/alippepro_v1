// models/admin_users_response.dart
import 'user.dart';

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