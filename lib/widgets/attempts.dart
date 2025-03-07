import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Attempts extends StatelessWidget {
  final count;
  const Attempts({super.key, this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xffFFB82E),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Сделает ширину минимальной
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16),
              ),
              const SizedBox(
                width: 14,
              ),
              Image.asset(width: 20, 'assets/img/palochka.png')
            ],
          ),
        ),
      ],
    );
  }
}
