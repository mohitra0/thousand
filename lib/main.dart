import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User user = auth.currentUser;
  runApp(MyApp(user: user));
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key key,
    this.user,
  }) : super(key: key);

  final User user;

  static Future<User> signIn(BuildContext context, String displayName) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    return state.signIn(displayName);
  }

  static Future<void> postMessage(ChatMessage message) async {
    await Firestore.instance.collection('messages').doc().set(message.toJson());
  }

  static Future<void> signOut(BuildContext context) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    return state.signOut();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<User> _userSub;
  User _user;

  Future<User> signIn(String displayName) async {
    final result = await FirebaseAuth.instance.signInAnonymously();
    await FirebaseAuth.instance.currentUser.updateProfile(
      displayName: displayName,
      photoURL: 'define an url',
    );

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    setState(() => _user = user);
    return user;
  }

  Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _userSub = FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() => _user = user);
    });
  }

  @override
  void dispose() {
    _userSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<User>.value(
      value: _user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firestore Chat List',
        home: _user == null ? LoginScreen() : ChatScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return LoginScreen();
      },
    );
  }

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _displayName;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _displayName = TextEditingController();
  }

  @override
  void dispose() {
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    setState(() => _loading = true);
    try {
      final user = await MyApp.signIn(context, _displayName.text);
      if (mounted) {
        await MyApp.postMessage(
            ChatMessage.notice2(user, 'has entered the chat'));
        Navigator.of(context).pushReplacement(ChatScreen.route());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Chat List'),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: theme.textTheme.headline4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              if (_loading)
                CircularProgressIndicator()
              else ...[
                TextField(
                  controller: _displayName,
                  decoration: InputDecoration(
                    hintText: 'Display Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onSubmitPressed(),
                  textInputAction: TextInputAction.go,
                ),
                SizedBox(height: 12.0),
                RaisedButton(
                  onPressed: () => _onSubmitPressed(),
                  child: Text('ENTER CHAT'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (BuildContext context) {
        return ChatScreen();
      },
    );
  }

  MaterialColor _calculateUserColor(String uid) {
    final hash = uid.codeUnits.fold(0, (prev, el) => prev + el);
    return Colors.primaries[hash % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Chat List'),
        actions: [
          IconButton(
            onPressed: () async {
              final user = Provider.of<User>(context, listen: false);
              MyApp.postMessage(
                  ChatMessage.notice2(user, 'has left the chat.'));
              Navigator.of(context).pushReplacement(LoginScreen.route());
              await MyApp.signOut(context);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FirestoreChatList(
              listenBuilder: () {
                return FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('posted', descending: true)
                    .limit(15);
              },
              pagedBuilder: () {
                return FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('posted', descending: true)
                    .limit(15);
              },
              itemBuilder2: (BuildContext context, int index,
                  DocumentSnapshot document, Animation<double> animation) {
                return SizeTransition(
                  key: Key('message-${document.documentID}'),
                  axis: Axis.vertical,
                  axisAlignment: -1.0,
                  sizeFactor: animation,
                  child: document.data()['type'] == 0
                      ? Container(
                          child: Text('has left wala scene here'),
                        )
                      : Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: document.data()['user']
                                        ['uid'] ==
                                    Provider.of<User>(context).uid
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              FractionallySizedBox(
                                widthFactor: 0.6,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: document.data()['user']
                                                ['uid'] ==
                                            Provider.of<User>(context).uid
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                            bottomLeft: Radius.circular(24.0),
                                          )
                                        : const BorderRadius.only(
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                            bottomRight: Radius.circular(24.0),
                                          ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (document
                                              .data()['message']
                                              ?.isNotEmpty ??
                                          false) ...[
                                        const SizedBox(width: 8.0),
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black,
                                          ),
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            document.data()['message'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(document.data()['user']
                                              ['displayName']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  document.data()['posted'].toString(),
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                  //  Builder(
                  //   builder: (BuildContext context) {
                  //     switch (message.type) {
                  //       case ChatMessageType.notice:

                  //       case ChatMessageType.text:
                  //     }
                  //     throw StateError('Bad message type');
                  //   },
                  // ),
                );
              },
            ),
          ),
          SendMessagePanel(),
        ],
      ),
    );
  }
}

class ChatMessageNotice extends StatelessWidget {
  const ChatMessageNotice({
    Key key,
    @required this.message,
  }) : super(key: key);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Text(
        '${message.displayName} ${message.message}',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    Key key,
    @required this.message,
  }) : super(key: key);

  final ChatMessage message;

  MaterialColor _calculateUserColor(String uid) {
    final hash = uid.codeUnits.fold(0, (prev, el) => prev + el);
    return Colors.primaries[hash % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: _calculateUserColor(message.uid).shade200,
                borderRadius: isMine
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                        bottomLeft: Radius.circular(24.0),
                      )
                    : const BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                        bottomRight: Radius.circular(24.0),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.displayName?.isNotEmpty ?? false) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _calculateUserColor(message.uid),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        message.displayName.substring(0, 1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(message.message),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              message.infoText(context),
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SendMessagePanel extends StatefulWidget {
  @override
  _SendMessagePanelState createState() => _SendMessagePanelState();
}

class _SendMessagePanelState extends State<SendMessagePanel> {
  final _controller = TextEditingController();

  User _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = Provider.of<User>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_controller.text.isEmpty) {
      return;
    }
    MyApp.postMessage(ChatMessage.text2(_user, _controller.text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0.0, -3.0),
            blurRadius: 4.0,
            spreadRadius: 3.0,
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 160.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  isDense: true,
                ),
                onSubmitted: (_) => _onSubmitPressed(),
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _onSubmitPressed(),
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

enum ChatMessageType {
  notice,
  text,
}

class ChatMessage {
  const ChatMessage({
    this.type,
    this.posted,
    this.message = '',
    this.uid,
    this.displayName,
    this.photoUrl,
  }) : assert(type != null && posted != null);

  final ChatMessageType type;
  final DateTime posted;
  final String message;
  final String uid;
  final String displayName;
  final String photoUrl;

  String infoText(BuildContext context) {
    final timeOfDay = TimeOfDay.fromDateTime(posted);
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(posted);
    final time = localizations.formatTimeOfDay(timeOfDay);
    return '$date at $time from $displayName';
  }

  bool isMine(BuildContext context) {
    final user = Provider.of<User>(context);
    return uid == user?.uid;
  }

  factory ChatMessage.notice2(User user, String message) {
    return ChatMessage(
      type: ChatMessageType.notice,
      posted: DateTime.now().toUtc(),
      message: message,
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  factory ChatMessage.text2(User user, String message) {
    return ChatMessage(
      type: ChatMessageType.text,
      posted: DateTime.now().toUtc(),
      message: message,
      uid: user.uid,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    return ChatMessage(
      type: ChatMessageType.values[doc['type'] as int],
      posted: (doc['posted'] as Timestamp).toDate(),
      message: doc['message'] as String,
      uid: doc['user']['uid'] as String,
      displayName: doc['user']['displayName'] as String,
      photoUrl: doc['user']['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'posted': Timestamp.fromDate(posted),
      'message': message,
      'user': {
        'uid': uid,
        'displayName': displayName,
        'photoUrl': photoUrl,
      },
    };
  }
}

// ---- CHAT LIST IMPLEMENTATION ----

typedef ChatQueryBuilder();

typedef Widget FirestoreChatListItemBuilder(
  BuildContext context,
  int index,
  DocumentSnapshot document,
  Animation<double> animation,
);

typedef Widget FirestoreChatListLoaderBuilder(
  BuildContext context,
  int index,
  Animation<double> animation,
);

class FirestoreChatList extends StatefulWidget {
  const FirestoreChatList({
    Key key,
    this.controller,
    @required this.listenBuilder,
    @required this.pagedBuilder,
    @required this.itemBuilder2,
    this.loaderBuilder = defaultLoaderBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = true,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.initialAnimate = false,
    this.padding,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  final ChatQueryBuilder listenBuilder;
  final ChatQueryBuilder pagedBuilder;
  final FirestoreChatListItemBuilder itemBuilder2;
  final FirestoreChatListLoaderBuilder loaderBuilder;
  final ScrollController controller;
  final Axis scrollDirection;
  final bool reverse;
  final bool primary;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final bool initialAnimate;
  final EdgeInsetsGeometry padding;
  final Duration duration;

  static Widget defaultLoaderBuilder(
      BuildContext context, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        padding: EdgeInsets.all(32.0),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  _FirestoreChatListState createState() => _FirestoreChatListState();
}

class _FirestoreChatListState extends State<FirestoreChatList> {
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _dataListen = List<DocumentSnapshot>();
  final _dataPaged = List<DocumentSnapshot>();

  Future _pageRequest;
  StreamSubscription<QuerySnapshot> _listenSub;
  ScrollController _controller;

  ScrollController get controller =>
      widget.controller ?? (_controller ??= ScrollController());
  @override
  void initState() {
    super.initState();
    controller.addListener(_onScrollChanged);
    _requestNextPage();
  }

  @override
  void dispose() {
    controller.removeListener(_onScrollChanged);
    _controller?.dispose();
    _listenSub?.cancel();

    super.dispose();
  }

  void _onScrollChanged() {
    if (!controller.hasClients) {
      return;
    }
    final position = controller.position;
    if ((position.pixels >=
            (position.maxScrollExtent - position.viewportDimension)) &&
        position.userScrollDirection == ScrollDirection.reverse) {
      print('always run this function');
      _requestNextPage();
    }
  }

  void _requestNextPage() {
    _pageRequest ??= () async {
      final loaderIndex = _addLoader();

      // await Future.delayed(const Duration(seconds: 3));

      var pagedQuery = widget.pagedBuilder();
      if (_dataPaged.isNotEmpty) {
        pagedQuery = pagedQuery.startAfterDocument(_dataPaged.last);
      }
      final snapshot = await pagedQuery.getDocuments();
      if (!mounted) {
        return;
      }

      final insertIndex = _dataListen.length + _dataPaged.length;
      _dataPaged.addAll(snapshot.docs);
      _removeLoader(loaderIndex);
      for (int i = 0; i < snapshot.documents.length; i++) {
        _animateAdded(insertIndex + i);
      }

      if (_listenSub == null) {
        var listenQuery = widget.listenBuilder();
        if (_dataPaged.isNotEmpty) {
          listenQuery = listenQuery.endBeforeDocument(_dataPaged.first);
        }

        _listenSub = listenQuery.snapshots().listen(_onListenChanged);
      }

      _pageRequest = null;
    }();
  }

  void _mytest(QuerySnapshot snapshot) {
    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {}
    }
  }

  void _onListenChanged(QuerySnapshot snapshot) {
    for (final change in snapshot.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          _dataListen.insert(change.newIndex, change.doc);
          _animateAdded(change.newIndex);
          break;
        case DocumentChangeType.modified:
          if (change.oldIndex == change.newIndex) {
            print('wtfff');
            _dataListen.removeAt(change.oldIndex);
            _dataListen.insert(change.newIndex, change.document);
            setState(() {});
          } else {
            final oldDoc = _dataListen.removeAt(change.oldIndex);
            _animateRemoved(change.oldIndex, oldDoc);
            _dataListen.insert(change.newIndex, change.document);
            _animateAdded(change.newIndex);
          }
          break;
        case DocumentChangeType.removed:
          final oldDoc = _dataListen.removeAt(change.oldIndex);
          _animateRemoved(change.oldIndex, oldDoc);
          break;
      }
    }
  }

  int _addLoader() {
    final index = _dataListen.length + _dataPaged.length;
    _animatedListKey?.currentState
        ?.insertItem(index, duration: widget.duration);
    return index;
  }

  void _removeLoader(int index) {
    _animatedListKey?.currentState?.removeItem(
      index,
      (BuildContext context, Animation<double> animation) {
        return widget.loaderBuilder(context, index, animation);
      },
      duration: widget.duration,
    );
  }

  void _animateAdded(int index) {
    final animatedListState = _animatedListKey.currentState;
    if (animatedListState != null) {
      animatedListState.insertItem(index, duration: widget.duration);
    } else {
      setState(() {});
    }
  }

  void _animateRemoved(int index, DocumentSnapshot old) {
    final animatedListState = _animatedListKey.currentState;
    if (animatedListState != null) {
      animatedListState.removeItem(
        index,
        (BuildContext context, Animation<double> animation) {
          return widget.itemBuilder2(context, index, old, animation);
        },
        duration: widget.duration,
      );
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print('data is _dataListen ${_dataListen}');
    if (_dataListen.length == 0 &&
        _dataPaged.length == 0 &&
        !widget.initialAnimate) {
      return SizedBox();
    }
    return AnimatedList(
      key: _animatedListKey,
      controller: controller,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding ?? MediaQuery.of(context).padding,
      initialItemCount: _dataListen.length + _dataPaged.length,
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        if (index < _dataListen.length) {
          print('datalisten');
          return widget.itemBuilder2(
            context,
            index,
            _dataListen[index],
            animation,
          );
        } else {
          final pagedIndex = index - _dataListen.length;
          if (pagedIndex < _dataPaged.length) {
            print('data is itemBuilder2 ${_dataPaged}');

            return widget.itemBuilder2(
                context, index, _dataPaged[pagedIndex], animation);
          } else {
            print('loaderBuilder');
            return widget.loaderBuilder(
              context,
              pagedIndex,
              AlwaysStoppedAnimation<double>(1.0),
            );
          }
        }
      },
    );
  }
}
