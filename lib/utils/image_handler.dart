// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  double? _imageWidth;
  double? _imageHeight;

  Future<File?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);

      // Determine the width and height of the image
      final imageBytes = await _image!.readAsBytes();
      final ui.Image image = await decodeImageFromList(imageBytes);
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();

      print("Width: $_imageWidth, Height: $_imageHeight");

      return _image;
    }
    return null;
  }

  Future<String?> uploadImageToCloudinary(File image) async {
    final cloudinaryUrl = Uri.parse("https://api.cloudinary.com/v1_1/dsfsrf2xw/image/upload");

    var request = http.MultipartRequest('POST', cloudinaryUrl)
      ..fields['upload_preset'] = 'mhiwvhzc'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      var data = json.decode(responseData.body);
      return data['secure_url'];
    } else {
      print('Error uploading image: ${responseData.body}');
      return null;
    }
  }
String addTransformationsToImageUrl(String imageUrl) {
  if (_imageHeight == null || _imageWidth == null) {
    // Возвращаем исходный URL, если размеры изображения неизвестны
    return imageUrl;
  }

  String transformation = 'f_auto/q_auto/c_fit,h_${_imageHeight!.toInt()},w_${_imageWidth!.toInt()}/';
  const String uploadPath = '/upload/';

  int uploadIndex = imageUrl.indexOf(uploadPath);

  if (uploadIndex != -1) {
    return imageUrl.replaceRange(
      uploadIndex + uploadPath.length,
      uploadIndex + uploadPath.length,
      transformation,
    );
  } else {
    return imageUrl;
  }
}


  Future saveImageUrlToServer(String imageUrl, String userId) async {
    final serverUrl = Uri.parse('${Constants.uri}/auth/set-avatar');
    var response = await http.post(
      serverUrl,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "userId": userId,
        "avatarUrl": addTransformationsToImageUrl(imageUrl),
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      await saveDataToLocalStorage('user', jsonEncode(responseData['data']));
      return response.statusCode;
      // print("Image URL successfully saved to server");
    } else {
      print("Error saving image URL: ${response.body}");
    }
  }
}
