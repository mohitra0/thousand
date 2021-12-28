import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:thousand/component/utils.dart';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:random_color/random_color.dart';
import 'package:text_editor/text_editor.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thousand/screens/loading_circle.dart';

import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class GalleryImage extends StatefulWidget {
  const GalleryImage({Key key, this.type, this.path, this.xpath})
      : super(key: key);
  final File path;
  final XFile xpath;
  final String type;
  @override
  _GalleryImageState createState() => _GalleryImageState();
}

class _GalleryImageState extends State<GalleryImage> {
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
    // croppedFile = File(widget.path.path);

    super.initState();
  }

  final fonts = [
    'roboto',
    'acme',
    'anton',
    'bebas',
    'caveat',
    'dance',
    'FjallaOne',
    'IndieFlower',
    'Lobster',
    'MonteCarlo',
    'NotoSansJP',
    'OpenSans',
    'Oswald',
    'Pacifico',
    'PaletteMosaic',
    'Raleway',
    'Robotomedium',
    'Robotoregular',
    'Staatliches',
    'Teko',
  ];
  TextStyle _textStyle = TextStyle(
    fontSize: 50,
    color: Colors.white,
    fontFamily: 'roboto',
  );
  String _text = '';
  TextAlign _textAlign = TextAlign.center;

  void _tapHandler(text, textStyle, textAlign) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(
        milliseconds: 400,
      ), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: Container(
                child: TextEditor(
                  fonts: fonts,
                  text: text,
                  textStyle: textStyle,
                  textAlingment: textAlign,
                  paletteColors: [
                    Colors.black,
                    Colors.white,
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                    Colors.pink,
                    Colors.cyanAccent,
                  ],
                  decoration: EditorDecoration(
                    doneButton: Icon(Icons.close, color: Colors.white),
                    fontFamily: Icon(Icons.title, color: Colors.white),
                    colorPalette: Icon(Icons.palette, color: Colors.white),
                    alignment: AlignmentDecoration(
                      left: Text(
                        'left',
                        style: TextStyle(color: Colors.white),
                      ),
                      center: Text(
                        'center',
                        style: TextStyle(color: Colors.white),
                      ),
                      right: Text(
                        'right',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  onEditCompleted: (style, align, text) {
                    setState(() {
                      _text = text;
                      _textStyle = style;
                      _textAlign = align;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset offset = Offset.zero;
  Offset offset1 = Offset.zero;

  var yOffset = 0.0;
  var xOffset = 0.0;
  double _scale = 1.0;
  double _previousScale = 1.0;
  String gifs;
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
                color: Colors.white,
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
          IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
                color: Colors.white,
              ),
              onPressed: () async {
                GiphyGif gif = await GiphyGet.getGif(
                    context: context, //Required
                    apiKey: "ZD1hA474mv3VLV0VPoY7IudkwvdDHPmC", //Required.
                    lang:
                        GiphyLanguage.english, //Optional - Language for query.
                    searchText:
                        "Search GIF", //Optional - AppBar search hint text.
                    tabColor: Colors.red, // Optional- default accent color.
                    modal: false);
                if (gif != null) {
                  setState(() {
                    gifs = gif.id;
                  });
                }
              }),
          IconButton(
            icon: Icon(
              Icons.title,
              size: 27,
              color: Colors.white,
            ),
            onPressed: () => _tapHandler(_text, _textStyle, _textAlign),
          ),
          IconButton(
              icon: Icon(
                Icons.edit,
                size: 27,
                color: Colors.white,
              ),
              onPressed: () {}),
        ],
      ),
      body: loading
          ? LoadingCircle()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    left: offset1.dx,
                    top: offset1.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        print(offset1);
                        setState(() {
                          offset1 = Offset(offset1.dx + details.delta.dx,
                              offset1.dy + details.delta.dy);
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 150,
                        child: Image.file(
                          croppedFile != null
                              ? croppedFile
                              : widget.path == null
                                  ? widget.xpath
                                  : widget.path,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  gifs != null
                      ? Container(
                          child: Positioned.fromRect(
                            rect: Rect.fromPoints(
                                Offset(xOffset - 125.0, yOffset - 100.0),
                                Offset(xOffset + 250.0, yOffset + 100.0)),
                            child: Container(
                              child: GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    gifs = null;
                                  });
                                },
                                onScaleStart: (ScaleStartDetails details) {
                                  print(details);

                                  setState(() {
                                    _previousScale = _scale;
                                  });
                                },
                                onScaleUpdate: (ScaleUpdateDetails details) {
                                  print(details);
                                  setState(() {
                                    var offset = details.focalPoint;
                                    xOffset = offset.dx;
                                    yOffset = offset.dy;
                                  });
                                  setState(() {
                                    _scale = _previousScale * details.scale;
                                  });
                                },
                                onScaleEnd: (ScaleEndDetails details) {
                                  print(details);

                                  _previousScale = 1.0;
                                  setState(() {});
                                },
                                child: RotatedBox(
                                  quarterTurns: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Transform(
                                      alignment: FractionalOffset.center,
                                      transform: Matrix4.diagonal3(
                                          Vector3(_scale, _scale, _scale)),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            'https://media.giphy.com/media/$gifs/giphy.gif',
                                        placeholder: (context, url) =>
                                            LoadingCircle(),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    child: Positioned(
                      left: offset.dx,
                      top: offset.dy,
                      child: GestureDetector(
                          onPanUpdate: (details) {
                            print(offset);
                            setState(() {
                              offset = Offset(offset.dx + details.delta.dx,
                                  offset.dy + details.delta.dy);
                            });
                          },
                          child: SizedBox(
                            width: 300,
                            height: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => _tapHandler(
                                      _text, _textStyle, _textAlign),
                                  child: Text(
                                    _text,
                                    style: _textStyle,
                                    textAlign: _textAlign,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ),
                  loading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          color: Colors.transparent,
                        )
                      : Positioned(
                          bottom: 0,
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('user')
                                  .where('uid', isEqualTo: useruid)
                                  .limit(1)
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                } else if (snapshot.data.docs.isEmpty) {
                                  return Container();
                                }
                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            int timedelete = DateTime.now()
                                                .millisecondsSinceEpoch;
                                            MyColor _myColor =
                                                getColorNameFromColor(
                                                    _textStyle.color);
                                            snapshot.data.docs
                                                .forEach((doc) async {
                                              String filePath =
                                                  'story/${doc.data()['uid']}/${DateTime.now().millisecondsSinceEpoch}';
                                              final Reference storageReference =
                                                  FirebaseStorage.instance
                                                      .ref()
                                                      .child(filePath);
                                              final UploadTask uploadTask =
                                                  storageReference.putFile(
                                                croppedFile != null
                                                    ? croppedFile
                                                    : widget.path == null
                                                        ? widget.xpath
                                                        : widget.path,
                                              );
                                              await uploadTask
                                                  .then((res) async {
                                                DocumentReference story =
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'groupchatroom')
                                                        .doc(timedelete
                                                            .toString());

                                                story.set({
                                                  'delete':
                                                      timedelete.toString(),
                                                  'name': snapshot.data.docs[0]
                                                      ['name'],
                                                  'image': snapshot.data.docs[0]
                                                      ['image'],
                                                  'token': snapshot.data.docs[0]
                                                      ['token'],
                                                  'idFrom': useruid,
                                                  'timestamp': timedelete,
                                                  'type': widget.type,
                                                  'caption': caption.text,
                                                  'isread': false,
                                                  'day': DateTime.now().day,
                                                  'phototimeStamp':
                                                      timedelete.toString(),
                                                  'timeStamp': DateTime.now()
                                                      .millisecondsSinceEpoch,
                                                  'gif': gifs,
                                                  'text': _text,
                                                  'imagedx': offset1.dx,
                                                  'imagedy': offset1.dy,
                                                  'textdx': offset.dx,
                                                  'textdy': offset.dy,
                                                  'gifscale': _scale,
                                                  'fontsize':
                                                      _textStyle.fontSize,
                                                  'textcolor': _myColor.getCode,
                                                  'textalign': _textAlign.index,
                                                  'font': _textStyle.fontFamily,
                                                  'gifdy': yOffset,
                                                  'gifdx': xOffset,
                                                  'scale': _scale,
                                                  'message':
                                                      await storageReference
                                                          .getDownloadURL(),
                                                  'uid': doc.data()['uid'],
                                                  'username':
                                                      doc.data()['username'],
                                                });
                                              });
                                            });
                                            await Timer(
                                                Duration(seconds: 2), () {});
                                            Navigator.pop(context);
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 0.1),
                                                  color: Colors.white,
                                                ),
                                                child: ClipRRect(
                                                  clipBehavior: Clip.hardEdge,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100.0),
                                                  child: CachedNetworkImage(
                                                    fit: BoxFit.cover,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.08,
                                                    imageUrl: snapshot
                                                        .data.docs[0]['image'],
                                                    placeholder: (context,
                                                            url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Text(
                                                'Send',
                                                style: GoogleFonts.roboto(
                                                  textStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .textSelectionColor,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.033),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
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
        // 'name': widget.name,
        // 'image': widget.image,
        // 'token': widget.token,
        'idFrom': useruid,
        'timestamp': timedelete,
        'message': 'loading',
        'type': 'gallery',
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
