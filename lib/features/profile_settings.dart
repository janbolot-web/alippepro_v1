import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/components/alert_widget.dart';
import 'package:alippepro_v1/features/home/view/home_screen.dart';
import 'package:alippepro_v1/features/loginNew/widgets/greenIntroWidget.dart';
import 'package:alippepro_v1/services/auth_controller.dart';
import 'package:alippepro_v1/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  var isLoad = false;

  AuthController authController = AuthController();
  // ignore: prefer_typing_uninitialized_variables
  var a;
  // getImage(ImageSource source) async {
  //   a = await getDataFromLocalStorage('userData');
  //   final XFile? image = await _picker.pickImage(source: source);
  //   if (image != null) {
  //     selectedImage = File(image.path);
  //     // authController.uploadProfileImage(File(image.path));
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  greenIntroWidgetWithoutLogos(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        // getImage(ImageSource.gallery);
                      },
                      child: selectedImage == null
                          ? Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffD6D6D6)),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.fill),
                                  shape: BoxShape.circle,
                                  color: const Color(0xffD6D6D6)),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFieldWidget('Имя', nameController, (String? input) {
                      if (input!.isEmpty) {
                        return 'Обязательно укажите ваше имя!';
                      }

                      if (input.length < 5) {
                        return 'Пожалуйста, предоставьте ваше официальное имя!';
                      }

                      return null;
                    }, onTap: () async {}, readOnly: false),
                    const SizedBox(
                      height: 10,
                    ),
                    // TextFieldWidget(
                    //     'Фамилия',
                    //     iconData: Icons.home_outlined,
                    //     lastNameController, (String? input) {
                    //   if (input!.isEmpty) {
                    //     return 'Обязательно укажите вашу фамилию';
                    //   }

                    //   return null;
                    // }, onTap: () async {}, readOnly: false),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    greenButton('Сактоо', onSubmit),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  TextFieldWidget(
      String title, TextEditingController controller, Function validator,
      {Function? onTap, bool readOnly = false, IconData? iconData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 130, 130, 130)),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: Get.width,
          // height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            readOnly: readOnly,
            onTap: () => onTap!(),
            validator: (input) => validator(input),
            controller: controller,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.greenColor),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget greenButton(String title, Function onPressed) {
    return MaterialButton(
      minWidth: Get.width,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: const Color(0xff088273),
      onPressed: () => onPressed(),
      child: isLoad
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
          : Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    );
  }

  onSubmit() async {
    // Получаем значения из контроллеров

    // Проверяем, чтобы поля были заполнены
    if (nameController.text.isEmpty) {
      // Обработка ошибки: поля не должны быть пустыми
      showNotification(context,
          color: AppColors.redColor, message: 'Пожалуйста, заполните все поля');
      return;
    }
    isLoad = true;
    // Создаем Map для передачи данных
    Map<String, dynamic> userData = {
      "name": nameController.text,
    };

    final response = await authController.setUserData(userData);
    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // ignore: use_build_context_synchronously
      showNotification(context, message: responseData['message']);
    isLoad = false;
      Get.to(() => const HomeScreen());
    } else {
      // ignore: use_build_context_synchronously
      showNotification(context,
          color: AppColors.redColor, message: responseData['message']);
    }

    // Опционально: добавьте логику перехода на следующий экран или другие действия по завершении
    // например, Navigator.push(context, MaterialPageRoute(builder: (context) => NextScreen()));
  }
}
