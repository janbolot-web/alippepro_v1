// // ignore_for_file: file_names

// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// // ignore: must_be_immutable
// class VideoPlayerScreen extends StatefulWidget {
//   // ignore: prefer_typing_uninitialized_variables
//   var url;
//   VideoPlayerScreen({super.key, required this.url});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late YoutubePlayerController controller;

//   @override
//   void initState() {
//     controller = YoutubePlayerController(
//         initialVideoId: YoutubePlayer.convertUrlToId(widget.url)!);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height-200,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               YoutubePlayer(
//                 controller: controller,
//                 showVideoProgressIndicator: true,
//                 progressIndicatorColor: Colors.amber,
//                 progressColors: const ProgressBarColors(
//                   playedColor: Colors.amber,
//                   handleColor: Colors.amberAccent,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
