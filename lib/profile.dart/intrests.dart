import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:screenshot/screenshot.dart';

import 'package:flutter/rendering.dart';
import 'package:thousand/component/backfullphoto.dart';
import 'package:thousand/component/utils.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/screens/loading_circle.dart';

class Intrests extends StatefulWidget {
  @override
  _IntrestsState createState() => _IntrestsState();
}

class _IntrestsState extends State<Intrests> {
  int countcomment(myID, snapshot) {
    int resultInt = snapshot.data.documents.length;

    return resultInt;
  }

  ScreenshotController screenshotController = ScreenshotController();
  int chatListLength = 30;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final useruid = user.uid;

    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          title: Text(
            'Intrests',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white.withOpacity(1),
                  fontSize: MediaQuery.of(context).size.width * 0.04),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: MediaQuery.of(context).size.height * 0.02),
                child: Text(
                  'Pick things you like from the list. These will show on your profile',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: MediaQuery.of(context).size.width * 0.04),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.01),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('intrests')
                        .where(useruid, isEqualTo: true)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return new LoadingCircle();
                      }

                      return GridView.builder(
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: MediaQuery.of(context)
                                        .size
                                        .width /
                                    (MediaQuery.of(context).size.height * 0.33),
                                crossAxisCount: 5),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot e = snapshot.data.docs[index];

                          return GestureDetector(
                            onTap: () {
                              DocumentReference usercoin = FirebaseFirestore
                                  .instance
                                  .collection('intrests')
                                  .doc(e.data()['timestamp']);
                              usercoin.update({
                                useruid: FieldValue.delete(),
                              }).then((value) {});
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 15, left: 10),
                              width: MediaQuery.of(context).size.width * 0.3,
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.02,
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.02),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  border:
                                      Border.all(width: 1, color: Colors.blue)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    e.data()['intrests'],
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 2.5),
                                    child: Icon(
                                      FontAwesomeIcons.times,
                                      color: Colors.white.withOpacity(0.8),
                                      size: MediaQuery.of(context).size.width *
                                          0.03,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ),
              SizedBox(
                height: 15,
              ),
              Divider(
                color: Colors.white.withOpacity(0.6),
                thickness: 1,
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.015),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('intrests')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return new LoadingCircle();
                      }

                      return GridView.builder(
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: MediaQuery.of(context)
                                        .size
                                        .width /
                                    (MediaQuery.of(context).size.height * 0.21),
                                crossAxisCount: 3),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot e = snapshot.data.docs[index];

                          return GestureDetector(
                            onTap: () {
                              DocumentReference usercoin = FirebaseFirestore
                                  .instance
                                  .collection('intrests')
                                  .doc(e.data()['timestamp']);
                              usercoin.update({
                                useruid: true,
                              }).then((value) {});
                            },
                            child: e.data()[useruid] == true
                                ? Container(
                                    margin: EdgeInsets.only(
                                        top: 15, left: 15, right: 15),
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        vertical:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                            width: 1, color: Colors.blue)),
                                    child: Text(
                                      e.data()['intrests'],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: EdgeInsets.only(
                                        top: 15, left: 15, right: 15),
                                    width:
                                        MediaQuery.of(context).size.width * 0.1,
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                        vertical:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        border: Border.all(
                                            width: 1, color: Colors.blue)),
                                    child: Text(
                                      e.data()['intrests'],
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ));
  }
}
