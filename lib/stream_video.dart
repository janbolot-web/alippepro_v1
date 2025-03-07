// import 'package:flutter/material.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const VideoConferenceApp());
// }

// class VideoConferenceApp extends StatelessWidget {
//   const VideoConferenceApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Video Conference',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const ConferenceHomePage(),
//     );
//   }
// }

// class ConferenceHomePage extends StatefulWidget {
//   const ConferenceHomePage({Key? key}) : super(key: key);

//   @override
//   State<ConferenceHomePage> createState() => _ConferenceHomePageState();
// }

// class _ConferenceHomePageState extends State<ConferenceHomePage> {
//   final _roomController = TextEditingController();
//   final _nameController = TextEditingController();
//   StreamVideo? _client;

//   @override
//   void initState() {
//     super.initState();
//     _initializeStreamVideo();
//   }

//   Future<void> _initializeStreamVideo() async {
//     try {
//       // Сначала сбрасываем существующий экземпляр
//       await StreamVideo.reset();

//       // Создаем новый экземпляр
//       _client = StreamVideo.create(
//         '8uwz975deb35', // Замените на ваш API ключ
//         user: User.regular(
//           userId: 'default_user',
//           name: 'Default User',
//         ),
//         userToken:
//             'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyZXNvdXJjZSI6ImFuYWx5dGljcyIsImFjdGlvbiI6IioiLCJ1c2VyX2lkIjoiKiJ9.G9qBqPujFzOtb1gDuOQakYeTolUH4uU1tJujlxHP9Lk', // Замените на ваш токен
//       );
//     } catch (e) {
//       print('Error initializing StreamVideo: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _roomController.dispose();
//     _nameController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Video Conference'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Your Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _roomController,
//               decoration: const InputDecoration(
//                 labelText: 'Room ID',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => _joinConference(isHost: true),
//                   child: const Text('Create Room'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _joinConference(isHost: false),
//                   child: const Text('Join Room'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _joinConference({required bool isHost}) {
//     if (_nameController.text.isEmpty || _roomController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill all fields')),
//       );
//       return;
//     }

//     if (_client == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Video client not initialized')),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ConferenceRoom(
//           roomId: _roomController.text,
//           userName: _nameController.text,
//           isHost: isHost,
//           client: _client!,
//         ),
//       ),
//     );
//   }
// }

// class ConferenceRoom extends StatefulWidget {
//   final String roomId;
//   final String userName;
//   final bool isHost;
//   final StreamVideo client;

//   const ConferenceRoom({
//     Key? key,
//     required this.roomId,
//     required this.userName,
//     required this.isHost,
//     required this.client,
//   }) : super(key: key);

//   @override
//   State<ConferenceRoom> createState() => _ConferenceRoomState();
// }

// class _ConferenceRoomState extends State<ConferenceRoom> {
//   Call? call;
//   bool isLoading = true;
//   bool isMicOn = true;
//   bool isCameraOn = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _joinCall();
//   }

//   Future<void> _joinCall() async {
//     try {
//       // Создание или присоединение к звонку
//       call = widget.client.makeCall(
//         callType: StreamCallType.liveStream(),
//         id: widget.roomId,
//       );

//       // Присоединение к звонку
//       await call!.join();

//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error joining call: $e');
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           errorMessage = 'Failed to join the conference';
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     call?.end();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (errorMessage != null) {
//       return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(errorMessage!),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Go Back'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       body: call == null
//           ? const Center(child: Text('Failed to join conference'))
//           : Stack(
//               children: [
//                 StreamCallContainer(
//                   call: call!,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   left: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     color: Colors.black54,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             isMicOn ? Icons.mic : Icons.mic_off,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               isMicOn = !isMicOn;
//                             });
//                             if (isMicOn) {
//                               // call?.microphone.enable();
//                             } else {
//                               // call?.microphone.disable();
//                             }
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             isCameraOn ? Icons.videocam : Icons.videocam_off,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               isCameraOn = !isCameraOn;
//                             });
//                             if (isCameraOn) {
//                               // call?.camera.enable();
//                             } else {
//                               // call?.camera.disable();
//                             }
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.call_end,
//                             color: Colors.red,
//                           ),
//                           onPressed: () {
//                             call?.end();
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
