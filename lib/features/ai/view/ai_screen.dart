import 'dart:convert';

import 'package:alippepro_v1/features/ai/screens/tools.dart';
import 'package:alippepro_v1/features/ai/screens/whaiAi.dart';
import 'package:alippepro_v1/features/video_conference.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  Map<String, dynamic>? user;
  bool ai = false;
  final AuthService authService = AuthService();

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
  void initState() {
    super.initState();
    _initLoad();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        title: const Text('Alippe Ai',
            style: TextStyle(
                color: Color(0xff004C92),
                fontFamily: "Montserrat",
                fontSize: 24,
                fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        toolbarHeight: 100,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 24,
            ),
            const Text('Мугалимдин зарыл жардамчысы',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xff004C92),
                  fontWeight: FontWeight.normal,
                  fontFamily: "Montserrat",
                )),
            const SizedBox(height: 43),
            GradientTextButton(
              text: 'Alippe Ai деген эмне?',
              onPressed: () {
                Get.to(const WhaiAi());
              },
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0099), // Pink color
                  Color(0xFF1387F2) // Blue color
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: 58),
            GradientTextButton(
              text: 'Alippe Ai куралдары',
              onPressed: () {
                Get.to(const ToolsScreen());
              },
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0099), // Pink color
                  Color(0xFF1387F2) // Blue color
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            const SizedBox(height: 58),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: GradientTextButton(
                    text: 'Түз эфир',
                    onPressed: () {
                      Get.to(const VideoConference());
                      // Get.to(const JitsiCustomView());
                    },
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0099), // Pink color
                        Color(0xFF1387F2) // Blue color
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
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
                Icon(Icons.stream, size: 32, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Түз эфир',
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

class MenuButton extends StatelessWidget {
  final String title;
  final Color color;

  const MenuButton({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(200, 50),
      ),
      onPressed: () {
        // Define what happens when the button is clicked
      },
      child: Text(title),
    );
  }
}

class GradientTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  const GradientTextButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.2,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
