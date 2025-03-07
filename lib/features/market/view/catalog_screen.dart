import 'package:alippepro_v1/features/market/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/category_item.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List categories = [];
  var _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var fetchedCategories = await APIService.getAllCategories();
      print("Количество продуктов: ${fetchedCategories.length}");

      setState(() {
        categories =
            fetchedCategories; // Update the state with the fetched products
        _isLoading = false;
      });
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        title: Text(
          'Каталог',
          style: GoogleFonts.rubik(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff1B434D),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintStyle: GoogleFonts.rubik(
                            fontWeight: FontWeight.w300,
                            color: const Color.fromARGB(119, 27, 67, 77)),
                        hintText: 'Товар издөө',
                        focusColor: const Color(0xff1B434D),
                        hoverColor: const Color(0xff1B434D),
                        suffixIcon: const Image(
                            image: AssetImage('assets/img/search.png')),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Каталог',
                      style: GoogleFonts.rubik(
                          color: const Color(0xff1B434D),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Оборачиваем GridView в Center для центрирования
                  GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    shrinkWrap: true,
                    crossAxisCount: 2, // Количество колонок в GridView
                    childAspectRatio: 1.2,
                    children: categories.map((category) {
                      return CategoryItem(
                        id: category['_id'],
                        title: category['description'],
                        imagePath: category['image'],
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
