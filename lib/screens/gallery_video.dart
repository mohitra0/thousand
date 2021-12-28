// import 'dart:io';
// import 'dart:typed_data';

// import 'package:camera/camera.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:thousand/screens/loading_circle.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:cached_video_player/cached_video_player.dart';

// class GalleryVideo extends StatefulWidget {
//   const GalleryVideo({Key key, this.path, this.image, this.name, this.token})
//       : super(key: key);
//   final File path;
//   final String name;
//   final String token;
//   final String image;
//   @override
//   _GalleryVideoState createState() => _GalleryVideoState();
// }

// class _GalleryVideoState extends State<GalleryVideo> {
//   CachedVideoPlayerController _controller;
//   var useruid;
//   final TextEditingController caption = new TextEditingController();
//   bool loading = false;
//   File croppedFile;
//   @override
//   void initState() {
//     FirebaseFirestore _firestore = FirebaseFirestore.instance;
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User user = auth.currentUser;
//     useruid = user.uid;
//     // croppedFile = widget.path as File;
//     croppedFile = File(widget.path.path);

//     super.initState();
//     _controller = CachedVideoPlayerController.file(widget.path)
//       ..initialize().then((_) {
//         // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//         setState(() {});
//       });
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
//             loading
//                 ? Container(
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     ),
//                     color: Colors.transparent,
//                   )
//                 : Positioned(
//                     bottom: 0,
//                     child: Container(
//                       color: Colors.black38,
//                       width: MediaQuery.of(context).size.width,
//                       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                       child: TextFormField(
//                         controller: caption,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                         ),
//                         maxLines: 6,
//                         minLines: 1,
//                         decoration: InputDecoration(
//                             border: InputBorder.none,
//                             hintText: "Add Caption....",
//                             prefixIcon: Icon(
//                               Icons.add_photo_alternate,
//                               color: Colors.white,
//                               size: 27,
//                             ),
//                             hintStyle: TextStyle(
//                               color: Colors.white,
//                               fontSize: 17,
//                             ),
//                             suffixIcon: GestureDetector(
//                               onTap: () async {
//                                 setState(() {
//                                   loading = true;
//                                 });
//                                 final uint8list =
//                                     await VideoThumbnail.thumbnailData(
//                                   video: widget.path.path,
//                                   // imageFormat: ImageFormat.JPEG,
//                                   maxWidth:
//                                       128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
//                                   quality: 25,
//                                 ).then((value) {
//                                   _saveUserVideoToFirebaseStorage(value)
//                                       .whenComplete(() {
//                                     Navigator.pop(context);
//                                     Navigator.pop(context);
//                                   });
//                                 });
//                               },
//                               child: CircleAvatar(
//                                 radius: 27,
//                                 backgroundColor: Colors.tealAccent[700],
//                                 child: Icon(
//                                   Icons.check,
//                                   color: Colors.white,
//                                   size: 27,
//                                 ),
//                               ),
//                             )),
//                       ),
//                     ),
//                   ),
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

//   Future<void> _saveUserVideoToFirebaseStorage(Uint8List thumbnail) async {
//     final Directory systemTempDir = Directory.systemTemp;
//     final File file = await new File('${systemTempDir.path}/foo.png').create();
//     file.writeAsBytes(thumbnail);
// // final Reference ref = storage.ref().child('images').child('image.png');
// // final UploadTask uploadTask = ref.putFile(file);
//     // setState(() {
//     //   imageFile = File.fromRawPath(thumbnail);
//     // });
//     // print(thumbnail);
//     int timedelete = DateTime.now().millisecondsSinceEpoch;

//     try {
//       await FirebaseFirestore.instance
//           .collection('groupchatroom')
//           .doc(timedelete.toString())
//           .set({
//         'delete': timedelete.toString(),
//         'name': widget.name,
//         'image': widget.image,
//         'token': widget.token,
//         'idFrom': useruid,
//         'timestamp': timedelete,
//         'message': 'loading',
//         'type': 'video',
//         'caption': caption.text,
//         'isread': false,
//       });

//       final Reference storageReference =
//           FirebaseStorage.instance.ref().child('groupchatroom/$timedelete');
//       final Reference storageReference1 =
//           FirebaseStorage.instance.ref().child('thumb/$timedelete');
//       final UploadTask uploadTask = storageReference.putFile(croppedFile);
//       final UploadTask uploadTask1 = storageReference1.putFile(file);
//       uploadTask.then((res) async {
//         DocumentReference userstotal = FirebaseFirestore.instance
//             .collection('groupchatroom')
//             .doc(timedelete.toString());
//         userstotal.update({
//           'video': await storageReference.getDownloadURL(),
//         }).then((value) {});
//       });
//       uploadTask1.then((res) async {
//         DocumentReference userstotal = FirebaseFirestore.instance
//             .collection('groupchatroom')
//             .doc(timedelete.toString());
//         userstotal.update({
//           'message': await storageReference1.getDownloadURL(),
//         }).then((value) {});

//         // DocumentSnapshot vari = await FirebaseFirestore.instance
//         //     .collection('group')
//         //     .doc('group')
//         //     .get();
//         // for (int i = 0; i < vari.data()['token'].length; i++) {
//         //   await sendNotificationMessageToPeerUser(
//         //     1,
//         //     'text',
//         //     'Shared an image',
//         //     '1000',
//         //     'group',
//         //     vari.data()['token'][i],
//         //   );
//         // }
//       });
//     } catch (e) {
//       // _showDialog('Error add user image to storage');
//     }
//   }
// }
