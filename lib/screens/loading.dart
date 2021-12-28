import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class Loading extends StatelessWidget {
  const Loading();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var widthh = screenSize.width;
    var heightt = screenSize.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'assets/images/loading.json',
                fit: BoxFit.fill,
                width: widthh * 0.3,
              ),
            ),
            Text(
              'Looking people for you...',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widthh * 0.06),
              ),
            ),
          ],
        ),
        color: Colors.transparent,
      ),
    );
  }
}
