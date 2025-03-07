import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: GoogleFonts.rubik(),
      ),
    ),
  );
}

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, jsonDecode(response.body)['message']);
      break;
    case 500:
      showSnackBar(context, jsonDecode(response.body)['error']);
      break;
    default:
      showSnackBar(context, response.body);
  }
}

void showGameDialog(BuildContext context, String text) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                // GameMethods().clearBoard(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Play Again',
              ),
            ),
          ],
        );
      });
}

void showKahootSnackbar(
    BuildContext context, String message, Color color, IconData icon) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          icon, // Используем переданную иконку
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    backgroundColor: color, // Используем переданный цвет
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class KahootStyleSnackbar extends StatelessWidget {
  const KahootStyleSnackbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kahoot Snackbar Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showKahootSnackbar(
              context,
              'Correct Answer!',
              Colors.green,
              Icons.check_circle_outline, // Передаем иконку
            );
          },
          child: const Text('Show Kahoot Snackbar'),
        ),
      ),
    );
  }
}
