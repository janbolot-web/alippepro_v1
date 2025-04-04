// region_selection_screen.dart
import 'dart:convert';

import 'package:alippepro_v1/features/book%D0%A1ompetition/view/phoneInput_screen.dart';
import 'package:alippepro_v1/features/book%D0%A1ompetition/view/users_screens.dart';
import 'package:alippepro_v1/services/competition_service.dart';
import 'package:alippepro_v1/widgets/bookWidgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_theme.dart';

class RegionSelectionScreen extends StatefulWidget {
  const RegionSelectionScreen({super.key});

  @override
  _RegionSelectionScreenState createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> {
  String? _selectedRegion;
  String? _selectedBookType;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final ParticipantService _participantService = ParticipantService();

  final List<String> _regions = [
    'Бишкек',
    'Чуй',
    'Нарын',
    'Ош',
    'Ысык-Көл',
    'Талас',
    'Баткен',
    'Жалал - Абад',
  ];
  final List<String> _bookTypes = [
    'Китептин аталышы',
  ];
  bool _isRegionExpanded = false;
  bool _isBookTypeExpanded = false;
  ParticipantResponse? _response;

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    var region = _selectedRegion;
    switch (region) {
      case "Бишкек":
        region = "BISHKEK";
        break;
      case "Чуй":
        region = "CHUY";
        break;
      case "Нарын":
        region = "NARYN";
        break;
      case "Ош":
        region = "OSH";
        break;
      case "Ысык-Көл":
        region = "ISSYK_KUL";
        break;
      case "Талас":
        region = "TALAS";
        break;
      case "Баткен":
        region = "BATKEN";
        break;
      case "Жалал - Абад":
        region = "JALAL_ABAD";
        break;
      default:
        break;
    }

    try {
      final userBook = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('userBook'));
      var userData = jsonDecode(userBook!);

      final request = ParticipantRequest(
        fullName: _nameController.text,
        region: region,
        bookId: 1,
        phone: "+996${userData['phone'].toString()}",
        // additionalInfo: _addInfoController.text,
      );

      final response = await _participantService.createParticipant(request);

      if (response == 200 || response == 201) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ParticipantsScreen(),
          ),
          (Route<dynamic> route) =>
              route.isFirst, // Сохранить только первый экран в стеке
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Ийгиликтүү катталдыңыз!'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // App Logo
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/img/logo.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(
                                  0xff1B434D), // розовый цвет (можно настроить)
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
                          return const LinearGradient(
                            colors: [
                              Color(
                                  0xff1B434D), // розовый цвет (можно настроить)
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
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'Өзүңүз тууралуу маалыматты так толтуруңуз',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xff005D67),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Name input
                AppInputField(
                  controller: _nameController,
                  hintText: 'Аты жөнүңүз толугу менен',
                  decoration: InputDecoration(
                    hintText: 'Аты жөнүңүз толугу менен',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                const SizedBox(height: 16),
                // Region dropdown
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRegionExpanded = !_isRegionExpanded;
                      _isBookTypeExpanded = false;
                    });
                  },
                  child: AppDropdown(
                    hintText: 'Жашаган аймагыңыз',
                    items: _regions,
                    value: _selectedRegion,
                    isExpanded: _isRegionExpanded,
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value!;
                        _isRegionExpanded = false;
                      });
                    },
                  ),
                ),
                if (_isRegionExpanded)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _regions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_regions[index]),
                          onTap: () {
                            setState(() {
                              _selectedRegion = _regions[index];
                              _isRegionExpanded = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Book type dropdown
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isBookTypeExpanded = !_isBookTypeExpanded;
                      _isRegionExpanded = false;
                    });
                  },
                  child: AppDropdown(
                    hintText: 'Китептин аталышы',
                    items: _bookTypes,
                    value: _selectedBookType,
                    isExpanded: _isBookTypeExpanded,
                    onChanged: (value) {
                      setState(() {
                        _selectedBookType = value;
                        _isBookTypeExpanded = false;
                      });
                    },
                  ),
                ),
                if (_isBookTypeExpanded)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.inputBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _bookTypes.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_bookTypes[index]),
                          onTap: () {
                            setState(() {
                              _selectedBookType = _bookTypes[index];
                              _isBookTypeExpanded = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                // Name input
                AppInputField(
                  controller: _bookController,
                  hintText: 'Китептин коду',
                  decoration: InputDecoration(
                    hintText: 'Китептин коду',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color(0xFFA5156D), width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: 'Катталуу',
                  isLoading: _isLoading ? true : false,
                  onPressed: () {
                    // Complete registration process
                    if (_nameController.text.isNotEmpty &&
                        _selectedRegion != null &&
                        _bookController.text.isNotEmpty &&
                        _selectedBookType != null) {
                      // Navigate to home screen or show success message
                      _submitForm();

                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     backgroundColor: Colors.green,
                      //     content: Text('Ийгиликтүү катталдыңыз!'),
                      //   ),
                      // );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Бардык талааларды толтуруңуз'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Сынакка катталуу менен, сиз биздин',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xff005D67),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Убираем отступ между первым текстом и строкой с кнопкой
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Show terms of service
                          },
                          // Уменьшаем внутренние отступы кнопки
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Колдонуу шарттарыбыз',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: const Color(0xff005D67),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'жана',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: const Color(0xff005D67),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Купуялык саясатыбыздын шарттарына',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xff005D67),
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
                        color: const Color(0xff005D67),
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
