import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../classes/Item.dart';
import '../pages/add_new_item_page.dart';
import '../classes/app_controller.dart';
import '../services/firebase_service.dart';
import 'components.dart';

class ItemListTile extends StatelessWidget {
  ItemListTile({Key? key, required this.item}) : super(key: key);
  Item item;

  AppController appCtr = Get.find<AppController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => (appCtr.selectedMustShowType.value == ItemType.all || appCtr.selectedMustShowType.value == item.type) &&
              (appCtr.shownItems.value == ShownItem.all ||
                  (appCtr.shownItems.value == ShownItem.added && item.isAddetToWebsite) ||
                  (appCtr.shownItems.value == ShownItem.notAdded && !item.isAddetToWebsite))
          ? Material(
              color: item.isAddetToWebsite
                  ? Colors.green.withOpacity(.2)
                  : Color.fromARGB(255, 255, 88, 73).withOpacity(.2),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => editItem(item: item),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          width: 50,
                          height: 50,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                for (var image in item.images)
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
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                                height: 50,
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical, child: Text(item.description))),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Text(
                              item.id,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () => deleteItem(item: item),
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
            )
          : Container(),
    );
  }

  editItem({required Item item}) {
    Get.to(() => AddNewItemPage(item: item));
  }

  deleteItem({required Item item}) {
    Components.showMyDialog(
        title: 'هل أنت متأكد من حذف ',
        itemTitle: item.title,
        content: 'هل تود بالفعل حذف العنصر نهائيا من البيانات المسجلة',
        onOk: () async {
          appCtr.isLoading.value = true;
          print(appCtr.isLoading.value);
          await FirebaseService.deleteItem(item);
          appCtr.isLoading.value = false;
          print(appCtr.isLoading.value);
          Get.back();
        },
        onCancell: () => Get.back());
  }
}
