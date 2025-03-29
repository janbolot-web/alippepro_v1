// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:alippepro_v1/features/ai/screens/prepareLessonPlan.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/services/chatgpt_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:alippepro_v1/widgets/attempts.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonPlanScreen extends StatefulWidget {
  const LessonPlanScreen({super.key});

  @override
  _LessonPlanScreenState createState() => _LessonPlanScreenState();
}

class _LessonPlanScreenState extends State<LessonPlanScreen> {
  final ChatgptService chatgptServices = ChatgptService();

  String? selectedSubject;
  String? selectedClass;
  String? selectedLanguages;
  String? subject = '';
  String? selectedMethod;

  final List<String> subjects = [
    "Математика",
    "Алгебра",
    "Геометрия",
    "Физика",
    "Химия",
    "Биология",
    "География",
    "Тарых / История",
    "Кыргыз тили",
    "Орус тили / Русский язык",
    "Кыргыз адабияты",
    "Орус адабияты / Русская литература",
    "Англис тили / English",
    "Немис тили / Deutsch",
    "Француз тили / Français",
    "Сүрөт / ИЗО",
    "Табият таануу / Я и мир",
    "Информатика",
    "Экономика",
    "Дене тарбия / Физкультура",
    "Технология",
    "Музыка",
    "Астрономия",
    "Психология",
    "Философия",
    "Адабий окуу",
    "Адам жана коом"
  ];

  // Example subjects
  final List<String> languages = ['Кыргызча', 'Русский', "English"];
  final List<String> classes = [
    "0-2 жаш",
    "2-4 жаш",
    "4-6 жаш",
    '1 - класс',
    '2 - класс',
    '3 - класс',
    '4 - класс',
    '5 - класс',
    '6 - класс',
    '7 - класс',
    '8 - класс',
    '9 - класс',
    '10 - класс',
    '11 - класс',
    '12 - класс',
  ]; // Example classes
  final List<String> methods = [
    "Классикалык план / Классический план",
    "Комбинированный ",
    "Топ менен иштөө / Работа в группе",
    "Дискуссия ",
    "Дебат / Дебаты",
    "Эркин сабак / Свободный урок",
    "Steam",
    "Жаңы билимди өздөштүрү / Освоение новых знаний",
    "Жалпы класс менен иштөө / Работа с классом",
    "Аралаш сабак / Смешанный урок",
    "Санариптештирилген сабак / Цифровой урок"
  ];
  String currentLanguage = 'KY';
  var promptData = {};
  @override
  bool isLoading = false;
  String data = '';
  var user;
  var planPoint = 0;
  final FocusNode _focusNode = FocusNode();
  final AuthService authService = AuthService();

  Future<void> getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    if (response != null) {
      setState(() {
        user = jsonDecode(response);
        print(user?['subscription']?[0]);

        var aiSubscription = user?['subscription']?.firstWhere(
          (sub) => sub["title"] == "ai" && sub["isActive"] == true,
          orElse: () => null,
        );

        planPoint =
            aiSubscription != null ? aiSubscription['planPoint'] ?? 0 : 0;
      });
    }
  }

  fetchChatGpt() async {
    setState(() {
      isLoading = true;
    });

    promptData = {
      "selectedSubject": selectedSubject,
      "selectedClass": selectedClass,
      "selectedLanguages": selectedLanguages,
      "subject": subject,
      "selectedMethod": selectedMethod
    };
    await chatgptServices.clearLessonPlan(context: context);

    var response = await chatgptServices.fetchChatGptResponse(
        context: context, message: promptData, userId: user['id']);

    if (response == 200) {
      setState(() {
        isLoading = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PrepareLessonPlan())).then((_) {
          _initLoad(); // Перезагружаем данные
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Бир аздан кийин аракет кылып көрүңүз!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
      throw Exception('Не удалось загрузить данные');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocalData();
    _initLoad();
    _focusNode.addListener(_onFocusChange);
    _refresh(); // Затем обновляем с сервера
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _initLoad(); // Обновляем данные при изменении фокуса
    }
  }

  Future<void> _initLoad() async {
    await getUserLocalData();
  }

  Future<void> _refresh() async {
    if (user == null) return;
    var response = await authService.getMe(user!['id']);
    if (response['statusCode'] == 200) {
      final newUserData = await getDataFromLocalStorage('user');
      if (newUserData != null) {
        setState(() {
          user = jsonDecode(newUserData);
          var aiSubscription = user?['subscription']?.firstWhere(
            (sub) => sub["title"] == "ai" && sub["isActive"] == true,
            orElse: () => null,
          );

          planPoint =
              aiSubscription != null ? aiSubscription['planPoint'] ?? 0 : 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xffF0F0F0),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.top, // Компенсация клавиатуры
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 1.125,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(71, 41, 45, 50),
                                offset: Offset(8, 8),
                                spreadRadius: 0,
                                blurRadius: 5),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/img/planLesson.png',
                              width: 50,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text('Сабактын планын түзүү',
                                style: TextStyle(
                                    color: Color(0xff004C92),
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(
                                width: 20), // Placeholder for spacing
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      DropdownButtonFormField<String>(
                        isExpanded: true, // Добавьте эту строку
                        value: selectedSubject,
                        onChanged: (value) =>
                            setState(() => selectedSubject = value),
                        decoration: const InputDecoration(
                          labelText: 'Предмет',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          labelStyle: TextStyle(
                              color: Color(0xffC0C0C0),
                              fontFamily: 'Montserrat',
                              fontSize: 20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Color(0xff004C92), // Цвет в обычном состоянии
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue, // Цвет при фокусе
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // Цвет по умолчанию
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                            fontFamily: 'Montserrat', color: Colors.black),

                        items: subjects
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedClass,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                              onChanged: (value) =>
                                  setState(() => selectedClass = value),
                              decoration: const InputDecoration(
                                labelText: 'Класс',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(
                                        0xff004C92), // Color for the normal state
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blue, // Color when the TextField is selected
                                    width: 2.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red, // Default Border Color
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              items: classes.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedLanguages,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                              onChanged: (value) =>
                                  setState(() => selectedLanguages = value),
                              decoration: const InputDecoration(
                                labelText: 'Тил',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(
                                        0xff004C92), // Color for the normal state
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blue, // Color when the TextField is selected
                                    width: 2.0,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red, // Default Border Color
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              items: languages.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedMethod,
                              style: GoogleFonts.rubik(
                                  fontSize: 13, color: Colors.black),
                              isExpanded:
                                  true, // Разрешает выпадающему списку занимать всю доступную ширину
                              onChanged: (value) =>
                                  setState(() => selectedMethod = value),
                              decoration: const InputDecoration(
                                labelText: 'Сабактын методу',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.black),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xff004C92), width: 1.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2.0),
                                ),
                              ),
                              items: methods.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: GoogleFonts.rubik(fontSize: 13)),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      TextField(
                        onChanged: (text) {
                          subject = text;
                        },
                        style: const TextStyle(fontFamily: 'Montserrat'),
                        decoration: const InputDecoration(
                          labelText: 'Сабактын темасын жазыңыз',
                          labelStyle: TextStyle(
                              color: Color(0xffC0C0C0),
                              fontFamily: 'Montserrat',
                              fontSize: 20),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(
                                  0xff004C92), // Color for the normal state
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors
                                  .blue, // Color when the TextField is selected
                              width: 2.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red, // Default Border Color
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Attempts(
                        count: planPoint,
                      ),
                      Text(
                        'аракетиңиз калды',
                        style: GoogleFonts.montserrat(
                            color: const Color(0xff004C92),
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // Text(response.messages?[0]?['message']?['content'] != null ? response.messages?[0]['message']?['content'] :''),
                      SizedBox(
                          // width: MediaQuery.of(context).size.width / 1.3,
                          child: TextButton(
                        onPressed: () => fetchChatGpt(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF0099), // Pink color
                                Color(0xFF1387F2)
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                5), // Optional: add a border radius if needed
                          ),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Генерациялоо',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Attempts(
                                  count: 1,
                                ),
                              ]),
                        ),
                      )),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                isLoading == true
                    ? Container(
                        color: Colors.black.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Center(
                              child: Text(
                                'Сиздин тапшырма аткарылып жатат, күтө туруңуз...',
                                style: TextStyle(
                                    fontFamily: "Montserrat",
                                    color: Colors.white,
                                    fontSize: 14),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            LinearProgressIndicator(
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xffFF0099),
                            ),
                          ],
                        ),
                      )
                    : const Text("")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
