import 'dart:async';

import 'package:alkot_mobilya/pages/home_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  double _opacity = 0;
  bool _value = true;

  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    )..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            Get.off(HomePage());
            Timer(Duration(milliseconds: 300), () => scaleController.reset());
          }
        },
      );

    scaleAnimation = Tween<double>(begin: 0.0, end: 12).animate(scaleController);

    Timer(Duration(milliseconds: 600), () {
      setState(() {
        _opacity = 1.0;
        _value = false;
      });
    });
    Timer(Duration(milliseconds: 3000), () {
      setState(() {
        scaleController.forward();
      });
    });
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'الكوت موبيليا',
                      speed: Duration(milliseconds: 150),
                      textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                  isRepeatingAnimation: false,
                  repeatForever: false,
                  displayFullTextOnTap: false,
                ),
              ),
            ],
          ),
          Center(
            child: AnimatedOpacity(
              curve: Curves.fastLinearToSlowEaseIn,
              duration: Duration(seconds: 6),
              opacity: _opacity,
              child: AnimatedContainer(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: Duration(seconds: 2),
                height: _value ? 50 : 200,
                width: _value ? 50 : 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icon/icon.png'),
                    fit: BoxFit.contain,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(.2),
                      blurRadius: 100,
                      spreadRadius: 10,
                    ),
                  ],
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0), shape: BoxShape.circle),
                    child: AnimatedBuilder(
                      animation: scaleAnimation,
                      builder: (c, child) => Transform.scale(
                        scale: scaleAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
