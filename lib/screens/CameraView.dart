import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:thousand/component/utils.dart';

class CameraViewPage extends StatefulWidget {
  const CameraViewPage({Key key, this.path, this.image, this.name, this.token})
      : super(key: key);
  final XFile path;
  final String name;
  final String token;
  final String image;
  @override
  _CameraViewPageState createState() => _CameraViewPageState();
}

class _CameraViewPageState extends State<CameraViewPage> {
  var useruid;
  final TextEditingController caption = new TextEditingController();
  bool loading = false;
  File croppedFile;
  @override
  void initState() {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    useruid = user.uid;
    // croppedFile = widget.path as File;
    croppedFile = File(widget.path.path);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () async {
                croppedFile = await ImageCropper.cropImage(
                    sourcePath: widget.path.path,
                    aspectRatioPresets: [
                      CropAspectRatioPreset.square,
                      CropAspectRatioPreset.ratio3x2,
                      CropAspectRatioPreset.original,
                      CropAspectRatioPreset.ratio4x3,
                      CropAspectRatioPreset.ratio16x9
                    ],
                    androidUiSettings: AndroidUiSettings(
                        toolbarTitle: 'Resize',
                        toolbarColor: Color(0XFF252331),
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        backgroundColor: Colors.black,
                        cropFrameColor: Colors.blue,
                        activeControlsWidgetColor: Colors.blue,
                        lockAspectRatio: false),
                    iosUiSettings: IOSUiSettings(
                      minimumAspectRatio: 1.0,
                    ));
                setState(() {});
              }),
          // IconButton(
          //     icon: Icon(
          //       Icons.emoji_emotions_outlined,
          //       size: 27,
          //     ),
          //     onPressed: () {}),
          // IconButton(
          //     icon: Icon(
          //       Icons.title,
          //       size: 27,
          //     ),
          //     onPressed: () {}),
          // IconButton(
          //     icon: Icon(
          //       Icons.edit,
          //       size: 27,
          //     ),
          //     onPressed: () {}),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(croppedFile == null ? widget.path.path : croppedFile.path),
                fit: BoxFit.cover,
              ),
            ),
            loading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    color: Colors.transparent,
                  )
                : Positioned(
                    bottom: 0,
                    child: Container(
                      color: Colors.black38,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: TextFormField(
                        controller: caption,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        maxLines: 6,
                        minLines: 1,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Add Caption....",
                            hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  loading = true;
                                });
                                _saveUserImageToFirebaseStorage()
                                    .whenComplete(() {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },
                              child: CircleAvatar(
                                radius: 27,
                                backgroundColor: Colors.tealAccent[700],
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUserImageToFirebaseStorage() async {
    try {
      int timedelete = DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('groupchatroom')
          .doc(timedelete.toString())
          .set({
        'delete': timedelete.toString(),
        'name': widget.name,
        'image': widget.image,
        'token': widget.token,
        'idFrom': useruid,
        'timestamp': timedelete,
        'message': 'loading',
        'type': 'camera',
        'caption': caption.text,
        'isread': false,
      });
      String filePath = 'groupchatroom/$timedelete';
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(filePath);
      final UploadTask uploadTask = storageReference.putFile(croppedFile);
      uploadTask.then((res) async {
        DocumentReference userstotal = FirebaseFirestore.instance
            .collection('groupchatroom')
            .doc(timedelete.toString());
        userstotal.update({
          'message': await storageReference.getDownloadURL(),
        }).then((value) {});

        // DocumentSnapshot vari = await FirebaseFirestore.instance
        //     .collection('group')
        //     .doc('group')
        //     .get();
        // for (int i = 0; i < vari.data()['token'].length; i++) {
        //   await sendNotificationMessageToPeerUser(
        //     1,
        //     'text',
        //     'Shared an image',
        //     '1000',
        //     'group',
        //     vari.data()['token'][i],
        //   );
        // }
      });
    } catch (e) {
      // _showDialog('Error add user image to storage');
    }
  }
}
