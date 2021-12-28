import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:linkable/linkable.dart';
import 'package:storage_path/storage_path.dart';
import 'dart:io';
import 'package:swipe_to/swipe_to.dart';
import 'package:thousand/chatbox/seenby.dart';
import 'package:thousand/component/full_photo.dart';
import 'package:thousand/component/utils.dart';
import 'package:thousand/constants.dart';
import 'package:thousand/profile.dart/Myprofile.dart';
import 'package:thousand/screens/camera.dart';
import 'package:thousand/screens/gallery_image.dart';
import 'package:thousand/groupsetting/groupinfo.dart';
import 'package:thousand/screens/loading_circle.dart';
import '../screens/imagePicker.dart';
import 'dart:convert';
import 'package:thousand/profile.dart/peopleprofile.dart';

class GroupChat extends StatefulWidget {
  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final TextEditingController _msgTextController = new TextEditingController();
  final ScrollController _chatListController = ScrollController();
  var useruid;
  bool _isLoading = false;
  int chatListLength = 50;
  double _scrollPosition = 60;
  // VideoPlayerController _controller;

  _scrollListener() {
    if (_scrollPosition < _chatListController.position.pixels) {
      setState(() {
        _scrollPosition = _scrollPosition + 560;
        chatListLength = chatListLength + 20;
      });
    }
  }

  @override
  void initState() {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    useruid = user.uid;
    _chatListController.addListener(_scrollListener);
    myFocusNode = FocusNode();
    getImagesPath();
    // final uint8list = await VideoThumbnail.thumbnailFile(
    //   video: url,
    //   thumbnailPath: (await getTemporaryDirectory()).path,
    //   // imageFormat: ImageFormat.WEBP,
    //   maxHeight:
    //       64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
    //   quality: 75,
    // );
    // return uint8list;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    myFocusNode.dispose();
    DocumentReference userstotal =
        FirebaseFirestore.instance.collection('group').doc('group');
    userstotal.update({
      'typing': false,
      "${useruid}timeStampseen": DateTime.now().millisecondsSinceEpoch,
    }).then((value) {});
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        DocumentReference userstotal =
            FirebaseFirestore.instance.collection('group').doc('group');
        userstotal.update({
          'typing': false,
          "${useruid}timeStampseen": DateTime.now().millisecondsSinceEpoch,
        }).then((value) {});
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        DocumentReference userstotal =
            FirebaseFirestore.instance.collection('group').doc('group');
        userstotal.update({
          'typing': false,
          "${useruid}timeStampseen": DateTime.now().millisecondsSinceEpoch,
        }).then((value) {});
        print("app in paused");
        break;
      case AppLifecycleState.detached:
        DocumentReference userstotal =
            FirebaseFirestore.instance.collection('group').doc('group');
        userstotal.update({
          'typing': false,
          "${useruid}timeStampseen": DateTime.now().millisecondsSinceEpoch,
        }).then((value) {});
        break;
    }
  }

  Future<void> cameraValue;
  bool isRecoring = false;
  bool flash = false;
  bool iscamerafront = true;
  double transform = 0;

  @override
  List<FileModel> files;
  FileModel selectedModel;
  String image;
  getImagesPath() async {
    try {
      var imagePath = await StoragePath.imagesPath;
      var videoPath = await StoragePath.videoPath;

      var images = jsonDecode(imagePath) as List;
      // var video = jsonDecode(videoPath) as List;
      files = images.map<FileModel>((e) => FileModel.fromJson(e)).toList();
      // files = video.map<FileModel>((e) => FileModel.fromJson(e)).toList();
      if (files != null && files.length > 0)
        setState(() {
          selectedModel = files[0];
          image = files[0].files[0];
        });
    } catch (e) {
      print(e);
    }
  }

  @override
  bool get wantKeepAlive => true;
  File _image;
  String replyname;
  String replymessage;
  String replytoken;
  bool reply = false;
  double replyheight = 0;
  FocusNode myFocusNode;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          elevation: 0,
          backgroundColor: Color(0XFF252331),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GroupInfo();
                  },
                ),
              );
            },
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('group')
                    .where('group')
                    .limit(1)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Container();

                  return Stack(
                    children: snapshot.data.docs.map((e) {
                      if (e.data()['typing'] != false &&
                          e.data()['typing'] != null &&
                          e.data()['typingId'] != useruid) {
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.of(context).size.width * 0.11,
                                  height:
                                      MediaQuery.of(context).size.width * 0.11,
                                  imageUrl: snapshot.data.docs[0]['photo'],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              '${e.data()['typing']} is typing...',
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.040),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.1,
                                  imageUrl: snapshot.data.docs[0]['photo'],
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              snapshot.data.docs[0]['name'].toString(),
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.040),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        );
                      }
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('uid', isEqualTo: useruid)
                  .limit(1)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return new LoadingCircle();
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyProfile()));
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.width * 0.1,
                            imageUrl: snapshot.data.docs[0]['image'],
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('groupchatroom')
                .orderBy('timestamp', descending: true)
                .limit(chatListLength)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              if (snapshot.hasData) {
                for (var data in snapshot.data.docs) {
                  if (data['idFrom'] != useruid && data['isread'] == false) {
                    if (data.reference != null) {
                      FirebaseFirestore.instance
                          .runTransaction((Transaction myTransaction) async {
                        await myTransaction.update(
                          data.reference,
                          {
                            'isread': true,
                            '${useruid}lurk': true,
                          },
                        );
                      });
                    }
                  }
                }
              }
              return Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                        color: Colors.transparent,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          addAutomaticKeepAlives: true, // Add this property

                          reverse: true,
                          controller: _chatListController,
                          itemCount: snapshot.data.docs.length,
                          padding: EdgeInsets.fromLTRB(4.0, 10, 4,
                              MediaQuery.of(context).size.height * 0.092),
                          itemBuilder: (context, index) {
                            DocumentSnapshot data = snapshot.data.docs[index];
                            return data.data()['idFrom'] == useruid
                                ? _listItemMine(
                                    context,
                                    data.data()['name'],
                                    data.data()['message'],
                                    returnTimeStamp(data.data()['timestamp']),
                                    data.data()['isread'],
                                    data.data()['type'],
                                    data.data()['name'],
                                    data.data()['timestamp'],
                                    data.data()['reply'],
                                    data.data()['image'],
                                    data.data()['delete'],
                                    data.data()['caption'],
                                    data.data()['video'],
                                    index,
                                    data.data()['themecolor'],
                                  )
                                : data.data()['idFrom'] == 'action'
                                    ? Center(
                                        child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                if (useruid !=
                                                    data.data()['uid'])
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return PeopleProfile(
                                                          data.data()['uid'],
                                                          data.data()['name'],
                                                          null,
                                                        );
                                                      },
                                                    ),
                                                  );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: Colors.white,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.fitWidth,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.09,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.09,
                                                      imageUrl:
                                                          data.data()['image'],
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              data.data()['content'],
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                    : _listItemOther(
                                        context,
                                        data.data()['name'],
                                        data.data()['image'],
                                        data.data()['message'],
                                        data['timestamp'],
                                        data.data()['type'],
                                        data.data()['reply'],
                                        data.data()['idFrom'],
                                        data.data()['token'],
                                        data.data()['delete'],
                                        data.data()['caption'],
                                        data.data()['video'],
                                        data.data()['${useruid}seen'],
                                        data.data()['themecolor'],
                                      );
                          },
                        ),
                      )),
                    ],
                  ),
                  Stack(
                    children: [
                      reply == true
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.04,
                                  left:
                                      MediaQuery.of(context).size.width * 0.02,
                                  right:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.03,
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                  right:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0XFF252331),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Replying to $replyname',
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.03,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          child: Icon(FontAwesomeIcons.times,
                                              size: 15, color: Colors.white),
                                          onTap: () {
                                            setState(() {
                                              reply = false;
                                              replyheight = 0;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      replymessage,
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03,
                                        ),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      _buildTextComposer()
                    ],
                  ),
                ],
              );
            }));
  }

  Widget _listItemOther(
    BuildContext context,
    String name,
    String image,
    String message,
    int time,
    String type,
    String replied,
    String otheruseruid,
    String token,
    String delete,
    String caption,
    String video,
    String seen,
    String themecolor,
  ) {
    if (type == 'text') {
      return Container(
        padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.2,
            top: MediaQuery.of(context).size.width * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                if (useruid != otheruseruid)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PeopleProfile(
                          otheruseruid,
                          name,
                          null,
                        );
                      },
                    ),
                  );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width * 0.09,
                    height: MediaQuery.of(context).size.width * 0.09,
                    imageUrl: image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SwipeTo(
                    onRightSwipe: () {
                      setState(() {
                        replyname = name;
                        replymessage = message;
                        reply = true;
                        replyheight = 0.08;
                        replytoken = token;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          // alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02,
                              horizontal: themecolor != null ? 10 : 5),
                          decoration: themecolor != null
                              ? BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.1),
                                  color: HexColor('#$themecolor'),
                                  borderRadius: BorderRadius.circular(100))
                              : BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.4),
                                  color: Color(0XFF252331),
                                  borderRadius: BorderRadius.circular(5)),
                          child: Linkable(
                            textColor: Colors.white.withOpacity(0.9),
                            text: message,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.035),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Linkable(
                    textColor: Colors.white.withOpacity(0.5),
                    text: readTimestamp(time).toString(),
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.025,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (type == 'reply') {
      return Container(
          padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.2,
              top: MediaQuery.of(context).size.width * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  if (useruid != otheruseruid)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PeopleProfile(
                            otheruseruid,
                            name,
                            null,
                          );
                        },
                      ),
                    );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: CachedNetworkImage(
                      width: MediaQuery.of(context).size.width * 0.09,
                      height: MediaQuery.of(context).size.width * 0.09,
                      imageUrl: image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.006,
              ),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    2.0)), //this right here
                            child: Wrap(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    '',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'time',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(
                                          new ClipboardData(text: "$message"));
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Copy",
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.04),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: SwipeTo(
                    onRightSwipe: () {
                      setState(() {
                        replyname = name;
                        replymessage = message;
                        reply = true;
                        replyheight = 0.08;
                        replytoken = token;
                      });
                      FocusScope.of(context).requestFocus(myFocusNode);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            ('Replied'),
                            overflow: TextOverflow.visible,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Container(
                          // margin: EdgeInsets.only(right: MediaQuery.of(context).size.width* 0.07),
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02,
                              horizontal: themecolor != null ? 10 : 5),
                          decoration: themecolor != null
                              ? BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.1),
                                  color: HexColor('#$themecolor'),
                                  borderRadius: BorderRadius.circular(100))
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.red.withOpacity(0.5),
                                ),
                          child: Linkable(
                            textColor: Colors.white.withOpacity(0.8),
                            text: replied,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.032),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.2),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Linkable(
                            textColor: Colors.white.withOpacity(0.8),
                            text: message,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.035),
                            ),
                          ),
                        ),
                        Linkable(
                          textColor: Colors.white.withOpacity(0.5),
                          text: readTimestamp(time).toString(),
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.025,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ));
    } else if (type == 'gif') {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullPhoto(timeStamp: time.toString())));
        },
        child: Container(
          margin: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * 0.3,
              top: MediaQuery.of(context).size.height * 0.02,
              left: 15),
          child: CachedNetworkImage(
            // width: MediaQuery.of(context).size.width* 0.25,
            imageUrl: 'https://media.giphy.com/media/$message/giphy.gif',
            placeholder: (context, url) => LoadingCircle(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      );
    } else if (type == 'camera') {
      return GestureDetector(
        onTap: () async {
          if (seen == null) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FullPhoto(
                          timeStamp: delete.toString(),
                        )));
            await FirebaseFirestore.instance
                .collection('groupchatroom')
                .doc(delete)
                .update({'${useruid}seen': 'true'});
          }
        },
        child: Container(
          margin: EdgeInsets.only(
              left: 15,
              top: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.width * 0.7),
          width: MediaQuery.of(context).size.width * 0.05,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  child: message == 'loading'
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(child: new CircularProgressIndicator()),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Color(0XFF252331),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.play,
                                color: seen == null
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: MediaQuery.of(context).size.width * 0.037,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                child: Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: seen == null
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Robotoregular',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01),
                    child: Linkable(
                      textColor: Colors.white.withOpacity(0.5),
                      text: readTimestamp(time).toString(),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.025,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          print(delete);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullPhoto(
                        timeStamp: delete.toString(),
                      )));
        },
        child: Container(
          margin: EdgeInsets.only(
              left: 15,
              top: MediaQuery.of(context).size.height * 0.02,
              right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: message == 'loading'
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          _image != null
                              ? ClipRRect(
                                  child: Image.file(
                                    _image,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.32,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: new CircularProgressIndicator(),
                                ),
                          Center(child: new CircularProgressIndicator()),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.transparent, width: 1),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.55,
                            height: MediaQuery.of(context).size.width * 0.4,
                            imageUrl: message,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01),
                    child: Linkable(
                      textColor: Colors.white.withOpacity(0.5),
                      text: readTimestamp(time).toString(),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.025,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  Widget _listItemMine(
    BuildContext context,
    String name,
    String message,
    String time,
    bool isRead,
    String type,
    String title,
    int timestamp,
    String replied,
    String image,
    String delete,
    String caption,
    String video,
    int index,
    String themecolor,
  ) {
    if (type == 'text') {
      return GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(2.0)), //this right here
                  child: Container(
                    color: Color(0XFF252331),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: "$message"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.trashAlt,
                                color: Colors.white),
                            onPressed: () {
                              CollectionReference users1 = FirebaseFirestore
                                  .instance
                                  .collection('groupchatroom');
                              users1
                                  .doc(delete.toString())
                                  .delete()
                                  .then((value) => print("User Deleted"))
                                  .catchError((error) =>
                                      print("Failed to delete user: $error"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.questionCircle,
                                color: Colors.white),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SeenBy(
                                      delete: delete,
                                    );
                                  },
                                ),
                              );
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.2,
              right: 15,
              top: MediaQuery.of(context).size.width * 0.02),
          alignment: Alignment.bottomRight,
          // width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.02,
                          horizontal: themecolor != null ? 10 : 5),
                      decoration: themecolor != null
                          ? BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.1),
                              color: HexColor('#$themecolor'),
                              borderRadius: BorderRadius.circular(100))
                          : BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5)),
                      child: Linkable(
                        textColor: Colors.white.withOpacity(0.9),
                        text: message,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Linkable(
                          textColor: Colors.white.withOpacity(0.5),
                          text: readTimestamp(timestamp).toString(),
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.025,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.008),
                          child: isRead
                              ? Icon(
                                  FontAwesomeIcons.checkDouble,
                                  size:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  FontAwesomeIcons.check,
                                  size:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.grey,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == 'reply') {
      return GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(2.0)), //this right here
                  child: Container(
                    color: Color(0XFF252331),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: "$message"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.trashAlt,
                                color: Colors.white),
                            onPressed: () {
                              CollectionReference users1 = FirebaseFirestore
                                  .instance
                                  .collection('groupchatroom');
                              users1
                                  .doc(delete.toString())
                                  .delete()
                                  .then((value) => print("User Deleted"))
                                  .catchError((error) =>
                                      print("Failed to delete user: $error"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.questionCircle,
                                color: Colors.white),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SeenBy(
                                      delete: delete,
                                    );
                                  },
                                ),
                              );
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          margin: EdgeInsets.only(
              right: 15,
              left: MediaQuery.of(context).size.width * 0.2,
              top: MediaQuery.of(context).size.width * 0.02),
          alignment: Alignment.bottomRight,
          width: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        ('you Replied'),
                        overflow: TextOverflow.visible,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2), width: 0.3),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white.withOpacity(0.065),
                      ),
                      child: Linkable(
                        textColor: Colors.white.withOpacity(0.8),
                        text: replied,
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.033),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      decoration: themecolor != null
                          ? BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.1),
                              color: HexColor('#$themecolor'),
                              borderRadius: BorderRadius.circular(100))
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.red,
                            ),
                      child: Wrap(
                        children: [
                          Linkable(
                            textColor: Colors.white.withOpacity(0.8),
                            text: message,
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      0.035),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Linkable(
                          textColor: Colors.white.withOpacity(0.5),
                          text: readTimestamp(timestamp).toString(),
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.025,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.width * 0.008),
                          child: isRead
                              ? Icon(
                                  FontAwesomeIcons.checkDouble,
                                  size:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  FontAwesomeIcons.check,
                                  size:
                                      MediaQuery.of(context).size.width * 0.03,
                                  color: Colors.grey,
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (type == 'camera') {
      return GestureDetector(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(2.0)), //this right here
                  child: Container(
                    color: Color(0XFF252331),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: "$message"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.trashAlt,
                                color: Colors.white),
                            onPressed: () {
                              CollectionReference users1 = FirebaseFirestore
                                  .instance
                                  .collection('groupchatroom');
                              users1
                                  .doc(delete.toString())
                                  .delete()
                                  .then((value) => print("User Deleted"))
                                  .catchError((error) =>
                                      print("Failed to delete user: $error"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.questionCircle,
                                color: Colors.white),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SeenBy(
                                      delete: delete,
                                    );
                                  },
                                ),
                              );
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.69,
              top: MediaQuery.of(context).size.height * 0.02,
              right: 15),
          width: MediaQuery.of(context).size.width * 0.05,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                  child: message == 'loading'
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(child: new CircularProgressIndicator()),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Color(0XFF252331),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.play,
                                color: Colors.white,
                                size: MediaQuery.of(context).size.width * 0.037,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 3),
                                child: Text(
                                  'Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Robotoregular',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01),
                    child: Linkable(
                      textColor: Colors.white.withOpacity(0.5),
                      text: readTimestamp(timestamp).toString(),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.025,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  isRead
                      ? Container(
                          // margin: EdgeInsets.only(right: 15),
                          child: Icon(
                            FontAwesomeIcons.checkDouble,
                            size: 15,
                            color: Colors.blue,
                          ),
                        )
                      : Container(
                          // margin: EdgeInsets.only(right: 15),
                          child: Icon(
                            FontAwesomeIcons.check,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          print(delete);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullPhoto(
                        timeStamp: delete.toString(),
                      )));
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(2.0)), //this right here
                  child: Container(
                    color: Color(0XFF252331),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(
                              FontAwesomeIcons.copy,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: "$message"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.trashAlt,
                                color: Colors.white),
                            onPressed: () {
                              CollectionReference users1 = FirebaseFirestore
                                  .instance
                                  .collection('groupchatroom');
                              users1
                                  .doc(delete.toString())
                                  .delete()
                                  .then((value) => print("User Deleted"))
                                  .catchError((error) =>
                                      print("Failed to delete user: $error"));
                              Navigator.pop(context);
                            }),
                        IconButton(
                            icon: Icon(FontAwesomeIcons.questionCircle,
                                color: Colors.white),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SeenBy(
                                      delete: delete,
                                    );
                                  },
                                ),
                              );
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ),
                );
              });
        },
        child: Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.2,
              top: MediaQuery.of(context).size.height * 0.02,
              right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: message == 'loading'
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          _image != null
                              ? ClipRRect(
                                  child: Image.file(
                                    _image,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.32,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: new CircularProgressIndicator(),
                                ),
                          Center(child: new CircularProgressIndicator()),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.transparent, width: 1),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          clipBehavior: Clip.hardEdge,
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.55,
                            height: MediaQuery.of(context).size.width * 0.4,
                            imageUrl: message,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.01),
                    child: Linkable(
                      textColor: Colors.white.withOpacity(0.5),
                      text: readTimestamp(timestamp).toString(),
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.025,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  isRead
                      ? Container(
                          // margin: EdgeInsets.only(right: 15),
                          child: Icon(
                            FontAwesomeIcons.checkDouble,
                            size: 15,
                            color: Colors.blue,
                          ),
                        )
                      : Container(
                          // margin: EdgeInsets.only(right: 15),
                          child: Icon(
                            FontAwesomeIcons.check,
                            size: 15,
                            color: Colors.grey,
                          ),
                        ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }

  Widget _buildTextComposer() {
    return Form(
      key: _formKey,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("user")
              .where('uid', isEqualTo: useruid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return new Container();
            } else if (snapshot.data.docs.isEmpty) {
              return new Container();
            }

            return snapshot.data.docs[0]['status'] == 'temp' ||
                    snapshot.data.docs[0]['status'] == 'prime'
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      // width: MediaQuery.of(context).size.width* 0.95,
                      height: MediaQuery.of(context).size.height * 0.075,
                      padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.height * 0.023,
                        right: MediaQuery.of(context).size.height * 0.02,
                      ),
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * replyheight,
                        bottom: MediaQuery.of(context).size.height * 0.015,
                        left: MediaQuery.of(context).size.width * 0.02,
                        right: MediaQuery.of(context).size.width * 0.02,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0XFF252331),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 0),
                            child: GestureDetector(
                              child: Text(
                                'Gif',
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                GiphyGif gif = await GiphyGet.getGif(
                                    context: context, //Required
                                    apiKey:
                                        "ZD1hA474mv3VLV0VPoY7IudkwvdDHPmC", //Required.
                                    lang: GiphyLanguage
                                        .english, //Optional - Language for query.
                                    searchText:
                                        "Search GIF", //Optional - AppBar search hint text.
                                    tabColor: Colors
                                        .red, // Optional- default accent color.
                                    modal: false);
                                if (gif != null) {
                                  int timedelete =
                                      DateTime.now().millisecondsSinceEpoch;
                                  DocumentReference story = FirebaseFirestore
                                      .instance
                                      .collection('groupchatroom')
                                      .doc(timedelete.toString());

                                  story.set({
                                    'type': 'gallery',
                                    'delete': timedelete.toString(),
                                    'name': snapshot.data.docs[0]['name'],
                                    'image': snapshot.data.docs[0]['image'],
                                    'token': snapshot.data.docs[0]['token'],
                                    'idFrom': useruid,
                                    'timestamp': timedelete,
                                    'isread': false,
                                    'day': DateTime.now().day,
                                    'message':
                                        'https://media.giphy.com/media/${gif.id}/giphy.gif',
                                    'uid': useruid,
                                    'username': snapshot.data.docs[0]
                                        ['username'],
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          new Flexible(
                            child: new TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              focusNode: myFocusNode,
                              controller: _msgTextController,
                              validator: MultiValidator([
                                RequiredValidator(errorText: ''),
                              ]), // onSubmitted: _handleSubmitted,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              decoration: new InputDecoration.collapsed(
                                  hintText: "Message...",
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.6),
                                  )),
                              onChanged: (value) {
                                if (value.length == 0) {
                                  DocumentReference userstotal =
                                      FirebaseFirestore.instance
                                          .collection('group')
                                          .doc('group');
                                  userstotal.update({
                                    'typing': false,
                                  }).then((value) {});
                                } else if (value.length == 1) {
                                  DocumentReference userstotal =
                                      FirebaseFirestore.instance
                                          .collection('group')
                                          .doc('group');
                                  userstotal.update({
                                    'typingId': useruid,
                                    'typing': snapshot.data.docs[0]['name'],
                                  }).then((value) {});
                                }
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 4),
                            child: IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.image,
                                  color: Colors.white,
                                ),
                                onPressed: () {
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                          child: selectedModel == null ||
                                                  selectedModel.files.length < 1
                                              ? Container()
                                              : Stack(
                                                  children: [
                                                    Row(
                                                      children: <Widget>[
                                                        SizedBox(width: 10),
                                                        DropdownButtonHideUnderline(
                                                            child:
                                                                DropdownButton<
                                                                    FileModel>(
                                                          items: getItems(),
                                                          onChanged:
                                                              (FileModel d) {
                                                            assert(
                                                                d.files.length >
                                                                    0);
                                                            image = d.files[0];
                                                            setState(() {
                                                              selectedModel = d;
                                                            });
                                                          },
                                                          value: selectedModel,
                                                        ))
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                        top: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.06,
                                                      ),
                                                      child: GridView.builder(
                                                          gridDelegate:
                                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                                  crossAxisCount:
                                                                      4,
                                                                  crossAxisSpacing:
                                                                      4,
                                                                  mainAxisSpacing:
                                                                      4),
                                                          itemBuilder: (_, i) {
                                                            var file =
                                                                selectedModel
                                                                    .files[i];
                                                            return GestureDetector(
                                                              child: Image.file(
                                                                File(file),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              onTap: () async {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => GalleryImage(
                                                                          path: File(
                                                                              file),
                                                                          type:
                                                                              'gallery'),
                                                                    ));
                                                              },
                                                            );
                                                          },
                                                          itemCount:
                                                              selectedModel
                                                                  .files
                                                                  .length),
                                                    ),
                                                  ],
                                                ),
                                        );
                                      });
                                    },
                                  );
                                }),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 4),
                            child: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.camera,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => CameraScreen(
                                              image: snapshot.data.docs[0]
                                                  ['image'],
                                              name: snapshot.data.docs[0]
                                                  ['name'],
                                              token: snapshot.data.docs[0]
                                                  ['token'],
                                            )));
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 0.0, vertical: 4),
                            child: GestureDetector(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/send.png',
                                ),
                                width:
                                    MediaQuery.of(context).size.width * 0.073,
                              ),
                              onTap: () {
                                snapshot.data.docs.forEach((element) {
                                  _handleSubmitted(
                                    _msgTextController.text,
                                    element.data()['image'],
                                    element.data()['token'],
                                    element.data()['name'],
                                    reply == true ? "reply" : 'text',
                                    element.data()['themecolor'],
                                    element.data()['coins'],
                                  );
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        // alignment: Alignment.bottomCenter,
                        // width: MediaQuery.of(context).size.width* 0.95,
                        height: MediaQuery.of(context).size.height * 0.086,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.015,
                          left: MediaQuery.of(context).size.height * 0.023,
                          right: MediaQuery.of(context).size.height * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0XFF252331),
                        ),
                        child: snapshot.data.docs[0]['status'] == 'expire'
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return GroupInfo();
                                      },
                                    ),
                                  );
                                },
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text:
                                        'Your Membership has been added due to more than 1000 Users',
                                    style: TextStyle(
                                      color: Colors.red.withOpacity(1),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Robotoregular',
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' Get Prime membership',
                                        style: TextStyle(
                                          color: Colors.blue.withOpacity(1),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Robotoregular',
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : snapshot.data.docs[0]['status'] == 'kick'
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return GroupInfo();
                                          },
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text:
                                            'You have been removed from the group',
                                        style: TextStyle(
                                          color: Colors.red.withOpacity(1),
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Robotoregular',
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: ' Get Prime membership',
                                            style: TextStyle(
                                              color: Colors.blue.withOpacity(1),
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Robotoregular',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Container()),
                  );
          }),
    );
  }

  Future<void> _handleSubmitted(
    String message,
    String image,
    String token,
    String name,
    String type,
    String themecolor,
    double coins,
  ) async {
    if (message.trim() == "") {
      return;
    }

    try {
      _msgTextController.clear();
      setState(() {
        reply = false;
        replyheight = 0;
      });
      await sendGroupMessage(
        name,
        image,
        useruid,
        message,
        type,
        replymessage,
        token,
        themecolor,
      );
      DocumentReference user =
          FirebaseFirestore.instance.collection('user').doc(useruid);
      user.update({'coins': coins + 0.01}).then((value) {});
      // DocumentSnapshot vari = await FirebaseFirestore.instance
      //     .collection('group')
      //     .doc('group')
      //     .get();
      // for (int i = 0; i < vari.data()['token'].length; i++) {
      //   await sendNotificationMessageToPeerUser(
      //     1,
      //     'text',
      //     message,
      //     '1000',
      //     'group',
      //     vari.data()['token'][i],
      //   );
      // }
      if (replytoken != null) {
        await sendNotificationMessageToPeerUser(
          1,
          'text',
          'Replied to your text',
          '1000',
          'group',
          replytoken,
        );
      }
    } catch (e) {
      _showDialog('Not Active Internet');
      // _resetTextFieldAndLoading();

    }
  }

  Future<void> _handleSubmittedGif(
    String message,
    String type,
  ) async {
    try {
      setState(() {
        reply = false;
        replyheight = 0;
      });

      int timedelete = DateTime.now().millisecondsSinceEpoch;
      await FirebaseFirestore.instance
          .collection('groupchatroom')
          .doc('group')
          .collection('group')
          .doc(timedelete.toString())
          .set({
        'chatId': 'group',
        'idFrom': useruid,
        'timestamp': timedelete,
        'content': message,
        'type': 'gif',
        'isread': false,
      });

      DocumentReference users =
          FirebaseFirestore.instance.collection('group').doc('group');
      users.update({
        "${useruid}timeStampseen": DateTime.now().millisecondsSinceEpoch,
        'sorting': DateTime.now().millisecondsSinceEpoch,
        'lastChat': 'Shared an Gif',
        "${useruid}seen": message,
      }).then((value) {});
      DocumentSnapshot vari = await FirebaseFirestore.instance
          .collection('group')
          .doc('group')
          .get();
      for (int i = 0; i < vari.data()['token'].length; i++) {
        await sendNotificationMessageToPeerUser(
          1,
          'text',
          'Shared a Gif',
          '1000',
          'group',
          vari.data()['token'][i],
        );
      }
    } catch (e) {
      _showDialog('Not Active Internet');
      // _resetTextFieldAndLoading();

    }
  }

  _showDialog(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(msg),
          );
        });
  }

  List<DropdownMenuItem> getItems() {
    return files
            .map((e) => DropdownMenuItem(
                  child: Text(
                    e.folder,
                    style: TextStyle(color: Colors.black),
                  ),
                  value: e,
                ))
            .toList() ??
        [];
  }
}

class ImageFormat {}
