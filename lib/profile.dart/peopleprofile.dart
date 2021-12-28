import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:screenshot/screenshot.dart';

import 'package:flutter/rendering.dart';
import 'package:thousand/component/utils.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/screens/loading_circle.dart';
import 'package:thousand/component/backfullphoto.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';

import 'package:thousand/profile.dart/intrests.dart';
import 'package:thousand/sign%20up/welcome_page.dart';
import 'package:thousand/profile.dart/bio.dart';
import 'package:thousand/profile.dart/name.dart';

class PeopleProfile extends StatefulWidget {
  PeopleProfile(this.uid, this.name, this.report);

  String uid;
  String name;
  int report;
  @override
  _PeopleProfileState createState() => _PeopleProfileState();
}

class _PeopleProfileState extends State<PeopleProfile> {
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

  File _image;
  final ImagePicker _picker = ImagePicker();
  getImage(source) async {
    var image = await _picker.getImage(
      source: source,
    );
    File croppedFile = await ImageCropper.cropImage(sourcePath: image.path);

    setState(() {
      _image = croppedFile;
    });
  }

  String searchString;
  final gradient = [
    '62deg',
    '8EC5FC',
    'E0C3FC',
  ];
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('uid', isEqualTo: widget.uid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return new LoadingCircle();
                    }

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot e = snapshot.data.docs[index];

                        return Container(
                          child: Stack(
                            children: [
                              e.data()['backImage'] == null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.51,
                                      child: Center())
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return BackFullPhoto(
                                                url: e.data()['image'],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          child: Container(
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fitWidth,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.51,
                                              imageUrl: e.data()['backImage'],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return BackFullPhoto(
                                          url: e.data()['image'],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top:
                                        MediaQuery.of(context).size.width * 0.3,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Container(
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fitWidth,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              imageUrl: e.data()['image'],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Text(
                                              e.data()['name'],
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.045),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          e.data()['status'] == 'prime'
                                              ? Image.asset(
                                                  'assets/images/ticks.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.04,
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      Container(
                                        child: Text(
                                          '${e.data()['username']}',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.4),
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Coins ${e.data()['coins']} ',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04),
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/dollar.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/calendar.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04,
                                          ),
                                          Text(
                                            '  ${readTimestampDays(e.data()['timeStamp'])} on Thousand',
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04),
                                            ),
                                            overflow: TextOverflow.visible,
                                          ),
                                        ],
                                      ),
                                      e.data()['bio'] != null
                                          ? Container(
                                              margin: EdgeInsets.only(top: 10),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              child: Text(
                                                e.data()['bio'],
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.visible,
                                                style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01),
                                        child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('intrests')
                                                .where(useruid, isEqualTo: true)
                                                .snapshots(),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container();
                                              }
                                              if (snapshot.data.docs.isEmpty) {
                                                return Container();
                                              }
                                              return GridView.builder(
                                                gridDelegate:
                                                    new SliverGridDelegateWithFixedCrossAxisCount(
                                                        childAspectRatio: MediaQuery
                                                                    .of(context)
                                                                .size
                                                                .width /
                                                            (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.35),
                                                        crossAxisCount: 5),
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    snapshot.data.docs.length,
                                                itemBuilder: (context, index) {
                                                  DocumentSnapshot e =
                                                      snapshot.data.docs[index];

                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) {
                                                            return Intrests();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          top: 15, left: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.02,
                                                          vertical: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.02),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.blue)),
                                                      child: Text(
                                                        e.data()['intrests'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.8),
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.035),
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
                                ),
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.arrow_back,
                                                color: Colors.white),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Text(
                                            'Info',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.05),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.questionCircle,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            showModalBottomSheet<dynamic>(
                                              isScrollControlled: true,
                                              backgroundColor: Colors.white,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        StateSetter
                                                            setState /*You can rename this!*/) {
                                                  return Container(
                                                      color: Colors.black,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.3,
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Image.asset(
                                                            'assets/images/report.png',
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.16,
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              DocumentReference
                                                                  user =
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'user')
                                                                      .doc(widget
                                                                          .uid);
                                                              user.update({
                                                                'report': widget
                                                                        .report +
                                                                    1,
                                                              }).then(
                                                                  (value) {});

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          15),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.08,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .red,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Report ${widget.name}',
                                                                    style:
                                                                        GoogleFonts
                                                                            .lato(
                                                                      textStyle: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              MediaQuery.of(context).size.width * 0.045),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                        ],
                                                      ));
                                                });
                                              },
                                            );
                                          })
                                    ],
                                  )),
                            ],
                          ),
                        );
                      },
                    );
                  }),
            ],
          ),
        ));
  }
}
