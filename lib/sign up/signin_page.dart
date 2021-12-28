import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:thousand/chatbox/chatpage.dart';
import 'package:thousand/screens/loading.dart';
import '../constants.dart';
import '../screens/screen.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../widgets/widget.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isPasswordVisible = true;
  bool loading = false;
  String _error;

  bool passwordVisibility = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
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
              //to make page scrollable
              child: CustomScrollView(
                reverse: true,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          showAlert(),
                          Form(
                            key: formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome back.",
                                  style: kHeadline,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "You've been missed!",
                                  style: kBodyText2,
                                ),
                                SizedBox(
                                  height: 60,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: 'Email Can\'t be Empty '),
                                      EmailValidator(
                                          errorText: 'Enter a Valid Email'),
                                    ]),
                                    controller: emailController,
                                    style:
                                        kBodyText.copyWith(color: Colors.white),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: TextFormField(
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText:
                                              'Password Can\'t be Empty '),
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
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Dont't have an account? ",
                                style: kBodyText,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Register',
                                  style: kBodyText.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          MyTextButton(
                            buttonName: 'Sign In',
                            onTap: () {
                              logIn();
                            },
                            bgColor: Colors.white,
                            textColor: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<String> logIn() async {
    if (formkey.currentState.validate()) {
      setState(() {
        loading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .whenComplete(() async {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User user = auth.currentUser;
          String current_uid = user.uid;
          DocumentReference users =
              FirebaseFirestore.instance.collection('user').doc(current_uid);
          DocumentReference group =
              FirebaseFirestore.instance.collection('group').doc('group');
          DocumentSnapshot vari = await FirebaseFirestore.instance
              .collection('group')
              .doc('group')
              .get();
          List<dynamic> tokenList = vari.data()['token'];
          FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

          firebaseMessaging.getToken().then((value) async {
            tokenList.add(value);
            users.update({
              'token': value,
            });
            group.update({
              'token': tokenList,
            });
          });
        });
        setState(() {
          loading = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => GroupChat()));
      } on FirebaseAuthException catch (err) {
        setState(() {
          loading = false;
        });
        setState(() {
          loading = false;
          _error = err.message;
        });
      }
    } else {
      print('Not Validated');
      loading = false;
    }
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
