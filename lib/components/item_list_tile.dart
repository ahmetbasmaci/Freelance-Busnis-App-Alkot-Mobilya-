import 'package:alkot_mobilya/components/images_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  @override
  Widget build(BuildContext context) {
    return _itemCard(context);
  }

  Widget _itemCard(BuildContext context) {
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
