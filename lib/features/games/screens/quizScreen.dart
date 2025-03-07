import 'dart:convert';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  static String routeName = '/quiz';
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final CarouselSliderController _controller = CarouselSliderController();
  final SocketMethods _socketMethods = SocketMethods();
  var roomDataProvider;
  var answers;
  var _currentPage = 0;
  late TextEditingController questionController;
  final List<TextEditingController> _answerControllers = [];

  final TextEditingController _questionController = TextEditingController();
  bool isEditingQuestion = false;
  bool isEditingAnswer = false;
  bool _isLoading = true; // Состояние загрузки

  @override
  void initState() {
    super.initState();
    
    // Инициализация начального состояния
    Future.delayed(Duration.zero, () {
      _initializeControllers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    roomDataProvider = Provider.of<RoomDataProvider>(context).chatGPTData;
    _initializeControllers();
  }
  
  void _initializeControllers() {
    if (roomDataProvider.isEmpty || !roomDataProvider.containsKey('questions')) {
      return;
    }
    
    var questions = roomDataProvider['questions'];
    if (questions.isEmpty) {
      return;
    }
    
    answers = questions[_currentPage]['answers'];
    questionController = TextEditingController(
        text: questions[_currentPage]['question']);
            
    // Инициализация контроллеров ответов
    _initializeAnswerControllers();
    
    setState(() {
      _isLoading = false;
    });
  }

  void _initializeAnswerControllers() {
    try {
      if (answers == null || answers.isEmpty) return;
      
      _answerControllers.clear();
      for (var answer in answers) {
        _answerControllers.add(TextEditingController(text: answer['text']));
      }
    } catch (e) {
      print("Ошибка инициализации контроллеров ответов: $e");
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Получаем актуальные данные от провайдера
    roomDataProvider = Provider.of<RoomDataProvider>(context).chatGPTData;
    
    // Проверка наличия данных
    final hasData = roomDataProvider.isNotEmpty && 
                    roomDataProvider.containsKey('questions') && 
                    roomDataProvider['questions'].isNotEmpty;
                    
    if (hasData) {
      if (_currentPage < roomDataProvider['questions'].length) {
        questionController = TextEditingController(
            text: roomDataProvider['questions'][_currentPage]['question']);
        answers = roomDataProvider['questions'][_currentPage]['answers'];
        
        // Обновление состояния загрузки
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                
                // Отображение состояния загрузки или контента
                if (_isLoading || !hasData)
                  _buildLoadingState()
                else
                  _buildContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Stack(
      children: [
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
                blurRadius: 5,
              ),
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
              const Text(
                'Викторина-тест даяр',
                style: TextStyle(
                  color: Color(0xff004C92),
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios,
            ),
          ),
        )
      ],
    );
  }
  
  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        const CircularProgressIndicator(
          color: Color(0xff004C92),
        ),
        const SizedBox(height: 20),
        Text(
          'Генерация вопросов...',
          style: GoogleFonts.rubik(
            color: const Color(0xff004C92),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Пожалуйста, подождите...',
          style: GoogleFonts.rubik(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Карусель с вопросами
        _buildQuestionCarousel(),
        const SizedBox(height: 20),
        
        // Сетка ответов
        _buildAnswersGrid(),
        const SizedBox(height: 40),
        
        // Кнопка для запуска викторины
        CustomButton(
          onTap: () {
            _socketMethods.createRoom(
              'Мугалим',
              jsonEncode(roomDataProvider),
            );
          },
          text: 'Викторинаны баштоо',
        ),
      ],
    );
  }
  
  Widget _buildQuestionCarousel() {
    // Проверка наличия вопросов
    if (roomDataProvider['questions'] == null || roomDataProvider['questions'].isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            'Нет доступных вопросов',
            style: GoogleFonts.rubik(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return CarouselSlider(
      carouselController: _controller,
      items: (roomDataProvider['questions'] as List<dynamic>)
          .map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: const BoxDecoration(
                color: Color(0xff004C92),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isEditingQuestion)
                      TextField(
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        controller: _questionController,
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        onSubmitted: (newText) {
                          setState(() {
                            roomDataProvider['questions']
                                [_currentPage]['question'] = newText;
                            isEditingQuestion = false;
                          });
                        },
                      )
                    else
                      Flexible(
                        child: Text(
                          roomDataProvider['questions']
                              [_currentPage]['question'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.visible,
                          softWrap: true,
                          maxLines: 5,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (!isEditingQuestion)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isEditingQuestion = true;
                            _questionController.text =
                                roomDataProvider['questions']
                                    [_currentPage]['question'];
                          });
                        },
                        icon: const Icon(Icons.edit,
                            color: Colors.white),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
      options: CarouselOptions(
        enlargeCenterPage: true,
        height: 200,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentPage = index;
            if (roomDataProvider['questions'] != null && 
                roomDataProvider['questions'].length > index) {
              answers = roomDataProvider['questions'][_currentPage]['answers'];
              _questionController.text = roomDataProvider['questions'][_currentPage]['question'];
              _initializeAnswerControllers();
            }
          });
        },
      ),
    );
  }
  
  Widget _buildAnswersGrid() {
    // Проверка наличия ответов
    if (answers == null || answers.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            'Нет доступных ответов',
            style: GoogleFonts.rubik(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    
    return SizedBox(
      height: 150,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.5,
        ),
        itemCount: answers.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => {
              setState(() {
                answers[index]['correct'] = !answers[index]['correct'];
              })
            },
            onLongPress: () {
              setState(() {
                if (isEditingAnswer) {
                  // Когда уже редактируем ответ, то при нажатии сохраняем изменения
                  if (_answerControllers.length > index) {
                    answers[index]['text'] = _answerControllers[index].text;
                  }
                  isEditingAnswer = false;
                } else {
                  // Иначе начинаем редактировать ответ
                  isEditingAnswer = true;
                  if (_answerControllers.length > index) {
                    _answerControllers[index].text = answers[index]['text'];
                  }
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xff004C92),
                  style: BorderStyle.solid,
                  width: 2,
                ),
                color: answers[index]['correct']
                    ? Colors.green.withOpacity(0.3)
                    : Colors.white,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isEditingAnswer && _answerControllers.length > index)
                      TextField(
                        controller: _answerControllers[index],
                        style: GoogleFonts.rubik(
                          color: const Color(0xff004C92),
                          fontWeight: FontWeight.w500,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (newText) {
                          setState(() {
                            roomDataProvider['questions']
                                    [_currentPage]['answers'][index]
                                ['text'] = newText;
                            isEditingAnswer = false;
                          });
                        },
                      )
                    else
                      Text(
                        answers[index]['text'],
                        style: GoogleFonts.rubik(
                          color: const Color(0xff004C92),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.visible,
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}