// phone_input_screen.dart
import 'package:alippepro_v1/features/book%D0%A1ompetition/view/regionSelection_screen.dart';
import 'package:alippepro_v1/utils/app_theme.dart';
import 'package:alippepro_v1/widgets/bookWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({Key? key}) : super(key: key);

  @override
  _PhoneInputScreenState createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAE3F4),
              Color(0xFFDDEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // App Logo
                Image.asset(
                  'assets/img/logo.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ALIPPE',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ТАЙМАШ',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Phone input with country code prefix
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '+ 996',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppInputField(
                        controller: _phoneController,
                        hintText: 'Телефон номеринизди жазыңыз',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(9),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Terms and conditions text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Сынакка катталуу менен, сиз биздин',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color(0xff005D67),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Убираем отступ между первым текстом и строкой с кнопкой
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Show terms of service
                          },
                          // Уменьшаем внутренние отступы кнопки
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Колдонуу шарттарыбыз',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Color(0xff005D67),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'жана',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Color(0xff005D67),
                          ),
                        ),
                      ],
                    ),
                    // Уменьшаем отступ между строкой и следующей кнопкой
                    TextButton(
                      onPressed: () {
                        // Show privacy policy
                      },
                      // Уменьшаем внутренние отступы кнопки
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Купуялык саясатыбыздын шарттарына',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Color(0xff005D67),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Уменьшаем отступ между кнопкой и последним текстом
                    SizedBox(height: 2),
                    Text(
                      'макулдугуңузду бересиз.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color(0xff005D67),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 70),
                AppButton(
                  text: 'Катталуу',
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmsVerificationScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Телефон номерин киргизиңиз'),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmsVerificationScreen extends StatelessWidget {
  const SmsVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFAE3F4),
              Color(0xFFDDEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // App Logo
                Image.asset(
                  'assets/img/logo.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ALIPPE',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xff1B434D), // розовый цвет (можно настроить)
                        Color.fromARGB(255, 131, 3,
                            79), // фиолетовый цвет (можно настроить)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'ТАЙМАШ',
                    style: GoogleFonts.montserrat(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors
                          .white, // Важно: цвет должен быть белым для корректной работы градиента
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Телефон номеринизге смс код жөнөтүлдү',
                  style: GoogleFonts.montserrat(
                    color: Color(0xff005D67),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'СМС кодду жазыңыз',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff005D67),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                SmsCodeInput(
                  onCompleted: (String code) {
                    // Verify SMS code
                  },
                ),
                const Spacer(),

                AppButton(
                  text: 'Катталуу',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegionSelectionScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 30,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Сынакка катталуу менен, сиз биздин',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color(0xff005D67),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Убираем отступ между первым текстом и строкой с кнопкой
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Show terms of service
                          },
                          // Уменьшаем внутренние отступы кнопки
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Колдонуу шарттарыбыз',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Color(0xff005D67),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'жана',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Color(0xff005D67),
                          ),
                        ),
                      ],
                    ),
                    // Уменьшаем отступ между строкой и следующей кнопкой
                    TextButton(
                      onPressed: () {
                        // Show privacy policy
                      },
                      // Уменьшаем внутренние отступы кнопки
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Купуялык саясатыбыздын шарттарына',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Color(0xff005D67),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Уменьшаем отступ между кнопкой и последним текстом
                    const SizedBox(height: 2),
                    Text(
                      'макулдугуңузду бересиз.',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color(0xff005D67),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
