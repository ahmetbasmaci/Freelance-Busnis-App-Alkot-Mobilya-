import 'dart:io';

import 'package:alkot_mobilya/components/images_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../classes/Item.dart';
import '../pages/add_new_item_page.dart';
import '../classes/app_controller.dart';
import '../services/firebase_service.dart';
import 'components.dart';

class ItemListTile extends StatefulWidget {
  ItemListTile({Key? key, required this.item}) : super(key: key);
  Item item;

  @override
  State<ItemListTile> createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  AppController appCtr = Get.find<AppController>();
  // int selectedImageIndex = 0;
  // CarouselController carouselCtr = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => (appCtr.selectedMustShowType.value == ItemType.all ||
                  appCtr.selectedMustShowType.value == widget.item.type) &&
              (appCtr.shownItems.value == ShownItem.all ||
                  (appCtr.shownItems.value == ShownItem.added && widget.item.isAddetToWebsite) ||
                  (appCtr.shownItems.value == ShownItem.notAdded && !widget.item.isAddetToWebsite))
          ? _itemCard2(context)
          : Container(),
    );
  }

  Widget _itemCard2(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
      ),
      height: 300,
      child: InkWell(
        onTap: () => editItem(item: widget.item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    ImageSlider(images: widget.item.images),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => deleteItem(item: widget.item),
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration:
                            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(.3), blurRadius: 10, spreadRadius: 5),
                        ]),
                        child: Icon(
                          widget.item.isAddetToWebsite ? Icons.download_done_rounded : Icons.dangerous,
                          color: widget.item.isAddetToWebsite ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 10),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.item.id, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(widget.item.title, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: Text(widget.item.description),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: widget.item.isAddetToWebsite
            ? Color.fromARGB(255, 255, 255, 255)
            : Color.fromARGB(255, 255, 246, 245).withOpacity(1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
      ),
      child: InkWell(
        onTap: () => editItem(item: widget.item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.only(left: 15),
                  width: 50,
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        for (var image in widget.item.images)
                          Image.network(
                            image.downloadUrl ?? '',
                            width: 50,
                            height: 50,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 50,
                      child:
                          SingleChildScrollView(scrollDirection: Axis.vertical, child: Text(widget.item.description)),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      widget.item.id,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => deleteItem(item: widget.item),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  editItem({required Item item}) {
    Get.to(
      () => AddNewItemPage(item: item),
      duration: Duration(milliseconds: 600),
      transition: Transition.leftToRight,
      curve: Curves.easeInOutCubic,
    );
  }

  deleteItem({required Item item}) {
    Components.showMyDialog(
        title: 'هل أنت متأكد من حذف ',
        itemTitle: item.title,
        content: 'هل تود بالفعل حذف العنصر نهائيا من البيانات المسجلة',
        onOk: () async {
          appCtr.isLoading.value = true;
          Get.back();
          await FirebaseService.deleteItem(item);
          appCtr.isLoading.value = false;
        },
        onCancell: () => Get.back());
  }
}
