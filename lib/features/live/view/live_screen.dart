import 'dart:convert';

import 'package:alippepro_v1/features/live/view/savedConference.dart';
import 'package:alippepro_v1/utils/local_storage_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  @override
  void initState() {
    super.initState();
    getUserLocalData();
  }

  var user;
  var linkToJoin;

  Future getUserLocalData() async {
    var response = await getDataFromLocalStorage('user');
    user = jsonDecode(response!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff1B434D)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Alippe Meet',
          style: GoogleFonts.rubik(
            color: const Color(0xff1B434D),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Мугалимдер үчүн видеочалуулар жана жолугушуулар',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  color: const Color(0xff1B434D),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Кайда болбоңуз Alippe Meet окуучуларыңыз же коллегаларыңыз менен чогу иштешүү үчүн видео байланыш түзүп бере алат',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  color: const Color(0xff1B434D),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              if (user != null)
                if (user['roles'][0] == "ADMIN")
                  GestureDetector(
                      onTap: () {
                        DateTime now = DateTime.now();
                        // Получаем секунды
                        int seconds = now.second;

                        // Получаем миллисекунды
                        int milliseconds = now.millisecond;
                        var conferenceID = '$seconds$milliseconds';

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => VideoConferencePage(
                        //       avatarUrl:  user != null ? user['avatarUrl'] : '',
                        //       role: Role.Host,
                        //       conferenceID: conferenceID,
                        //       userId: user != null ? user['id'] : '',
                        //       userName: user != null ? user['name'] : '',
                        //     ),
                        //   ),
                        // );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color(0xff005558),
                              ),
                              child: const Icon(
                                Icons.videocam_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Жаңы жолугушуу түзүү',
                              style: GoogleFonts.rubik(
                                  color: const Color(0xff1B434D),
                                  // fontSize: ,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: const Color(0xff005558),
                      ),
                      child: const Icon(
                        Icons.link,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 1.9,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              linkToJoin = value;
                            });
                          },
                          onSubmitted: (value) => {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => VideoConferencePage(
                            //       avatarUrl:  user != null ? user['avatarUrl'] : '',
                            //       role: Role.Audience,
                            //       conferenceID: value,
                            //       userId: user != null ? user['id'] : '',
                            //       userName: user != null ? user['name'] : '',
                            //     ),
                            //   ),
                            // )
                          },
                          decoration: InputDecoration(
                              hintStyle: GoogleFonts.rubik(
                                  fontSize: 12,
                                  color: const Color(0xff005558),
                                  fontWeight: FontWeight.w400),
                              hintText: 'Жолугушуу кодун жазыңыз...'),
                        )),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => VideoConferencePage(
                        //       avatarUrl:  user != null ? user['avatarUrl'] : '',
                        //       role: Role.Audience,
                        //       conferenceID: linkToJoin,
                        //       userId: user != null ? user['id'] : '',
                        //       userName: user != null ? user['name'] : '',
                        //     ),
                        //   ),
                        // );
                      },
                      child: const Icon(
                        Icons.check,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SavedConference()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xff005558),
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Сакталган эфирлер',
                        style: GoogleFonts.rubik(
                            color: const Color(0xff1B434D),
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    // Container(
                    //   height: 180,
                    //   width: 180,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: const [
                    //       BoxShadow(
                    //         color: Colors.black12,
                    //         blurRadius: 10,
                    //         spreadRadius: 2,
                    //       ),
                    //     ],
                    //   ),
                    //   child: const Center(
                    //     child: Icon(
                    //       Icons.qr_code_2,
                    //       size: 150,
                    //       color: Color(0xff1B434D),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 20),
                    // Text(
                    //   'Жолугушуу ссылкасы',
                    //   style: GoogleFonts.rubik(
                    //     color: Color(0xff1B434D),
                    //     fontWeight: FontWeight.bold,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    Text(
                      '“Жаңы жолугушуу түзүү” менен жолугушуунун\nссылкасын ала аласыз. Ссылканын жардамы менен\nкаалаган адамдар жолугушууга кире алышат.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        color: const Color(0xff1B434D),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
