import 'package:get/get.dart';
import 'Item.dart';

class AppController extends GetxController {
  Rx<ItemType> selectedMustShowType = ItemType.all.obs;
  Rx<ShownItem> shownItems = ShownItem.all.obs;
  RxBool   isLoading = false.obs;
}