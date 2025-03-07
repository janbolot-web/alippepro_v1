// ignore_for_file: file_names, library_private_types_in_public_api, prefer_typing_uninitialized_variables

import 'dart:async';
import 'package:alippepro_v1/features/games/views/resultQuiz.dart';
import 'package:alippepro_v1/features/home/view/home_screen.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class QuizBoard extends StatefulWidget {
  const QuizBoard({super.key});

  @override
  _QuizBoardState createState() => _QuizBoardState();
}

class _QuizBoardState extends State<QuizBoard> with WidgetsBindingObserver {
  final SocketMethods _socketMethods = SocketMethods();
  int _timerDuration = 10;
  Timer? _timer;
  int _currentQuestionIndex = 0;
  bool _showResults = false;
  bool showGameResults = false;
  var _questions;
  var isReplied = false;
  var isInvalid;
  int maxPoints = 1000; // Максимальное количество очков
  int maxTime = 10; // Максимальное время (в секундах)
  int timeRemaining = 10; // Оставшееся время, когда игрок дал правильный ответ
  var roomIdController;
  var roomDataProvider;
  int hasAnswered = 0;
  var players;
  var playersCount;
  List<String> selectedAnswers = []; // Список выбранных ответов игроком
  List<int> selectedAnswersIndex = []; // Список выбранных ответов игроком
  bool correct = false;
  var correctAnswers = [];
  String result = '';
  bool isTrueFalse = false;

  @override
  void initState() {
    super.initState();
    _socketMethods.updateRoomListener(context);
    _questions = Provider.of<RoomDataProvider>(context, listen: false)
        .roomData['questions'];
    roomIdController =
        Provider.of<RoomDataProvider>(context, listen: false).roomData['_id'];
    roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    
    // Fix: Handle both String and int types for time
    var timeValue = roomDataProvider.roomData['questions'][_currentQuestionIndex]['time'];
    _timerDuration = timeValue is String ? int.parse(timeValue) : timeValue as int;
    maxTime = timeValue is String ? int.parse(timeValue) : timeValue as int;
    
    _startTimer();
  }

  @override
  void dispose() {
    // Убираем наблюдатель при удалении виджета
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _socketMethods.socketClient.off('updateRoom');
  }

  // Отслеживаем изменения жизненного цикла приложения
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Если приложение свернуто, перенаправляем пользователя на HomeScreen
      Get.offAll(const HomeScreen());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerDuration > 0) {
          _timerDuration--;
        } else {
          _showResultScreen();
        }
      });
    });
  }

  void _showResultScreen() {
    isReplied = false;
    isInvalid = '';
    _timer?.cancel();
    setState(() {
      _showResults = true;
    });

    if (_currentQuestionIndex == _questions.length - 1) {
      _socketMethods.endGame(
          roomDataProvider.roomData['_id'], true, roomDataProvider.playerId);

      setState(() {
        showGameResults = true;
      });
    }

    Timer(const Duration(seconds: 3), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        
        // Fix: Handle both String and int types for time
        var timeValue = roomDataProvider.roomData['questions'][_currentQuestionIndex]['time'];
        _timerDuration = timeValue is String ? int.parse(timeValue) : timeValue as int;
        maxTime = timeValue is String ? int.parse(timeValue) : timeValue as int;
        
        _showResults = false;
        selectedAnswers.clear();
        selectedAnswersIndex.clear();
      });
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  // Проверяем, выбраны ли все правильные ответы
  bool _areAllCorrectAnswersSelected(List<dynamic> answers) {
    for (var answer in answers) {
      if (answer['correct'] &&
          !selectedAnswersIndex.contains(answers.indexOf(answer))) {
        return false;
      }
      if (!answer['correct'] &&
          selectedAnswersIndex.contains(answers.indexOf(answer))) {
        return false;
      }
    }
    return true;
  }

  void checkAnswer(
      String playerId, List<dynamic> answers, String questionText) {
    timeRemaining = 0;
    timeRemaining = _timerDuration;
    int points = calculateKahootPoints(maxPoints, timeRemaining, maxTime);
    correctAnswers = [];
    for (var i = 0; i < answers.length; i++) {
      if (answers[i]['correct']) {
        correctAnswers.add(answers[i]['text']);
      }
    }
    // Проверка правильности всех выбранных ответов
    correct = _areAllCorrectAnswersSelected(answers);

    // Вызываем метод для отправки результата
    _socketMethods.tapGrid(points, roomIdController, playerId, correct,
        questionText, selectedAnswers, correctAnswers);
    result = correctAnswers.join(', ');

    // Показать Snackbar с результатом ответа
    QuickAlert.show(
      context: context,
      type: correct ? QuickAlertType.success : QuickAlertType.error,
      text: correct ? result : 'Туура жооп: $result',
      title: correct ? 'Сиздин жооп туура!' : 'Сиздин жооп ката!',
      confirmBtnColor: correct ? Colors.green : Colors.red,
      showConfirmBtn: false,
      autoCloseDuration: Duration(
          seconds: timeRemaining,
          milliseconds: 500), // Закрытие через оставшееся время
    );
  }

  int calculateKahootPoints(int maxPoints, int timeRemaining, int maxTime) {
    if (timeRemaining > maxTime) {
      timeRemaining = maxTime;
    }
    double timeFactor = timeRemaining / maxTime;
    int points = (maxPoints * timeFactor).round();
    return points;
  }

  @override
  Widget build(BuildContext context) {
    var question = _questions[_currentQuestionIndex];
    roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
    players = roomDataProvider.roomData['players'];
    isTrueFalse = _questions[_currentQuestionIndex]['answers'].length == 2 ? true : false;
    return _showResults
        ? ScoreBoard(showGameResults, false)
        : WillPopScope(
            onWillPop: () async {
              // Логика обработки нажатия кнопки "Назад"
              Provider.of<RoomDataProvider>(context, listen: false).removeAll();

              Provider.of<RoomDataProvider>(context, listen: false)
                  .updateShowGameResults(false);
              return await _showExitConfirmationDialog(context) ?? false;
            },
            child: Scaffold(
              backgroundColor:
                  _showResults ? const Color(0xff004C92) : Colors.white,
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _buildQuestionScreen(question),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  List<Widget> _buildQuestionScreen(question) {
    // Fix: Handle both String and int types for time
    var timeValue = roomDataProvider.roomData['questions'][_currentQuestionIndex]['time'];
    int timeAsInt = timeValue is String ? int.parse(timeValue) : timeValue as int;
    
    return [
      Padding(
          padding: const EdgeInsets.all(15.0),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: _timerDuration / timeAsInt,
                end: 0.0),
            duration: Duration(seconds: _timerDuration),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                minHeight: 7,
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xff004C92)),
              );
            },
          )),
      Text(
        '0:${_timerDuration.toString().padLeft(2, '0')}',
        style: GoogleFonts.rubik(
            fontSize: 24,
            color: const Color(0xffBA0F43),
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 40,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          height: 200,
          alignment: Alignment.center,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff004C92),
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            question['question'],
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      const SizedBox(
        height: 45,
      ),
      SizedBox(
        height: 200,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: isTrueFalse
              ? const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1,
                )
              : const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2.5,
                ),
          itemCount: question['answers'].length,
          itemBuilder: (BuildContext context, int index) {
            return isTrueFalse
                ? Container(
                    decoration: BoxDecoration(
                      color: question['answers'][index]['text'] ==
                              question['answers'][0]['text']
                          ? const Color.fromARGB(255, 3, 192, 38)
                          : const Color.fromARGB(255, 222, 15, 0),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: question['answers'][index]['text'] ==
                                question['answers'][0]['text']
                            ? const Color.fromARGB(255, 3, 192, 38)
                            : const Color.fromARGB(255, 222, 15, 0),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (isReplied) {
                          return;
                        }
                        isReplied = true;
                        setState(() {
                          if (selectedAnswers
                              .contains(question['answers'][index]['text'])) {
                            selectedAnswersIndex.remove(index);
                            selectedAnswers
                                .remove(question['answers'][index]['text']);
                          } else {
                            selectedAnswers
                                .add(question['answers'][index]['text']);
                            selectedAnswersIndex.add(index);
                          }
                        });
                        var playerId = roomDataProvider.playerId;
                        checkAnswer(playerId, question['answers'],
                            question['question']);
                      },
                      child: Center(
                        child: Text(question['answers'][index]['text'],
                            overflow: TextOverflow.visible,
                            maxLines: 3,
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: selectedAnswers
                              .contains(question['answers'][index]['text'])
                          ? (question['answers'][index]['correct']
                              ? const Color(0xff004C92)
                              : isInvalid == index
                                  ? const Color.fromARGB(255, 222, 15, 0)
                                  : const Color(0xff004C92))
                          : null,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: const Color(0xff004C92),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (isReplied) {
                          return;
                        }

                        // Добавляем или убираем текст ответа из списка выбранных
                        setState(() {
                          if (selectedAnswers
                              .contains(question['answers'][index]['text'])) {
                            selectedAnswersIndex.remove(index);
                            selectedAnswers
                                .remove(question['answers'][index]['text']);
                          } else {
                            selectedAnswers
                                .add(question['answers'][index]['text']);
                            selectedAnswersIndex.add(index);
                          }
                        });
                      },
                      child: Center(
                        child: Text(
                          question['answers'][index]['text'],
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: isInvalid == index
                              ? GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )
                              : selectedAnswers.contains(
                                      question['answers'][index]['text'])
                                  ? GoogleFonts.rubik(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    )
                                  : GoogleFonts.rubik(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                        ),
                      ),
                    ),
                  );
          },
        ),
      ),
      if (!isTrueFalse)
        CustomButton(
          onTap: () {
            if (isReplied) {
              return;
            }
            if (selectedAnswers.isEmpty) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.warning,
                text: 'Туура жоопту танданыз!',
                title: 'Эскертүү',
                confirmBtnText: 'ОК',
                confirmBtnColor: Colors.green,
                autoCloseDuration: const Duration(
                  seconds: 2,
                ), // Закрытие через оставшееся время
              );
              return;
            }
            isReplied = true;
            var playerId = roomDataProvider.playerId;
            checkAnswer(playerId, question['answers'], question['question']);
          },
          text: 'Жооп берүү',
        ),

      // const Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     CircleAvatar(
      //       radius: 20,
      //     ),
      //     SizedBox(width: 8),
      //     CircleAvatar(
      //       radius: 20,
      //     ),
      //     SizedBox(width: 8),
      //     CircleAvatar(
      //       radius: 20,
      //     ),
      //   ],
      // ),
    ];
  }
}

Future<bool?> _showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Чыгуу'),
      content: const Text('Артка кайткыңыз келеби?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Stay on the page
          child: const Text('Жок'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // Exit the page
          child: const Text('Ооба'),
        ),
      ],
    ),
  );
}