// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:alippepro_v1/features/videoPlayer/videoPlayer.dart';
import 'package:alippepro_v1/providers/course_provider.dart';
import 'package:alippepro_v1/services/auth_services.dart';
import 'package:alippepro_v1/services/course_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseDetailScreen extends StatefulWidget {
  final idCourse;
  final bgImage;

  const CourseDetailScreen({super.key, this.idCourse, required this.bgImage});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseService courseService = CourseService();
  final AuthService authService = AuthService();
  bool _isExpanded = false;
  var dropValue = 0;
  var modules = [];
  List module = [];
  List options = [];
  var userCourses = [];
  var user = {"phoneNumber": "0"};

  @override
  void initState() {
    super.initState();
    courseService.getCourse(context: context, id: widget.idCourse.toString());
    getUserLocalData();
  }

  Future getUserLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var response = prefs.getString('user');
    var responseData = jsonDecode(response!);
    user['phoneNumber'] = responseData['phoneNumber'];
    final userData = await authService.getMe(responseData['id']);
    print('userData $userData');
    userCourses = userData['userData']['courses'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var course = Provider.of<CourseDetailProvider>(context).courseDetail;

    var seen = <String>{};
    var userCourses2 = [];
    for (var element in userCourses) {
      if (element['courseId'] == widget.idCourse) {
        userCourses2.add(element);
      }
    }
    var combineModules = [...userCourses2, ...course.modules];
    modules = combineModules
        .where((module) => seen.add(module['name'].toString()))
        .toList();

    modules.sort((a, b) {
      return a['name']
          .toString()
          .toLowerCase()
          .compareTo(b['name'].toString().toLowerCase());
    });

    final List fixedList = Iterable.generate(modules.length).toList();
    if (modules.isNotEmpty) {
      module = modules[dropValue]['lessons'];
    }


    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100.0,
            floating: false,
            backgroundColor: Colors.white,
            pinned: true,
            leading: GestureDetector(
              child: const Icon(Icons.arrow_back_ios_new),
              onTap: () {
                Get.back();
              },
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  // image: DecorationImage(
                  //   image: NetworkImage(
                  //       "https://img.freepik.com/free-vector/green-gradient-background-gradient-3d-design_343694-3667.jpg"),
                  //   fit: BoxFit.cover,
                  // ),
                  color: Colors.white),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var top = constraints.biggest.height;
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: top <= 120 ? 1.0 : 0.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .75,
                        child: Text(course.title,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                                fontSize: 16.0,
                                color: const Color(0xff005558),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: top <= 120 ? 0.0 : 1.0,
                          child: Image.network(
                            'https://alippebucket.s3.eu-north-1.amazonaws.com/coursesBg.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // AnimatedOpacity(
                        //   duration: Duration(milliseconds: 300),
                        //   opacity: top <= 120 ? 1.0 : 0.0,
                        //   child:
                        // ),

                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: top >= 110 ? 80 : 300,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black
                                      .withOpacity(top <= 120 ? 0.0 : 1.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 20,
                            left: 70,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                course.title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.rubik(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22),
                              ),
                            ))
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 22,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xff006A6E),
                            borderRadius: BorderRadius.circular(5)),
                        child: ListTile(
                          minTileHeight: 30,
                          title: Text(
                            'Кененирээк',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: IconButton(
                            color: Colors.white,
                            icon: Icon(_isExpanded
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: _isExpanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: _isExpanded
                              ? const EdgeInsets.all(8.0)
                              : EdgeInsets.zero,
                          child: _isExpanded
                              ? MarkdownBody(
                                  data: course.description,
                                  styleSheet: MarkdownStyleSheet(
                                    h1: GoogleFonts.rubik(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    h2: GoogleFonts.rubik(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    h3: GoogleFonts.rubik(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    h4: GoogleFonts.rubik(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    h5: GoogleFonts.rubik(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    h6: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xff005558)),
                                    p: GoogleFonts.rubik(
                                        fontSize: 14,
                                        color: const Color(0xff005558)),
                                    blockquote: GoogleFonts.rubik(
                                        fontSize: 14,
                                        color: const Color(0xff005558),
                                        fontStyle: FontStyle.italic),
                                    code: GoogleFonts.rubik(),
                                    listBullet: GoogleFonts.rubik(
                                        fontSize: 14,
                                        color: const Color(0xff005558)),
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    Row(
                      children: [
                        Text(
                          'Модуль - ',
                          style:
                              GoogleFonts.rubik(color: const Color(0xff005558)),
                        ),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: const Color(0xff006A6E), width: 1.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              value: dropValue,
                              items: fixedList.map((i) {
                                int a = i;
                                return DropdownMenuItem(
                                  value: a,
                                  child: Text((i + 1).toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                courseService.getCourse(
                                    context: context, id: widget.idCourse);
                                setState(() {
                                  dropValue = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ),
          modules.isNotEmpty && modules[dropValue]['isAccess'] == false
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return GestureDetector(
                          onTap: () {
                            // Get.to(YoutubeIframe(
                            //   // url: module[index]['rumbleUrl'],
                            //   lessonId: module[index]['_id'],
                            //   courseId: modules[0]['courseId'],
                            // ));
                            Get.to(() => YoutubePlayerIframe(
                              lessonId: module[index]['_id'],
                              courseId: modules[0]['courseId'],
                            ));
                          },
                          child:
                              LessonCard(lesson: module[index], index: index));
                    },
                    childCount: module.length,
                  ),
                )
              : const SliverToBoxAdapter(
                  child: Text(''),
                ),
          modules.isNotEmpty && modules[dropValue]['isAccess'] == false
              ? const SliverToBoxAdapter(
                  child: Text(''),
                )
              : SliverToBoxAdapter(
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .66,
                      color: const Color(
                        0xff054e45,
                      ).withOpacity(.65),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 130, horizontal: 40),
                        child: Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Сизде бул курска\nдоступ жок",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(
                                        0xffba0f43,
                                      ),
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )),
                      )),
                ),
        ],
      ),
    );
  }
}

class Lesson {
  final String title;
  final String duration;

  Lesson({required this.title, required this.duration});
}

class LessonCard extends StatelessWidget {
  final lesson;
  final index;

  const LessonCard({super.key, required this.lesson, required this.index});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: const DecorationImage(
                image: AssetImage('assets/img/courseBgImg.png'),
                fit: BoxFit.cover)),
        child: Container(
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.transparent,
                Colors.black,
              ], // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 45,
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                      text: '${index + 1}-сабак',
                      style: GoogleFonts.rubik(
                          color: Colors.white,
                          height: 1,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: ' "${lesson['name']}"',
                          style: GoogleFonts.rubik(
                              color: Colors.white,
                              height: 1,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        )
                      ]),
                  selectionRegistrar: SelectionContainer.maybeOf(context),
                  selectionColor: const Color(0xAF6694e8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class CourseDetailScreen extends StatefulWidget {
//   const CourseDetailScreen({super.key, required this.idCourse});

//   final idCourse;

//   @override
//   State<CourseDetailScreen> createState() => _CourseDetailScreenState();
// }

// class _CourseDetailScreenState extends State<CourseDetailScreen> {
//   final CourseService courseService = CourseService();
// final AuthService authService = AuthService();

// var dropValue = 0;
// var modules = [];
// List module = [];
// List options = [];
// var userCourses = [];
// var user = {"phoneNumber": "0"};

// @override
// void initState() {
//   super.initState();
//   courseService.getCourse(context: context, id: widget.idCourse.toString());
//   getUserLocalData();
// }

// Future getUserLocalData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   var response = prefs.getString('user');
//   var responseData = jsonDecode(response!);
//   user['phoneNumber'] = responseData['phoneNumber'];
//   final userData = await authService.getMe(responseData['id']);
//   userCourses = userData['courses'];
//   setState(() {});
// }

// @override
// Widget build(BuildContext context) {
//   var course = Provider.of<CourseDetailProvider>(context).courseDetail;
//   var seen = Set<String>();
//   var userCourses2 = [];
//   for (var element in userCourses) {
//     if (element['courseId'] == widget.idCourse) {
//       userCourses2.add(element);
//     }
//   }
//   var combineModules = [...userCourses2, ...course.modules];
//   modules = combineModules
//       .where((module) => seen.add(module['name'].toString()))
//       .toList();

//   modules.sort((a, b) {
//     return a['name']
//         .toString()
//         .toLowerCase()
//         .compareTo(b['name'].toString().toLowerCase());
//   });

//   final List fixedList = Iterable.generate(modules.length).toList();
//   if (modules.isNotEmpty) {
//     module = modules[dropValue]['lessons'];
//   }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 100.0,
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_ios_new,
//                 color: Color(0xff054e45),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               background: Center(
//                 child: Ink(
//                   width: MediaQuery.of(context).size.width / 1.2,
//                   height: 90,
//                   decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                           colors: [Color(0xff3cd8c5), Color(0xff088273)]),
//                       borderRadius: BorderRadius.circular(10)),
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                         top: 0, left: 20, bottom: 16, right: 30),
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           CircleAvatar(
//                             radius: 20,
//                             backgroundColor: Colors.white,
//                             child: SvgPicture.asset(
//                               'assets/img/courses1.svg',
//                             ),
//                           ),
//                           SizedBox(
//                             width: 200,
//                             child: Text(
//                               course.title,
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w900,
//                                   fontFamily: 'RobotoFlex'),
//                               textAlign: TextAlign.end,
//                             ),
//                           ),
//                         ]),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 10,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       dropValue = 0;
//                     });
//                   },
//                   icon: Icon(
//                     Icons.info_outline,
//                     size: 35,
//                     color: dropValue == 0
//                         ? const Color(0xff054e45)
//                         : const Color(0xffb8c7c5),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () {
//                     setState(() {
//                       dropValue = 1;
//                     });
//                   },
//                   icon: Icon(
//                     Icons.apps,
//                     size: 35,
//                     color: dropValue == 1
//                         ? const Color(0xff054e45)
//                         : const Color(0xffb8c7c5),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: DropdownButton(
//               value: dropValue,
//               items: fixedList.map((i) {
//                 int a = i;
//                 return DropdownMenuItem(
//                   value: a,
//                   child: Text((i + 1).toString()),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 courseService.getCourse(context: context, id: widget.idCourse);
//                 setState(() {
//                   dropValue = value!;
//                 });
//               },
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('${course.title.toUpperCase()}:',
//                     style: const TextStyle(
//                         color: Color(0xffb8c7c5),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700)),
//                 Text(
//                     modules.isNotEmpty
//                         ? '${modules[dropValue]['name'].toUpperCase()}'
//                         : '',
//                     style: const TextStyle(
//                         color: Color(0xffb8c7c5),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700))
//               ],
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//             sliver: SliverGrid(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 20,
//                 crossAxisSpacing: 20,
//                 childAspectRatio: 3 / 2,
//               ),
//               delegate: SliverChildBuilderDelegate(
//                 (BuildContext context, int index) {
//                   return TextButton(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${index + 1} - сабак',
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           style: const TextStyle(
//                             color: Color(0xff1b434d),
//                             fontSize: 14,
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             alignment: Alignment.center,
//                             color: Colors.blueAccent,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 5.0),
//                               child: Text(
//                                 module[index]['name'],
//                                 style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Color.fromRGBO(255, 255, 255, 1)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => WebYoutube(
//                             url: module[index]['youtubeUrl'],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 childCount: module.length,
//               ),
//             ),
//           ),
//           if (modules.isNotEmpty &&
//               modules[dropValue]['isAccess'] == false ||
//               user["phoneNumber"].toString() == '996990859695')
//             SliverFillRemaining(
//               hasScrollBody: false,
//               child: Container(
//                 color: const Color(0xff054e45).withOpacity(.65),
//                 child: Center(
//                   child: Container(
//                     color: Colors.white,
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 20, horizontal: 40),
//                     child: const Text(
//                       "Сизде бул курска\nдоступ жок",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           color: Color(0xffba0f43),
//                           fontWeight: FontWeight.w700),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
