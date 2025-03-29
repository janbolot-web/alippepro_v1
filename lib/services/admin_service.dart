// services/admin_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/constants.dart';

class AdminService {
  final String token;

  AdminService({required this.token});

  Future<AdminUsersResponse> getUsers(
      {int page = 1,
      int limit = 20,
      String search = '',
      String sortBy = 'createdAt',
      int sortOrder = -1}) async {
    final response = await http.get(
      Uri.parse(
          '${Constants.uri}/admin/users?page=$page&limit=$limit&search=$search&sortBy=$sortBy&sortOrder=$sortOrder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return AdminUsersResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> grantAiAccess({
    required String userId,
    int planPoint = 120,
    int quizPoint = 30,
    int expiresInDays = 30,
  }) async {
    final response = await http.post(
      Uri.parse('${Constants.uri}/admin/grant-ai-access'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: json.encode({
        'userId': userId,
        'planPoint': planPoint,
        'quizPoint': quizPoint,
        'expiresInDays': expiresInDays,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to grant AI access: ${response.body}');
    }
  }

  // services/admin_service.dart
  Future<AdminUsersResponse> getUsersWithAiSubscription(
      {int page = 1,
      int limit = 20,
      String search = '',
      String sortBy = 'createdAt',
      int sortOrder = -1}) async {
    final response = await http.get(
      Uri.parse(
          '${Constants.uri}/admin/users-with-subscription?page=$page&limit=$limit&search=$search&sortBy=$sortBy&sortOrder=$sortOrder'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      return AdminUsersResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load users with subscription: ${response.body}');
    }
  }

  // services/admin_service.dart
  Future<Map<String, dynamic>> getAiStatistics() async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/admin/ai-statistics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load AI statistics: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserAiStatistics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/admin/user-ai-statistics/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user AI statistics: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user statistics: $e');
      throw Exception('Failed to load user AI statistics: $e');
    }
  }
}
