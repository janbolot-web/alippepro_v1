import 'package:alippepro_v1/features/ai/screens/lessonPlan.dart';
import 'package:alippepro_v1/features/ai/screens/prepareLessonPlan.dart';
import 'package:alippepro_v1/features/ai/widgets/progress_page.dart';
import 'package:alippepro_v1/features/games/screens/mainMenuScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToolButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String link;

  const ToolButton(
      {super.key, required this.text, required this.link, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.pinkAccent),
          ),
        ),
        onPressed: () {
          switch (link) {
            case 'lessonPlan':
              Get.to(const LessonPlanScreen());
              break;
            case 'progress':
              Get.to(const ProgressPage());
              break;
            case 'prepareLessonPlan':
              Get.to(const PrepareLessonPlan());
              break;
            case 'games':
              Navigator.pushNamed(
                context,
                MainMenuScreen.routeName,
              );
              break;
            default:
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.pinkAccent),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                  color: Color(0xFF004C92),
                  fontSize: 20,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
