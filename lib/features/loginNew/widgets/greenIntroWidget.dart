// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget greenIntroWidget() {
  return Container(
    width:Get.width ,
    height: Get.height * 0.56,
    decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/img/mask.png'), fit: BoxFit.cover)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            'assets/img/logoSplash.png',
            width: 200,
            height: 200,
          )),
      const SizedBox(
        height: 20,
      ),
      const Text(
        'Кош келиниз!',
        style: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
      )
    ]),
  );
}

Widget greenIntroWidgetWithoutLogos(
    {String title = "Profile Settings", String? subtitle}) {
  return Container(
    width: Get.width,
    decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/img/mask.png'), fit: BoxFit.fill)),
    height: Get.height * 0.3,
    child: Container(
        height: Get.height * 0.1,
        width: Get.width,
        margin: const EdgeInsets.only(bottom: double.infinity * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
          ],
        )),
  );
}
