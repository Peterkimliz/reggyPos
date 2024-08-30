import 'package:reggypos/models/productcategory.dart';
import 'package:reggypos/models/shop.dart';
import 'package:reggypos/models/supplier.dart';

import '../screens/product/create_product.dart';

class Product {
  List<CustomImage>? images;
  String? sId;
  String? type;
  String? name;
  String? manufacturer;
  double? buyingPrice;
  double? sellingPrice;
  double? wholesalePrice;
  double? dealerPrice;
  double? minSellingPrice;
  String? measureUnit;
  double? quantity;
  int? lastCount;
  double? maxDiscount;
  int? reorderLevel;
  ProductCategory? productCategoryId;
  String? barcode;
  String? expiryDate;
  Supplier? supplierId;
  Shop? shop;
  String? description;
  String? uploadImage;
  Attendant? attendantId;
  String? lastcoundate;
  String? date;
  bool? taxable;

  Product(
      {this.sId,
      this.images = const [],
      this.name,
      this.manufacturer,
      this.expiryDate,
      this.taxable,
      this.buyingPrice,
      this.sellingPrice,
      this.minSellingPrice,
      this.quantity,
      this.lastCount,
      this.maxDiscount,
      this.reorderLevel,
      this.barcode,
      this.productCategoryId,
      this.measureUnit,
      this.supplierId,
      this.shop,
      this.description,
      this.uploadImage,
      this.type,
      this.dealerPrice,
      this.wholesalePrice,
      this.attendantId,
      this.lastcoundate,
      this.date});

  Product.fromJson(Map<String, dynamic> json) {
    images = json["images"] == null ||
            json["images"].isEmpty ||
            json["images"] is String
        ? null
        : List<CustomImage>.from(json["images"].map(
            (x) => CustomImage(imgType: ImageType.network, path: x ?? "")));
    sId = json['_id'];
    type = json['productType'] ?? "product";
    manufacturer = json['manufacturer'] ?? "";
    name = json['name'];
    wholesalePrice = json['wholesalePrice'] == null
        ? 0.0
        : json['wholesalePrice'].toDouble();
    dealerPrice =
        json['dealerPrice'] == null ? 0.0 : json['dealerPrice'].toDouble();
    barcode = json['barcode'];
    expiryDate = json['expiryDate'] ?? '';
    taxable = json['taxable'] == 1 || json['taxable'] == true
        ? true
        : json['taxable'] == false
            ? false
            : null;
    buyingPrice =
        json['buyingPrice'] == null ? 0.0 : json['buyingPrice'].toDouble();
    sellingPrice =
        json['sellingPrice'] == null ? 0.0 : json['sellingPrice'].toDouble();
    minSellingPrice = json['minSellingPrice'] == null
        ? 0.0
        : json['minSellingPrice'].toDouble();
    quantity = json['quantity'] == null ? 0.0 : json['quantity'].toDouble();

    maxDiscount =
        json['maxDiscount'] == null ? 0.0 : json['maxDiscount'].toDouble();

    reorderLevel = json['reorderLevel'];
    if (json['productCategoryId'] != null &&
        json['productCategoryId'] is String == false) {
      productCategoryId = ProductCategory.fromJson(json['productCategoryId']);
    }
    if (json['supplierId'] != null && json['supplierId'] is String == false) {
      supplierId = Supplier.fromJson(json['supplierId']);
    }
    if (json['attendantId'] != null && json['attendantId'] is String == false) {
      attendantId = Attendant.fromJson(json['attendantId']);
    }
    if (json['shopId'] != null && json['shopId'] is String == false) {
      shop = Shop.fromJson(json['shopId']);
    }
    lastCount = json['lastCount'] ?? 0;
    measureUnit = json['measure'] ?? "";
    description = json['description'];
    uploadImage = json['uploadImage'];
    lastcoundate = json['lastcoundate'] ?? json['date'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['buyingPrice'] = buyingPrice;
    data['buyingPrice'] = buyingPrice;
    data['sellingPrice'] = sellingPrice;
    data['minSellingPrice'] = minSellingPrice;
    data['quantity'] = quantity;
    data['maxDiscount'] = maxDiscount;
    data['reorderLevel'] = reorderLevel;
    if (productCategoryId != null) {
      data['productCategoryId'] = productCategoryId!.toJson();
    }
    data['measure'] = measureUnit;
    if (supplierId != null) {
      data['supplierId'] = supplierId!.toJson();
    }
    if (shop != null) {
      data['shopId'] = shop!.toJson();
    }
    data['description'] = description;
    data['uploadImage'] = uploadImage;
    if (attendantId != null) {
      data['attendantId'] = attendantId!.toJson();
    }
    data['date'] = date;
    data['lastcoundate'] = lastcoundate;
    return data;
  }
}

bool isInteger(num value) => value is int || value == value.roundToDouble();

class Attendant {
  String? sId;
  String? username;

  Attendant({this.sId, this.username});

  Attendant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['username'] = username;
    return data;
  }
}
