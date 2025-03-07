// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/features/games/screens/createRoomScreen.dart';
import 'package:alippepro_v1/features/games/screens/game_screen.dart';
import 'package:alippepro_v1/features/games/screens/joinRoomScreen.dart';
import 'package:alippepro_v1/features/games/screens/mainMenuScreen.dart';
import 'package:alippepro_v1/features/games/screens/quizScreen.dart';
import 'package:alippepro_v1/features/home/home.dart';
import 'package:alippepro_v1/features/loginNew/login_screen.dart';
import 'package:alippepro_v1/features/update.dart';
import 'package:alippepro_v1/providers/chatgpt_provider.dart';
import 'package:alippepro_v1/providers/course_provider.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/providers/story_provider.dart';
import 'package:alippepro_v1/services/auth_controller.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/constants.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:alippepro_v1/providers/user_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';  // Changed from route_manager
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestNotificationPermission();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => CourseDetailProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => ChatgptProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const AlippePro(),
    ),
  );
}

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid && !kIsWeb) {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
}

class AlippePro extends StatefulWidget {
  const AlippePro({super.key});

  @override
  State<AlippePro> createState() => _AlippeProState();
}

class _AlippeProState extends State<AlippePro> {
  final AuthService authService = AuthService();
  final AuthController authController = AuthController();
  
  Map<String, dynamic> token = {};
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  bool? isVersion;
  Map<String, dynamic>? lastVersion;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await getVersion();
    await verificationUser();
    await getUserLocalData();
  }

  Future<void> getUserLocalData() async {
    final response = await getDataFromLocalStorage('user');
    if (response == null || response.isEmpty) {
      debugPrint("Error: response is empty or null");
      return;
    }

    try {
      if (mounted) {
        setState(() {
          user = jsonDecode(response) as Map<String, dynamic>;
        });
      }
    } catch (e) {
      debugPrint("JSON parsing error: $e");
    }
  }

  Future<void> verificationUser() async {
    final prefs = await SharedPreferences.getInstance();
    final response = prefs.getString('user');
    
    if (response != null && response.isNotEmpty && response != 'null') {
      if (mounted) {
        setState(() {
          token = jsonDecode(response);
        });
      }
    }
  }

  Future<void> getVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await http.get(
        Uri.parse('${Constants.uri}/getVersion'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      
      if (mounted) {
        setState(() {
          appName = packageInfo.appName;
          packageName = packageInfo.packageName;
          version = packageInfo.version;
          buildNumber = packageInfo.buildNumber;
          lastVersion = jsonDecode(response.body);
        });
      }

      if (lastVersion == null || lastVersion!.isEmpty) return;

      if (Platform.isAndroid) {
        _checkAndroidVersion();
      } else if (Platform.isIOS) {
        _checkIOSVersion();
      }
    } catch (e) {
      debugPrint("Error getting version: $e");
    }
  }

  void _checkAndroidVersion() {
    if (mounted) {
      setState(() {
        isVersion = buildNumber == lastVersion!['android'].toString() ||
            buildNumber == lastVersion!['updateForAndroid'].toString();
      });
    }
  }

  void _checkIOSVersion() {
    if (mounted) {
      setState(() {
        isVersion = buildNumber == lastVersion!['ios'].toString() ||
            buildNumber == lastVersion!['updateForIos'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => RoomDataProvider(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Alippepro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: GoogleFonts.rubik().fontFamily,
        ),
        routes: {
          MainMenuScreen.routeName: (context) => const MainMenuScreen(),
          JoinRoomScreen.routeName: (context) => const JoinRoomScreen(),
          CreateRoomScreen.routeName: (context) => const CreateRoomScreen(),
          GameScreen.routeName: (context) => const GameScreen(),
          QuizScreen.routeName: (context) => const QuizScreen(),
        },
        home: isVersion == false
            ? const UpdateScreen()
            : token['name']?.isEmpty ?? true
                ? const LoginScreen()
                : const HomeScreen(),
      ),
    );
  }
}