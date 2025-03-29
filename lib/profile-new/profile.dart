// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/features/settings/view/settings.dart';
import 'package:alippepro_v1/profile-new/content_page.dart';
import 'package:alippepro_v1/profile-new/my_files.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    getUserLocalData();
    super.initState();
  }

  File? _image; // Для хранения выбранного изображения
  final ImagePicker _picker = ImagePicker();
  var user;
  bool _isLoading = false;
  double? _imageWidth;
  double? _imageHeight;

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    setState(() {});
  }

  Future<String?> uploadImageToCloudinary(
    File image,
  ) async {
    final cloudinaryUrl =
        Uri.parse("https://api.cloudinary.com/v1_1/dsfsrf2xw/image/upload");

    // Создаем форму с необходимыми данными
    var request = http.MultipartRequest('POST', cloudinaryUrl)
      ..fields['upload_preset'] = 'mhiwvhzc'
      ..fields['public_id'] = user['id'] // Устанавливаем public ID как userId
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    // Отправляем запрос и получаем ответ
    var response = await request.send();
    var responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      var data = json.decode(responseData.body);
      return data['secure_url']; // URL загруженного изображения
    } else {
      print('Ошибка при загрузке изображения: ${responseData.body}');
      return null;
    }
  }

  void _pickImageFromGallery() async {
    Navigator.pop(context); // Закрываем BottomSheet
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);

      // Определяем ширину и высоту изображения
      final imageBytes = await _image!.readAsBytes();
      final ui.Image image = await decodeImageFromList(imageBytes);
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();

      print("Ширина: $_imageWidth, Высота: $_imageHeight");

      setState(() {
        _isLoading = true; // Начало загрузки
      });

      // Загрузка изображения в Cloudinary
      String? imageUrl = await uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        await saveImageUrlToServer(imageUrl);
        print("URL изображения: $imageUrl");
        await getUserLocalData();
      }

      setState(() {
        _isLoading = false; // Конец загрузки
      });
    }
  }

  void _pickImageFromCamera() async {
    Navigator.pop(context); // Закрываем BottomSheet
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);

      // Определяем ширину и высоту изображения
      final imageBytes = await _image!.readAsBytes();
      final ui.Image image = await decodeImageFromList(imageBytes);
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();

      print("Ширина: $_imageWidth, Высота: $_imageHeight");

      setState(() {
        _isLoading = true; // Начало загрузки
      });

      // Загрузка изображения в Cloudinary
      String? imageUrl = await uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        await saveImageUrlToServer(imageUrl);
        print("URL изображения: $imageUrl");
        await getUserLocalData();
      }

      setState(() {
        _isLoading = false; // Конец загрузки
      });
    }
  }

  Future<void> saveImageUrlToServer(String imageUrl) async {
    final serverUrl = Uri.parse('${Constants.uri}/auth/set-avatar');
    var response = await http.post(
      serverUrl,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "userId": user['id'], // ID текущего пользователя
        "avatarUrl": addTransformationsToImageUrl(imageUrl),
      }),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      await saveDataToLocalStorage('user', jsonEncode(responseData['data']));
      print("URL успешно сохранен на сервере");
    } else {
      print("Ошибка при сохранении URL: ${response.body}");
    }
  }

  String addTransformationsToImageUrl(String imageUrl) {
    String transformation =
        'f_auto/q_auto/c_fit,h_${_imageHeight!.toInt()},w_${_imageWidth!.toInt()}/';
    const String uploadPath = '/upload/';

    // Найти позицию '/upload/' в URL
    int uploadIndex = imageUrl.indexOf(uploadPath);

    if (uploadIndex != -1) {
      // Вставить 'f_auto,q_auto/' сразу после '/upload/'
      return imageUrl.replaceRange(uploadIndex + uploadPath.length,
          uploadIndex + uploadPath.length, transformation);
    } else {
      // Если '/upload/' не найден, возвращаем URL без изменений
      return imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Stack(
          children: [
            Positioned(
              top: 0,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
                child: const Icon(
                  Icons.settings,
                  color: Colors.black54,
                  size: 28,
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showRoundedBottomSheet(context);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black12,
                          backgroundImage: _isLoading
                              ? null
                              : user != null &&
                                      user['avatarUrl'] != null &&
                                      user['avatarUrl'].isNotEmpty
                                  ? NetworkImage(user['avatarUrl'])
                                  : null,
                          child: _isLoading
                              ? const CircularProgressIndicator() // Показать индикатор загрузки
                              : (user == null ||
                                      user['avatarUrl'] == null ||
                                      user['avatarUrl'].isEmpty)
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                        ),
                        // CircleAvatar(
                        //   radius: 50,
                        //   backgroundColor: Colors.black12,
                        //   backgroundImage: AssetImage('assets/img/avatar.jpg'),
                        //   child: _isLoading
                        //       ? const CircularProgressIndicator() // Показать индикатор загрузки
                        //       : (user == null ||
                        //               user['avatarUrl'] == null ||
                        //               user['avatarUrl'].isEmpty)
                        //           ? const Icon(Icons.person, size: 50)
                        //           : null,
                        // ),
                        // Positioned для иконки добавления фото
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Colors.white, // Белая обводка вокруг иконки
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        // Positioned для иконки добавления фото
                      ],
                    ),
                  ),
                  const Gap(30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user != null ? user['name'] : '',
                        style: GoogleFonts.rubik(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (user != null) {
                            Clipboard.setData(
                                ClipboardData(text: '${user['phoneNumber']}'));
                            Get.snackbar(
                              'Скопировано',
                              'Номер телефона скопирован в буфер обмена',
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                        child: Text(
                          user != null ? '+${user['phoneNumber']}' : '',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        toolbarHeight: 200,
      ),
      body: ContainedTabBarView(
        tabs: const [
          Icon(Icons.apps, color: Color(0xff005558)),
          // Icon(Icons.bookmark_added_outlined, color: Color(0xff005558)),
          Icon(Icons.folder, color: Color(0xff005558)),
        ],
        tabBarProperties: const TabBarProperties(
          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
        ),
        initialIndex: 0,
        views: const [ContentPage(), MyFiles()],
        // OurCoureses(),
        onChange: (index) => print(index),
      ),
    );
  }

  void _showRoundedBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Text(
                  textAlign: TextAlign.center,
                  'Профилиңиздин сүрөтүн коюңуз: ',
                  style: GoogleFonts.rubik(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera),
                    label: Text(
                      "Камерадан",
                      style: GoogleFonts.rubik(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo),
                    label: Text(
                      "Галереядан",
                      style: GoogleFonts.rubik(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
