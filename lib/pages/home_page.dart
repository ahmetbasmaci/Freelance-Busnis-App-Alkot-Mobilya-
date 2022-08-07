import 'package:alkot_mobilya/components/components.dart';
import 'package:alkot_mobilya/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../classes/Item.dart';
import '../classes/app_controller.dart';
import '../components/item_list_tile.dart';
import '../contstents/styles.dart';
import '../services/firebase_message_service.dart';
import '../services/notification_api.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
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
        ),
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: ListTile(
                  leading: Text(
                    'انواع العناصر',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  trailing: MaterialButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    minWidth: 0,
                    elevation: 10,
                    color: Theme.of(context).primaryColor,
                    child: Icon(Icons.search, color: Colors.white),
                    onPressed: () => showSearch(context: context, delegate: MySearchDelegate(false)),
                  ),
                ),
                accountEmail: Text(''),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                otherAccountsPictures: [],
                otherAccountsPicturesSize: Size.square(40),
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
                  return Column(
                    children: <Widget>[
                      for (int i = 0; i < dataMap.length; i++)
                        Components.drawerItem(
                          context: context,
                          title: Components.getItemTypeArabicText(
                              ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(i))),
                          icon: Components.getItemTypeIcon(
                              ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(i))),
                          selected: false,
                          itemCount: dataMap.values.elementAt(i),
                          onTap: () {
                            appCtr.selectedMustShowType.value =
                                ItemType.values.firstWhere((type) => type.name == dataMap.keys.elementAt(i));
                            Get.back();
                          },
                        ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
        floatingActionButton:
          
        FloatingActionButton(onPressed: () => Get.to(() => AddNewItemPage()), child: Icon(Icons.add)),
        body: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.streamItems(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Loading');
                }

                List<DocumentSnapshot> list = snapshot.data.docs;
                return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (DocumentSnapshot element in list)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ItemListTile(item: Item.fromJson(element)),
                        )
                    ],
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
        ),
      ),
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
                selected: false,
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
