import 'dart:async';
import 'dart:io';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:linkable/linkable.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thousand/screens/loading_circle.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class FullPhoto extends StatefulWidget {
  final String timeStamp;

  FullPhoto({Key key, this.timeStamp});
  @override
  _FullPhotoState createState() => _FullPhotoState();
}

class _FullPhotoState extends State<FullPhoto> {
  int countcomment(myID, snapshot) {
    int resultInt = snapshot.data.documents.length;

    return resultInt;
  }

  int pageindex;
  @override
  void initState() {
    print('this scrreen');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final useruid = user.uid;

    return Scaffold(
      backgroundColor: HexColor('#1c1f43'),
      body: Screenshot(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groupchatroom')
                  .where('delete', isEqualTo: widget.timeStamp)
                  // .limit(1)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return new Center(
                      child: Text(
                    'sadssddddddddddddddddddddddddddd',
                  ));
                } else if (snapshot.data.docs.isEmpty) {
                  return new Center(
                      child: Text(
                    'sadssddddddddddddddddddddddddddd',
                  ));
                }

                return PageView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data.docs[index];

                    return GestureDetector(
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            Positioned(
                              left: documentSnapshot.data()['imagedx'],
                              top: documentSnapshot.data()['imagedy'],
                              child: Container(
                                alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                    border: Border(
                                  bottom: BorderSide(
                                    //                   <--- left side
                                    color: Colors.white,
                                    width: 0.1,
                                  ),
                                )),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: CachedNetworkImage(
                                  imageUrl: documentSnapshot.data()['message'],
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  filterQuality: FilterQuality.low,
                                  placeholder: (context, url) =>
                                      LoadingCircle(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            documentSnapshot.data()['gif'] != null
                                ? Container(
                                    child: Positioned.fromRect(
                                      rect: Rect.fromPoints(
                                          Offset(
                                              documentSnapshot.data()['gifdx'] -
                                                  125.0,
                                              documentSnapshot.data()['gifdy'] -
                                                  100.0),
                                          Offset(
                                              documentSnapshot.data()['gifdx'] +
                                                  250.0,
                                              documentSnapshot.data()['gifdy'] +
                                                  100.0)),
                                      child: Container(
                                        child: RotatedBox(
                                          quarterTurns: 0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Transform(
                                              alignment:
                                                  FractionalOffset.center,
                                              transform: Matrix4.diagonal3(
                                                  Vector3(
                                                      documentSnapshot
                                                          .data()['scale'],
                                                      documentSnapshot
                                                          .data()['scale'],
                                                      documentSnapshot
                                                          .data()['scale'])),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    'https://media.giphy.com/media/${documentSnapshot.data()['gif']}/giphy.gif',
                                                placeholder: (context, url) =>
                                                    LoadingCircle(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            documentSnapshot.data()['text'] == null
                                ? Container()
                                : Container(
                                    child: Positioned(
                                      left: documentSnapshot.data()['textdx'],
                                      top: documentSnapshot.data()['textdy'],
                                      child: SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              documentSnapshot.data()['text'],
                                              style: TextStyle(
                                                color: HexColor(
                                                    '#${documentSnapshot.data()['textcolor']}'),
                                                fontSize: documentSnapshot
                                                    .data()['fontsize'],
                                                fontFamily: documentSnapshot
                                                    .data()['font'],
                                              ),
                                              textAlign: documentSnapshot
                                                              .data()[
                                                          'textalign'] ==
                                                      0
                                                  ? TextAlign.left
                                                  : documentSnapshot.data()[
                                                              'textalign'] ==
                                                          1
                                                      ? TextAlign.right
                                                      : TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              })),
    );
  }

  // _onTapUp(TapUpDetails details) {
  //   var x = details.globalPosition.dx;
  //   var y = details.globalPosition.dy;
  //   // or user the local position method to get the offset
  //   print(details.localPosition);
  //   print("tap up " + x.toString() + ", " + y.toString());
  // }

}
