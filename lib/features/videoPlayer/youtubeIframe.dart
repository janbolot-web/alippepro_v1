// ignore_for_file: prefer_typing_uninitialized_variables, file_names

import 'package:alippepro_v1/services/course_services.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:flutter/services.dart';

class YoutubeIframe extends StatefulWidget {
  const YoutubeIframe(
      {super.key, required this.lessonId, required this.courseId});

  final String lessonId;
  final String courseId;

  @override
  State<YoutubeIframe> createState() => _YoutubeIframeState();
}

class _YoutubeIframeState extends State<YoutubeIframe> {
  PodPlayerController? controller;
  final CourseService courseService = CourseService();
  var courses;
  var url = '';

  @override
  void initState() {
    super.initState();
    getLesson();
  }

  @override
  void dispose() {
    // Dispose of the controller if it has been initialized
    controller?.dispose();
    // Lock the screen orientation to portrait when the widget is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> getLesson() async {
    final params = {"courseId": widget.courseId, "lessonId": widget.lessonId};

    courses = await courseService.getLesson(params);
    url = courses!['videoUrl'];

    // Initialize the controller after the URL is retrieved
    controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.youtube(url),
        podPlayerConfig: const PodPlayerConfig(
            autoPlay: true, isLooping: false, videoQualityPriority: [720]))
      ..initialise();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: url.isNotEmpty && controller != null
            ? PodVideoPlayer(controller: controller!)
            : const CircularProgressIndicator(), // Show a loader while the videoId is being fetched
      ),
    );
  }
}
