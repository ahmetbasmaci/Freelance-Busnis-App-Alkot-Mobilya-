class Item {
  late String id;
  late String title;
  late String description;
  late List<MyImage> images;
  late ItemType type;
  late bool isAddetToWebsite;
  Item(
      {required this.title,
      required this.description,
      required this.images,
      required this.id,
      required this.type,
      required this.isAddetToWebsite});
  Item.empty() {
    id = '';
    title = '';
    description = '';
    images = [];
    type = ItemType.other;
    isAddetToWebsite = false;
  }
  update(Item item) {
    id = item.id;
    title = item.title;
    description = item.description;
    images = item.images;
  }

  Map<String, dynamic> toJson() {
    List<Map> listImages = [];
    for (var image in images) listImages.add(image.toJson());
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': listImages,
      'type': type.name,
      'isAddetToWebsite': isAddetToWebsite,
    };
  }

  static Item fromJson(var data) {
    List<MyImage> listImages = [];
    for (var image in data['images']) {
      listImages.add(MyImage.fromJson(image));
    }

    return Item(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      images: listImages,
      type: ItemType.values.firstWhere((element) => element.name == data['type']),
      isAddetToWebsite: data['isAddetToWebsite'] as bool,
    );
  }
}

class MyImage {
  MyImage({required this.path, required this.name, this.downloadUrl});
  String path;
  String name;
  String? downloadUrl = '';

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'downloadUrl': downloadUrl,
      };

  static MyImage fromJson(var data) {
    return MyImage(
      path: data['path'] as String,
      name: data['name'] as String,
      downloadUrl: data['downloadUrl'] as String,
    );
  }
}

enum ItemType { all, kitchen, table, chair, bed, wardrobe, other }
enum ShownItem { all,added,notAdded }
