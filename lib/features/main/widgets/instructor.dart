import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerPage extends StatefulWidget {
  const YoutubePlayerPage({super.key});

  @override
  _YoutubePlayerPageState createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Задайте нужный videoId. Например, этот videoId принадлежит легендарному видео ;)
    _controller = YoutubePlayerController(
      initialVideoId: 'YkgXmpXf44w',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        onEnded: (metaData) {
          // Автоматически закрываем экран, когда видео завершилось
          Navigator.pop(context);
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: AspectRatio(
                  // Вертикальный формат: ширина 9, высота 16
                  aspectRatio: 9 / 16,
                  child: player,
                ),
              ),
              // Кнопка для ручного закрытия экрана
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
