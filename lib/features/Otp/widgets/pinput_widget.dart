import 'package:alippepro_v1/services/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinputWidget extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final phoneNumber;
  const PinputWidget({super.key, required this.phoneNumber});

  @override
  State<PinputWidget> createState() => _PinputWidgetState();
}

class _PinputWidgetState extends State<PinputWidget> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  AuthController authController = AuthController();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  someMethod(context, verificationCode) async {
    try {
      await authController.verifyCode(
          context, widget.phoneNumber, verificationCode);
      // Обработайте реультат verificationResult здесь
    } catch (error) {
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color(0xffAC046A);
    const fillColor =  Colors.transparent;
    const borderColor =  Color(0xffAC046A);
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color(0xffAC046A),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              controller: pinController,
              keyboardType: TextInputType.number,
              focusNode: focusNode,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              separatorBuilder: (index) => const SizedBox(width: 8),

              // onClipboardFound: (value) {
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (String input) {
                // authController.verifyOtp(input);
                someMethod(context, input);

                // Get.to(() => ProfileSettingsScreen());
              },
              onChanged: (value) {
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
         
        ],
      ),
    );
  }
}
