import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(200, 0, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: const Color(0xFFEA3799),
              size: 100,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Text(
            'Сиздин викторина түзүлүп жатат!',
            style: GoogleFonts.rubik(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
