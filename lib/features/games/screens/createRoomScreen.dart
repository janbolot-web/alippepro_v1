// ignore_for_file: file_names

import 'dart:convert';

import 'package:alippepro_v1/features/games/screens/quizScreen.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/services/chatgpt_service.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:alippepro_v1/widgets/attempts.dart';
import 'package:alippepro_v1/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});
  static String routeName = '/create-room';

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  bool isSingleAnswer = true;
  bool isMultipleAnswer = false;
  bool isTrueFalse = false;
  String? selectedSubject;
  String? selectedQuestionTimer = '10';
  String? selectedClass;
  String? selectedLanguages;
  String? subject;
  String? selectedQuantity;
  String? subjectText;

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
    "Философия"
  ];

  final List<String> languages = ['KG', 'RU'];
  final List<String> classes = [
    '1-класс',
    '2-класс',
    '3-класс',
    '4-класс',
    '5-класс',
    '6-класс',
    '7-класс',
    '8-класс',
    '9-класс',
    '10-класс',
    '11-класс',
    '12 - класс',
  ];

  final List<String> quantity = [
    "1",
    "3",
    "5",
    "10",
    "15",
    "25",
  ];

  final List<String> questionTime = [
    "5",
    "10",
    "15",
    "20",
    "30",
  ];

  String currentLanguage = 'KY';
  var promptData = {};
  bool isLoading = false;
  String data = '';
  var user;
  var quizPoint = 0;
  final AuthService authService = AuthService();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    getUserLocalData();
    _socketMethods.createRoomSuccessListener(context);
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

        quizPoint =
            aiSubscription != null ? aiSubscription['quizPoint'] ?? 0 : 0;
      });
    }
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

          quizPoint =
              aiSubscription != null ? aiSubscription['quizPoint'] ?? 0 : 0;
        });
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _nameController.dispose();

    super.dispose();
  }

  bool _response = false;

  void _sendMessage() async {
    var data = {
      "selectedSubject": selectedSubject,
      "selectedClass": selectedClass,
      "selectedLanguages": selectedLanguages,
      "subject": subject,
      "selectedQuantity": selectedQuantity,
      "subjectText": subjectText,
    };

    Provider.of<RoomDataProvider>(context, listen: false).updateInfoData(data);
    Provider.of<RoomDataProvider>(context, listen: false).updateChatGPTData({});

    setState(() {
      _response = true;
    });

    var message = selectedLanguages == 'KG'
        ? 'Квиз-стильде JSON-тест түзүңүз, $selectedClass - класстын $selectedSubject китебинин негизинде> темасы: $subjectText $selectedClass-классы үчүн, $selectedQuantity суроодон турган. Предмет: $selectedSubject. Кыйынчылык деңгээли: Абдан кыйын. Суроолор $selectedClass-классынын деңгээлине туура келиши керек. Викторина түрү: ${isTrueFalse ? 'чындык жана жалган' : ""} ${isTrueFalse ? 'суроолорго 2 жооп (чындык же жалган),' : 'суроолорго 4 жооп,'} Туура жооптор: ${isMultipleAnswer ? 'бир нече туура жооп болушу мүмкүн' : 'бир гана туура жооп болушу мүмкүн'}. Ар бир жооп 45 символдон ашпоого тийиш. Кошумча: 1. Ар кандай деңгээлдеги кыйынчылыктарды камтыган суроолорду түзүңүз, анын ичинде татаалыраак суроолорду киргизиңиз.  без лишних текстов, тольо json. Тестин форматы: "questions": [{ "question": "//мисал суроо", "answers": [ {"text": "//мисал жооп", "correct": //мисал туура}, {"text": "//мисал жооп", "correct": //мисал туура}, {"text": "//мисал жооп", "correct": //мисал туура}, {"text": "//мисал жооп", "correct": //мисал туура} ], "time": $selectedQuestionTimer  //здесь надо указать, какое число указано здесь}]'
        : 'Создай JSON-тест в стиле Квиз-стиль на тему: $subjectText для $selectedClass-го класса, включающий $selectedQuantity; вопроса на русском языке. Предмет:$selectedSubject. Сложность: Очень сложный.  Вопросы должны быть на уровне сложности $selectedClass-го класса. Тип викторины: ${isTrueFalse ? 'правда и ложь' : ""} ${isTrueFalse ? 'количество ответов на вопросы: 2 (правда или ложь),' : 'количество ответов на вопросы: 4,'} Правильные ответы: ${isMultipleAnswer ? 'варианты правильных ответов может быть несколько' : 'варианты правильных ответов может быть только один'}. Каждый ответ не должен превышать 45 символов. Дополнительно: 1. Генерировать вопросы с разной степенью сложности, включая более сложные вопросы. без лишних текстов, тольо json. Формат ответа:"questions": [ { "question": "//example question", "answers": [ {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct}, {"text": "//example answer", "correct": //example correct} ], "time": $selectedQuestionTimer //здесь надо указать, какое число указано здесь }  ]';

    var userId = user?['id'];

    final response = await sendMessageToChatGPT(
        context, message, _socketMethods, selectedQuestionTimer, userId);

    if (!mounted) return; // Check if the widget is still mounted

    setState(() {
      _response = false;
    });

    if (response == 200) {
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => const QuizScreen()))
          .then((_) {
        _initLoad(); // Перезагружаем данные
      });
    } else {
      isLoading = false;
      Fluttertoast.showToast(
        msg: 'Бир аздан кийин аракет кылып көрүңүз!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .top, // Компенсация клавиатуры
            ),
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Stack(children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
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
                              const Text('Викторина - тест түзүү',
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
                        Positioned(
                          top: 20,
                          left: 20,
                          child: GestureDetector(
                              onTap: () => Get.back(),
                              child: const Icon(Icons.arrow_back_ios)),
                        )
                      ]),
                      const SizedBox(height: 40), // Placeholder for spacing
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
                              fontSize: 16),
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
                          const SizedBox(width: 5),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedQuantity,
                              style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                              onChanged: (value) =>
                                  setState(() => selectedQuantity = value),
                              decoration: InputDecoration(
                                labelStyle: GoogleFonts.rubik(),
                                labelText: 'Cуроо',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(
                                        0xff004C92), // Color for the normal state
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blue, // Color when the TextField is selected
                                    width: 2.0,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red, // Default Border Color
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              items: quantity.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedLanguages,
                              style: GoogleFonts.rubik(color: Colors.black),
                              onChanged: (value) =>
                                  setState(() => selectedLanguages = value),
                              decoration: InputDecoration(
                                labelText: 'Тил',
                                labelStyle: GoogleFonts.rubik(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(
                                        0xff004C92), // Color for the normal state
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blue, // Color when the TextField is selected
                                    width: 2.0,
                                  ),
                                ),
                                border: const OutlineInputBorder(
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 115,
                            child: DropdownButtonFormField<String>(
                              value: selectedQuestionTimer,
                              style: GoogleFonts.rubik(color: Colors.black),
                              onChanged: (value) =>
                                  setState(() => selectedQuestionTimer = value),
                              decoration: InputDecoration(
                                labelText: 'Таймер',
                                labelStyle: GoogleFonts.rubik(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(
                                        0xff004C92), // Color for the normal state
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .blue, // Color when the TextField is selected
                                    width: 2.0,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red, // Default Border Color
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              items: questionTime.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text('$value сек'),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      TextField(
                        onChanged: (text) {
                          subjectText = text;
                        },
                        style: const TextStyle(fontFamily: 'Montserrat'),
                        decoration: const InputDecoration(
                          labelText: 'Викторинанын темасын жазыңыз...',
                          labelStyle: TextStyle(
                              color: Color(0xffC0C0C0),
                              fontFamily: 'Montserrat',
                              fontSize: 16),
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
                      const SizedBox(height: 20),
                      ExpansionTile(
                        title: Text(
                          'Суроонун түрлөрү',
                          style: GoogleFonts.rubik(
                            color: const Color(0xff004C92),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: <Widget>[
                          CheckboxListTile(
                            title: Text(
                              'Тест (бир туура жооп)',
                              style: GoogleFonts.rubik(
                                color: const Color(0xff004C92),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: isSingleAnswer,
                            onChanged: (bool? value) {
                              setState(() {
                                isSingleAnswer = value!;
                                if (isSingleAnswer) {
                                  isMultipleAnswer = false;
                                  isTrueFalse = false;
                                }
                              });
                            },
                          ),
                          CheckboxListTile(
                            title: Text(
                              'Чындык-ката',
                              style: GoogleFonts.rubik(
                                color: const Color(0xff004C92),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: isTrueFalse,
                            onChanged: (bool? value) {
                              setState(() {
                                isTrueFalse = value!;
                                if (isTrueFalse) {
                                  isMultipleAnswer = false;
                                  isSingleAnswer = false;
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 80,
                      ),
                      Attempts(
                        count: quizPoint,
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
                      GestureDetector(
                        onTap: () => _sendMessage(),
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
                                  "Викторина - тест түзүү",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _response != false ? const Loading() : const Text('')
        ],
      ),
    );
  }
}
