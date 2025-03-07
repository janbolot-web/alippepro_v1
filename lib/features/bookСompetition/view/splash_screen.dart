// splash_screen.dart
import 'package:alippepro_v1/features/book%D0%A1ompetition/view/phoneInput_screen.dart';
import 'package:alippepro_v1/utils/app_theme.dart';
import 'package:alippepro_v1/widgets/bookWidgets.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAE3F4),
              Color(0xFFDDEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 100),
                // App Logo
                Image.asset(
                  'assets/img/logo.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 36),
                Text(
                  'Китеп окууну жайылтуу',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff1B434D),
                  ),
                ),
                Text(
                  'максатында уюштурулган',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff1B434D),
                  ),
                ),
                const SizedBox(height: 37),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ALIPPE',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ТАЙМАШ',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Китеп сынагына кош келдиңиз...',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightPurple,
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: 'Катталуу',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneInputScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
