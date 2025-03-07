import 'dart:async';

import 'package:alippepro_v1/features/loginNew/login_screen.dart';
import 'package:alippepro_v1/services/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/otp_verification_widget.dart';

// ignore: must_be_immutable
class OtpVerificationScreen extends StatefulWidget {
  String phoneNumber;

  OtpVerificationScreen(this.phoneNumber, {super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  AuthController authController = Get.put(AuthController());
  int _seconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resendCode() {
    if (_canResend) {
      // Логика повторной отправки SMS
      _startTimer(); // Сброс таймера
      Get.off(const LoginScreen());
    }
  }

  someMethod(context, verificationCode) async {
    try {
      await authController.verifyCode(
          context, widget.phoneNumber, verificationCode);
      // Обработайте реультат verificationResult здесь
    } catch (error) {
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              ),
              const SizedBox(
                height: 80,
              ),
              Text(
                'Телефон номериңзге смс код жөнөтүлдү',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff005D67)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 14,
              ),
              Text(
                'СМС кодду жазыңыз',
                style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff005D67)),
                textAlign: TextAlign.center,
              )
            ],
          ),
          otpVerificationScreen(widget.phoneNumber),
          Column(
            children: [
              Text(
                'Кодду кайрадан жөнөтүү :  $_seconds секунд',
                style: GoogleFonts.montserrat(color: const Color(0xff005D67)),
              ),
              const SizedBox(
                height: 26,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: MaterialButton(
                  minWidth: Get.width,
                  height: 50,
                  disabledColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  color: const Color(0xffAC046A),
                  onPressed: _canResend ? _resendCode : null,
                  child: Text(
                    'Кодду кайра жөнөтүү',
                    style: GoogleFonts.rubik(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/img/bottom.png',
          ),
        ],
      ),
    );
  }
}
