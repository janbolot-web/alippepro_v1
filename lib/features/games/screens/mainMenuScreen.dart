// ignore_for_file: file_names

import 'dart:convert';

import 'package:alippepro_v1/features/games/screens/createRoomScreen.dart';
import 'package:alippepro_v1/features/games/screens/joinRoomScreen.dart';
import 'package:alippepro_v1/features/payment/view/payment_screen.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  static String routeName = '/main-menu';

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  void createRoom(BuildContext context) {
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context) {
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }

  Map<String, dynamic>? user;
  bool ai = false;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initLoad();

    // Очищаем playerId после завершения фазы сборки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomDataProvider>(context, listen: false).removeAll();
    });
  }

  Future<void> _initLoad() async {
    await getUserLocalData();
    await _refresh(); // Затем обновляем с сервера
  }

  Future<void> getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    if (response != null) {
      setState(() {
        user = jsonDecode(response);
        ai = user?['subscription']?.any(
                (sub) => sub["title"] == "ai" && sub["isActive"] == true) ??
            false;
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
          ai = user?['subscription']?.any(
                  (sub) => sub["title"] == "ai" && sub["isActive"] == true) ??
              false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RoomDataProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
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
                      const Text('Оюн түзүү',
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
                  height: 100,
                ),
                Column(
                  children: [
                    ai == true
                        ? CustomButton(
                            onTap: () {
                              createRoom(context);
                            },
                            text: "Жаңы викторина түзүү")
                        : GestureDetector(
                            onTap: () async {
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (context) =>
                                    const CustomBottomSheet(product: 'ai'),
                              );
                              if (result == true) {
                                await _refresh();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PaymentSuccessDialog(
                                      onRedirect: () {
                                        // Get.to(LessonPlanScreen());
                                      },
                                      message: 'Төлөм ийгиликтүү аяктады!',
                                    );
                                  },
                                );
                              }
                            },
                            child: _buildLockedContent(),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomButton(
                        onTap: () {
                          joinRoom(context);
                        },
                        text: "Оюнга кошулуу")
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

Widget _buildLockedContent() {
  return Container(
    // decoration: BoxDecoration(
    //   gradient: const LinearGradient(
    //     colors: [Color(0xffFF0099), Color(0xff1387F2)],
    //     begin: Alignment.topLeft,
    //     end: Alignment.bottomRight,
    //   ),
    //   borderRadius: BorderRadius.circular(12),
    //   border: Border.all(color: Colors.pink.shade100, width: 2),
    // ),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFFE1E1E1), // 0%
          Color(0xFF838383), // 100%
        ],
      ),
      border: Border.all(
        color: const Color.fromARGB(
            56, 131, 131, 131), // Дополнительный акцентный цвет
        width: 2,
      ),
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 0,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: const Color(0xff5B5B5B),
                borderRadius: BorderRadius.circular(50)),
            child: const Icon(
              Icons.lock,
              color: Color(0xffFFD861), // Белый замок для контраста
              size: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Жаңы викторина түзүү',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
