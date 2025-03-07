// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var token;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  verificationUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('x-auth-token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/img/top.png',
              ),
              Column(
                children: [
                  Image.asset(
                    'assets/img/logo.png',
                    width: 100,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  DefaultTextStyle(
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, color: const Color(0xff1B5468)),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Мугалимдерди өнүктүрүүчү аянтча',
                          cursor: '|',
                          speed: const Duration(milliseconds: 30),
                        ),
                      ],
                      onTap: () {},
                      isRepeatingAnimation: false,
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                ],
              ),
              Image.asset(
                'assets/img/bottom.png',
              ),
            ]),
      ),
    );
  }
}
