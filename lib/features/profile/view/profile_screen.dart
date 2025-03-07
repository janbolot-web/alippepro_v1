import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/features/courses/courses.dart';
import 'package:alippepro_v1/features/liveList/liveListScreen.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;
  void signOutUser(BuildContext context) {
    AuthService().signOut(context);
  }

  var user;

  @override
  void initState() {
    super.initState();
    getUserLocalData();
  }

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    setState(() {});
  }

  File? _image; // Для хранения выбранного изображения
  final ImagePicker _picker = ImagePicker();

  // Функция для выбора изображения из галереи

  // Future<void> uploadFile(File file) async {
  //   try {
  //     final result = await Amplify.Storage.uploadFile(
  //       localFile: AWSFile.fromPath(file.path),
  //       path: StoragePath.fromString(
  //           'public/profile_pictures/${user['id']}.jpg'), // уникальный путь для каждого пользователя
  //     ).result;
  //     print('Файл загружен: ${result.uploadedItem.path}');
  //   } on StorageException catch (e) {
  //     print('Ошибка при загрузке файла: ${e.message}');
  //   }
  // }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Вызовите uploadFile после выбора изображения
      // await uploadFile(_image!);
      print('object');
    }
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Вызовите uploadFile после выбора изображения
      // await uploadFile(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/3607/3607444.png'),
                  ),
                  const SizedBox(height: 20),
                  Text(user != null ? user['name'] : '',
                      style: const TextStyle(
                          color: Color(0xff054e45),
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 320,
                    child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            side: const BorderSide(color: Color(0xff1b434d))),
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/img/shape.svg'),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.only(right: 45.0),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          color: Color(0xff1b434d)))),
                              child: const Text(
                                'Бонус',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xff1b434d)),
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              "0 сом",
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xffba0f43)),
                            ),
                            const SizedBox(width: 25),
                            const Icon(
                              Icons.question_mark_sharp,
                              size: 20,
                              color: Color(0xffb8c7c5),
                            )
                          ],
                        )),
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CoursesScreen(myCourse: true),
                              ),
                            );
                          },
                          child: Ink(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xffba0f43),
                                    Color.fromARGB(255, 255, 209, 209)
                                  ]),
                                  borderRadius: BorderRadius.circular(50)),
                              child: SvgPicture.asset(
                                  "assets/img/myCourseIcon.svg",
                                  height: 30,
                                  width: 40,
                                  fit: BoxFit.scaleDown)),
                        ),
                        const SizedBox(height: 11.0),
                        const Text(
                          'Менин \nкурстарым',
                          textAlign: TextAlign.center,
                        )
                      ]),
                      const SizedBox(width: 100.0),
                      Column(children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LiveListScreen(),
                              ),
                            );
                          },
                          child: Ink(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xff1b434d),
                                    Color(0xffb8c7c5)
                                  ]),
                                  borderRadius: BorderRadius.circular(50)),
                              child: SvgPicture.asset(
                                  "assets/img/bookmarkIcon.svg",
                                  height: 30,
                                  width: 40,
                                  fit: BoxFit.scaleDown)),
                        ),
                        const SizedBox(height: 11.0),
                        const Text(
                          'Түз эфирлер',
                          textAlign: TextAlign.center,
                        )
                      ]),
                    ],
                  ),
                  const SizedBox(height: 36),
                  //  user.roles[0] == "ADMIN"
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Column(children: [
                  //             TextButton(
                  //               onPressed: () {
                  //                 Navigator.of(context).push(
                  //                   MaterialPageRoute(
                  //                     builder: (context) => const UsersScreen(),
                  //                   ),
                  //                 );
                  //               },
                  //               child: Ink(
                  //                   width: 70,
                  //                   height: 70,
                  //                   decoration: BoxDecoration(
                  //                       gradient: const LinearGradient(colors: [
                  //                         Color(0xff0437f2),
                  //                         Color(0xff6495ed)
                  //                       ]),
                  //                       borderRadius:
                  //                           BorderRadius.circular(50)),
                  //                   child: const Icon(
                  //                     Icons.people,
                  //                     color: Colors.white,
                  //                     size: 40,
                  //                   )),
                  //             ),
                  //             const SizedBox(height: 11.0),
                  //             const Text(
                  //               'Колдонуучулар',
                  //               textAlign: TextAlign.center,
                  //             )
                  //           ]),
                  //           const SizedBox(width: 70.0),
                  //           Column(children: [
                  //             TextButton(
                  //               onPressed: () {},
                  //               child: Ink(
                  //                   width: 70,
                  //                   height: 70,
                  //                   decoration: BoxDecoration(
                  //                       gradient: const LinearGradient(colors: [
                  //                         Color(0xff0437f2),
                  //                         Color(0xff6495ed)
                  //                       ]),
                  //                       borderRadius:
                  //                           BorderRadius.circular(50)),
                  //                   child: const Icon(
                  //                     Icons.people,
                  //                     color: Colors.white,
                  //                     size: 40,
                  //                   )),
                  //             ),
                  //             const SizedBox(height: 11.0),
                  //             const Text(
                  //               'Медиафайлдар',
                  //               textAlign: TextAlign.center,
                  //             )
                  //           ]),
                  //         ],
                  //       )
                  //     : const SizedBox()
                ],
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            ElevatedButton(
                onPressed: () => signOutUser(context),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(color: Colors.white),
                  ),
                  minimumSize: WidgetStateProperty.all(
                    const Size(80, 30),
                  ),
                ),
                child: const SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Чыгуу",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                      )
                    ],
                  ),
                )),
            const SizedBox(
              height: 50,
            ),
            TextButton(
              onPressed: () {
                _showAlertDialog(context, user['id']);
              },
              child: const Text('Удалить аккаунт'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context, userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Нельзя закрыть, касаясь вне окна
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Предупреждение'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'После удаления аккаунта ваши данные будет удалены из базы'),
                Text('Вы действительно этого хотите.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Да'),
              onPressed: () {
                AuthService().deleteUserAccount(userId);
                AuthService().signOut(context);
                Navigator.of(context).pop(); // Закрыть окно предупреждения
              },
            ),
            TextButton(
              child: const Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть окно предупреждения
              },
            ),
          ],
        );
      },
    );
  }
}
