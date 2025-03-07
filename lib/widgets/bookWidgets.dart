// app_button.dart
import 'package:alippepro_v1/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            AppColors.buttonGradientStart,
            AppColors.buttonGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppInputField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final InputDecoration? decoration;

  const AppInputField({
    Key? key,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      decoration: decoration ?? InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFFA5156D), width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFFA5156D), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Color(0xFFA5156D), width: 2.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
class AppDropdown extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;
  final bool isExpanded;

  const AppDropdown({
    Key? key,
    required this.hintText,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              hintText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          value: value,
          icon: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.primary,
          ),
          iconSize: 24,
          elevation: 16,
          style: Theme.of(context).textTheme.bodyLarge,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(value),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SmsCodeInput extends StatelessWidget {
  final Function(String) onCompleted;
  final int length;

  const SmsCodeInput({
    Key? key,
    required this.onCompleted,
    this.length = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FocusNode> focusNodes = List.generate(length, (index) => FocusNode());
    List<TextEditingController> controllers =
        List.generate(length, (index) => TextEditingController());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        length,
        (index) => SizedBox(
          width: 48,
          height: 48,
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < length - 1) {
                focusNodes[index].unfocus();
                FocusScope.of(context).requestFocus(focusNodes[index + 1]);
              }

              // Check if all fields are filled
              String code = '';
              bool isCompleted = true;
              for (var controller in controllers) {
                if (controller.text.isEmpty) {
                  isCompleted = false;
                  break;
                }
                code += controller.text;
              }

              if (isCompleted) {
                onCompleted(code);
              }
            },
          ),
        ),
      ),
    );
  }
}
