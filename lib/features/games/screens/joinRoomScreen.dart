// ignore_for_file: file_names

import 'package:alippepro_v1/custom_textfield.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Импорт для работы с буфером обмена

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});
  static String routeName = '/join-room';

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  final SocketMethods _socketMethods = SocketMethods();
  late RoomDataProvider roomDataProvider;

  @override
  void initState() {
    super.initState();

    _socketMethods.joinRoomSuccessListener(context);
    _socketMethods.updateRoomListener(context);
    _socketMethods.errorOccuredListener(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    roomDataProvider = Provider.of<RoomDataProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gameIdController.dispose();
    _socketMethods.socketClient.off('updateRoom');
    _socketMethods.socketClient.off('joinRoomSuccess');
    super.dispose();
  }

  // Метод для вставки текста из буфера обмена
  Future<void> _pasteFromClipboard() async {
    ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData != null && clipboardData.text != null) {
      _gameIdController.text = clipboardData.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Логика обработки нажатия кнопки "Назад"
        Provider.of<RoomDataProvider>(context, listen: false).removeAll();
        Provider.of<RoomDataProvider>(context, listen: false)
            .updateShowGameResults(false);
        return true; // true — разрешить возврат, false — заблокировать
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF0F0F0),
        appBar: AppBar(),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
                      'assets/img/pet.png',
                      width: 50,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text('Оюнга кошулуу',
                        style: TextStyle(
                            color: Color(0xff004C92),
                            fontSize: 20,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 20), // Placeholder for spacing
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              CustomTextField(
                controller: _nameController,
                hintText: "",
                labelText: 'Атыңызды жазыңыз',
                type: '',
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _gameIdController,
                      hintText: "",
                      labelText: 'Оюндун кодун жазыңыз',
                      type: '',
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 1,
                            color: const Color(0xff004C92),
                            style: BorderStyle.solid)),
                    child: TextButton(
                      onPressed: _pasteFromClipboard,
                      child: const Icon(Icons.paste, color: Color(0xff004C92)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Кнопка "Paster" для вставки из буфера обмена

              const SizedBox(
                height: 40,
              ),
              CustomButton(
                  onTap: () => {
                        _socketMethods.joinRoom(_nameController.text,
                            _gameIdController.text, roomDataProvider.playerId)
                      },
                  text: "Кошулуу")
            ],
          ),
        ),
      ),
    );
  }
}
