// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:io';

import 'package:alippepro_v1/features/ai/view/ai_screen.dart';
import 'package:alippepro_v1/features/author/view/author_screen.dart';
import 'package:alippepro_v1/features/book%D0%A1ompetition/view/splash_screen.dart';
import 'package:alippepro_v1/features/e-book/e-book.dart';
import 'package:alippepro_v1/features/main/view/newDetail_screen.dart';
import 'package:alippepro_v1/features/main/widgets/instructor.dart';
import 'package:alippepro_v1/features/main/widgets/ishker.dart';
import 'package:alippepro_v1/features/market/view/market_screen.dart';
import 'package:alippepro_v1/features/podcast/view/podcast_screen.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MainScreen extends StatefulWidget {
  final isLoading;
  final user;
  const MainScreen({super.key, this.isLoading, this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var user;
  var subscriptions;
  var live = false;
  var serverUserData; // Добавим переменную для хранения данных с сервера
  final AuthService authService = AuthService();
  File? _cachedAvatar;
  String? _currentAvatarUrl;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initLoad();
    _focusNode.addListener(_onFocusChange);
    _loadCachedAvatar();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _initLoad(); // Загружаем данные при возвращении
      print('object');
    }
  }

  Future<void> _loadCachedAvatar() async {
    if (user?['avatarUrl'] != null) {
      _cachedAvatar = await _getCachedAvatar(user!['avatarUrl']);
      _currentAvatarUrl = user!['avatarUrl'];
    }
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
        live = user?['subscription']?.any(
                (sub) => sub["title"] == "live" && sub["isActive"] == true) ??
            false;
      });
    }
  }

  Future<void> _refresh() async {
    var response = await authService.getMe(widget.user?['id']);

    if (response['statusCode'] == 200) {
      final newUserData = await getDataFromLocalStorage('user');
      serverUserData = jsonDecode(newUserData!);

      final newAvatarUrl = serverUserData?['avatarUrl'];

      // Если аватар изменился
      setState(() {
        user = jsonDecode(newUserData);
        live = user?['subscription']?.any(
                (sub) => sub["title"] == "live" && sub["isActive"] == true) ??
            false;
      });
      if (newAvatarUrl != null && newAvatarUrl != _currentAvatarUrl) {
        // Удаляем старый кэш
        if (_currentAvatarUrl != null) {
          await DefaultCacheManager().removeFile(_currentAvatarUrl!);
        }
        // Загружаем и кэшируем новый аватар
        _cachedAvatar = await _cacheImage(newAvatarUrl);
        _currentAvatarUrl = newAvatarUrl;
      }

      // Сохраняем локальные данные
      if (!_deepCompare(user, serverUserData)) {
        await saveDataToLocalStorage('user', newUserData);
        user = serverUserData;
      }

      // Остальная логика...
    } else {}
  }

  Future<File?> _cacheImage(String url) async {
    // Проверяем, есть ли уже кэш
    final cachedFile = await DefaultCacheManager().getFileFromCache(url);
    if (cachedFile != null && await cachedFile.file.exists()) {
      return cachedFile.file;
    }

    // Если нет — грузим и сохраняем
    final file = await DefaultCacheManager().getSingleFile(url);
    final directory = await getApplicationDocumentsDirectory();
    return file.copy('${directory.path}/${p.basename(url)}');
  }

  Future<File?> _getCachedAvatar(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(url);
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error getting cached avatar: $e');
      return null;
    }
  }

  bool _deepCompare(a, b) {
    if (a == b) return true;
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepCompare(a[key], b[key])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepCompare(a[i], b[i])) return false;
      }
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (user.containsKey('access') ==false) {
    //   print('Свойство access существует');
    // } else {
    //   print('Свойство access отсутствует');
    // }

    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: false,
              backgroundColor: Colors.white,
              pinned: true,
              toolbarHeight: 65,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                ),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FlexibleSpaceBar(
                      centerTitle: true,
                      title: Row(
                        children: [
                          const SizedBox(width: 20),
                          CircleAvatar(
                            backgroundColor: Colors.black12,
                            radius: 25,
                            backgroundImage: (user?['avatarUrl'] != null
                                ? NetworkImage(user!['avatarUrl'])
                                : null),
                            // backgroundImage:
                            //     AssetImage('assets/img/avatar.jpg'),
                            child: _buildAvatarChild(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            user != null ? user['name'] : '',
                            style: GoogleFonts.rubik(
                              fontSize: 18.0,
                              color: const Color(0xff1B434D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Эмне жаңылык',
                          style: GoogleFonts.rubik(
                              fontSize: 24.0,
                              color: const Color(0xff1B434D),
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 130,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const YoutubePlayerPage(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return ScaleTransition(
                                              scale: Tween<double>(
                                                      begin: 0.5, end: 1.0)
                                                  .animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeOut,
                                                ),
                                              ),
                                              child: child,
                                            );
                                          },
                                        ));
                                    // Get.to(YoutubePlayerPage());
                                    // Get.to(const NewDetailScreen(
                                    //     img: 'assets/img/instuc.png'));
                                  },
                                  child: SizedBox(
                                    // width:
                                    //     MediaQuery.of(context).size.width * 0.7,
                                    child: Image.asset(
                                      'assets/img/instuc.png',
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(const NewDetailScreen(
                                        img: 'assets/img/news.png'));
                                  },
                                  child: SizedBox(
                                    child: Image.asset(
                                      'assets/img/news.png',
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(const TeacherProgramScreen());
                                  },
                                  child: SizedBox(
                                    child: Image.asset(
                                      'assets/img/ishker.png',
                                      height: 100,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/logo.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text(
                              'Жасалма интеллект',
                              style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffBC0273)),
                            ),
                            subtitle: Text('менен жумушуңузду жеңилдетиңиз',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            onTap: () {
                              Get.to(const AiScreen());
                              // Get.to(const RaitingScreen());
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/podcastIcon.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text('Подкаст',
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1B434D))),
                            subtitle: Text('билим берүүдөгү маанилуу маселелер',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Get.to(const PodcastScreen());
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/e-book.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text('Электрондук китептер',
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1B434D))),
                            subtitle: Text('сиз издеген китептердин топтому',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Get.to(const EBookScreen());
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/shop.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text('Alippe Market',
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1B434D))),
                            subtitle: Text('сиз издеген китептердин топтому',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Get.to(const MarketScreen());
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/author.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text('Авторлор',
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1B434D))),
                            subtitle: Text('Компания тууралуу маалымат',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Get.to(const AuthorPage());
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Любой цвет фона, который вам нужен
                            borderRadius: BorderRadius.circular(
                                10.0), // Опционально, для закругленных углов
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/img/author.png',
                              width: 40,
                              height: 40,
                            ),
                            title: Text('Авторлор',
                                style: GoogleFonts.rubik(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff1B434D))),
                            subtitle: Text('Компания тууралуу маалымат',
                                style: GoogleFonts.rubik(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff1B434D))),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                            ),
                            onTap: () {
                              Get.to(const WelcomeScreen());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarChild() {
    if (user == null) {
      return const CircularProgressIndicator();
    }

    if (user['avatarUrl'] == null || user['avatarUrl'].isEmpty) {
      return const Icon(Icons.person, size: 25);
    }

    // Показываем прогресс только при первой загрузке
    return widget.isLoading
        ? const CircularProgressIndicator()
        : const SizedBox();
  }
}
