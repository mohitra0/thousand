import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BackFullPhoto extends StatefulWidget {
  final String url;

  BackFullPhoto({Key key, @required this.url}) : super(key: key);

  @override
  _BackFullPhotoState createState() => _BackFullPhotoState();
}

class _BackFullPhotoState extends State<BackFullPhoto> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> share2() async {
    var request = await HttpClient().getUrl(Uri.parse(widget.url));
    var response = await request.close();
    String urls = 'https://rb.gy/hc85l3';
    var bytes = await consolidateHttpClientResponseBytes(response);
    await Share.file('ESYS AMLOG', 'amlog.jpg', bytes, 'image/jpg', text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff212334),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                share2();
              })
        ],
        title: Text(
          "Image",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
          child:
              PhotoView(imageProvider: CachedNetworkImageProvider(widget.url))),
    );
  }
}
