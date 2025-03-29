import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// URL API
const String baseUrl =
    'http://ec2-18-195-169-159.eu-central-1.compute.amazonaws.com';
const String participantsEndpoint = '/participants';

// Модель данных для запроса
class ParticipantRequest {
  final String fullName;
  final region;
  final bookId;
  final String phone;
  // final String additionalInfo;

  ParticipantRequest({
    required this.fullName,
    required this.region,
    required this.bookId,
    required this.phone,
    // required this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'region': region,
      'bookId': bookId,
      'phone': phone,
      // 'additionalInfo': additionalInfo,
    };
  }
}

// Модель данных для ответа
class ParticipantResponse {
  final int id;
  final String fullName;
  final String region;
  final String bookName;
  // final String additionalInfo;
  final String phone;
  final String status;

  ParticipantResponse({
    required this.id,
    required this.fullName,
    required this.region,
    required this.bookName,
    // required this.additionalInfo,
    required this.phone,
    required this.status,
  });

  factory ParticipantResponse.fromJson(Map<String, dynamic> json) {
    return ParticipantResponse(
      id: json['id'],
      fullName: json['fullName'],
      region: json['region'],
      bookName: json['bookName'],
      // additionalInfo: json['additionalInfo'],
      phone: json['phone'],
      status: json['status'],
    );
  }
}

class ParticipantService {
  Future createParticipant(ParticipantRequest request) async {
    print('url');

    String encodedPhone = Uri.encodeQueryComponent(request.phone);

    var url =
        Uri.parse(baseUrl + participantsEndpoint + '?phone=' + encodedPhone);
    print(url);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    print(jsonDecode(response.body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userBook', response.body);
      return response.statusCode;
    } else {
      throw Exception('Failed to create participant: ${response.statusCode}');
    }
  }

  Future<List<ParticipantResponse>> getParticipants() async {
    final response = await http.get(
      Uri.parse(baseUrl + participantsEndpoint+'/results'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => ParticipantResponse.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load participants: ${response.statusCode}');
    }
  }

  // Метод для отправки кода подтверждения
  Future sendVerificationCode(String phoneNumber) async {
    // Форматирование номера телефона
    String formattedPhone = _formatPhoneNumber(phoneNumber);

    // Используем Uri.parse с query параметрами
    final uri = Uri.parse('$baseUrl/participants/send')
        .replace(queryParameters: {'phoneNumber': formattedPhone});
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // if (response.body == "Пользователь с таким номером уже существует") {}

    if (response.statusCode == 200 || response.statusCode == 201) {
      return (response.statusCode);
    } else {
      return response.statusCode;
    }
  }

  // Метод для проверки кода подтверждения
  Future verifyCode(String phoneNumber, String code) async {
    // Форматирование номера телефона
    print(code);

    String formattedPhone = _formatPhoneNumber(phoneNumber);
    print(phoneNumber);

    // Создание URL с query параметрами
    final uri = Uri.parse('$baseUrl/participants/check').replace(
      queryParameters: {
        'phoneNumber': formattedPhone,
        'code': code,
      },
    );

    // Отправка запроса без тела
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.statusCode;
    } else {
      throw Exception('Failed to verify code: ${response.statusCode}');
    }
  }

  // Вспомогательный метод для форматирования номера телефона
  String _formatPhoneNumber(String phoneNumber) {
    // Удаление всех нецифровых символов
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Удаление ведущего нуля, если он есть
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    // Проверка длины номера (должно быть 9 или 10 цифр)
    if (digitsOnly.length < 9 || digitsOnly.length > 10) {
      throw Exception('Phone number must be 9 or 10 digits');
    }

    // Добавление кода страны и возврат отформатированного номера
    return '+996$digitsOnly';
  }
}
