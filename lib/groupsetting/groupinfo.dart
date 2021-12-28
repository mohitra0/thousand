import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:screenshot/screenshot.dart';

import 'package:flutter/rendering.dart';
import 'package:thousand/component/backfullphoto.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/groupsetting/description.dart';
import 'package:thousand/groupsetting/kick.dart';
import 'package:thousand/groupsetting/namechange.dart';
import 'package:thousand/groupsetting/photochange.dart';
import 'package:thousand/groupsetting/prime.dart';
import 'package:thousand/groupsetting/viewmembers.dart';
import 'package:thousand/screens/loading_circle.dart';
import 'dart:io';
import 'package:thousand/groupsetting/themes.dart';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';

class GroupInfo extends StatefulWidget {
  String delete;
  GroupInfo({
    this.delete,
  });
  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  int countcomment(myID, snapshot) {
    int resultInt = snapshot.data.documents.length;

    return resultInt;
  }

  ScreenshotController screenshotController = ScreenshotController();
  int chatListLength = 30;

  @override
  void initState() {
    print(widget.delete);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String searchString;
  Future<void> share2(url, useruid) async {
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    String urls = 'https://rb.gy/hc85l3';
    var bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file(
      'ESYS AMLOG',
      'amlog.jpg',
      bytes,
      'image/jpg',
      text:
          '1000, Join the group of 1000 and be a part of a community \n\n Promo Code: $useruid \n\n  https://play.google.com/store/apps/details?id=www.unify.thousand',
    );
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
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: kBackgroundColor,
        title: Text(
          'Group Info',
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width * 0.05),
          ),
        ),
        actions: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('uid', isEqualTo: useruid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return new LoadingCircle();
                }

                return Container(
                  child: Row(
                    children: [
                      Text(
                        '${snapshot.data.docs[0]['coins']} ',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04),
                        ),
                      ),
                      Image.asset(
                        'assets/images/coins.png',
                        width: MediaQuery.of(context).size.width * 0.04,
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                );
              }),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('group')
              .limit(1)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return new LoadingCircle();
            }

            return Stack(
              children: snapshot.data.docs.map((e) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .where('uid', isEqualTo: useruid)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return new LoadingCircle();
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              snapshot.data.docs[index];

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BackFullPhoto(
                                            url: e.data()['photo'],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
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
                                          imageUrl: e.data()['photo'],
                                          placeholder: (context, url) =>
                                              CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    e.data()['name'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.045),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    e.data()['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                    top: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return Themes();
                                          },
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        Text(
                                          'Change Themes',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '40 ',
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
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                    top: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
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
                                                      'assets/images/cart.png',
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                    .data()[
                                                                'coins'] >=
                                                            20) {
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                                return NameChange(
                                                                  name: e.data()[
                                                                      'name'],
                                                                  useruid:
                                                                      useruid,
                                                                  coins: documentSnapshot
                                                                          .data()[
                                                                      'coins'],
                                                                );
                                                              },
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
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
                                                            color: Colors.blue,
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
                                                              'Spend 20 Coins ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.045),
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              'assets/images/dollar.png',
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    documentSnapshot.data()[
                                                                'coins'] <
                                                            20
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
                                                                    GoogleFonts
                                                                        .lato(
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize: MediaQuery.of(context)
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        Text(
                                          'Change Group Name',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '20 ',
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
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
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
                                                      'assets/images/cart.png',
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                    .data()[
                                                                'coins'] >=
                                                            30) {
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                                return Description(
                                                                  name: e.data()[
                                                                      'descripton'],
                                                                  useruid:
                                                                      useruid,
                                                                  coins: documentSnapshot
                                                                          .data()[
                                                                      'coins'],
                                                                );
                                                              },
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
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
                                                            color: Colors.blue,
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
                                                              'Spend 30 Coins ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.045),
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              'assets/images/dollar.png',
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    documentSnapshot.data()[
                                                                'coins'] <
                                                            30
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
                                                                    GoogleFonts
                                                                        .lato(
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize: MediaQuery.of(context)
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        Text(
                                          'Change Group Description',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '30 ',
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
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
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
                                                      'assets/images/cart.png',
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                    .data()[
                                                                'coins'] >=
                                                            40) {
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                                return PhotoGroup(
                                                                  e.data()[
                                                                      'photo'],
                                                                  useruid,
                                                                  documentSnapshot
                                                                          .data()[
                                                                      'coins'],
                                                                );
                                                              },
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
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
                                                            color: Colors.blue,
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
                                                              'Spend 40 Coins ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.045),
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              'assets/images/dollar.png',
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    documentSnapshot.data()[
                                                                'coins'] <
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
                                                                    GoogleFonts
                                                                        .lato(
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize: MediaQuery.of(context)
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        Text(
                                          'Change Group Photo',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '40 ',
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
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
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
                                                      'assets/images/cart.png',
                                                      width:
                                                          MediaQuery.of(context)
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
                                                                    .data()[
                                                                'coins'] >=
                                                            50) {
                                                          await Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                                return Kick(
                                                                  useruid,
                                                                  documentSnapshot
                                                                          .data()[
                                                                      'coins'],
                                                                );
                                                              },
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
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
                                                            color: Colors.blue,
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
                                                              'Spend 30 Coins ',
                                                              style: GoogleFonts
                                                                  .lato(
                                                                textStyle: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.045),
                                                              ),
                                                            ),
                                                            Image.asset(
                                                              'assets/images/dollar.png',
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.04,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    documentSnapshot.data()[
                                                                'coins'] <
                                                            50
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
                                                                    GoogleFonts
                                                                        .lato(
                                                                  textStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize: MediaQuery.of(context)
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.12,
                                        ),
                                        Text(
                                          'Kick People',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '50 ',
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
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ViewMembers();
                                          },
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'View Members',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PrimeMembers();
                                          },
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Prime Members',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.orange,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      //
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1.0,
                                    ),
                                  )),
                                  child: FlatButton(
                                    onPressed: () {
                                      share2(e.data()['photo'], useruid);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/moneybag.png',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Refer and Earn Coins',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                                color: Colors.green,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.04),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                documentSnapshot.data()['status'] != 'prime'
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            border: Border(
                                          bottom: BorderSide(
                                            //
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            width: 1.0,
                                          ),
                                        )),
                                        child: FlatButton(
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
                                                            'assets/images/cart.png',
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
                                                            onTap: () async {
                                                              if (documentSnapshot
                                                                          .data()[
                                                                      'coins'] >=
                                                                  250) {
                                                                DocumentReference
                                                                    user =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'user')
                                                                        .doc(
                                                                            useruid);
                                                                user.update({
                                                                  'status':
                                                                      'prime',
                                                                }).then(
                                                                    (value) {});
                                                                DocumentReference
                                                                    usercoin =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'user')
                                                                        .doc(
                                                                            useruid);
                                                                usercoin.update({
                                                                  'coins': documentSnapshot
                                                                              .data()[
                                                                          'coins'] -
                                                                      250,
                                                                }).then(
                                                                    (value) {});
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                              }

                                                              int timedelete =
                                                                  DateTime.now()
                                                                      .millisecondsSinceEpoch;
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'groupchatroom')
                                                                  .doc(timedelete
                                                                      .toString())
                                                                  .set({
                                                                'uid': documentSnapshot
                                                                        .data()[
                                                                    'uid'],
                                                                'name': documentSnapshot
                                                                        .data()[
                                                                    'name'],
                                                                'color': documentSnapshot
                                                                        .data()[
                                                                    'color'],
                                                                'image': documentSnapshot
                                                                        .data()[
                                                                    'image'],
                                                                'timestamp':
                                                                    timedelete,
                                                                'content':
                                                                    '${documentSnapshot.data()['name']} has upgraded to Prime Membership',
                                                                'idFrom':
                                                                    'action',
                                                                'isread': true,
                                                              });
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
                                                                      .blue,
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
                                                                    'Spend 250 Coins ',
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
                                                                  Image.asset(
                                                                    'assets/images/dollar.png',
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.04,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          documentSnapshot.data()[
                                                                      'coins'] <
                                                                  250
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
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.04,
                                                                    ),
                                                                    Text(
                                                                      ' You do not Sufficient amount of Coins ',
                                                                      style: GoogleFonts
                                                                          .lato(
                                                                        textStyle: TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            fontSize: MediaQuery.of(context).size.width * 0.04),
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
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.12,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    'assets/images/premium.png',
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(
                                                    'Get Prime Membership',
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          color: Colors.cyan,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '250 ',
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                    ),
                                                  ),
                                                  Image.asset(
                                                    'assets/images/dollar.png',
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.04,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.1),
                                  child: Text(
                                    '1000 people can use the app at a particular time. Once the 1001th person joins the app their account will be deactivated until they earn the Prime Membership',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.035),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    });
              }).toList(),
            );
          }),
    );
  }
}
