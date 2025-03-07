// ignore_for_file: must_be_immutable, file_names, prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'package:alippepro_v1/features/games/screens/raiting_screen.dart';
import 'package:alippepro_v1/features/home/home.dart';
import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/recources/socket_methods.dart';
import 'package:alippepro_v1/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Participant {
  final String name;
  final String avatar;
  Participant({required this.name, required this.avatar});
}

class ScoreBoard extends StatefulWidget {
  var showGameResults;
  var scaffold;
  // ignore: use_super_parameters
  ScoreBoard(this.showGameResults, this.scaffold, {Key? key}) : super(key: key);
  @override
  _ScoreBoardState createState() => _ScoreBoardState();
}

class _ScoreBoardState extends State<ScoreBoard> {
  var roomDataProvider;
  late List<dynamic> sortedPlayers;
  final SocketMethods _socketMethods = SocketMethods();
  var infoData;

  @override
  void initState() {
    super.initState();
    roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false).roomData;
    _socketMethods.updateRoomListener(context);
    _updateScores();

    final roomData = Provider.of<RoomDataProvider>(context, listen: false);
    _socketMethods.hasAnswers(roomData.roomData['_id']);
  }

  @override
  void dispose() {
    // Отписка от сокета для предотвращения утечек
    super.dispose();
    _socketMethods.socketClient.off('updateRoom');
    // Provider.of<RoomDataProvider>(context, listen: false).removeAll();
  }

  void _updateScores() {
    setState(() {
      // Фильтруем игроков, исключая создателя комнаты
      if (roomDataProvider['players'] != null) {
        sortedPlayers =
            List<Map<String, dynamic>>.from(roomDataProvider['players'])
                .where((player) => player['playerType'] != 'X')
                .toList();
      }
      // Сортируем игроков по количеству очков в порядке убывания
      sortedPlayers
          .sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    });
  }

  @override
  Widget build(BuildContext context) {
    infoData = Provider.of<RoomDataProvider>(context).infoData;
    roomDataProvider = Provider.of<RoomDataProvider>(context).roomData;

    _updateScores();
    if (infoData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WillPopScope(
      onWillPop: () async {
        Provider.of<RoomDataProvider>(context, listen: false).removeAll();
        Provider.of<RoomDataProvider>(context, listen: false)
            .updateShowGameResults(false);
        return await _showExitConfirmationDialog(context) ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff004C92),
        ),
        backgroundColor: const Color(0xff004C92),
        body: SingleChildScrollView(
          child: SizedBox(
            // height: MediaQuery.of(context).size.height / 1.4,
            child: Column(
              children: [
                widget.showGameResults ? _resultGame() : _buildScoreBoard()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check, color: Colors.white, size: 60),
        const SizedBox(height: 10),
        Text(
          infoData['subjectText'] ?? '',
          style: GoogleFonts.rubik(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Text(
          'АЛДЫДА',
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            itemCount: sortedPlayers.length,
            itemBuilder: (context, index) {
              return LeaderboardItem(
                avatar: '',
                name: sortedPlayers[index]['nickname'],
                points: sortedPlayers[index]['points'],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _resultGame() {
    // Fetch the top players (up to 3)
    final topPlayers = sortedPlayers.take(3).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 10),

            // Текст сверху
            Text(
              infoData['subjectText'] ?? '',
              style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            // Заголовок "АЛДЫДА"
            Text(
              'Жеңүүчүлөр',
              style: GoogleFonts.rubik(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (topPlayers.isNotEmpty) ...[
              // 1st place (highest points)
              _winnerItem(topPlayers[0], 1),
              if (topPlayers.length > 1)
                // 2nd place
                _winnerItem(topPlayers[1], 2),
              if (topPlayers.length > 2)
                // 3rd place
                _winnerItem(topPlayers[2], 3),
            ] else
              const Text('Катышуучулар жок', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  onTap: () {
                    Get.to(const RaitingScreen());
                  },
                  text: 'Рейтинг',
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomButton(
                  onTap: () {
                    // Navigate to ranking page
                    Get.offAll(const HomeScreen());
                  },
                  text: 'Жыйынтыктоо',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _winnerItem(Map<String, dynamic> player, int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                position.toString(),
                style: GoogleFonts.rubik(
                    color: const Color(0xffFFA961),
                    fontSize: 40,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            CircleAvatar(
              backgroundColor: position == 1
                  ? const Color(0xffFFA961)
                  : (position == 2 ? const Color(0xffAC046A) : (Colors.blue)),
              child: Text(
                player['nickname'][0],
                style: const TextStyle(color: Colors.white),
              ), // Display the first letter of the nickname
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player['nickname']} - $position орун',
                  style: GoogleFonts.rubik(
                      fontSize: 20,
                      color: const Color(0xff004C92),
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  '${player['points']} упай',
                  style: GoogleFonts.rubik(
                      fontSize: 20,
                      color: const Color(0xffAC046A),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final String avatar;
  final String name;
  final int points;

  const LeaderboardItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            // backgroundImage: AssetImage(avatar),
            radius: 30,
            child: Text(
              name[0],
              style:
                  GoogleFonts.rubik(fontWeight: FontWeight.w600, fontSize: 22),
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.rubik(
                    color: const Color(0xff004C92),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${points.toString()} упай',
                  style: GoogleFonts.rubik(
                      color: const Color(0xffAC046A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showExitConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Чыгуу'),
      content: const Text('Артка кайткыңыз келеби?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // Stay on the page
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
