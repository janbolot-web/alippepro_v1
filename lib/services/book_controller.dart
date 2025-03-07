import 'dart:convert';
import 'package:alippepro_v1/models/book.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Book>> fetchBooks() async {
  final response = await http.get(Uri.parse('${Constants.uri}/getAllBooks'));

  if (response.statusCode == 200) {
    // Парсим JSON, если сервер возвращает 200 OK
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((book) => Book.fromJson(book)).toList();
  } else {
    // Если сервер не возвращает 200 OK, выбрасываем исключение
    throw Exception('Не удалось загрузить книги');
  }
}

Future<List<Book>> fetchBooksByCategory(category) async {
  // Создаем URL с переданными категориями
  final response = await http.get(
      Uri.parse('${Constants.uri}/getBooksForCategory?category=$category'));

  if (response.statusCode == 200) {
    // Парсим JSON, если сервер возвращает 200 OK
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((book) => Book.fromJson(book)).toList();
  } else {
    // Если сервер не возвращает 200 OK, выбрасываем исключение
    throw Exception('Не удалось загрузить книги');
  }
}

Future<List<Book>> fetchSearchBooks(query, category) async {
  var url = category.isNotEmpty
      ? '${Constants.uri}/searchBooks?q=$query&category=$category'
      : '${Constants.uri}/searchBooks?q=$query';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((book) => Book.fromJson(book)).toList();
  } else {
    throw Exception('Failed to load books');
  }
}

Future<List<Book>> fetchMyBooks() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userResonse = prefs.getString('user');
  var userResonseData = jsonDecode(userResonse!);

  final response = await http.get(
      Uri.parse('${Constants.uri}/getMyBooks?userId=${userResonseData['id']}'));

  if (response.statusCode == 200) {
    // Парсим JSON, если сервер возвращает 200 OK
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((book) => Book.fromJson(book)).toList();
  } else {
    // Если сервер не возвращает 200 OK, выбрасываем исключение
    throw Exception('Не удалось загрузить книги');
  }
}

Future<List<Book>> saveToBook(bookId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userResonse = prefs.getString('user');
  var userResonseData = jsonDecode(userResonse!);
  final response = await http.post(
    Uri.parse('${Constants.uri}/setBookToUser'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, dynamic>{"userId": userResonseData['id'], "bookId": bookId}),
  );

  if (response.statusCode == 200) {
    // Парсим JSON, если сервер возвращает 200 OK
    List<dynamic> jsonResponse = json.decode(response.body);
    return jsonResponse.map((book) => Book.fromJson(book)).toList();
  } else {
    // Если сервер не возвращает 200 OK, выбрасываем исключение
    throw Exception('Не удалось загрузить книги');
  }
}
