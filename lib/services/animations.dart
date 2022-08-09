import 'package:flutter/material.dart';

class Animations {
  static StatefulBuilder animatedButton(
      {required VoidCallback onPressed, required Widget child, required bool radiusToRight}) {
    bool isTapping = false;
    return StatefulBuilder(builder: ((context, setState) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: isTapping ? 100 : 110,
        height: isTapping ? 35 : 40,
        child: MaterialButton(
          elevation: 10,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: radiusToRight ? Radius.circular(40) : Radius.circular(0),
              bottomRight: radiusToRight ? Radius.circular(40) : Radius.circular(0),
              topRight: radiusToRight ? Radius.circular(0) : Radius.circular(40),
              bottomLeft: radiusToRight ? Radius.circular(0) : Radius.circular(40),
            ),
          ),
          color: Theme.of(context).primaryColor,
          onPressed: onPressed,
          onHighlightChanged: (value) => setState(() {
            isTapping = value;
          }),
          child: child,
        ),
      );
    }));
  }
}
