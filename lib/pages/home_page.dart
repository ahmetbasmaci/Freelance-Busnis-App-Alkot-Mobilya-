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
  @override
  void initState() {
    super.initState();
    FirebaseMessageService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("WidgetsBinding");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _myAppBar(),
        drawer: _myDrawer(),
        body: _myBody(),
        floatingActionButton: FloatingActionButton(
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
            child: Icon(Icons.add)),
      ),
    );
  }

  AppBar _myAppBar() {
    return AppBar(
      title: Text('الكوت موبيليا', style: MyStyles.appBarStyle),
      actions: [
        Obx(
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
        ),
        Components.mySpace(false),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: MySearchDelegate(true));
          },
        ),
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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseService.streamCountOfItem(),
              builder: ((context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError)
                  return Center(
                      child: Text('حدث خطأ اثناء جلب البيانات, من فضلك اعد تشفيل التطبيق',
                          style: TextStyle(color: Colors.red)));
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
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
                        itemType: ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(index)),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _myBody() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamItems(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else if (snapshot.hasError) return Text('Loading');

            List<DocumentSnapshot> list = snapshot.data.docs;
            list = list.reversed.toList();
            return RefreshIndicator(
              onRefresh: () async => Future.delayed(Duration(seconds: 1)).then((value) => setState(() {})),
              child: AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: list.length,
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
                          child: ItemListTile(item: Item.fromJson(list[i])),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
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
    if (isSearchingForItems)
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
    if (isSearchingForItems)
      return getItemResult();
    else
      return getItemTypeResult();
  }

  Widget getItemResult() {
    List<Item> list = itemSearchList
        .where((element) => element.id.contains(query.toLowerCase()) || element.title.contains(query.toLowerCase()))
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ItemListTile(item: list[index]);
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
