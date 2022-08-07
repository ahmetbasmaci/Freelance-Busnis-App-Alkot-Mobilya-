import 'dart:io';
import 'package:alkot_mobilya/pages/full_screen_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../classes/Item.dart';
import '../components/components.dart';
import '../contstents/styles.dart';
import '../services/firebase_service.dart';

class AddNewItemPage extends StatefulWidget {
  AddNewItemPage({Key? key, Item? item}) : super(key: key) {
    if (item != null)
      newItem = item;
    else
      newItem = Item.empty();
  }
  late Item newItem;
  @override
  State<AddNewItemPage> createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  TextEditingController titleCtr = TextEditingController(text: '1');
  FocusScopeNode titleFocusNode = FocusScopeNode();
  TextEditingController descreptionCtr = TextEditingController(text: '2');
  FocusScopeNode descraptionFocusNode = FocusScopeNode();

  Item defaultItem = Item.empty();

  bool isEditingItem = false;
  bool isLoading = false;
  bool isTapping = false;
  @override
  void initState() {
    super.initState();
    checkIfEditing();
  }

  checkIfEditing() async {
    if (widget.newItem.id != '') {
      isEditingItem = true;
      defaultItem.id = widget.newItem.id;
      titleCtr.text = widget.newItem.title;
      descreptionCtr.text = widget.newItem.description;
      defaultItem.type = widget.newItem.type;
      defaultItem.isAddetToWebsite = widget.newItem.isAddetToWebsite;
      defaultItem.images.clear();
      defaultItem.images.addAll(widget.newItem.images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () {
          descraptionFocusNode.unfocus();
          titleFocusNode.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('اضف عنصر جديد', style: MyStyles.appBarStyle),
            centerTitle: true,
            leading: Row(
              children: <Widget>[
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: isLoading ? null : () => Get.back()),
              ],
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(children: [Text('الصورة', style: MyStyles.header), Components.mySpace(false)]),
                      Container(
                        width: double.maxFinite,
                        height: 300,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: isEditingItem ? Colors.transparent : Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: [
                              BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 5),
                            ],
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            MaterialButton(
                              onPressed: () => showImageModalButtomSheet(),
                              onLongPress: () {},
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: defaultItem.images.isNotEmpty
                                  ? Center(
                                      child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: <Widget>[
                                          for (int i = 0; i < defaultItem.images.length; i++)
                                            InkWell(
                                              onLongPress: () => deleteImage(defaultItem.images[i]),
                                              onTap: () {
                                                Get.to(
                                                    () => FullScreenImage(images: defaultItem.images, initialIndex: i));
                                              },
                                              child: Hero(
                                                tag: defaultItem.images[i].name,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: Components.isImageInDevice(defaultItem.images[i].path)
                                                          ? Image.file(File(defaultItem.images[i].path),
                                                              fit: BoxFit.fill)
                                                          : Image.network(defaultItem.images[i].downloadUrl ?? '',
                                                              fit: BoxFit.fill),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.topCenter,
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(top: 10),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(.1),
                                                          borderRadius: BorderRadius.circular(100),
                                                        ),
                                                        child: Text('${i + 1}/${defaultItem.images.length}',
                                                            style: TextStyle(fontSize: 15, color: Colors.white)),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: Container(
                                                        height: 40,
                                                        width: 40,
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(bottom: 10),
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(.1),
                                                          borderRadius: BorderRadius.circular(100),
                                                        ),
                                                        child: IconButton(
                                                            onPressed: () {
                                                              Clipboard.setData(ClipboardData(
                                                                  text: defaultItem.images[i].downloadUrl));
                                                              Fluttertoast.showToast(
                                                                  msg: 'تم نسخ رابط الصورة الى الذاكرة بنجاح');
                                                            },
                                                            icon: const Icon(Icons.copy, color: Colors.white)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ].reversed.toList(),
                                      ),
                                    ))
                                  : Container(),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: isTapping ? 100 : 110,
                                height: isTapping ? 35 : 40,
                                child: MaterialButton(
                                  elevation: 10,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () => showImageModalButtomSheet(),
                                  onHighlightChanged: (value) => setState(() {
                                    isTapping = value;
                                  }),
                                  child: Text('اضافة صورة'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Components.mySpace(true),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('العنوان: ', style: MyStyles.header),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 5),
                                ],
                                color: Theme.of(context).scaffoldBackgroundColor),
                            width: 250,
                            height: 40,
                            child: TextField(
                              controller: titleCtr,
                              focusNode: titleFocusNode,
                              maxLength: 20,
                              maxLines: 1,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: titleCtr.text));
                                    Fluttertoast.showToast(msg: 'تم نسخ العنوان الى الذاكرة بنجاح');
                                  },
                                  icon: Icon(Icons.copy),
                                ),
                                counterText: '',
                                hintText: 'ادخل عنوان العنصر...',
                                hintStyle: TextStyle(),
                                hintTextDirection: TextDirection.rtl,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Components.mySpace(true),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('الوصف: ', style: MyStyles.header),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              boxShadow: [
                                BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 5)
                              ],
                            ),
                            width: 250,
                            height: 90,
                            child: TextField(
                              controller: descreptionCtr,
                              focusNode: descraptionFocusNode,
                              maxLength: 500,
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.bottom,
                              maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: descreptionCtr.text));
                                      Fluttertoast.showToast(msg: 'تم نسخ الوصف الى الذاكرة بنجاح');
                                    },
                                    icon: Icon(Icons.copy),
                                  ),
                                  counterText: '',
                                  hintText: 'ادخل وصف العنصر...',
                                  hintStyle: TextStyle(),
                                  hintTextDirection: TextDirection.rtl,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  contentPadding: EdgeInsets.all(4)),
                            ),
                          ),
                        ],
                      ),
                      Components.mySpace(true),
                      Row(
                        children: <Widget>[
                          Text('النوع العنصر:  ', style: MyStyles.header),
                          DropdownButton<ItemType>(
                            value: defaultItem.type,
                            items: [
                              for (var element in ItemType.values)
                                if (element != ItemType.all)
                                  DropdownMenuItem(
                                      value: element, child: Text(Components.getItemTypeArabicText(element)))
                            ],
                            onChanged: (val) {
                              setState(() {
                                defaultItem.type = val!;
                              });
                            },
                          ),
                        ],
                      ),
                      Components.mySpace(true),
                      Row(
                          children: isEditingItem
                              ? <Widget>[
                                  Text('تم اضافته للموقع: ', style: MyStyles.header),
                                  Checkbox(
                                    value: defaultItem.isAddetToWebsite,
                                    onChanged: (val) {
                                      setState(() {
                                        defaultItem.isAddetToWebsite = val!;
                                      });
                                    },
                                  )
                                ]
                              : []),
                      Components.mySpace(true),
                      Components.mySpace(true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          OutlinedButton(
                            onPressed: () => addItemToDatabase(),
                            style: ButtonStyle(
                              shadowColor: MaterialStateProperty.all(Colors.black),
                              elevation: MaterialStateProperty.all(5),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
                            ),
                            child: Row(
                              children: [
                                Text("تأكيد"),
                                Components.mySpace(false),
                                Icon(Icons.done_rounded, color: Colors.green),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Get.back();
                            },
                            style: ButtonStyle(
                              shadowColor: MaterialStateProperty.all(Colors.black),
                              elevation: MaterialStateProperty.all(5),
                              backgroundColor: MaterialStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
                            ),
                            child: Row(
                              children: [
                                Text("اغلاق"),
                                Components.mySpace(false),
                                Icon(Icons.close, color: Colors.red),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              isLoading
                  ? GestureDetector(
                      onTap: () {},
                      child: Container(
                        color: Colors.grey.withOpacity(.5),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  showImageModalButtomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('اضافة صورة من الكاميرا'),
                  onTap: () => getImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('اضافة صورة من المعرض'),
                  onTap: () => getImage(ImageSource.gallery),
                ),
              ],
            ),
          );
        });
  }

  getImage(ImageSource imageSource) async {
    List<XFile?>? selectedImages = [];
    if (imageSource == ImageSource.gallery)
      selectedImages = await ImagePicker().pickMultiImage();
    else {
      XFile? newImg = await ImagePicker().pickImage(source: imageSource);
      selectedImages.add(newImg);
    }
    Get.back();
    try {
      if (selectedImages != null && selectedImages[0] != null) {
        for (XFile? image in selectedImages) defaultItem.images.add(MyImage(path: image!.path, name: image.name));
        setState(() {});
      } else
        Fluttertoast.showToast(msg: 'لم يتم اختيار اي صورة');
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: 'حدث خطأ ما اثناء تحميل الصور $e');
    }
  }

  deleteImage(MyImage image) {
    Components.showMyDialog(
        title: 'هل أنت متأكد من حذف الصورة ',
        content: 'هل تود بالفعل حذف العنصر نهائيا من البيانات المسجلة',
        onOk: () {
          defaultItem.images.remove(image);
          Get.back();
          setState(() {});
        },
        onCancell: () => Get.back());
  }

  addItemToDatabase() async {
    if (defaultItem.images.isEmpty) {
      Components.showErrorSnackBar(title: 'خطأ', msg: 'يجب ادخال صورة للعنصر');
      return;
    } else if (descreptionCtr.text.isEmpty) {
      Components.showErrorSnackBar(title: 'خطأ', msg: 'يجب ادخال وصف العنصر');
      return;
    } else if (titleCtr.text.isEmpty) {
      Components.showErrorSnackBar(title: 'خطأ', msg: 'يجب ادخال عنوان العنصر');
      return;
    }
    isLoading = true;
    setState(() {});

    if (isEditingItem) {
      if (widget.newItem.type != defaultItem.type) {
        //we need to decrease the old item type count
        await FirebaseService.changeItemTypeCount(widget.newItem.type, increase: false);
        await FirebaseService.changeItemTypeCount(defaultItem.type, increase: true);
      }
      widget.newItem.title = titleCtr.text;
      widget.newItem.description = descreptionCtr.text;
      widget.newItem.id = defaultItem.id;
      widget.newItem.type = defaultItem.type;
      widget.newItem.isAddetToWebsite = defaultItem.isAddetToWebsite;

      await FirebaseService.updateItem(widget.newItem, defaultItem.images);
      Get.back();
    } else {
      widget.newItem = Item(
        title: titleCtr.text,
        description: descreptionCtr.text,
        images: defaultItem.images,
        id: await FirebaseService.getNewId(),
        type: defaultItem.type,
        isAddetToWebsite: defaultItem.isAddetToWebsite,
      );
      await FirebaseService.addItem(widget.newItem);
    }
    clearTextFileds();
    isLoading = false;
    setState(() {});
    Get.back();
  }

  clearTextFileds() {
    titleCtr.clear();
    descreptionCtr.clear();

    titleFocusNode.unfocus();
    descraptionFocusNode.unfocus();

    FocusManager.instance.primaryFocus?.unfocus(); //hide kyboard
  }
}
