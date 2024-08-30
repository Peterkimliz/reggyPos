import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/models/shoptype.dart';
import 'package:reggypos/models/subscription.dart';
import 'package:reggypos/models/usermodel.dart';

class Shop {
  bool? primary;
  String? id;
  String? name;
  String? location;
  double? distance;
  bool? allownegativeselling;
  bool? allowOnlineSelling;
  bool? allowBackup;
  String? backupemail;
  String? backupInterval;
  double? latitude;
  double? longitude;
  ShopTypes? shopCategoryId;
  Subscription? subscription;
  String? currency;
  UserModel? owner;
  String? adminId;
  String? contact;
  String? paybillAccount;
  String? paybillTill;
  String? addressReceipt;

  Shop(
      {this.primary,
      this.id,
      this.name,
      this.allownegativeselling,
      this.backupemail,
      this.backupInterval,
      this.allowOnlineSelling,
      this.allowBackup,
      this.location,
      this.distance,
      this.subscription,
      this.shopCategoryId,
      this.currency,
      this.adminId,
      this.paybillTill,
      this.paybillAccount,
      this.contact,
      this.addressReceipt});

  Shop.fromJson(Map<String, dynamic> json) {
    primary = json['primary'] ?? false;
    allowBackup = json['allowBackup'] == 1 || json['allowBackup'] == true
        ? true
        : json['allowBackup'] == 0 || json['allowBackup'] == false
            ? false
            : false;
    allowOnlineSelling = json['allowOnlineSelling'] == 1 ||
            json['allowOnlineSelling'] == true
        ? true
        : json['allowOnlineSelling'] == 0 || json['allowOnlineSelling'] == false
            ? false
            : false;
    allownegativeselling = json['allownegativeselling'] ?? false;
    backupInterval = json['backupInterval'] ?? '';
    backupemail = json['backupemail'] ?? '';
    id = json['_id'];
    name = json['name'];
    distance =
        json['distance'] == null ? 0.0 : toDouble(json['distance'].toString());
    location = json['address'] is String ? json['address'] : null;
    latitude = json['latitude'] is String ? json['latitude'] : null;
    longitude = json['longitude'] is String ? json['longitude'] : null;
    if (json['shopCategoryId'] != null &&
        json['shopCategoryId'] is String == false) {
      shopCategoryId = ShopTypes.fromJson(json['shopCategoryId']);
    }

    if (json['subscription'] != null &&
        json['subscription'] is String == false) {
      subscription = json['subscription'] == null
          ? null
          : Subscription.fromJson(json['subscription']);
    } else {
      subscription = null;
    }
    currency = json['currency'];
    owner = json['adminId'] == null || json['adminId'] is String
        ? null
        : UserModel.fromJson(json['adminId']);
    adminId = json['adminId'] is String ? json['adminId'] : null;
    contact = json['contact'];
    paybillAccount = json['paybill_account'];
    paybillTill = json['paybill_till'];
    addressReceipt = json['address_receipt'];
  }
  bool isInteger(num value) => value is int || value == value.roundToDouble();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['primary'] = primary;
    data['_id'] = id;
    data['name'] = name;
    data['location'] = location;
    data['shopCategoryId'] = shopCategoryId;
    data['currency'] = currency;
    data['adminId'] = adminId;
    return data;
  }
}
