import 'dart:io';
import 'package:alkot_mobilya/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../classes/Item.dart';
import 'firebase_message_service.dart';

class FirebaseService {
  static FirebaseFirestore fireBaseStore = FirebaseFirestore.instance;
  static var countDoc = fireBaseStore.collection(itemsCountCollection).doc('items count document');
  static String itemsCollaction = 'items';
  static String itemsCountCollection = 'items count';

  static Future uploadFile(Item item) async {
    try {
      for (var image in item.images) {
        if (image.downloadUrl == null) {
          await FirebaseStorage.instance.ref('images/${item.id}/${image.name}').putFile(File(image.path));
          image.downloadUrl = await FirebaseService._getDownloadURL(path: 'images/${item.id}/${image.name}');
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'حدث خطا في تحميل الصورة     =>$e');
    }
  }

  static Future<String> _getDownloadURL({required String path}) async {
    try {
      return await FirebaseStorage.instance.ref(path).getDownloadURL();
    } catch (e) {
      Fluttertoast.showToast(msg: 'حدذ خطا في تحميل الصورة $e');
      return '';
    }
  }

  static streamItems() {
    return fireBaseStore.collection(itemsCollaction).snapshots();
  }

  static Future<String> getNewId() async {
    int count = await _getTotalCountFromDatabase();
    // count++;
    if (count < 10)
      return '0000$count';
    else if (count < 100)
      return '000$count';
    else if (count < 1000)
      return '00$count';
    else if (count < 10000)
      return '0$count';
    else
      return '$count';
  }

  static Future<int> _getTotalCountFromDatabase() async {
    int count = 0;
    var countData = await fireBaseStore.collection(itemsCountCollection).doc('items count document').get();
    if (countData.data() != null) count = countData.data()!['all'] ?? 0;
    return count + 1;
  }

  static Future addItem(Item newItem) async {
    bool isConnetcted = await Components.checkConnection();

    if (!isConnetcted) return;

    try {
      await FirebaseService.uploadFile(newItem);
      await fireBaseStore.collection(itemsCollaction).doc(newItem.id).set(newItem.toJson());

      var countData = await fireBaseStore.collection(itemsCountCollection).doc('items count document').get();

      if (countData.data() != null) {
        await countDoc.update({'all': countData.data()!['all'] + 1});
        if (countData.data()![newItem.type.name] != null)
          await changeItemTypeCount(newItem.type, increase: true);
        // await countDoc.update({newItem.type.name: countDocData.data()![newItem.type.name] + 1});
        else
          await countDoc.update({newItem.type.name: 1});
      } else {
        await countDoc.set({'all': 1, newItem.type.name: 1});
      }
      FirebaseMessageService.sentNotifiy();
    } catch (e) {
      Components.showErrorSnackBar(title: 'title', msg: 'msg $e');
    }
  }

  static Future updateItem(Item item, List<MyImage> newImages) async {
    bool isConnetcted = await Components.checkConnection();

    if (!isConnetcted) return;

    List<MyImage> mustDeleteImages = [];
    List<MyImage> mustAddImages = [];

    for (var oldImage in item.images) {
      bool isFound = false;
      for (var newImage in newImages)
        if (oldImage == newImage) {
          isFound = true;
          break;
        }
      if (!isFound) mustDeleteImages.add(oldImage);
    }

    for (var newImage in newImages) {
      bool isFound = false;
      for (var oldImage in item.images)
        if (newImage == oldImage) {
          isFound = true;
          break;
        }
      if (!isFound) mustAddImages.add(newImage);
    }
    try {
      await _deleteItemFromStorage(item.id, mustDeleteImages);
      for (var deleteImage in mustDeleteImages) item.images.removeWhere((element) => element == deleteImage);
      for (var addImage in mustAddImages) item.images.add(addImage);
      await uploadFile(item);
      await fireBaseStore.collection(itemsCollaction).doc(item.id).update(item.toJson());
    } catch (e) {
      Components.showErrorSnackBar(title: 'title', msg: 'msg $e');
    }
  }

  static Future deleteItem(Item item) async {
    fireBaseStore.collection(itemsCollaction).doc(item.id).delete();
    await changeItemTypeCount(item.type, increase: false);
    await fireBaseStore
        .collection(itemsCountCollection)
        .doc('items count document')
        .update({ItemType.all.name: FieldValue.increment(-1)});
    await _deleteItemFromStorage(item.id, item.images);
  }

  static _deleteItemFromStorage(String id, List<MyImage> images) async {
    for (var image in images) {
      final desertRef = FirebaseStorage.instance.ref().child("images/$id/${image.name}");
      await desertRef.delete();
    }
  }

  static Future<List<Item>> getAllItems() async {
    List<Item> items = [];
    var coll = await fireBaseStore.collection(itemsCollaction).get();
    for (var doc in coll.docs) items.add(Item.fromJson(doc.data()));
    return items;
  }

  static Stream<DocumentSnapshot> streamCountOfItem() {
    return fireBaseStore.collection(itemsCountCollection).doc('items count document').snapshots();
    try {} catch (e) {}
  }

  static Future<int> getCountOfItem(ItemType element) async {
    int count = 0;
    var coll = await fireBaseStore.collection(itemsCountCollection).doc('items count document').get();
    if (coll.data() != null) {
      count = coll.data()![element.name] ?? 0;
    }
    return count;
  }

  static Future changeItemTypeCount(ItemType type, {required bool increase}) async {
    int num = increase ? 1 : -1;
    await countDoc.update({type.name: FieldValue.increment(num)});
  }
}
