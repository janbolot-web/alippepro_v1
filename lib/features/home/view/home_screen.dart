import 'dart:io';

import 'package:alippepro_v1/features/courses/courses.dart';
import 'package:alippepro_v1/features/main/view/main_screen.dart';
import 'package:alippepro_v1/features/splash/splash_screen.dart';
import 'package:alippepro_v1/profile-new/profile.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/utils/image_handler.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Для работы с JSON
import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static of(BuildContext context) {}
}

class _HomeScreenState extends State<HomeScreen> {
  var _selectedPageIndex = 1;

  refresh() {
    setState(() {
      _selectedPageIndex = 1;
    });
  }

  var isLoad = true;
  var user;
  final ImageHandler _imageHandler = ImageHandler();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  double? _imageWidth;
  double? _imageHeight;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getUserLocalData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomDataProvider>(context, listen: false).removeAll();
    });
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      setState(() {
        isLoad = false;
        getUserLocalData();
      });
    });
  }

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    if (user?['avatarUrl'] == null || user['avatarUrl'].isEmpty) {
      if (isLoad == false) {
        _showAvatarBottomSheet(context); // Показываем предупреждение
      }
    }
    setState(() {});
  }

  Widget body() {
    switch (_selectedPageIndex) {
      case 0:
        return const CoursesScreen();
      case 1:
        return MainScreen(isLoading: _isLoading, user: user);
      case 2:
        return const Profile();
    }
    return Container();
  }

  void _showAvatarBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Профилиңиздин сүрөтүн коюңуз',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff005558),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: _isLoading
                    ? null
                    : user != null &&
                            user['avatarUrl'] != null &&
                            user['avatarUrl'].isNotEmpty
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : (user == null ||
                            user['avatarUrl'] == null ||
                            user['avatarUrl'].isEmpty)
                        ? const Icon(Icons.person, size: 60)
                        : null,
              ),

             
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      _pickImageFromCamera();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.blue),
                        const SizedBox(width: 5),
                        Text(
                          'Камерадан',
                          style:
                              GoogleFonts.rubik(color: const Color(0xff005558)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      _pickImageFromGallery();
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.photo_library_rounded,
                            color: Colors.blue),
                        const SizedBox(width: 5),
                        Text('Галереядан',
                            style: GoogleFonts.rubik(
                                color: const Color(0xff005558))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: const Color(0xff005558),
                  child: const Text('Улантуу'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final Uri whatsapp = Uri.parse('https://wa.me/996707072247');

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientaion) {
      switch (orientaion) {
        case Orientation.portrait:
          return isLoad == true
              ? const SplashScreen()
              : Scaffold(
                  backgroundColor: const Color(0xffF0F0F0),
                  body: body(),
                  floatingActionButton: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 164, 230, 158),
                            Color.fromARGB(255, 146, 236, 138),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff239b19).withOpacity(0.2),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]),
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(whatsapp);
                      },
                      child: Image.asset(
                        'assets/img/wh.png',
                      ),
                    ),
                  ),
                  bottomNavigationBar: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .12,
                        child: BottomNavigationBar(
                          onTap: (int index) {
                            setState(() {
                              _selectedPageIndex = index;
                            });
                          },

                          selectedItemColor: Colors.red,
                          selectedFontSize: 10,
                          unselectedFontSize: 10,
                          backgroundColor: Colors.white,
                          type: BottomNavigationBarType.fixed,

                          currentIndex:
                              _selectedPageIndex, // This is all you need!

                          items: [
                            BottomNavigationBarItem(
                                icon:
                                    SvgPicture.asset("assets/img/courses.svg"),
                                label: 'Курстар',
                                activeIcon: SvgPicture.asset(
                                    "assets/img/courses_active.svg")),
                            BottomNavigationBarItem(
                                icon: SvgPicture.asset("assets/img/home.svg"),
                                label: 'Башкы бет',
                                activeIcon: SvgPicture.asset(
                                    "assets/img/home_active.svg")),
                            BottomNavigationBarItem(
                                icon:
                                    SvgPicture.asset("assets/img/profile.svg"),
                                label: 'Жеке кабинет',
                                activeIcon: SvgPicture.asset(
                                    "assets/img/profile_active.svg")),
                          ],
                        ),
                      )));

        case Orientation.landscape:
          return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Scaffold(
                backgroundColor: Colors.white,
                body: body(),
              ));
      }
    });
  }

  void _pickImageFromGallery() async {
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
      String? imageUrl = await _imageHandler.uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        await _imageHandler.saveImageUrlToServer(imageUrl, user['id']);
        var statusCode =
            await _imageHandler.saveImageUrlToServer(imageUrl, user['id']);
        print("URL изображения: $imageUrl");
        print('statusCode $statusCode');
        if (statusCode == 200) {
          await getUserLocalData();
        }
      }

      setState(() {
        _isLoading = false; // Конец загрузки
      });
    }
  }

  void _pickImageFromCamera() async {
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
      String? imageUrl = await _imageHandler.uploadImageToCloudinary(_image!);
      if (imageUrl != null) {
        var statusCode =
            await _imageHandler.saveImageUrlToServer(imageUrl, user['id']);
        print("URL изображения: $imageUrl");
        print('statusCode $statusCode');
        if (statusCode == 200) {
          await getUserLocalData();
        }
      }

      setState(() {
        _isLoading = false; // Конец загрузки
      });
    }
  }

  Widget _avatarOption(IconData icon, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: CircleAvatar(
        radius: 24,
        backgroundColor:
            isSelected ? CupertinoColors.activeGreen : Colors.grey[300],
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
}
