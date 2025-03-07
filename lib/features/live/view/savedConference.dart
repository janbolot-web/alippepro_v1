
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedConference extends StatefulWidget {
  const SavedConference({super.key});

  @override
  State<SavedConference> createState() => _SavedConferenceState();
}

class _SavedConferenceState extends State<SavedConference> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff1B434D)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Сакталган эфирлер',
          style: GoogleFonts.rubik(
            color: const Color(0xff1B434D),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(child: Text('Азырынча сакталган эфирлер жок')),
      ),
    );
  }
}
