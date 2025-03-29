// ignore_for_file: prefer_typing_uninitialized_variables
import 'dart:convert';
import 'package:alippepro_v1/features/calendar/screens/main_navigation_page.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
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

  // Обработчик для анимированного перехода
  void _navigateToCalendar(BuildContext context) {
    // Создаем анимированный переход (эффект перелистывания страницы)
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationPage(),
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Используем кривую, которая быстрее достигает конечного значения
          var curve = Curves.easeOutCubic;
          var animation2 = CurvedAnimation(parent: animation, curve: curve);
          
          // Простая анимация сдвига справа налево без поворота
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation2),
            child: child, // Страница отображается ровно, без трансформаций
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),

        // Кнопка перехода к календарю
        InkWell(
          onTap: () => _navigateToCalendar(context),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff1B434D),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Менин регламентим',
                      style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Здесь можно добавить остальное содержимое страницы
      ],
    );
  }
}