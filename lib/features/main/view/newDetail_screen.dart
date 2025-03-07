// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class NewDetailScreen extends StatefulWidget {
  final img;
  const NewDetailScreen({super.key, this.img});

  @override
  State<NewDetailScreen> createState() => _NewDetailScreenState();
}

class _NewDetailScreenState extends State<NewDetailScreen> {
  final String phone =
      "+996707072247"; // Add the phone number in international format
  final String message =
      "Саламатсызбы! \"Ишкер мугалим\" долбоору боюнча маалымат бересизби?";

  Future<void> _launchWhatsApp() async {
    final String whatsappUrl =
        "https://wa.me/$phone?text=${Uri.encodeFull(message)}";

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    widget.img
                        .toString(), // замените на путь к вашему изображению
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Text(
                //   'ЖАКЫНДА',
                //   style: GoogleFonts.rubik(
                //     fontSize: 18,
                //     color: const Color(0xff004C92),
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // const SizedBox(height: 4.0),
                // Text(
                //   'ОКУТУУ БОРБОР АЧ',
                //   style: GoogleFonts.rubik(
                //     fontSize: 24,
                //     color: Colors.black,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // Text(
                //   'реалити долбоор',
                //   style: GoogleFonts.rubik(
                //     fontSize: 14,
                //     color: Colors.black54,
                //   ),
                // ),
                // const SizedBox(height: 16.0),
                widget.img == 'assets/img/instuc.png'
                    ? const Column(
                        children: [
                          Text(
                            'Здесь будет инструкция по использованию приложения',
                            textAlign: TextAlign.center,

                          )
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            'Реалити долбоор ЖЕКЕ ИШКЕР болом деген мугалимдерибизге арналат. Долбоордун жүрүшүндө өзүңүздүн жеке ОКУТУУ БОРБОРУҢУЗДУ ача аласыз.',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Биз',
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '• Осоо ачып беребиз\n'
                            '• Ишкердик боюнча зарыл билимдер берилет\n'
                            '• Өзү менен кошо 3 адамды окутуп беребиз (СММ, сатуучу, тренер)\n'
                            '• Замандын методикаларды үйрөтөбүз\n'
                            '• Алгачкы кадамдарыңыздан баштап, окутуу борборуңузду иштетип баштаганга чейинки басып өткөн жолдорунузду экран аркылуу чагылдырылып беребиз\n',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Өзүңүздүн тажрыйбаныз, билимиңиз менен ишкерлик кылып, кошумча кирешеге чыгуууну, команда жогултуп иштетүүнү же болбосо иштетип аткан окутуу борборуңузду күчтөндүрүүнү кааласаңыз "Окутуу борбор ач" реалити-долбоор сиз үчүн.',
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                _launchWhatsApp();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff004C92),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                'Катталуу',
                                style: GoogleFonts.rubik(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
