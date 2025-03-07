// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isReadOnly;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/1.5,
      decoration: BoxDecoration(
          border: Border.all(
              width: 1, style: BorderStyle.solid, color: Colors.white),
          borderRadius: BorderRadius.circular(5)),
      child: TextField(
        readOnly: isReadOnly,
        controller: controller,
        style: GoogleFonts.rubik(color: const Color(0xff004C92), fontSize: 15,fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          filled: true,
          hintText: hintText,
          
          
        ),
      ),
    );
  }
}
