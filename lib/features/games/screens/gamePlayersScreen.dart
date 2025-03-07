// // ignore_for_file: file_names

// import 'package:flutter/material.dart';

// class QuizStartScreen extends StatelessWidget {
//   const QuizStartScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           Colors.grey[700], // Background color for the entire screen
//       body: Center(
//         child: Container(
//           width: 350,
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: const Color(0xFF004C92), // Blue background
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.check,
//                 color: Colors.white,
//                 size: 40,
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Барсбек баатыр',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildTag('Тарых'),
//                   _buildTag('8-класс'),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Викторинага кошулган окуучулар',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildStudentGrid(),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Handle start game
//                 },
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
//                   // primary: Colors.pink,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//                 child: const Text(
//                   'Оюнду баштоо',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTag(String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Color(0xFF004C92),
//           fontSize: 16,
//         ),
//       ),
//     );
//   }

//   Widget _buildStudentGrid() {
//     List<Map<String, String>> students = [
//       {'name': 'Айбек', 'image': 'assets/aybek.png'},
//       {'name': 'Болот', 'image': 'assets/bolot.png'},
//       {'name': 'Тилека', 'image': 'assets/tileka.png'},
//       {'name': 'Аман', 'image': 'assets/aman.png'},
//       {'name': 'Бермет', 'image': 'assets/bermet.png'},
//       {'name': '15+', 'image': 'assets/plus15.png'},
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       itemCount: students.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 10,
//         crossAxisSpacing: 10,
//         childAspectRatio: 1,
//       ),
//       itemBuilder: (context, index) {
//         return Column(
//           children: [
//             CircleAvatar(
//               radius: 30,
//               backgroundImage: AssetImage(students[index]['image']!),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               students[index]['name']!,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
