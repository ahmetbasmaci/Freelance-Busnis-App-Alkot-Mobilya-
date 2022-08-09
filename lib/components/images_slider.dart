import 'package:alkot_mobilya/classes/Item.dart';
import 'package:alkot_mobilya/components/components.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../pages/full_screen_image.dart';

class ImageSlider extends StatefulWidget {
  ImageSlider({Key? key, required this.images}) : super(key: key);
  List<MyImage> images;
  @override
  State<ImageSlider> createState() => ImageSliderState();
}

class ImageSliderState extends State<ImageSlider> {
  int selectedImageIndex = 0;
  CarouselController carouselCtr = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: CarouselSlider.builder(
            carouselController: carouselCtr,
            itemCount: widget.images.length,
            options: CarouselOptions(
              autoPlay: true,
              // aspectRatio: 1.0,
              viewportFraction: 0.9,
              enlargeCenterPage: true,
              autoPlayAnimationDuration: Duration(seconds: 1),
              autoPlayInterval: Duration(seconds: 4),
              enableInfiniteScroll: true, //small right and left
              initialPage: selectedImageIndex,
              onPageChanged: (index, reason) {
                setState(() {
                  selectedImageIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, index2) {
              return Image.network(widget.images[index].downloadUrl ?? '', fit: BoxFit.cover);
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              carouselCtr.previousPage();
            },
            icon: const Icon(Icons.arrow_left),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () {
              carouselCtr.nextPage();
            },
            icon: const Icon(Icons.arrow_right),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSmoothIndicator(
            activeIndex: selectedImageIndex,
            count: widget.images.length,
            effect: ScrollingDotsEffect(
              dotHeight: 10,
              dotWidth: 15,
              dotColor: Colors.grey,
              activeDotColor: Theme.of(context).colorScheme.primary,
            ),
            onDotClicked: (index) {
              carouselCtr.animateToPage(index);
            },
          ),
        ),
      ],
    );
  }
}
