import 'dart:io';

import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snippet_coder_utils/multi_images_utils.dart';

class CreateProductScreen extends StatefulWidget {
  final String storeId;

  const CreateProductScreen({super.key, required this.storeId});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  bool _isLoading = false;
  List categories = [];
  var selectedOption;

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(image.path); // Добавляем путь к изображению
      });
    }
  }

  @override
  initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      // setState(() {
      //   _isLoading = true;
      // });
      var fetchedCategories = await APIService.getAllCategories();
      print("Количество продуктов: ${fetchedCategories.length}");

      setState(() {
        categories =
            fetchedCategories; // Update the state with the fetched products
        // _isLoading = false;
      });
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  Future<void> _createProduct() async {
    setState(() {
      _isLoading = true;
    });

    var newProductData = {
      "_id": widget.storeId,
      "title": _titleController.text,
      "price": _priceController.text,
      "description": _descriptionController.text,
      "category": selectedOption['_id'],
      "imagesUrl": _images, // Передаем список путей к изображениям
      "stock": _stockController.text,
    };

    try {
      final response = await APIService.createProduct(newProductData);
      print(response.statusCode);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Товар успешно создан'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // Закрыть экран после успешного создания
      } else {
        throw Exception('Ошибка: ${response.body}');
      }
    } catch (e) {
      // print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось создать товар: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Создание продукта"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Информация о продукте",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: "Название продукта",
                hint: "Введите название",
              ),
              _buildTextField(
                controller: _priceController,
                label: "Цена",
                hint: "Введите цену",
                keyboardType: TextInputType.number,
              ),
              // _buildTextField(
              //   controller: _categoryController,
              //   label: "Категория",
              //   hint: "Введите категорию",
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Выберите категорию:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButton(
                          isExpanded: true,
                          value: selectedOption,
                          hint: const Text("Выберите категорию"),
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category['description'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedOption = newValue;
                            });
                          },

                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.blue), // Иконка стрелки
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              const Text(
                "Фотографии продукта",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black26,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: MultiImagePicker(
                        gridCrossAxisCount: 1,
                        gridChildAspectRatio: 1,
                        imgWidth: MediaQuery.of(context).size.width,
                        imgHeight: MediaQuery.of(context).size.height,
                        totalImages: 8,
                        initialValue: const [],
                        onImageChanged: (images) {
                          if (images.isNotEmpty) {
                            setState(() {
                              _images.add(images[0].imageFile);
                            });
                          }
                        },
                        imageSource: ImagePickSource.gallery,
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        Image.file(
                          File(_images[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                          "Создать продукт",
                          style: TextStyle(fontSize: 16,color: Colors.white),
                        ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Описание продукта",
        hintText: "Введите описание с поддержкой Markdown",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Описание не должно быть пустым';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Поле не должно быть пустым';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
