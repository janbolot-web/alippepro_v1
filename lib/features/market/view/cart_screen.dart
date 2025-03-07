import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffF0F0F0),
        appBar: AppBar(
          title: Text(
            'Корзина',
            style: GoogleFonts.rubik(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1B434D)),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                child: Container(
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          'Сиздин корзина',
                          style: GoogleFonts.rubik(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xff00342E)),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Товарлар (1)',
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: const Color(0xff00342E)),
                            ),
                            Text(
                              '1546  с',
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: const Color(0xff00342E)),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Скидка',
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: const Color(0xff00342E)),
                            ),
                            Text(
                              '-750 с',
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: const Color(0xffBA0F43)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
