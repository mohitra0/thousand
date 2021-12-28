import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:screenshot/screenshot.dart';

import 'package:flutter/rendering.dart';
import 'package:thousand/component/utils.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/screens/loading_circle.dart';
import 'package:linkable/linkable.dart';
import 'package:hexcolor/hexcolor.dart';

class Themes extends StatefulWidget {
  @override
  _ThemesState createState() => _ThemesState();
}

class _ThemesState extends State<Themes> {
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

  List color = [
    'd27775',
    '5fa4d3',
    'a86da6',
    '2f3448',
    '5172b7',
    '8166ad',
    'f1664c',
    '609b9e',
    'c4498e',
    '6db0b3',
    '191d2c',
  ];
  String searchString;

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
            'Themes',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05),
            ),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .where('uid', isEqualTo: useruid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return new LoadingCircle();
              }

              return Center(
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      DocumentSnapshot documentSnapshot = snapshot.data.docs[0];
                      return documentSnapshot.data()[color[index]] == true
                          ? GestureDetector(
                              onTap: () {
                                showModalBottomSheet<dynamic>(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder: (BuildContext
                                            context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                      return Container(
                                          color: Colors.black,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Image.asset(
                                                'assets/images/themes.png',
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.16,
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  DocumentReference user =
                                                      FirebaseFirestore.instance
                                                          .collection('user')
                                                          .doc(useruid);
                                                  user.update({
                                                    'themecolor': color[index],
                                                  }).then((value) {});

                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.08,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                        'Set theme',
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.045),
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
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            left: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 0.1),
                                            color: HexColor('#${color[index]}'),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: Linkable(
                                          textColor: Colors.white,
                                          text:
                                              'These are the examples of the themes, tap to choose',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       '40 ',
                                    //       style: GoogleFonts.lato(
                                    //         textStyle: TextStyle(
                                    //             color: Colors.white,
                                    //             fontSize: MediaQuery.of(context)
                                    //                     .size
                                    //                     .width *
                                    //                 0.04),
                                    //       ),
                                    //     ),
                                    //     Image.asset(
                                    //       'assets/images/dollar.png',
                                    //       width: MediaQuery.of(context)
                                    //               .size
                                    //               .width *
                                    //           0.04,
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ))
                          : GestureDetector(
                              onTap: () {
                                showModalBottomSheet<dynamic>(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(builder: (BuildContext
                                            context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                      return Container(
                                          color: Colors.black,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Image.asset(
                                                'assets/images/themes.png',
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.16,
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  if (documentSnapshot
                                                          .data()['coins'] >=
                                                      40) {
                                                    DocumentReference user =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('user')
                                                            .doc(useruid);
                                                    user.update({
                                                      'themecolor':
                                                          color[index],
                                                      color[index]: true,
                                                      'coins': documentSnapshot
                                                              .data()['coins'] -
                                                          40
                                                    }).then((value) {});

                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 15),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.08,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                        'Get the theme',
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.045),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              documentSnapshot.data()['coins'] <
                                                      40
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/alarm.png',
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04,
                                                        ),
                                                        Text(
                                                          ' You do not Sufficient amount of Coins ',
                                                          style:
                                                              GoogleFonts.lato(
                                                            textStyle: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.04),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ));
                                    });
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        padding: EdgeInsets.only(
                                            top: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            bottom: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            left: 10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 0.1),
                                            color: HexColor('#${color[index]}'),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: Linkable(
                                          textColor: Colors.white,
                                          text:
                                              'These are the examples of the themes, tap to choose',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '40 ',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
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
                                  ],
                                ),
                              ));
                    }),
              );
            }));
  }
}
