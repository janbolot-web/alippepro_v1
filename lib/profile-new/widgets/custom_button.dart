import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.color,
    this.text,
    this.onTap,
    this.textColor,
  });
  final Color? color;
  final String? text;
  final Function()? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: color,
        ),
        onPressed: onTap,
        child: Text(
          text ?? "",
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.black),
        ),
      ),
    );
  }
}