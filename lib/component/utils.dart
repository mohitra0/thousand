import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
// For Chatlist Functions

String readTimestamp(int timestamp) {
  var nows = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = nows.difference(date);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final dateToCheck = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final aDate = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    if (diff.inHours > 0 && aDate == yesterday) {
      time = 'Yesterday at ' + DateFormat.jm().format(date).toString();
    } else if (diff.inMinutes > 0) {
      time = 'Today at ' + DateFormat.jm().format(date).toString();
    } else {
      time = 'Today at ' + DateFormat.jm().format(date).toString();
    }
  } else if (diff.inDays > 0 && diff.inDays < 1) {
    time = 'Yesterday at ' + DateFormat.jm().format(date).toString();
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    time = diff.inDays.toString() + ' days ago';
  } else if (diff.inDays > 6) {
    time = (diff.inDays / 7).floor().toString() + ' weeks ago';
  } else if (diff.inDays > 29) {
    time = (diff.inDays / 30).floor().toString() + ' months ago';
  } else if (diff.inDays > 365) {
    time = '${date.month}-${date.day}-${date.year}';
  }
  return time;
}

String readTimestampDays(int timestamp) {
  var now = DateTime.now();
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    if (diff.inHours > 0) {
      time = diff.inHours.toString() + ' hour ago';
    } else if (diff.inMinutes > 0) {
      time = diff.inMinutes.toString() + ' mins ago';
    } else if (diff.inSeconds > 0) {
      time = 'now';
    } else if (diff.inMilliseconds > 0) {
      time = 'now';
    } else if (diff.inMicroseconds > 0) {
      time = 'now';
    } else {
      time = 'now';
    }
  } else if (diff.inDays == 1) {
    time = diff.inDays.toString() + '  Day ago';
  } else if (diff.inDays > 0 && diff.inDays < 10000000) {
    time = diff.inDays.toString() + '  Days';
  }
  return time;
}

String makeChatId(myID, selectedUserID) {
  String chatID;
  if (myID.hashCode > selectedUserID.hashCode) {
    chatID = '$selectedUserID-$myID';
  } else {
    chatID = '$myID-$selectedUserID';
  }
  return chatID;
}

int countChatListUsers(myID, snapshot) {
  int resultInt = snapshot.data.documents.length;
  for (var data in snapshot.data.documents) {
    if (data.data()['uid'] == myID) {
      resultInt--;
    }
  }
  return resultInt;
}

// For ChatRoom Functions

String returnTimeStamp(int messageTimeStamp) {
  String resultString = '';
  var format = DateFormat('hh:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(messageTimeStamp);
  resultString = format.format(date);
  return resultString;
}

void setCurrentChatRoomID(value) async {
  // To know where I am in chat room. Avoid local notification.
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('currentChatRoom', value);
}

// For main view Functions

String checkValidUserData(userImageFile, userImageUrlFromFB, name, intro) {
  String returnString = '';
  if (userImageFile.path == '' && userImageUrlFromFB == '') {
    returnString = returnString + 'Please select a image.';
  }

  if (name.trim() == '') {
    if (returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your name';
  }

  if (intro.trim() == '') {
    if (returnString.trim() != '') {
      returnString = returnString + '\n\n';
    }
    returnString = returnString + 'Please type your intro';
  }
  return returnString;
}

String randomIdWithName(userName) {
  int randomNumber = Random().nextInt(100000);
  return '$userName$randomNumber';
}

class PickImageController {
  static PickImageController get instance => PickImageController();

  Future<File> cropImageFromFile(String type) async {
    File imageFileFromLibrary;
    if (type == 'gallery') {
      imageFileFromLibrary = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 25,
      );
    } else {
      imageFileFromLibrary = await ImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
      );
    }
  }
}

Future<void> sendNotificationMessageToPeerUser(unReadMSGCount, messageType,
    textFromTextField, myName, chatID, peerUserToken) async {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAOccUk-I:APA91bG7W9VuBU43SijC_8610HALhIzeZYMiKl3_I5KPcym_zSrEDbI2vgTiHnVN-6EvGHg0Txq9gAUefCM95u5iLryYQOdIeMeltv0mt5JVzLQXEC4RFii7V7jjKTrAz-KZVpqosnts',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': messageType == 'text' ? '$textFromTextField' : '(Photo)',
          'title': '$myName',
          'badge': '$unReadMSGCount', //'$unReadMSGCount'
          "sound": "default",
          'color': '#6200EE'
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          // 'chatroomid': chatID,
        },
        'to': peerUserToken,
      },
    ),
  );

  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> textFromTextField) async {
      completer.complete(textFromTextField);
      // NotificationController.instance.sendLocalNotification(
      //     textFromTextField['notification']['title'],
      //     textFromTextField['notification']['body']);
      print("notification: $textFromTextField");
    },
    onBackgroundMessage: myBackgroundMessageHandler,
    // onLaunch: (Map<String, dynamic> textFromTextField) async {
    //   print("onLaunch: $textFromTextField");
    //   NotificationController.instance.sendLocalNotification(
    //       textFromTextField['notification']['title'],
    //       textFromTextField['notification']['body']);
    //   completer.complete(textFromTextField);
    // },
    // onResume: (Map<String, dynamic> textFromTextField) async {
    //   print("onResume: $textFromTextField");
    //   NotificationController.instance.sendLocalNotification(
    //       textFromTextField['notification']['title'],
    //       textFromTextField['notification']['body']);
    //   completer.complete(textFromTextField);
    // },
  );
  return completer.future;
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('notification')) {
    // Handle notification message

  }
}

Future sendGroupMessage(
    name, image, myID, message, messageType, reply, token, themecolor) async {
  int timedelete = DateTime.now().millisecondsSinceEpoch;
  await FirebaseFirestore.instance
      .collection('groupchatroom')
      .doc(timedelete.toString())
      .set({
    'name': name,
    'image': image,
    'idFrom': myID,
    'delete': timedelete.toString(),
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'message': message,
    'type': messageType,
    'isread': false,
    'reply': reply,
    'token': token,
    'themecolor': themecolor,
  });
  // DocumentReference users =
  //     FirebaseFirestore.instance.collection('group').doc(chatID);
  // users.update({
  //   "${myID}timeStampseen": timedelete,
  //   'sorting': timedelete,
  //   'lastChat': messageType == 'image' || messageType == 'camera'
  //       ? 'Shared an image'
  //       : message,
  //   "${myID}seen": message,
  // }).then((value) {});
}
