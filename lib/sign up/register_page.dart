import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thousand/chatbox/chatpage.dart';
import 'package:thousand/sign%20up/signin_page.dart';
import '../widgets/widget.dart';
import '../constants.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thousand/screens/loading.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool loading = false;
  String _error;
  bool _termsChecked = false;
  File _image;
  final ImagePicker _picker = ImagePicker();
  bool _isloadig = false;
  var downurl;

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

  bool passwordVisibility = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController promo = TextEditingController();
  final TextEditingController username = TextEditingController();

  bool user = true;
  bool again = false;
  bool promocode = false;
  bool valid = true;

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var widthh = screenSize.width;
    var heightt = screenSize.height;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
              backgroundColor: kBackgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image(
                  width: 24,
                  color: Colors.white,
                  image: Svg('assets/images/back_arrow.svg'),
                ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                // hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Form(
                    key: formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        showAlert(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Register",
                              style: kHeadline,
                            ),

                            // Center(
                            //   child: Container(
                            //     width: widthh * 0.7,
                            //     child: Image(
                            //       image: AssetImage('assets/images/people.png'),
                            //     ),
                            //   ),
                            // ),
                            Center(
                              child: Container(
                                child: _image == null
                                    ? Column(
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () =>
                                                getImage(ImageSource.gallery),
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                  heightt * 0.05),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white),
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: Colors.transparent,
                                              ),
                                              child: Icon(
                                                FontAwesomeIcons.cameraRetro,
                                                color: Colors.white,
                                                size: widthh * 0.1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          again == true
                                              ? Text(
                                                  ' Please Select an image to Register',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: Colors.red,
                                                        fontSize:
                                                            widthh * 0.04),
                                                  ),
                                                )
                                              : Text(
                                                  ' Choose Picture',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            widthh * 0.04),
                                                  ),
                                                ),
                                        ],
                                      )
                                    : Container(
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
                                            child: Image.file(
                                              _image,
                                              height: heightt * 0.2,
                                              width: widthh * 0.33,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextFormField(
                                inputFormatters: [
                                  BlacklistingTextInputFormatter(
                                      new RegExp(r"\s\b|\b\s"))
                                ],

                                onChanged: (values) {
                                  FirebaseFirestore.instance
                                      .collection('user')
                                      .where("username",
                                          isEqualTo:
                                              values.toString().toLowerCase())
                                      .limit(1)
                                      .get()
                                      .then(
                                    (value) {
                                      if (value.docs.length > 0) {
                                        print('yes');
                                        user = true;
                                      } else {
                                        print('not');

                                        user = false;
                                      }
                                    },
                                  );
                                },
                                validator: (values) {
                                  setState(() {});
                                  if (values.length < 4 || user == true) {
                                    return 'Username is taken';
                                  }
                                },
                                controller: username,
                                style: kBodyText.copyWith(color: Colors.white),
                                // keyboardType: TextInputType.text,
                                // textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  hintText: 'Username',
                                  hintStyle: kBodyText,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextFormField(
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Email Can\'t be Empty '),
                                  EmailValidator(
                                      errorText: 'Enter a Valid Email'),
                                ]),
                                controller: emailController,
                                style: kBodyText.copyWith(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(20),
                                  hintText: 'Email',
                                  hintStyle: kBodyText,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: TextFormField(
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Password Can\'t be Empty '),
                                  MinLengthValidator(6,
                                      errorText:
                                          "Password should be between 6 to 15 Character"),
                                  MaxLengthValidator(15,
                                      errorText:
                                          "Password Should be between 6 to 15 Character")
                                ]),
                                controller: passwordController,
                                style: kBodyText.copyWith(
                                  color: Colors.white,
                                ),
                                obscureText: passwordVisibility,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        setState(() {
                                          passwordVisibility =
                                              !passwordVisibility;
                                        });
                                      },
                                      icon: Icon(
                                        passwordVisibility
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(20),
                                  hintText: 'Password',
                                  hintStyle: kBodyText,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                          width: widthh,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: CheckboxListTile(
                              activeColor:
                                  _termsChecked ? Colors.blue : Colors.white,
                              title: Wrap(
                                children: [
                                  Text(
                                    'By checking this you agtree to',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: widthh * 0.035,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => launch(
                                        'https://www.blogger.com/u/0/blog/post/edit/preview/4218528620688014868/8872877180365550168'),
                                    child: Text(
                                      '1000\'s Terms & Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: widthh * 0.035,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: !_termsChecked
                                  ? Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                                      child: Text(
                                        'Required field',
                                        style: TextStyle(
                                            color: Color(0xFFe53935),
                                            fontSize: 12),
                                      ),
                                    )
                                  : null,
                              value: timeDilation != 1.0,
                              onChanged: (bool value) {
                                setState(() {
                                  _termsChecked = value;
                                  timeDilation = value ? 2.0 : 1.0;
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
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
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            child: TextFormField(
                                              inputFormatters: [
                                                BlacklistingTextInputFormatter(
                                                    new RegExp(r"\s\b|\b\s"))
                                              ],
                                              onChanged: (values) {
                                                FirebaseFirestore.instance
                                                    .collection('user')
                                                    .where('uid',
                                                        isEqualTo:
                                                            values.toString())
                                                    .limit(1)
                                                    .get()
                                                    .then(
                                                  (value) {
                                                    if (value.docs.length > 0) {
                                                      setState(() {
                                                        promocode = true;
                                                      });
                                                      print('yes');
                                                      user = true;
                                                    } else {
                                                      print('not');

                                                      user = false;
                                                    }
                                                  },
                                                );
                                              },
                                              validator: (values) {
                                                setState(() {});
                                                if (promocode == false) {
                                                  return 'Invalid Promo Code';
                                                }
                                              },
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              controller: promo,
                                              style: kBodyText.copyWith(
                                                  color: Colors.white),
                                              keyboardType: TextInputType.text,
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.all(20),
                                                hintText: 'Promo Code',
                                                hintStyle: kBodyText,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                ),
                                              ),
                                            ),
                                          ),
                                          valid == false
                                              ? Container(
                                                  margin:
                                                      EdgeInsets.only(left: 25),
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    'Invalid Promo Code',
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.045),
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (promocode == true) {
                                                Navigator.pop(context);
                                              } else {
                                                setState(() {
                                                  valid = false;
                                                });
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
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Submit Code',
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
                          },
                          child: promocode == true
                              ? Wrap(
                                  children: [
                                    Text(
                                      "Promo Code has been added ",
                                      style: kBodyText.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignInPage()));
                                      },
                                      child: Image.asset(
                                        'assets/images/dollar.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.blue),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "Promo Code ",
                                        style: kBodyText.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SignInPage()));
                                        },
                                        child: Image.asset(
                                          'assets/images/dollar.png',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Wrap(
                          children: [
                            Text(
                              "Already have an account? ",
                              style: kBodyText,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignInPage()));
                              },
                              child: Text(
                                "Sign In",
                                style: kBodyText.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("user")
                              .orderBy('timeStamp', descending: true)
                              .where('status', isEqualTo: 'temp')
                              .limit(1)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.connectionState ==
                                    ConnectionState.waiting) {
                              return new MyTextButton(
                                buttonName: 'Register',
                                onTap: () {},
                                bgColor: Colors.white,
                                textColor: Colors.black87,
                              );
                            } else if (snapshot.data.docs.isEmpty) {
                              return new MyTextButton(
                                buttonName: 'Register',
                                onTap: () {},
                                bgColor: Colors.white,
                                textColor: Colors.black87,
                              );
                            }
                            return MyTextButton(
                              buttonName: 'Register',
                              onTap: () async {
                                DocumentSnapshot vari = await FirebaseFirestore
                                    .instance
                                    .collection('group')
                                    .doc('group')
                                    .get();
                                FirebaseAuth _auth = FirebaseAuth.instance;
                                if (_image == null) {
                                  setState(() {
                                    again = true;
                                  });
                                  return;
                                }
                                if (formkey.currentState.validate() &&
                                    _termsChecked == true &&
                                    _image != null) {
                                  setState(() {
                                    loading = true;
                                  });

                                  try {
                                    final User user = (await _auth
                                            .createUserWithEmailAndPassword(
                                      email: emailController.text
                                          .toString()
                                          .trim(),
                                      password: passwordController.text,
                                    ))
                                        .user;
                                    if (user != null) {
                                      final User user = _auth.currentUser;
                                      String current_uid = user.uid;

                                      String time = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      List<String> spilList =
                                          name.text.split('');
                                      List<String> indexList = [];

                                      for (int i = 0;
                                          i < spilList.length;
                                          i++) {
                                        for (int j = 0;
                                            j < spilList[i].length;
                                            j++) {
                                          indexList.add(spilList[i]
                                              .substring(0, j + 1)
                                              .toLowerCase());
                                        }
                                      }
                                      FirebaseMessaging firebaseMessaging =
                                          new FirebaseMessaging();

                                      firebaseMessaging
                                          .getToken()
                                          .then((valueToken) async {
                                        String filePath = 'user/$current_uid';
                                        final Reference storageReference =
                                            FirebaseStorage.instance
                                                .ref()
                                                .child(filePath);
                                        final UploadTask uploadTask =
                                            storageReference.putFile(_image);
                                        uploadTask.then((res) async {
                                          DocumentReference userstotal =
                                              FirebaseFirestore.instance
                                                  .collection('user')
                                                  .doc(current_uid);
                                          userstotal.set({
                                            'searchIndex': indexList,
                                            'uid': current_uid,
                                            'name': username.text,
                                            'username':
                                                username.text.toString(),
                                            'image': await storageReference
                                                .getDownloadURL(),
                                            'timeStamp': DateTime.now()
                                                .millisecondsSinceEpoch,
                                            'token': valueToken,
                                            'count': vari.data()['members'] + 1,
                                            'coins': promocode ? 20.02 : 10.01,
                                            'status': 'temp',
                                            'report': 0,
                                          }).then((value) {});
                                          List<dynamic> tokenList =
                                              vari.data()['token'];
                                          tokenList.add(valueToken);
                                          await FirebaseFirestore.instance
                                              .collection('group')
                                              .doc('group')
                                              .update({
                                            'members':
                                                vari.data()['members'] + 1,
                                            'sorting': DateTime.now()
                                                .millisecondsSinceEpoch,
                                            'token': tokenList,
                                          });
                                        }).whenComplete(() async {
                                          snapshot.data.docs
                                              .forEach((element) async {
                                            if (vari.data()['members'] >= 1000)
                                              await FirebaseFirestore.instance
                                                  .collection('user')
                                                  .doc(element.data()['uid'])
                                                  .update({
                                                'status': 'expire',
                                              });
                                          });
                                          int timedelete = DateTime.now()
                                              .millisecondsSinceEpoch;
                                          FirebaseFirestore.instance
                                              .collection('groupchatroom')
                                              .doc(timedelete.toString())
                                              .set({
                                            'uid': current_uid,
                                            'name': name.text,
                                            'image': await storageReference
                                                .getDownloadURL(),
                                            'timestamp': timedelete,
                                            'content':
                                                '${username.text} has Joined the Chat',
                                            'idFrom': 'action',
                                            'isread': true,
                                          });
                                          if (promocode) {
                                            DocumentSnapshot vari =
                                                await FirebaseFirestore.instance
                                                    .collection('user')
                                                    .doc(promo.text)
                                                    .get();
                                            await FirebaseFirestore.instance
                                                .collection('user')
                                                .doc(promo.text)
                                                .update({
                                              'coins':
                                                  vari.data()['coins'] + 10,
                                            });
                                          }
                                          Future.delayed(Duration(seconds: 5),
                                              () {
                                            Navigator.pushReplacement(
                                              this.context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                return GroupChat();
                                              }),
                                            );
                                          });
                                        });
                                      });
                                    }
                                  } catch (e) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Text(e),
                                          );
                                        });
                                  }
                                }
                              },
                              bgColor: Colors.white,
                              textColor: Colors.black87,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget showAlert() {
    if (_error != null) {
      return Container(
        color: Colors.amberAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(
                _error,
                maxLines: 3,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox(
      height: 0,
    );
  }
}
