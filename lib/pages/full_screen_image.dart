import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../classes/Item.dart';
import '../components/components.dart';

class FullScreenImage extends StatelessWidget {
  FullScreenImage({Key? key, required this.images, this.initialIndex = 0}) : super(key: key);
  List<MyImage> images = [];
  int initialIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: images.length,
      initialIndex: initialIndex,
      child: TabBarView(
        children: [
          for (int i = 0; i < images.length; i++)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Components.isImageInDevice(images[i].path)
                      ? Image.file(File(images[i].path), fit: BoxFit.fill)
                      : Image.network(images[i].downloadUrl ?? '', fit: BoxFit.fill),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipOval(
                      child: MaterialButton(
                          color: Colors.white,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: images[i].downloadUrl));
                            Fluttertoast.showToast(msg: 'تم نسخ رابط الصورة الى الذاكرة بنجاح');
                          },
                          child: const Icon(Icons.ios_share_rounded, color: Colors.black)),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
