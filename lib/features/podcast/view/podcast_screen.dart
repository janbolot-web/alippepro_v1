// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  _PodcastScreenState createState() => _PodcastScreenState();
}

late YoutubePlayerController _controller;
late YoutubePlayerController _controller2;
late YoutubePlayerController _controller3;
late YoutubePlayerController _controller4;
late YoutubePlayerController _controller5;

class _PodcastScreenState extends State<PodcastScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const AboutPodcastPage(),
    const ReleasesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final videoId =
        YoutubePlayer.convertUrlToId("https://youtu.be/4mxZ-Vvb5EY");

    final videoId2 =
        YoutubePlayer.convertUrlToId("https://youtu.be/-ddRVHRRCjw");

    final videoId3 =
        YoutubePlayer.convertUrlToId("https://youtu.be/821zy4-TFBY");

    _controller3 = YoutubePlayerController(
        initialVideoId: videoId3!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ));

    final videoId4 =
        YoutubePlayer.convertUrlToId("https://youtu.be/Ff8LgYfY0oM");

    _controller4 = YoutubePlayerController(
        initialVideoId: videoId4!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ));

    final videoId5 =
        YoutubePlayer.convertUrlToId("https://youtu.be/NnjRgmJOz-s");

    _controller5 = YoutubePlayerController(
        initialVideoId: videoId5!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ));

    _controller = YoutubePlayerController(
        initialVideoId: videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ));

    _controller2 = YoutubePlayerController(
        initialVideoId: videoId2!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            title: Text(
              'Подкаст',
              style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1B434D)),
            ),
            pinned: true,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                Row(
                    // color: Colors.white,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButtons(
                        borderColor: const Color(0xff054E45),
                        selectedBorderColor: const Color(0xff054E45),
                        borderRadius: BorderRadius.circular(20),
                        fillColor: const Color(0xff054E45),
                        color: const Color(0xff054E45),
                        selectedColor: Colors.white,
                        isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                        onPressed: (int index) {
                          _onItemTapped(index);
                        },
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Подкаст тууралуу',
                              style: GoogleFonts.rubik(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Чыгарылыштар',
                              style: GoogleFonts.rubik(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _pages[_selectedIndex],
            ]),
          ),
        ],
      ),
    );
  }
}

class AboutPodcastPage extends StatelessWidget {
  const AboutPodcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          RichText(
              text: TextSpan(
                  style: GoogleFonts.rubik(
                      color: const Color(0xff005558),
                      fontSize: 14,
                      letterSpacing: .5,
                      fontWeight: FontWeight.normal),
                  text: '    Салам, достор! Назарыңыздарда ',
                  children: [
                TextSpan(
                  text: "Alippe ",
                  style: GoogleFonts.rubik(
                      color: const Color(0xffBA0F43),
                      fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: 'подкасты.\n'),
                const TextSpan(
                    text:
                        '\n    Бул подкастта балдарга, өспүрүмдөргө билим жана тарбия берүү багытында ушул тармактын кыйын эксперттери, таанымал инсандары менен маек курабыз.\n\n'),
                const TextSpan(
                    text:
                        '\n    Билим жана тарбия берүүдөгү өлкөбүздөгү жүйөөлү көйгөйлөрдү чечүү жолдору, тарбия берүүдөгү учурдагы актуалдуу кеңештер биздин подкастта орун алат\n\n'),
                const TextSpan(
                    text: '\n    Сизге жагымдуу көрүү каалайбыз!\n\n'),
              ])),
          YoutubePlayer(
            controller: _controller2,
            showVideoProgressIndicator: true,
          ),
        ],
      ),
    );
  }
}

class ReleasesPage extends StatelessWidget {
  const ReleasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 48,
          ),
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          YoutubePlayer(
            controller: _controller2,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          YoutubePlayer(
            controller: _controller3,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          YoutubePlayer(
            controller: _controller4,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          YoutubePlayer(
            controller: _controller5,
            showVideoProgressIndicator: true,
          ),
          const SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
