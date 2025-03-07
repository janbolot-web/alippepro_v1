import 'dart:convert';
import 'dart:math';

import 'package:alippepro_v1/features/payment/view/payment_screen.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class VideoConference extends StatefulWidget {
  const VideoConference({
    super.key,
  });

  @override
  State<VideoConference> createState() => _VideoConferenceState();
}

class _VideoConferenceState extends State<VideoConference> {
  final meetingNameController = TextEditingController();
  final jitsiMeet = JitsiMeet();
  var user;
  bool isButtonEnabled = false;

  bool ai = false;
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    getUserLocalData();
    _initLoad();

    meetingNameController.addListener(() {
      setState(() {
        isButtonEnabled = meetingNameController.text.isNotEmpty;
      });
    });
  }

  String generateRoomCode() {
    final random = Random();
    String code = '';
    for (var i = 0; i < 6; i++) {
      code += random.nextInt(10).toString();
    }
    return code;
  }

  void join([String? roomCode]) {
    Map<String, Object> featureFlag = {};
    featureFlag['welcomepage.enabled'] = false;
    featureFlag['prejoinpage.enabled'] = true;
    featureFlag['add-people.enabled'] = true;
    featureFlag['ios.recording.enabled'] = true;
    featureFlag['ios.screensharing.enabled'] = true;

    var options = JitsiMeetConferenceOptions(
      room: roomCode ?? meetingNameController.text,
      serverURL: 'https://jitsi.103-195-6-237.cloud-xip.com/',
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
        "subject": 'Код - ${roomCode ?? meetingNameController.text}',
      },
      userInfo: JitsiMeetUserInfo(
          displayName: user['name'], email: 'email', avatar: user['avatarUrl']),
      featureFlags: featureFlag,
    );
    var jitsiMeet = JitsiMeet();
    jitsiMeet.join(options);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Alippe Meet',
          style: GoogleFonts.rubik(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xff1B434D)),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Text(
                    'Мугалимдер үчүн видеочалуулар жана жолугушуулар',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                        color: const Color(0xff1B434D),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    'Кайда болбоңуз Alippe Meet окуучуларыңыз\n же коллегаларыңыз менен чогу иштешүү \nүчүн  видео байланыш түзүп бере алат',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(height: 20),
                ai
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final roomCode = generateRoomCode();
                            join(roomCode);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1B434D),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Жаңы түз эфир түзүү",
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: GestureDetector(
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
                                      Get.to(const VideoConference());
                                    },
                                    message: 'Төлөм ийгиликтүү аяктады!',
                                  );
                                },
                              );
                            }
                          },
                          child: _buildLockedContent(),
                        ),
                      ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 240,
                          height: 40,
                          child: TextField(
                            controller: meetingNameController,
                            style: GoogleFonts.rubik(fontSize: 14),
                            decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintStyle: GoogleFonts.rubik(fontSize: 14),
                              hintText: 'Жолугушуу кодун жазыңыз',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: isButtonEnabled ? join : null,
                          style: TextButton.styleFrom(
                            backgroundColor: isButtonEnabled
                                ? const Color(0xff1B434D)
                                : Colors.grey,
                          ),
                          child: Text(
                            "Кошулуу",
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '"Жаңы жолугушуу түзүү" менен жолугушуунун ссылкасын ала аласыз. Ссылка аркылуу сиз каалаган адамдар жолугушууга кире алышат.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w300),
              ),
            )
          ],
        ),
      ),
    );
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
          width: 1,
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
            top: 7,
            right: 10,
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stream, size: 32, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Жаңы түз эфир түзүү',
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
}
