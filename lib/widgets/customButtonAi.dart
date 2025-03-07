import 'package:flutter/material.dart';

class CustomButtonAi extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPremium;

  const CustomButtonAi({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.pink.shade100, // Дополнительный акцентный цвет
              width: 2,
            ),
            color: Colors.white,
            // gradient: LinearGradient(
            //   colors: isPremium
            //       ? [
            //           const Color(0xFFFFD700),
            //           const Color(0xFFFFA500)
            //         ] // Gold gradient for premium
            //       : [Color(0xffFF0099), Color(0xff1387F2)],
            //   // Pink to blue gradient
            //   begin: Alignment.centerLeft,
            //   end: Alignment.centerRight,
            // ),
            boxShadow: [
              BoxShadow(
                color: isPremium
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xff004C92),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xff004C92),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isPremium)
                      const Icon(
                        Icons.stars,
                        color: Colors.white,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// // Example usage:
// class ExampleScreen extends StatelessWidget {
//   const ExampleScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Alippe AI деген эмне?'),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFF1493), Color(0xFF4169E1)],
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
          
//         ],
//       ),
//     );
//   }
// }