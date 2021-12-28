import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:io';

import 'package:random_color/random_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/screens/loading_circle.dart';

class PhotoGroup extends StatefulWidget {
  PhotoGroup(this.photo, this.useruid, this.coins);

  String photo;
  String useruid;
  double coins;

  @override
  _PhotoGroupState createState() => _PhotoGroupState();
}

class _PhotoGroupState extends State<PhotoGroup> {
  var downurl;
  File _image;
  final ImagePicker _picker = ImagePicker();
  bool _isloadig = false;
  double _progress;
  getImage(source) async {
    var image = await _picker.getImage(
      source: source,
    );
    File croppedFile = await ImageCropper.cropImage(sourcePath: image.path);

    setState(() {
      _image = croppedFile;
    });
  }

  bool empty = false;
  // void setStateIfMounted(f) {
  //   if (mounted) setState(f);
  // }

  progress(loading) {
    if (loading) {
      return Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey,
          ),
          Text('${(_progress * 100).toStringAsFixed(2)} %'),
        ],
      );
    } else {
      return Text('');
    }
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var widthh = screenSize.width;
    var heightt = screenSize.height;
    return loading
        ? LoadingCircle()
        : Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              elevation: 0,
              backgroundColor: kBackgroundColor,
              title: Text(
                'Change Group Photo',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: _image == null
                          ? Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fitWidth,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        imageUrl: widget.photo,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  child: Image.file(
                                    _image,
                                    fit: BoxFit.fitWidth,
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                ),
                              ),
                            ),
                    )
                  ],
                )),

                Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () => getImage(ImageSource.gallery),
                                child: Container(
                                  padding: EdgeInsets.all(heightt * 0.04),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.cameraRetro,
                                    color: Colors.white,
                                    size: widthh * 0.07,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Camera',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: widthh * 0.04),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () => getImage(ImageSource.gallery),
                                child: Container(
                                  padding: EdgeInsets.all(heightt * 0.04),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.transparent,
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.image,
                                    color: Colors.white,
                                    size: widthh * 0.07,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Gallery',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: widthh * 0.04),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: heightt * 0.02,
                      ),
                      Column(
                        children: <Widget>[
                          FlatButton.icon(
                              color: Colors.transparent,
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.white)),
                              disabledColor: Colors.grey,
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 100),
                              disabledTextColor: Colors.black,
                              splashColor: Colors.blueAccent,
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                upload();
                                setState(() {
                                  loading = false;
                                });
                              },
                              icon: Icon(Icons.cloud_upload),
                              label: Text(
                                'Set Group Photo',
                                style: TextStyle(
                                  fontSize: widthh * 0.04,
                                  fontFamily: "Proximathin",
                                ),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      empty == true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/alarm.png',
                                  width:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                Text(
                                  '   Please Select an image to upload',
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.04),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                // progress(_isloadig)
              ],
            ),
          );
  }

  upload() async {
    if (_image == null) {
      setState(() {
        empty = true;
      });
      return;
    } else {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User user = auth.currentUser;
      String current_uid = user.uid;
      DocumentReference usercoin =
          FirebaseFirestore.instance.collection('user').doc(widget.useruid);
      usercoin.update({
        'coins': widget.coins - 40,
      }).then((value) {});
      DocumentReference users =
          FirebaseFirestore.instance.collection('group').doc('group');
      String time = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference reference =
          FirebaseStorage.instance.ref().child('group/$time');
      final UploadTask uploadTask = reference.putFile(_image);
      await uploadTask.then((res) async {
        users.update({
          'photo': await reference.getDownloadURL(),
        }).then((value) {});
      });

      Navigator.pop(context);
    }
  }
}
