import 'dart:io';
import 'dart:math';

import 'package:alkot_mobilya/pages/full_screen_image.dart';
import 'package:alkot_mobilya/services/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  TextEditingController titleCtr = TextEditingController();
  FocusScopeNode titleFocusNode = FocusScopeNode();
  TextEditingController descreptionCtr = TextEditingController();
  FocusScopeNode descraptionFocusNode = FocusScopeNode();

  Item defaultItem = Item.empty();

  bool isEditingItem = false;
  bool isLoading = false;
  bool isTapping = false;

  int selectedImageIndex = 0;
  CarouselController carouselCtr = CarouselController();
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
                      _selectedImages(),
                      Components.mySpace(true),
                      _addTitle(),
                      Components.mySpace(true),
                      _addDescreption(),
                      Components.mySpace(true),
                      _itemTypeDropDownMenu(),
                      Components.mySpace(true),
                      _addCheckBox(),
                      Components.mySpace(true),
                      Components.mySpace(true),
                      _submitBtns(),
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

  Widget _selectedImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الصورة', style: MyStyles.header),
        Components.mySpace(false),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 20),
          height: 300,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, spreadRadius: 10)],
          ),
          child: Stack(
            children: [
              defaultItem.images.isNotEmpty
                  ? CarouselSlider.builder(
                      carouselController: carouselCtr,
                      itemCount: defaultItem.images.length,
                      options: CarouselOptions(
                        autoPlay: true,
                        // aspectRatio: 2,
                        // viewportFraction: 1,
                        enlargeCenterPage: true,
                        autoPlayAnimationDuration: Duration(seconds: 1),
                        autoPlayInterval: Duration(seconds: Random().nextInt(5) + 8),
                        enableInfiniteScroll: false,
                        initialPage: selectedImageIndex,

                        onPageChanged: (index, reason) {
                          setState(() {
                            selectedImageIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, index2) {
                        return Stack(
                          children: [
                            InkWell(
                              onLongPress: () {
                                deleteImage(defaultItem.images[index]);
                              },
                              onTap: () {
                                Get.to(
                                  () => FullScreenImage(images: defaultItem.images, initialIndex: index),
                                  duration: Duration(milliseconds: 500),
                                  transition: Transition.zoom,
                                  curve: Curves.easeOutBack,
                                );
                              },
                              child: Center(
                                child: Components.isImageInDevice(defaultItem.images[index].path)
                                    ? Image.file(File(defaultItem.images[index].path), fit: BoxFit.contain)
                                    : Image.network(
                                        defaultItem.images[index].downloadUrl ?? '',
                                        fit: BoxFit.contain,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          return loadingProgress == null
                                              ? child
                                              : Center(child: CircularProgressIndicator());
                                        },
                                      ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: defaultItem.images[index].downloadUrl));
                                  Fluttertoast.showToast(msg: 'تم نسخ رابط الصور الى الذاكرة بنجاح');
                                },
                                icon: const Icon(Icons.copy, color: Colors.white)),
                          ],
                        );
                      },
                    )
                  : Container(),
              defaultItem.images.isNotEmpty
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSmoothIndicator(
                        activeIndex: selectedImageIndex,
                        count: defaultItem.images.length,
                        effect: ScrollingDotsEffect(
                          dotHeight: 10,
                          dotWidth: 20,
                          dotColor: Colors.grey,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                        onDotClicked: (index) {
                          carouselCtr.animateToPage(index);
                        },
                      ),
                    )
                  : Container(),
              Align(
                alignment: Alignment.bottomLeft,
                child: Animations.animatedButton(
                    onPressed: () {
                      for (var element in defaultItem.images)
                        Clipboard.setData(ClipboardData(text: element.downloadUrl));

                      Fluttertoast.showToast(msg: 'تم نسخ رابط الصور الى الذاكرة بنجاح');
                    },
                    radiusToRight: false,
                    child: Icon(Icons.copy, color: Colors.white)),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Animations.animatedButton(
                    onPressed: () => showImageModalButtomSheet(), child: Text('اضافة صورة'), radiusToRight: true),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _addTitle() {
    return Row(
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
    );
  }

  Widget _addDescreption() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text('الوصف: ', style: MyStyles.header),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(0, 0), blurRadius: 5, spreadRadius: 5)],
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
    );
  }

  Widget _itemTypeDropDownMenu() {
    return Row(
      children: <Widget>[
        Text('النوع العنصر:  ', style: MyStyles.header),
        DropdownButton<ItemType>(
          value: defaultItem.type,
          items: [
            for (var element in ItemType.values)
              if (element != ItemType.all)
                DropdownMenuItem(value: element, child: Text(Components.getItemTypeArabicText(element)))
          ],
          onChanged: (val) {
            setState(() {
              defaultItem.type = val!;
            });
          },
        ),
      ],
    );
  }

  Widget _addCheckBox() {
    return Row(
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
          : [],
    );
  }

  Widget _submitBtns() {
    return Row(
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
    if (titleCtr.text.isEmpty) {
      Components.showErrorSnackBar(title: 'خطأ', msg: 'يجب ادخال عنوان العنصر');
      return;
    } else if (defaultItem.images.isEmpty) {
      Components.showErrorSnackBar(title: 'خطأ', msg: 'يجب ادخال صورة للعنصر');
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
