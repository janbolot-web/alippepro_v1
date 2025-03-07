import 'dart:convert';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:http/http.dart' as http;

class APIService {
  static var client = http.Client();

  static Future<bool> uploadImages(
      String logoImageFile, List<String> multipleImages, storesData) async {
    try {
      // Используем правильный хост для Android эмулятора
      var url = Uri.parse("${Constants.uri}/image-upload");

      var request = http.MultipartRequest("POST", url);

      // Добавляем логотип, если он указан
      if (logoImageFile.isNotEmpty) {
        http.MultipartFile logoFile = await http.MultipartFile.fromPath(
          'logo',
          logoImageFile,
        );
        request.files.add(logoFile);
      }

      // Добавляем несколько изображений
      if (multipleImages.isNotEmpty) {
        for (var file in multipleImages) {
          http.MultipartFile multiFile = await http.MultipartFile.fromPath(
            'images',
            file,
          );
          request.files.add(multiFile);
        }
      }

      // Отправка запроса
      var response = await request.send();
      if (response.statusCode == 200) {
        // After the upload, send the storesData to another endpoint
        var responseBody = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseBody);

        // Extract file URLs from the response
        List<String> fileUrls = List<String>.from(responseJson['fileUrls']);

        // You can now use the fileUrls to update your UI or database
        print('File URLs: $fileUrls');

        // Now send the storesData along with the file URLs to the createShop endpoint
        http.Response res = await http.post(
          Uri.parse('${Constants.uri}/createShop'),
          body: jsonEncode({
            ...storesData,
            'fileUrls': fileUrls, // Include the file URLs in the request
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        if (res.statusCode == 200) {
          return true;
        } else {
          print("Failed to create shop with status: ${res.statusCode}");
          return false;
        }
      } else {
        print("Upload failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error during upload: $e");
      return false;
    }
  }

  static Future<List<dynamic>> getStores() async {
    final url = Uri.parse(
        '${Constants.uri}/getAllShops'); // Full URL for getting all stores
    try {
      // Sending a GET request to fetch the stores
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the stores
        List<dynamic> stores = json.decode(response.body);
        return stores;
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load stores');
      }
    } catch (e) {
      // If there is an error (network, JSON decoding, etc.), print it and return an empty list
      print('Error fetching stores: $e');
      return [];
    }
  }

  static Future getStoreById(id) async {
    final url = Uri.parse(
        '${Constants.uri}/getStoreById/$id'); // Full URL for getting all stores
    try {
      // Sending a GET request to fetch the stores
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the stores
        var store = json.decode(response.body);
        print('store $store');
        return store;
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load store');
      }
    } catch (e) {
      // If there is an error (network, JSON decoding, etc.), print it and return an empty list
      print('Error fetching storeeeee: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getAllProducts(query) async {
    try {
      Uri url;
      if (query == '') {
        url = Uri.parse(
            "${Constants.uri}/getAllProducts"); // Укажите ваш API endpoint
      } else {
        url = Uri.parse(
            "${Constants.uri}/getAllProducts?query=$query"); // Укажите ваш API endpoint
      }

      // Отправляем GET-запрос
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Парсим JSON в список продуктов
        var data = json.decode(response.body);
        print("Продукты успешно получены: $data");
        return data;
      } else {
        throw Exception(
            'Не удалось получить продукты. Код ошибки: ${response.statusCode}, Ответ: ${response.body}');
      }
    } catch (e) {
      print("Ошибка при получении продуктов: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getProductsByCategory(id) async {
    try {
      var url = Uri.parse(
          "${Constants.uri}/getProductsByCategory/$id"); // Укажите ваш API endpoint

      // Отправляем GET-запрос
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Парсим JSON в список продуктов
        var data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Не удалось получить продукты. Код ошибки: ${response.statusCode}, Ответ: ${response.body}');
      }
    } catch (e) {
      print("Ошибка при получении продуктов: $e");
      rethrow;
    }
  }

  static Future<List<dynamic>> getAllCategories() async {
    try {
      var url = Uri.parse(
          "${Constants.uri}/getAllCategories"); // Укажите ваш API endpoint

      // Отправляем GET-запрос
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Парсим JSON в список продуктов
        var data = json.decode(response.body);
        print("Продукты успешно получены: $data");
        return data;
      } else {
        throw Exception(
            'Не удалось получить продукты. Код ошибки: ${response.statusCode}, Ответ: ${response.body}');
      }
    } catch (e) {
      print("Ошибка при получении продуктов: $e");
      rethrow;
    }
  }

  static Future<void> deleteStore(String storeId) async {
    print('Deleting store with URL: ${Constants.uri}/stores/$storeId');

    // Вызов API для удаления магазина
    final response = await http.delete(
      Uri.parse('${Constants.uri}/stores/$storeId'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete store');
    }
  }

  static Future createProduct(product) async {
    try {
      // Используем правильный хост для Android эмулятора
      var url = Uri.parse("${Constants.uri}/image-upload");
      print(product);
      var request = http.MultipartRequest("POST", url);

      // Добавляем несколько изображений
      if (product['imagesUrl'].isNotEmpty) {
        for (var file in product['imagesUrl']) {
          http.MultipartFile multiFile = await http.MultipartFile.fromPath(
            'images',
            file,
          );
          request.files.add(multiFile);
        }
      }

      // Отправка запроса
      var response = await request.send();
      if (response.statusCode == 200) {
        // After the upload, send the storesData to another endpoint
        var responseBody = await response.stream.bytesToString();
        var responseJson = jsonDecode(responseBody);

        // Extract file URLs from the response
        List<String> fileUrls = List<String>.from(responseJson['fileUrls']);

        // You can now use the fileUrls to update your UI or database
        print('File URLs: $fileUrls');

        // Now send the storesData along with the file URLs to the createShop endpoint
        http.Response res = await http.post(
          Uri.parse('${Constants.uri}/createProduct/${product['_id']}'),
          body: jsonEncode({
            "parentId": product['_id'],
            "title": product['title'],
            "price": product['price'],
            "description": product['description'],
            "categoryId": product['category'],
            "imagesUrl": fileUrls, // Include the file URLs in the request
            "stock": product['stock'],
          }),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (res.statusCode == 201) {
          return res;
        } else {
          print("Failed to create shop with status: ${res.statusCode}");
          return false;
        }
      } else {
        print("Upload failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error during upload: $e");
      return false;
    }
  }

  // static Future createProduct(Map<String, dynamic> product) async {
  //   try {
  //     // Формируем URL для загрузки данных товара
  //     var url =
  //         Uri.parse("${Constants.uri}/createProduct/${product['_id']}");

  //     // Создаем multipart-запрос
  //     var request = http.MultipartRequest("POST", url);

  //     // Добавляем текстовые данные

  //     // Добавляем изображения
  //     if (product['imagesUrl'] != null && product['imagesUrl'].isNotEmpty) {
  //       for (String imagePath in product['imagesUrl']) {
  //         var imageFile = await http.MultipartFile.fromPath(
  //           'images',
  //           imagePath,
  //         );
  //         request.files.add(imageFile);
  //       }
  //     }

  //     // Отправляем запрос
  //     var response = await request.send();

  //     if (response.statusCode == 201) {
  //       print("Товар успешно создан");
  //     } else {
  //       print("Ошибка: ${response.statusCode}");
  //     }

  //     return response;
  //   } catch (e) {
  //     print("Ошибка при создании товара: $e");
  //     rethrow;
  //   }
  // }
}
