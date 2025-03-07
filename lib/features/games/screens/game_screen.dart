// ignore_for_file: unnecessary_null_comparison, prefer_typing_uninitialized_variables

import 'package:alippepro_v1/features/games/views/quizBoard.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:alippepro_v1/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final SocketMethods _socketMethods = SocketMethods();
  TextEditingController roomIdController = TextEditingController();
  late RoomDataProvider roomDataProvider;
  var students;
  var arguments;
  var infoData;
  @override
  void initState() {
    super.initState();
    // _socketMethods.updatePlayersStateListener(context);
    _socketMethods.updateRoomListener(context);
    _socketMethods.endGameListener(context);
    _socketMethods.roomStateListener(context);
    infoData = Provider.of<RoomDataProvider>(context, listen: false).infoData;
    WidgetsBinding.instance.addObserver(this);
    _requestRoomState();

    AppLifecycleListener(
      onResume: () {
        _requestRoomState(); // Вызывается, когда приложение возвращается из фона
      },
    );
  }

  void _requestRoomState() {
    if (roomIdController.text != null && roomIdController.text.isNotEmpty) {
      _socketMethods.requestRoomState(roomIdController.text);
    }
  }

  @override
  void dispose() {
    roomIdController.dispose();
    // Отписка от сокета для предотвращения утечек
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _socketMethods.socketClient.off('updateRoom');
    _socketMethods.socketClient.off('roomState');

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
  print('s');
    // Инициализация roomDataProvider через Provider
    roomDataProvider = Provider.of<RoomDataProvider>(context);

    // Безопасно инициализируем другие переменные
    roomIdController =
        TextEditingController(text: roomDataProvider.roomData['_id']);
    students = roomDataProvider.roomData['players'];
    arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    roomIdController =
        TextEditingController(text: roomDataProvider.roomData['_id']);
    students = roomDataProvider.roomData['players'];
    arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
print(roomDataProvider.roomData['isJoin']);
    return roomDataProvider.roomData['isJoin']
        ? _waitingLobby()
        : const QuizBoard();
  }

  // arguments?['isAuthor'] == true
  //           ? ScoreBoard(false, true)
  //           :

  Widget _waitingLobby() {
    
    return WillPopScope(
      onWillPop: () async {
        // Сначала сохраняем локальные ссылки на RoomDataProvider

        var roomDataProvider =
            Provider.of<RoomDataProvider>(context, listen: false);

        // Выполняем необходимые действия
        roomDataProvider.removeAll();
        roomDataProvider.updateShowGameResults(false);

        // Убедитесь, что контекст остается доступным для endGameListener
        return await _showExitConfirmationDialog(context) ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 30,
          backgroundColor: const Color(0xFF004C92),
          foregroundColor: Colors.white,
        ),
        backgroundColor: const Color(0xFF004C92),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 40),
                  Text(infoData['subjectText'] ?? '',
                      style: GoogleFonts.rubik(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTag(infoData['selectedSubject'] ?? ''),
                      _buildTag(infoData['selectedClass'] ?? ''),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Викторинага кошулган \n окуучулар',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildStudentGrid(roomDataProvider),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CustomTextField(
                        controller: roomIdController,
                        hintText: '',
                        isReadOnly: true,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: roomIdController.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied to clipboard!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Цвет кнопки
                          padding: const EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ), // Закруглённые края
                        ),
                        child: const Icon(
                          Icons.copy,
                          size: 18,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  arguments?['isAuthor'] == true
                      ? CustomButton(
                          onTap: () {
                            if (students.length - 1 == 0) {
                              return showSnackBar(context,
                                  'Катышуулардын саны 1ден жогоруу болушу керек!');
                            }
                            _socketMethods.startGame(roomIdController.text);
                          },
                          text: 'Оюнду баштоо')
                      : const Text(''),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Чыгуу'),
        content: const Text('Артка кайткыңыз келеби?'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(false), // Stay on the page
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(text,
          style: GoogleFonts.rubik(
              color: const Color(0xFF004C92),
              fontSize: 16,
              fontWeight: FontWeight.bold)),
    );
  }

 Widget _buildStudentGrid(RoomDataProvider roomDataProvider) {
  if (students == null || students.isEmpty) {
    return const Center(
      child: Text(
        'Нет студентов',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  int maxVisibleStudents = 5;

  List<dynamic> filteredStudents = students.where((student) => student['playerType'] != 'X').toList();

  return Container(
    height: MediaQuery.of(context).size.height / 3.5,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: const Color(0xff0A71CF),
    ),
    child: GridView.builder(
      shrinkWrap: true,
      itemCount: filteredStudents.length > maxVisibleStudents
          ? maxVisibleStudents + 1
          : filteredStudents.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < maxVisibleStudents) {
          final student = filteredStudents[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  student['nickname'][0],
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w500, fontSize: 22),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                student['nickname'],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          );
        } else {
          int remainingCount = filteredStudents.length - maxVisibleStudents;
          return Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  '+$remainingCount',
                  style: GoogleFonts.rubik(fontWeight: FontWeight.w500, fontSize: 22),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Ещё',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          );
        }
      },
    ),
  );
}
}
