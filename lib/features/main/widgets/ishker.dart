import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherProgramScreen extends StatelessWidget {
  const TeacherProgramScreen({super.key});

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
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                width: double.infinity,
                child: Image.asset('assets/img/teacher.png')),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _launchWhatsApp ,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1B434D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Байланышуу',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}


// class TeacherProgramScreen extends StatelessWidget {
//   const TeacherProgramScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header with gradient background and person
//               Stack(
//                 children: [
//                   Container(
//                     height: 180,
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.centerLeft,
//                         end: Alignment.centerRight,
//                         colors: [Colors.purple, Color(0xFF0A1A3F)],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 15,
//                     left: 15,
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//                       onPressed: () {},
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 40),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'ИШМЕР\nМУГАЛИМ',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Spacer(),
//                             Image.asset(
//                               'assets/graduate_student.png', // Replace with your image
//                               width: 120,
//                               height: 120,
//                               // Use a placeholder in actual implementation
//                             ),
//                           ],
//                         ),
//                         const Text(
//                           '7 багыт • долбоордо',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
              
//               // Program info section
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       '"Ишмер мугалим" өз ичине\n7 багыттагы заманбап билимдерди\nкамтыган уникалдуу долбоор.',
//                       style: TextStyle(
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     RichText(
//                       text: const TextSpan(
//                         style: TextStyle(color: Colors.black, fontSize: 14),
//                         children: [
//                           TextSpan(
//                             text: '"Ишмер мугалим" ',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: 'долбоору 500 мугалимди заманбап билим-методикаларды сиңирип алуусуна шарт түзүп берди.',
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     RichText(
//                       text: const TextSpan(
//                         style: TextStyle(color: Colors.black, fontSize: 14),
//                         children: [
//                           TextSpan(
//                             text: 'Эң негизги долбоордун артыкча 1 ',
//                           ),
//                           TextSpan(
//                             text: 'айлык интенсив ',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: 'сабактагы кийин ар бир мугалим чыныгы ',
//                           ),
//                           TextSpan(
//                             text: '"авторитет мугалим" ',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: 'болууга кадам ташташ, өзүнө болгон ишенимди аалаалаш.',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Speakers section header
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Долбоордун',
//                       style: TextStyle(
//                         color: Colors.purple,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const Text(
//                       'СПИКЕРЛЕРИ',
//                       style: TextStyle(
//                         color: Color(0xFF0A1A3F),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Speakers list
//               buildSpeakerItem("Мээрим Арзыкулова", "ШДО окуу методисти"),
//               buildSpeakerItem("Тынчтыкбек Кеңжебек уулу", "Жаңы актуу"),
//               buildSpeakerItem("Адель Эсенгулова", "Мугалимдин жаңычыл жөндөмдөрүн өнүктүрүү платформасы"),
//               buildSpeakerItem("Ибарат Буларбекова", "Логопедия"),
//               buildSpeakerItem("Суйун Калчаев", "Мугалимдин жаңычыл жөндөмдөрүн өнүктүрүү платформасы"),
//               buildSpeakerItem("Рано Акматова", "Мугалимдин жаңычыл жөндөмдөрүн өнүктүрүү платформасы"),
//               buildSpeakerItem("Адель Эсенгулова", "Мугалимдин жаңычыл жөндөмдөрүн өнүктүрүү платформасы"),
              
//               // Bottom info section
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const Text(
//                       '"Ишмер\nМУГАЛИМ"',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Color(0xFF0A1A3F),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'бул мугалимдердин потенциалын ачып, алардын келечегин куруп аалыш!',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(height: 30),
//                     const Text(
//                       'Биздин',
//                       style: TextStyle(
//                         color: Colors.purple,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const Text(
//                       'МАКСАТ',
//                       style: TextStyle(
//                         color: Color(0xFF0A1A3F),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'руханий өсүүгү көпүрө кылып\nтарбиялаган\nэффективдүү методикаларды\nКыргызстандын ар бир мугалимине\nжайылтуу.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0A1A3F),
//                         minimumSize: const Size(double.infinity, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Байланышуу',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildSpeakerItem(String name, String position) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.grey[300],
//               image: const DecorationImage(
//                 image: AssetImage('assets/placeholder.png'), // Replace with actual image
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   position,
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }