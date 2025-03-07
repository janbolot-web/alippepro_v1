// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:alippepro_v1/features/courseDetail/view/courseDetail_screen.dart';
import 'package:alippepro_v1/providers/course_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key, this.user});
  final user;

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    var id = Provider.of<CourseProvider>(context).course.id;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xff054e45),
          ),
          onPressed: () {
            Navigator.pop(
              context,
            );
          },
        ),
      ),
      body: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(30, 0, 30, 35),
          padding: const EdgeInsets.only(bottom: 14),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
              color: Color(0xffba0f43),
              width: 1.5,
            )),
          ),
          child: const Text('Менин курстарым',
              style: TextStyle(
                  fontSize: 24,
                  color: Color(0xff1b434d),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto')),
        ),
        widget.user?.courses?.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CourseDetailScreen(
                                idCourse: id,
                                bgImage: '',
                              ),
                            ),
                          );
                        },
                        child: id.isNotEmpty
                            ? Ink(
                                width: 150,
                                height: 95,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xff3cd8c5),
                                      Color(0xff088273)
                                    ]),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'ШАР ОКУУ\nМУГАЛИМИ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    fontFamily: 'RobotoFlex'),
                                                textAlign: TextAlign.end,
                                              )
                                            ]),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.white,
                                                child: SvgPicture.asset(
                                                  'assets/img/courses1.svg',
                                                ),
                                              )
                                            ])
                                      ]),
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.black.withOpacity(0.04)),
                                height: 95,
                                width: 150,
                                padding: const EdgeInsets.all(15),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // Skelton(
                                            //   height: 10,
                                            //   width: 100,
                                            //   radius: 16,
                                            // ),
                                            // SizedBox(
                                            //   height: 5,
                                            // ),
                                            // Skelton(
                                            //   height: 10,
                                            //   width: 80,
                                            //   radius: 16,
                                            // )
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        // Skelton(
                                        //   height: 30,
                                        //   width: 30,
                                        //   radius: 16,
                                        // ),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                  ],
                ),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const Icon(
                    Icons.block,
                    size: 48,
                    color: Color(0xffba0f43),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  const SizedBox(
                    width: 240,
                    child: Text(
                      "Сиздин кабинетиңизде азыр эч бир курска доступ жок!",
                      style: TextStyle(
                        color: Color(0xffb8c7c5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      "Курстар тууралуу маалымат алуу үчүн",
                      style: TextStyle(
                        color: Color(0xffb8c7c5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {},
                    label: const Text(
                      'КУРСТАР',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xff088273),
                    extendedPadding: const EdgeInsets.symmetric(horizontal: 38),
                  ),
                  const SizedBox(
                    height: 34,
                  ),
                  const SizedBox(
                    width: 200,
                    child: Text(
                      "Сиз каалаган курска доступ алуу үчүн",
                      style: TextStyle(
                        color: Color(0xffb8c7c5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Roboto",
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 34,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {},
                    label: const Text(
                      'ДОСТУП',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: const Color(0xff088273),
                    extendedPadding: const EdgeInsets.symmetric(horizontal: 38),
                  ),
                ],
              )
      ]),
    );
  }
}
