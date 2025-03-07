import 'package:alippepro_v1/services/course_services.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // Импортируем пакет

class YoutubePlayerIframe extends StatefulWidget {
  final lessonId;
  final courseId;
  const YoutubePlayerIframe({super.key, this.courseId, this.lessonId});

  @override
  State<YoutubePlayerIframe> createState() => _YoutubePlayerIframeState();
}

class _YoutubePlayerIframeState extends State<YoutubePlayerIframe> {
  String videoId = '';
  final CourseService courseService = CourseService();
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    secureScreen(); // Защищаем экран
    getLesson();
  }

  /// Функция для запрета скриншотов и записи экрана
  Future<void> secureScreen() async {
    // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  /// Функция для получения YouTube video ID из URL
  String getYouTubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'(?:(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=))|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
      multiLine: false,
    );
    var match = regExp.firstMatch(url);
    return match != null ? match.group(1) ?? '' : '';
  }

  /// Получение урока и инициализация плеера
  Future<void> getLesson() async {
    final params = {"courseId": widget.courseId, "lessonId": widget.lessonId};

    final courses = await courseService.getLesson(params);
    videoId = getYouTubeVideoId(courses['videoUrl']);

    // Инициализация контроллера после получения videoId
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    setState(() {}); // Обновление экрана после получения данных
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose(); // Не забываем освобождать ресурсы
    
    super.dispose();
  }
}
