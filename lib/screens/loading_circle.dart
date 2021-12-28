import 'package:flutter/material.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      color: Colors.transparent,
    );
  }
}
