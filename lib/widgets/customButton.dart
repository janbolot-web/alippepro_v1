// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  const CustomButton({super.key, required this.onTap, required this.text});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, 50),
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0xff004C92), // Цвет границы
          width: 2, // Ширина границы
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Радиус скругления углов
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.rubik(fontSize: 18,fontWeight: FontWeight.bold,color: const Color(0xff004C92)),
      ),
    );
  }
}
