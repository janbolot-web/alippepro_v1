import 'dart:convert';

import 'package:alippepro_v1/features/ai/screens/lessonPlan.dart';
import 'package:alippepro_v1/features/games/screens/mainMenuScreen.dart';
import 'package:alippepro_v1/features/payment/view/payment_screen.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:alippepro_v1/widgets/customButtonAi.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  Map<String, dynamic>? user;
  bool ai = false;
  final AuthService authService = AuthService();

  // @override
  // void initState() {
  //   super.initState();
  //   _initLoad();
  //   print('init');
  // }

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLoad();
    _focusNode.addListener(_onFocusChange);
    print('object');
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _initLoad(); // Загружаем данные при возвращении
      print('object');
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    await getUserLocalData();
    await _refresh(); // Затем обновляем с сервера
  }

  Future<void> getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    if (response != null) {
      setState(() {
        user = jsonDecode(response);
        ai = user?['subscription']?.any(
                (sub) => sub["title"] == "ai" && sub["isActive"] == true) ??
            false;
      });
    }
  }

  Future<void> _refresh() async {
    if (user == null) return;
    var response = await authService.getMe(user!['id']);
    if (response['statusCode'] == 200) {
      final newUserData = await getDataFromLocalStorage('user');
      if (newUserData != null) {
        setState(() {
          user = jsonDecode(newUserData);
          ai = user?['subscription']?.any(
                  (sub) => sub["title"] == "ai" && sub["isActive"] == true) ??
              false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xffFF0099), Color(0xff1387F2)],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Alippe Ai деген эмне?',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ai
              ? CustomButtonAi(
                  title: 'Сабактын планын түзүү',
                  icon: Icons.calendar_today,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LessonPlanScreen()));
                  },
                )
              : GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) =>
                          const CustomBottomSheet(product: 'ai'),
                    );
                    if (result == true) {
                      await _refresh();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return PaymentSuccessDialog(
                            onRedirect: () {
                              Get.to(const LessonPlanScreen());
                            },
                            message: 'Төлөм ийгиликтүү аяктады!',
                          );
                        },
                      );
                    }
                  },
                  child: _buildLockedContent(),
                ),
          CustomButtonAi(
            title: 'Оюн түзүү',
            icon: Icons.groups,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainMenuScreen())).then((_) {
                _initLoad(); // Перезагружаем данные
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent() {
    return Container(
      // decoration: BoxDecoration(
      //   gradient: const LinearGradient(
      //     colors: [Color(0xffFF0099), Color(0xff1387F2)],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: Colors.pink.shade100, width: 2),
      // ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE1E1E1), // 0%
            Color(0xFF838383), // 100%
          ],
        ),
        border: Border.all(
          color: const Color.fromARGB(
              56, 131, 131, 131), // Дополнительный акцентный цвет
          width: 2,
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 7,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color(0xff5B5B5B),
                  borderRadius: BorderRadius.circular(50)),
              child: const Icon(
                Icons.lock,
                color: Color(0xffFFD861), // Белый замок для контраста
                size: 18,
              ),
            ),
          ),
          Container(
            // height: 80,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 32, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Сабактын планын түзүү',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // const Positioned(
          //   right: 20,
          //   bottom: 0,
          //   top: 0,
          //   child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          // ),
        ],
      ),
    );
  }
}
