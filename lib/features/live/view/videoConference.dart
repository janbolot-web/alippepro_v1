
// import 'package:alippepro_v1/services/auth_services.dart';
// import 'package:alippepro_v1/utils/constants.dart';
// import 'package:flutter/material.dart';
// import 'package:share/share.dart';
// import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

// enum Role { Host, Audience }

// class VideoConferencePage extends StatefulWidget {
//   final String conferenceID;
//   final String userId;
//   final String userName;
//   final String avatarUrl;
//   final Role role;

//   const VideoConferencePage({
//     super.key,
//     required this.conferenceID,
//     required this.userId,
//     required this.userName,
//     required this.role,
//     required this.avatarUrl,
//   });

//   @override
//   _VideoConferencePageState createState() => _VideoConferencePageState();
// }

// class _VideoConferencePageState extends State<VideoConferencePage> {
//   final AuthService authService = AuthService();
//   bool isFullscreen = true;

//   ZegoUIKitPrebuiltVideoConferenceController controller =
//       ZegoUIKitPrebuiltVideoConferenceController();
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<IconData> customIcons = [
//       Icons.ios_share,
//     ];

//     return SafeArea(
//       child: ZegoUIKitPrebuiltVideoConference(
//         appID: Constants.appId,
//         appSign: Constants.appSign,
//         userID: widget.userId,
//         userName: widget.userName,
//         conferenceID: widget.conferenceID,
//         config: (ZegoUIKitPrebuiltVideoConferenceConfig(
//           avatarBuilder: (BuildContext context, Size size, ZegoUIKitUser? user,
//               Map extraInfo) {
//             return user != null
//                 ? Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       image: DecorationImage(
//                         fit: BoxFit.cover,
//                         image: NetworkImage(
//                             'https://res.cloudinary.com/dsfsrf2xw/image/upload/f_auto/q_auto/c_fit,h_500,w_500/${user.id}.jpg'),
//                       ),
//                     ),
//                   )
//                 : const SizedBox();
//           },
//         )
//           ..layout = ZegoLayout.gallery(
//               showScreenSharingFullscreenModeToggleButtonRules:
//                   ZegoShowFullscreenModeToggleButtonRules.alwaysShow,
//               showNewScreenSharingViewInFullscreenMode: true)
//           ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(
//             maxCount: 5,
//             extendButtons: [
//               for (int i = 0; i < customIcons.length; i++)
//                 FloatingActionButton(
//                   shape: const CircleBorder(),
//                   backgroundColor: const Color(0xff2C2F3E).withOpacity(0.6),
//                   onPressed: () {
//                     Share.share(
//                         'Бул код аркылуу AlippeMeet видеоконференцияга кошулунуз - ${widget.conferenceID}');
//                   },
//                   child: Icon(
//                     customIcons[i],
//                     color: Colors.white,
//                   ),
//                 ),
//             ],
//             buttons: [
//               ZegoMenuBarButtonName.toggleCameraButton,
//               ZegoMenuBarButtonName.toggleMicrophoneButton,
//               ZegoMenuBarButtonName.leaveButton,
//               ZegoMenuBarButtonName.chatButton,
//               ZegoMenuBarButtonName.switchAudioOutputButton,
//             ],
//           )
//           ..duration = ZegoVideoConferenceDurationConfig(
//             canSync: widget.role == Role.Host,
//           )
//           ..turnOnCameraWhenJoining = false
//           ..turnOnMicrophoneWhenJoining = false
//           ..useSpeakerWhenJoining = true
//           ..leaveConfirmDialogInfo = ZegoLeaveConfirmDialogInfo(
//             title: "Конференциядан чыгуу",
//             message: "Конференциядан чыгууну каалайсызбы?",
//             cancelButtonName: "Жок",
//             confirmButtonName: "Ооба",
//           )
//           ..onLeave = () {
//             Navigator.pop(context);
//           }
//           ..topMenuBarConfig.title = widget.conferenceID
//           ..topMenuBarConfig.backgroundColor = Colors.black),
//       ),
//     );
//   }
// }
