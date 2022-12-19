import 'package:alkot_mobilya/components/components.dart';
import 'package:alkot_mobilya/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:wave_transition/wave_transition.dart';
import '../classes/Item.dart';
import '../classes/app_controller.dart';
import '../components/item_list_tile.dart';
import '../contstents/styles.dart';
import '../services/firebase_message_service.dart';
import 'add_new_item_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppController appCtr = Get.find<AppController>();

  TextEditingController roomNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    FirebaseMessageService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _myAppBar(),
        drawer: _myDrawer(),
        body: _myBody(),
        floatingActionButton: FirebaseService.isInRoom()
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    WaveTransition(
                      child: AddNewItemPage(),
                      center: FractionalOffset.bottomLeft,
                      duration: Duration(milliseconds: 1000),
                    ),
                  );

                  // Get.to(
                  //   () => AddNewItemPage(),
                  // duration: Duration(milliseconds: 500),
                  // transition: Transition.zoom,
                  // );
                },
                child: Icon(Icons.add))
            : null,
      ),
    );
  }

  AppBar _myAppBar() {
    return AppBar(
      title: Text('الكوت موبيليا', style: MyStyles.appBarStyle),
      actions: [
        FirebaseService.isInRoom()
            ? Obx(
                () => DropdownButton<ShownItem>(
                  underline: Container(),
                  borderRadius: BorderRadius.circular(10),
                  icon: Icon(Icons.arrow_drop_down_outlined, color: Theme.of(context).scaffoldBackgroundColor),
                  value: appCtr.shownItems.value,
                  dropdownColor: Theme.of(context).primaryColor,
                  style: TextStyle(color: Colors.white),
                  alignment: Alignment.bottomCenter,
                  items: [
                    for (var element in ShownItem.values)
                      DropdownMenuItem(value: element, child: Components.getShownItemArabixTxt(element)),
                  ],
                  onChanged: (val) => appCtr.shownItems.value = val!,
                ),
              )
            : Container(),
        Components.mySpace(false),
        FirebaseService.isInRoom()
            ? IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: MySearchDelegate(true));
                },
              )
            : Container(),
      ],
    );
  }

  Widget _myDrawer() {
    return ClipPath(
      clipper: OvalLeftBorderClipper(),
      child: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(color: Colors.black, blurRadius: 10, spreadRadius: 5),
                      BoxShadow(color: Theme.of(context).colorScheme.primary, blurRadius: 10, spreadRadius: 5),
                    ],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Image.asset('assets/icon/icon.png', width: 150),
                ),
              ),
            ),
            FirebaseService.isInRoom()
                ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseService.streamCountOfItem(),
                    builder: ((context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError)
                        return Center(
                            child: Text('حدث خطأ اثناء جلب البيانات, من فضلك اعد تشفيل التطبيق',
                                style: TextStyle(color: Colors.red)));
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      if (snapshot.data!.data() == null) return Container();
                      Map dataMap = snapshot.data!.data() as Map;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: dataMap.length,
                          padding: EdgeInsets.only(left: 30),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          itemBuilder: (context, index) {
                            return Components.drawerItem(
                              context: context,
                              title: Components.getItemTypeArabicText(
                                  ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(index))),
                              icon: Components.getItemTypeIcon(
                                  ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(index))),
                              itemType:
                                  ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(index)),
                              itemCount: dataMap.values.elementAt(index),
                              onTap: () {
                                appCtr.selectedMustShowType.value =
                                    ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(index));
                                Get.back();
                              },
                            );
                          },
                        ),
                      );
                    }),
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("الغرفة الحالية: ${FirebaseService.currentRoomName}"),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.dialog(AlertDialog(
                        title: Text("انضم الى غرفة جديدة. الغرفة الحالية(${FirebaseService.currentRoomName})"),
                        content: TextField(
                          controller: roomNameController,
                          decoration: InputDecoration(
                            hintText: "اسم الغرفة",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              if (roomNameController.text.isNotEmpty) {
                                FirebaseService.joinToRoom(roomNameController.text);
                                Get.back();
                                setState(() {});
                              }
                            },
                            child: Text("تسجيل الدخول الى الغرفة"),
                          ),
                          FirebaseService.isInRoom()
                              ? MaterialButton(
                                  onPressed: () {
                                    FirebaseService.leaveRoom();
                                    Get.back();
                                    setState(() {});
                                  },
                                  child: Text("تسجيل الخروج"),
                                )
                              : Container(),
                          MaterialButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text("الغاء"),
                          ),
                        ],
                      ));
                    },
                    child: Text("انضم الى الغرفة"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _myBody() {
    return Stack(
      children: [
        FirebaseService.isInRoom()
            ? Obx(
                () => StreamBuilder<QuerySnapshot>(
                  stream: appCtr.selectedMustShowType.value.index == 0 &&
                          appCtr.shownItems.value.index == 0 // just to referesh the lists
                      ? FirebaseService.streamItems()
                      : FirebaseService.streamItems(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator());
                    else if (snapshot.hasError) return Text('Loading');

                    List<DocumentSnapshot> list = snapshot.data.docs;
                    list = list.reversed.toList();
                    List<Item> itemsList = [];
                    for (var element in list) itemsList.add(Item.fromJson(element));
                    List<Item> selectedItemsList = [];
                    for (var element in itemsList)
                      selectedItemsList.addIf(
                        (appCtr.selectedMustShowType.value == ItemType.all ||
                                appCtr.selectedMustShowType.value == element.type) &&
                            (appCtr.shownItems.value == ShownItem.all ||
                                (appCtr.shownItems.value == ShownItem.added && element.isAddetToWebsite) ||
                                (appCtr.shownItems.value == ShownItem.notAdded && !element.isAddetToWebsite)),
                        element,
                      );

                    return RefreshIndicator(
                      onRefresh: () async => Future.delayed(Duration(seconds: 1)).then((value) => setState(() {})),
                      child: AnimationLimiter(
                        child: ListView.builder(
                          padding: EdgeInsets.all(20),
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          itemCount: selectedItemsList.length,
                          itemBuilder: (BuildContext c, int i) {
                            return AnimationConfiguration.staggeredList(
                              position: i,
                              delay: Duration(milliseconds: 100),
                              child: SlideAnimation(
                                duration: Duration(milliseconds: 2500),
                                curve: Curves.fastLinearToSlowEaseIn,
                                horizontalOffset: 30,
                                verticalOffset: 300.0,
                                child: FlipAnimation(
                                  duration: Duration(milliseconds: 3000),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                  flipAxis: FlipAxis.y,
                                  child: ItemListTile(item: selectedItemsList[i]),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("كي تتمكن من مشاهدة وتحميل العناصر يجب عليك الانضمام الى غرفة"),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.dialog(AlertDialog(
                          title: Text("اكتب اسم الغرفة التي تود الانضمام لها (يمكنك كتابة اي اسم تريد)"),
                          content: TextField(
                            controller: roomNameController,
                            decoration: InputDecoration(
                              hintText: "اسم الغرفة",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          actions: [
                            MaterialButton(
                              onPressed: () {
                                if (roomNameController.text.isNotEmpty) {
                                  FirebaseService.joinToRoom(roomNameController.text);
                                  Get.back();
                                  setState(() {});
                                }
                              },
                              child: Text("تسجيل الدخول الى الغرفة"),
                            ),
                            FirebaseService.isInRoom()
                                ? MaterialButton(
                                    onPressed: () {
                                      FirebaseService.leaveRoom();
                                      Get.back();
                                      setState(() {});
                                    },
                                    child: Text("تسجيل الخروج"),
                                  )
                                : Container(),
                            MaterialButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text("الغاء"),
                            ),
                          ],
                        ));
                      },
                      child: Text("انضم الى الغرفة"),
                    ),
                  ),
                ],
              ),
        Obx(() => appCtr.isLoading.value
            ? GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.grey.withOpacity(.5),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : Container())
      ],
    );
  }
}

class MySearchDelegate extends SearchDelegate {
  MySearchDelegate(this.isSearchingForItems) {
    setList();
  }
  AppController appCtr = Get.find<AppController>();
  bool isSearchingForItems;
  List<Item> itemSearchList = [];
  List<ItemType> itemTypeSearchList = [];

  void setList() async {
    if (isSearchingForItems && FirebaseService.isInRoom())
      itemSearchList = await FirebaseService.getAllItems();
    else
      itemTypeSearchList = ItemType.values.map((e) => e).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (isSearchingForItems && FirebaseService.isInRoom())
      return getItemResult();
    else
      return getItemTypeResult();
  }

  Widget getItemResult() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.streamItems(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (snapshot.hasError) return Text('Loading');

          List<DocumentSnapshot> list = snapshot.data.docs;
          list = list.reversed.toList();
          List<Item> itemsList = [];
          for (var element in list) itemsList.add(Item.fromJson(element));

          List<Item> resultList = itemsList
              .where(
                  (element) => element.id.contains(query.toLowerCase()) || element.title.contains(query.toLowerCase()))
              .toList();

          return AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(20),
              shrinkWrap: true,
              physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: resultList.length,
              itemBuilder: (BuildContext c, int i) {
                return AnimationConfiguration.staggeredList(
                  position: i,
                  delay: Duration(milliseconds: 100),
                  child: SlideAnimation(
                    duration: Duration(milliseconds: 2500),
                    curve: Curves.fastLinearToSlowEaseIn,
                    horizontalOffset: 30,
                    verticalOffset: 300.0,
                    child: FlipAnimation(
                      duration: Duration(milliseconds: 3000),
                      curve: Curves.fastLinearToSlowEaseIn,
                      flipAxis: FlipAxis.y,
                      child: ItemListTile(item: resultList[i]),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  getItemTypeResult() {
    List<ItemType> resultList = itemTypeSearchList
        .where((element) => Components.getItemTypeArabicText(element).toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: resultList.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: FirebaseService.getCountOfItem(resultList[index]),
            builder: ((context, AsyncSnapshot<int> snapshot) {
              int count = 0;
              if (snapshot.hasData) count = snapshot.data ?? 0;
              return Components.drawerItem(
                context: context,
                title: Components.getItemTypeArabicText(resultList[index]),
                icon: Components.getItemTypeIcon(resultList[index]),
                itemType: ItemType.values.firstWhere((type) => type == resultList[index]),
                itemCount: count,
                onTap: () {
                  appCtr.selectedMustShowType.value = resultList[index];
                  Get.back();
                },
              );
            }),
          );
        },
      ),
    );
  }
}
