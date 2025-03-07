// ignore_for_file: file_names
// import 'package:alippepro_v1/features/main/widgets/carousel.dart';
// import 'package:alippepro_v1/features/main/widgets/numbersInfo.dart';
// import 'package:alippepro_v1/features/main/widgets/stories.dart';
// import 'package:alippepro_v1/features/videoPlayer/youtubeIframe.dart';
// import 'package:alippepro_v1/services/stories_services.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_gradient_text/simple_gradient_text.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({
//     super.key,
//     required this.page,
//   });
//   // ignore: prefer_typing_uninitialized_variables
//   final page;

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   final StoryService storyService = StoryService();
//   // ignore: prefer_typing_uninitialized_variables
//   var user;

//   verificationUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('user');
//     setState(() {
//       user = token;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     verificationUser();
//     storyService.getAllStories(context);
//   }

//   final Uri whatsapp = Uri.parse('https://wa.me/996705089710');
//   final Uri youtube = Uri.parse('https://wa.me/996990859695');
//   final Uri tiktok = Uri.parse('https://www.tiktok.com/@alippe_pro');
//   final Uri gmail = Uri.parse('https://wa.me/996705089710');
//   final Uri instagram = Uri.parse('https://www.instagram.com/alippepro_v1/');

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//         child: Column(
//       children: [
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20),
//           child: Stories(),
//         ),
//         const SizedBox(
//           height: 30,
//         ),
//         // YoutubeVideoPlayer(
//         //   url: 'https://youtube.com/shorts/wL0rUXXzZ3w?feature=share',
//         //   type: 'main',
//         // ),
//         GradientText(
//           'AliPPE  PRO',
//           style: const TextStyle(
//               fontSize: 40.0,
//               fontWeight: FontWeight.w900,
//               fontFamily: 'Roboto'),
//           gradientType: GradientType.linear,
//           colors: const [
//             Color(0xffba0f43),
//             Color(0xff157d97),
//           ],
//         ),
//         const SizedBox(
//           height: 15,
//         ),
//         const Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'Мугалимдерди',
//               textAlign: TextAlign.end,
//               style: TextStyle(
//                   color: Color(0xff1B434D),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 26,
//                   fontFamily: 'Roboto'),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'ӨНҮКТҮРҮҮЧҮ',
//                   textAlign: TextAlign.end,
//                   style: TextStyle(
//                       color: Color(0xff1B434D),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 26,
//                       fontFamily: 'Roboto'),
//                 ),
//                 Text(
//                   ' жана',
//                   textAlign: TextAlign.end,
//                   style: TextStyle(
//                       color: Color(0xff1B434D),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 26,
//                       fontFamily: 'Roboto'),
//                 ),
//               ],
//             ),
//             Text(
//               'ШЫКТАНДЫРУУЧУ',
//               textAlign: TextAlign.end,
//               style: TextStyle(
//                   color: Color(0xff1B434D),
//                   fontWeight: FontWeight.bold,
//                   fontSize: 26,
//                   fontFamily: 'Roboto'),
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 25,
//         ),
//         GradientText(
//           'Кыргызстандагы\nалгачкы тиркеме',
//           style: const TextStyle(
//               fontSize: 26.0,
//               fontWeight: FontWeight.w900,
//               fontFamily: 'Roboto'),
//           gradientType: GradientType.linear,
//           colors: const [
//             Color(0xffba0f43),
//             Color(0xff157d97),
//           ],
//           textAlign: TextAlign.center,
//         ),

//         const SizedBox(
//           height: 45,
//         ),
//         YoutubeIframe(
//           type: 'main',
//           url: "hPo_41wjMX4",
//           autoPlay: true,
//         ),

//         // const VideoPlayerView(
//         //   url:
//         //       "https://d3v55qvjb2v012.cloudfront.net/AmZ9/2024/05/01/11/58/cZhVX9VMzke/sc.mp4?srcid=cZhVX9VMzke&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM3Y1NXF2amIydjAxMi5jbG91ZGZyb250Lm5ldC9BbVo5LzIwMjQvMDUvMDEvMTEvNTgvY1poVlg5Vk16a2Uvc2MubXA0P3NyY2lkPWNaaFZYOVZNemtlIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzE0ODA1OTUwfX19XX0_&Signature=edVDGxEUM6dtFIfP-BMwOgeLIRfSwRLb8P1lNEApowD1mg4unEDDNyvCLYI863MsKtue-u1XvvoqyN~5yUdLIJ~NIIFapY~iMMpk1hCnwS~F~cFYTzvU1H9g4unU3mVxDr~ZXChvhzH1eP~0cYK-zEz1PFG8-G0dKyJMNDDe71w_&Key-Pair-Id=APKAI4E2RN57D46ONMEQ",
//         //   showControls: "",
//         // ),
//         const SizedBox(
//           height: 40,
//         ),

//         Container(
//             margin: const EdgeInsets.only(top: 20.0),
//             child: const NumbersInfo()),
//         const SizedBox(
//           height: 40,
//         ),

//         const SizedBox(
//           height: 22,
//         ),
//         Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(horizontal: 30),
//           child: GradientText(
//             'Бардык заманбап\nжана эфективдүү\nметодикалар ушул\nжерде!',
//             style: const TextStyle(
//               fontSize: 32.0,
//               fontWeight: FontWeight.w900,
//               fontFamily: 'Roboto',
//             ),
//             textAlign: TextAlign.center,
//             gradientType: GradientType.linear,
//             colors: const [
//               Color(0xffba0f43),
//               Color(0xff157d97),
//             ],
//           ),
//         ),
//         const SizedBox(
//           height: 22,
//         ),
//         Carousel(),
//         const SizedBox(
//           height: 98,
//         ),
//         Column(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     GradientText(
//                       'Чыныгүл эжей',
//                       style: const TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Roboto'),
//                       gradientType: GradientType.linear,
//                       colors: const [
//                         Color(0xffba0f43),
//                         Color(0xff157d97),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     GradientText(
//                       '“Кесибимди сүйүп\n баштадым...”',
//                       style: const TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Roboto'),
//                       gradientType: GradientType.linear,
//                       colors: const [
//                         Color(0xffba0f43),
//                         Color.fromARGB(255, 18, 158, 205)
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 YoutubeIframe(
//                     type: 'main', url: "lNnBfmwoKu0", autoPlay: false),
//                 // const VideoPlayerView(
//                 //     place: 'assets/img/IMG_1094.png',
//                 //     auto: false,
//                 //     url:
//                 //         "https://d3v55qvjb2v012.cloudfront.net/AmZ9/2024/05/01/18/18/cZhVFFVMACr/sc.mp4?srcid=cZhVFFVMACr&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM3Y1NXF2amIydjAxMi5jbG91ZGZyb250Lm5ldC9BbVo5LzIwMjQvMDUvMDEvMTgvMTgvY1poVkZGVk1BQ3Ivc2MubXA0P3NyY2lkPWNaaFZGRlZNQUNyIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzE0NjczOTI2fX19XX0_&Signature=ZZ9d1vrGFmgtQVqy4wZ5hQU6UXwZf0jb651~RSVA3rkXk2qX3RMl5tlUP3f0KuI49MvDVBOjTKkdU5nvH0ZjSpq4YpW8TLZpEiOv0RzwIUqElAEDVH9g3j0CHXAyw7XCAtOO0WrePqsi~pfXDLlyjR9C4POz43U9owatWEv0N4k_&Key-Pair-Id=APKAI4E2RN57D46ONMEQ",
//                 //     showControls: ""),
//               ],
//             ),
//             const SizedBox(
//               height: 40,
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Column(
//                   children: [
//                     GradientText(
//                       'Окуучуларын 300-400 сөзгө\nжеткирген Айжан эжей',
//                       style: const TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Roboto'),
//                       textAlign: TextAlign.end,
//                       gradientType: GradientType.linear,
//                       colors: const [
//                         Color(0xff157d97),
//                         Color(0xffba0f43),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   width: 20,
//                 ),
//                 YoutubeIframe(
//                     type: 'main', url: "9ZKhtjp8NFY", autoPlay: false),
//                 // const VideoPlayerView(
//                 //     place: 'assets/img/IMG_1095.png',
//                 //     auto: false,
//                 //     url:
//                 //         "https://d3v55qvjb2v012.cloudfront.net/AmZ9/2024/05/01/12/31/cZhVlwVMzEb/sc.mp4?srcid=cZhVlwVMzEb&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM3Y1NXF2amIydjAxMi5jbG91ZGZyb250Lm5ldC9BbVo5LzIwMjQvMDUvMDEvMTIvMzEvY1poVmx3Vk16RWIvc2MubXA0P3NyY2lkPWNaaFZsd1ZNekViIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzE0NjczMjQ4fX19XX0_&Signature=aMz~uEQwn4JWsHsj0fAfaqXzCmKW~IdGLyX32ObKiXDDrndW9iVjEIKtYxnUd5-dBXhpySG7e7gV0zsGN0fF1Xl5jZd5Ds3LpoeuLnw8rZs2rwk9W5OEWygGZARE1KXY4CXlqzUZhAs~Bi2otsUuM9CzOuWFddeoU1zeNYyG8HI_&Key-Pair-Id=APKAI4E2RN57D46ONMEQ",
//                 //     showControls: ""),
//               ],
//             ),
//             const SizedBox(
//               height: 40,
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GradientText(
//                           'Алтынай эжей',
//                           style: const TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.w900,
//                               fontFamily: 'Roboto'),
//                           gradientType: GradientType.linear,
//                           colors: const [
//                             Color(0xffba0f43),
//                             Color(0xff157d97),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         GradientText(
//                           '“Окуучуларымдын берилип\nокуганына таң калдым”',
//                           style: const TextStyle(
//                               fontSize: 16.0,
//                               fontWeight: FontWeight.w900,
//                               fontFamily: 'Roboto'),
//                           textAlign: TextAlign.end,
//                           gradientType: GradientType.linear,
//                           colors: const [
//                             Color(0xffba0f43),
//                             Color.fromARGB(255, 18, 158, 205)
//                           ],
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     // const VideoPlayerView(
//                     //   place: 'assets/img/IMG_10891.png',
//                     //   url:
//                     //       "https://d3v55qvjb2v012.cloudfront.net/AmZ9/2024/05/01/12/31/cZhVlwVMzEq/sc.mp4?srcid=cZhVlwVMzEq&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM3Y1NXF2amIydjAxMi5jbG91ZGZyb250Lm5ldC9BbVo5LzIwMjQvMDUvMDEvMTIvMzEvY1poVmx3Vk16RXEvc2MubXA0P3NyY2lkPWNaaFZsd1ZNekVxIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzE0NjcyNDkzfX19XX0_&Signature=Qaz8j9zslGbKpI5ozy7gfSddTB5-O0pOXE7fJzKNNPJXTsuLNAvt8JXEBq6e-v031r4IRXVbvSzhV7D5KeOx6SxM64lL~IGLtzXJzje6sLTdsZsZfAR-Nxf4L1uBtojTQtiK~iTAPtsgdYHyWy9iKtbKdYUpqeJazBfNCAUUEAc_&Key-Pair-Id=APKAI4E2RN57D46ONMEQ",
//                     //   showControls: "",
//                     //   full: false,
//                     //   auto: false,
//                     //   loop: false,
//                     // ),
//                     YoutubeIframe(
//                     type: 'main', url: "YRZvL7HWSa4", autoPlay: false),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 40,
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     GradientText(
//                       'Гүлмира эжей',
//                       style: const TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Roboto'),
//                       gradientType: GradientType.linear,
//                       colors: const [
//                         Color(0xffba0f43),
//                         Color(0xff157d97),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     GradientText(
//                       '“Мугалим кошумча капитал\nтоптосо боло экен”',
//                       style: const TextStyle(
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.w900,
//                           fontFamily: 'Roboto'),
//                       gradientType: GradientType.linear,
//                       colors: const [
//                         Color(0xffba0f43),
//                         Color.fromARGB(255, 18, 158, 205)
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 // const VideoPlayerView(
//                 //     place: 'assets/img/IMG_1093.png',
//                 //     auto: false,
//                 //     url:
//                 //         "https://d3v55qvjb2v012.cloudfront.net/AmZ9/2024/05/01/12/31/cZhVlwVMzEF/sc.mp4?srcid=cZhVlwVMzEF&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM3Y1NXF2amIydjAxMi5jbG91ZGZyb250Lm5ldC9BbVo5LzIwMjQvMDUvMDEvMTIvMzEvY1poVmx3Vk16RUYvc2MubXA0P3NyY2lkPWNaaFZsd1ZNekVGIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzE0NjcyMzYzfX19XX0_&Signature=GvdX~sjGvpU9CLUHv-3nybVfXhbDSst4i~FZ7AD4AGBuw~BLx7N7JEGBfMzqKIONuBimB-shnX1EKQ7IMRuqmU976g3i7TAKAM9OyDHlSPt5~vF3wIClHz1biVm1vm5dp8~2UFuBKJtDOj8UcsQnVoeHwwZ0~Hj-A28BOwJ2tZo_&Key-Pair-Id=APKAI4E2RN57D46ONMEQ",
//                 //     showControls: ""),

//                     YoutubeIframe(
//                     type: 'main', url: "96uRDj3Gniw", autoPlay: false),
//                 const SizedBox(
//                   width: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(
//           height: 145,
//         ),
//         GradientText(
//           'Жаңы деңгээлге',
//           style: const TextStyle(
//               fontSize: 26.0,
//               fontWeight: FontWeight.w900,
//               fontFamily: 'Roboto'),
//           textAlign: TextAlign.end,
//           gradientType: GradientType.linear,
//           colors: const [Color(0xffba0f43), Color.fromARGB(255, 18, 158, 205)],
//         ),

//         const SizedBox(
//           height: 25,
//         ),
//         const Text(
//           'КАДАМ',
//           style: TextStyle(
//               color: Color(0xff0e4958),
//               fontWeight: FontWeight.bold,
//               fontSize: 32,
//               fontFamily: "Roboto"),
//         ),
//         const SizedBox(
//           height: 25,
//         ),
//         const Text(
//           'таштаңыз!',
//           style: TextStyle(
//               color: Color(0xff0e4958),
//               fontWeight: FontWeight.bold,
//               fontSize: 26,
//               fontFamily: "Roboto"),
//         ),
//         const SizedBox(
//           height: 45,
//         ),
//         Image.asset(
//           'assets/img/arrowDown.png',
//           width: 58,
//           height: 56,
//         ),
//         const SizedBox(
//           height: 65,
//         ),
//         FloatingActionButton.extended(
//           heroTag: null,
//           backgroundColor: const Color(0xff088273),
//           extendedPadding: const EdgeInsets.symmetric(horizontal: 40),
//           onPressed: () {
//             widget.page();
//           },
//           label: const Text(
//             'КУРСТАРГА',
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: "Roboto"),
//           ),
//         ),
//         const SizedBox(
//           height: 107,
//         ),
//         Column(
//           children: [
//             Image.asset(
//               'assets/img/logoMain.png',
//               width: 130,
//               height: 70,
//             ),
//             const Text(
//               'Биз байланыштабыз!',
//               style: TextStyle(color: Color(0xff1b434d)),
//             )
//           ],
//         ),
//         const SizedBox(
//           height: 87,
//         ),
//         Column(
//           children: [
//             const Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.location_on_outlined,
//                   color: Color(0xffba0f43),
//                 ),
//                 SizedBox(
//                   width: 33,
//                 ),
//                 Text(
//                   'Исанова 102 Бишкек ш.',
//                   style: TextStyle(
//                       color: Color(0xff1b434d), fontWeight: FontWeight.bold),
//                 )
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 FloatingActionButton(
//                     heroTag: null,
//                     onPressed: () async {
//                       await launchUrl(whatsapp);
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     hoverColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     focusElevation: 0,
//                     hoverElevation: 0,
//                     child: Image.asset(
//                       'assets/img/youtube.png',
//                       width: 20,
//                       height: 20,
//                     )),
//                 FloatingActionButton(
//                     heroTag: null,
//                     onPressed: () async {
//                       await launchUrl(whatsapp);
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     hoverColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     focusElevation: 0,
//                     hoverElevation: 0,
//                     child: Image.asset(
//                       'assets/img/gmail.png',
//                       width: 20,
//                       height: 20,
//                     )),
//                 FloatingActionButton(
//                     heroTag: null,
//                     onPressed: () async {
//                       await launchUrl(instagram);
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     hoverColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     focusElevation: 0,
//                     hoverElevation: 0,
//                     child: Image.asset(
//                       'assets/img/instagram.png',
//                       width: 20,
//                       height: 20,
//                     )),
//                 FloatingActionButton(
//                     heroTag: null,
//                     onPressed: () async {
//                       await launchUrl(tiktok);
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     hoverColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     focusElevation: 0,
//                     hoverElevation: 0,
//                     child: Image.asset(
//                       'assets/img/tiktok.png',
//                       width: 20,
//                       height: 20,
//                     )),
//                 FloatingActionButton(
//                     heroTag: null,
//                     onPressed: () async {
//                       await launchUrl(whatsapp);
//                     },
//                     backgroundColor: Colors.transparent,
//                     elevation: 0,
//                     hoverColor: Colors.transparent,
//                     focusColor: Colors.transparent,
//                     focusElevation: 0,
//                     hoverElevation: 0,
//                     child: Image.asset(
//                       'assets/img/WhatsApp.png',
//                       width: 20,
//                       height: 20,
//                     )),
//               ],
//             ),
//             const SizedBox(height: 35),
//           ],
//         )
//       ],
//     ));
//   }
// }
