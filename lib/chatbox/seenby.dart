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

class SeenBy extends StatefulWidget {
  String delete;
  SeenBy({
    this.delete,
  });
  @override
  _SeenByState createState() => _SeenByState();
}

class _SeenByState extends State<SeenBy> {
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
          'Seen By',
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
              .collection('groupchatroom')
              .where('delete', isEqualTo: widget.delete)
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

                          if (e.data()[
                                  '${documentSnapshot.data()['uid']}lurk'] ==
                              true) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fitWidth,
                                      width: MediaQuery.of(context).size.width *
                                          0.13,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.13,
                                      imageUrl:
                                          documentSnapshot.data()['image'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      documentSnapshot.data()['name'],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    documentSnapshot.data()['tick'] != null
                                        ? Container(
                                            child: Image.asset(
                                              "assets/images/tick.png",
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.017,
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                                onTap: () {
                                  if (documentSnapshot.data()['uid'] !=
                                      useruid) {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) {
                                    //       return Profile(
                                    //         documentSnapshot.data()['uid'],
                                    //         documentSnapshot.data()['color'],
                                    //       );
                                    //     },
                                    //   ),
                                    // );
                                  }
                                },
                              ),
                            );
                          }
                          return Container();
                        },
                      );
                    });
              }).toList(),
            );
          }),
    );
  }
}
