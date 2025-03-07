import 'package:alippepro_v1/utils/app_colors.dart';
import 'package:flutter/material.dart';

void showNotification( BuildContext context, {Color? color = AppColors.greenColor,required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: color, // Цвет фона уведомления
      behavior: SnackBarBehavior.floating, // Плавающее уведомление
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Закругленные углы
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context)
              .hideCurrentSnackBar(); // Закрытие уведомления по нажатию на действие
        },
        label: 'x',
      ),
    ),
  );
}
