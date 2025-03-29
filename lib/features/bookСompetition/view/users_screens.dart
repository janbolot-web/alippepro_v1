import 'dart:convert';

import 'package:alippepro_v1/services/competition_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParticipantsScreen extends StatefulWidget {
  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  var participants = [];
  int?
      currentUserId; // Добавляем переменную для хранения ID текущего пользователя

  late Future<Map<String, dynamic>?> _userBookFuture;

  @override
  void initState() {
    super.initState();
    _userBookFuture = getLocalData();
    getParticipants();

    // Получаем ID пользователя сразу после получения данных
    _userBookFuture.then((data) {
      if (data != null && data['id'] != null) {
        setState(() {
          currentUserId = data['id'] is int
              ? data['id']
              : int.tryParse(data['id'].toString());
        });
      }
    });
  }

  Future<Map<String, dynamic>?> getLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final userBookString = prefs.getString('userBook');

    if (userBookString == null) {
      return null;
    }

    try {
      return jsonDecode(userBookString) as Map<String, dynamic>;
    } catch (e) {
      print('Ошибка декодирования JSON: $e');
      return null;
    }
  }

  getParticipants() async {
    final response = await ParticipantService().getParticipants();
    setState(() {
      participants = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xff1B434D),
          ),
          child: Text(
            "Катышуучулар",
            style: GoogleFonts.rubik(color: Colors.white, fontSize: 14),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff1B434D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
              future: _userBookFuture,
              builder: (context, snapshot) {
                String idText = 'Загрузка...';

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data != null) {
                    // Преобразуем id в строку, чтобы избежать ошибки типа
                    var id = snapshot.data!['id'];
                    idText = id != null ? id.toString() : 'Н/Д';
                  } else {
                    idText = 'Н/Д';
                  }
                }

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      "ID $idText",
                      style: GoogleFonts.rubik(
                        color: Color(0xff1B434D),
                        fontWeight: FontWeight.bold,
                      ),
                      // Ограничиваем ширину текста, чтобы избежать переполнения
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
        ],
      ),
      body: ListView.builder(
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];

          // Проверяем, совпадает ли ID участника с ID пользователя
          final isSelected = currentUserId != null &&
              participant.id != null &&
              currentUserId ==
                  (participant.id is int
                      ? participant.id
                      : int.tryParse(participant.id.toString()));

          // Преобразуем код региона в удобочитаемый текст
          String displayRegion = participant.region;
          switch (participant.region) {
            case "BISHKEK":
              displayRegion = "Бишкек";
              break;
            case "CHUY":
              displayRegion = "Чуй";
              break;
            case "NARYN":
              displayRegion = "Нарын";
              break;
            case "OSH":
              displayRegion = "Ош";
              break;
            case "ISSYK_KUL":
              displayRegion = "Ысык-Көл";
              break;
            case "TALAS":
              displayRegion = "Талас";
              break;
            case "BATKEN":
              displayRegion = "Баткен";
              break;
            case "JALAL_ABAD":
              displayRegion = "Жалал-Абад";
              break;
            default:
              break;
          }

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFB2C1C8) : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Text(
                "${index + 1}.",
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A3D4D),
                ),
              ),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.fullName,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3D4D),
                      ),
                    ),
                    participant.status == "PARTICIPANT"
                        ? Text(
                            '',
                            style: TextStyle(fontSize: 0),
                          )
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xffFFB82E),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              participant.status,
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                  ]),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ID ${participant.id}",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3D4D),
                    ),
                  ),
                  Text(
                    displayRegion,
                    style: GoogleFonts.montserrat(
                      color: Color(0xFF1A3D4D),
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Обработка нажатия на участника
              },
            ),
          );
        },
      ),
    );
  }
}
