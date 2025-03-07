// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:alippepro_v1/components/alert_widget.dart';
import 'package:alippepro_v1/services/auth_controller.dart';
import 'package:alippepro_v1/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthController authController = AuthController();

  onSubmit(String? input) async {
    var response = await authController.startVerification("996" + input!);
    if (response == 500) {
      showNotification(context,
          color: AppColors.redColor, message: 'Не корректный номер телефона');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Image.asset(
                'assets/img/top.png',
              ),
              const SizedBox(
                height: 50,
              ),
              Center(
                child: Image.asset(
                  'assets/img/logo.png',
                  width: 80,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Text(
                'Мугалимдердин аянтчасына \n кош келдиңиз!',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff005D67)),
                textAlign: TextAlign.center,
              )
            ],
          ),
          // greenIntroWidget(),

          loginWidget(() async {
            setState(() {});
          }, onSubmit),
          Image.asset(
            'assets/img/bottom.png',
          ),
        ],
      ),
    );
  }
}
