import 'dart:io';

import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:snippet_coder_utils/multi_images_utils.dart';

class CreateShopScreen extends StatefulWidget {
  const CreateShopScreen({super.key});

  @override
  State<CreateShopScreen> createState() => _CreateShopScreenState();
}

class _CreateShopScreenState extends State<CreateShopScreen> {
  final _formKey = GlobalKey<FormState>();
  String logoImageFile = "";
  bool isApiCallProcess = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание магазина'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ProgressHUD(
        inAsyncCall: isApiCallProcess,
        key: UniqueKey(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Информация о магазине",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Логотип",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: logoImageFile.isEmpty
                          ? MultiImagePicker(
                              gridCrossAxisCount: 1,
                              gridChildAspectRatio: 1,
                              imgWidth: MediaQuery.of(context).size.width,
                              imgHeight: MediaQuery.of(context).size.height,
                              totalImages: 1,
                              initialValue: const [],
                              onImageChanged: (images) {
                                if (images.isNotEmpty) {
                                  setState(() {
                                    logoImageFile = images[0].imageFile;
                                  });
                                }
                              },
                              imageSource: ImagePickSource.gallery,
                            )
                          : Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(logoImageFile),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        logoImageFile = "";
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                        "Название магазина", "Введите название", nameController,
                        (value) {
                      if (value == null || value.isEmpty) {
                        return "Название магазина обязательно";
                      }
                      return null;
                    }),
                    const SizedBox(height: 24),
                    _buildTextField("Местоположение", "Введите местоположение",
                        locationController, (value) {
                      if (value == null || value.isEmpty) {
                        return "Местоположение обязательно";
                      }
                      return null;
                    }),
                    const SizedBox(height: 24),
                    _buildTextField(
                      "Номер телефона",
                      "Введите номер телефона",
                      phoneNumberController,
                      (value) {
                        if (value == null || value.isEmpty) {
                          return "Номер телефона обязателен";
                        }
                        if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
                          return "Введите корректный номер телефона";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      "WhatsApp",
                      "Введите номер WhatsApp",
                      whatsappController,
                      (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\+?[0-9]{10,13}$').hasMatch(value)) {
                          return "Введите корректный номер WhatsApp";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      "Instagram",
                      "Введите ссылку на Instagram",
                      instagramController,
                      (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !Uri.parse(value).isAbsolute) {
                          return "Введите корректную ссылку";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 20, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Отмена",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isApiCallProcess = true;
                          });

                          var storesData = {
                            "name": nameController.text,
                            "location": locationController.text,
                            "author": {
                              "phoneNumber": phoneNumberController.text,
                              "whatsapp": whatsappController.text,
                              "instagram": instagramController.text,
                            }
                          };

                          await APIService.uploadImages(
                                  logoImageFile, [], storesData)
                              .then((value) {
                            setState(() {
                              isApiCallProcess = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Магазин успешно создан!")),
                            );
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Создать магазин",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, String? Function(String?) validator,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
