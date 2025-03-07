import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pinput_widget.dart';

Widget otpVerificationScreen(phoneNumber) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Get.width,
          height: 90,
          child: PinputWidget(
            phoneNumber: phoneNumber,
            
          ),
        ),
        const SizedBox(
          height: 20,
        ),

        // TimerCountdown(
        //   format: CountDownTimerFormat.minutesSeconds,
        //   endTime: DateTime.now().add(
        //     const Duration(
        //       minutes: 1,
        //       seconds: 0,
        //     ),
        //   ),
        //   onEnd: () {
        //   },
        // ),
      ],
    ),
  );
}
