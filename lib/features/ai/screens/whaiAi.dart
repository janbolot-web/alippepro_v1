// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class WhaiAi extends StatelessWidget {
  const WhaiAi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.pink, Colors.purple, Colors.blue],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Alippe Ai деген эмне?',
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Сиздин эң ишенимдүү жардамчыңыз!',
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                  color: const Color(0xff004C92),
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Image.asset(
                'assets/img/whatAIImage.png'), // Ensure the image is in the assets folder
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Мугалим өзү 2 саатта жасачу ишти 2 мүнөттө аткарат',
                    style: GoogleFonts.rubik(
                        fontSize: 16, color: const Color(0xff004C92)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Идея жок болуп жаткан учурда “миллион” идея берет',
                    style: GoogleFonts.rubik(
                        fontSize: 16, color: const Color(0xff004C92)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.star_border, color: Colors.pink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Кыскасы жумушуңузду жеңилдетип, колуңузга кол, бутуңузга бут болуп берет',
                    style: GoogleFonts.rubik(
                        fontSize: 16, color: const Color(0xff004C92)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              'Alippe Ai сизге сабак планын жазып, презентация жасап жана анимация менен оюндарды түзүп бере алат',
              style: GoogleFonts.rubik(fontSize: 16, color: const Color(0xff004C92)),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: 
//     );
//   }
// }
