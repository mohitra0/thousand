// import 'dart:io';

// import 'package:cached_video_player/cached_video_player.dart';
// import 'package:camera/camera.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';

// class FullVideo extends StatefulWidget {
//   const FullVideo({Key key, this.url, this.caption}) : super(key: key);
//   final String url;
//   final String caption;

//   @override
//   _FullVideoState createState() => _FullVideoState();
// }

// class _FullVideoState extends State<FullVideo> with WidgetsBindingObserver {
//   CachedVideoPlayerController _controller;
//   var useruid;
//   final TextEditingController caption = new TextEditingController();

//   File croppedFile;
//   @override
//   void initState() {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User user = auth.currentUser;
//     useruid = user.uid;
//     // croppedFile = widget.path as File;

//     super.initState();
//     _controller = CachedVideoPlayerController.network(widget.url)
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {
//           _controller.play();
//         });
//       });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     setState(() {
//       _controller.pause();
//     });
//     super.dispose();
//   }

//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         setState(() {
//           _controller.pause();
//         });
//         print("app in resumed");
//         break;
//       case AppLifecycleState.inactive:
//         print("app in inactive");
//         break;
//       case AppLifecycleState.paused:
//         setState(() {
//           _controller.pause();
//         });
//         print("app in paused");
//         break;
//       case AppLifecycleState.detached:
//         setState(() {
//           _controller.pause();
//         });
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//       ),
//       body: Container(
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         child: Stack(
//           children: [
//             Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height - 150,
//               child: _controller.value.initialized
//                   ? AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: CachedVideoPlayer(_controller),
//                     )
//                   : Container(),
//             ),
//             Positioned(
//               bottom: 0,
//               child: Container(
//                 color: Colors.black38,
//                 width: MediaQuery.of(context).size.width,
//                 padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                 child:
//                     widget.caption != null ? Text(widget.caption) : Container(),
//               ),
//             ),
//             Align(
//               alignment: Alignment.center,
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     _controller.value.isPlaying
//                         ? _controller.pause()
//                         : _controller.play();
//                   });
//                 },
//                 child: CircleAvatar(
//                   radius: 33,
//                   backgroundColor: Colors.black38,
//                   child: Icon(
//                     _controller.value.isPlaying
//                         ? Icons.pause
//                         : Icons.play_arrow,
//                     color: Colors.white,
//                     size: 50,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
