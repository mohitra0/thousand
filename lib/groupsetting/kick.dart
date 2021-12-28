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

class Kick extends StatefulWidget {
  Kick(this.useruid, this.coins);

  String useruid;
  double coins;
  @override
  _KickState createState() => _KickState();
}

class _KickState extends State<Kick> {
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
            'Kick People',
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
                .where('status', isEqualTo: 'temp')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return new LoadingCircle();
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot = snapshot.data.docs[index];

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          color: Colors.white,
                          child: CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            width: MediaQuery.of(context).size.width * 0.13,
                            height: MediaQuery.of(context).size.width * 0.13,
                            imageUrl: documentSnapshot.data()['image'],
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          documentSnapshot.data()['tick'] != null
                              ? Container(
                                  child: Image.asset(
                                    "assets/images/tick.png",
                                    height: MediaQuery.of(context).size.height *
                                        0.017,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      onTap: () {
                        if (documentSnapshot.data()['uid'] != useruid) {
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
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Image.asset(
                                          'assets/images/kick.png',
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
                                                    .doc(documentSnapshot
                                                        .data()['uid']);
                                            user.update({
                                              'status': 'kick',
                                            }).then((value) {});
                                            DocumentReference usercoin =
                                                FirebaseFirestore.instance
                                                    .collection('user')
                                                    .doc(widget.useruid);
                                            usercoin.update({
                                              'coins': widget.coins - 50,
                                            }).then((value) {});

                                            int timedelete = DateTime.now()
                                                .millisecondsSinceEpoch;
                                            FirebaseFirestore.instance
                                                .collection('groupchatroom')
                                                .doc(timedelete.toString())
                                                .set({
                                              'uid': documentSnapshot
                                                  .data()['uid'],
                                              'name': documentSnapshot
                                                  .data()['name'],
                                              'color': documentSnapshot
                                                  .data()['color'],
                                              'image': documentSnapshot
                                                  .data()['image'],
                                              'timestamp': timedelete,
                                              'content':
                                                  '${documentSnapshot.data()['name']} has been removed from the group',
                                              'idFrom': 'action',
                                              'isread': true,
                                            });
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
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Kick ${documentSnapshot.data()['name']}',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: Colors.white,
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
                        }
                      },
                    ),
                  );
                },
              );
            }));
  }
}
