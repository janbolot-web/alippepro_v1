import 'package:flutter/material.dart';

class GradientBackgroundText extends StatelessWidget {
  final String text;
  final LinearGradient gradient;
  final double fontSize;

  const GradientBackgroundText({super.key, 
    required this.text,
    required this.gradient,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius:
            BorderRadius.circular(5), // Optional: add a border radius if needed
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
