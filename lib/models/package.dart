class Package {
  String? id;
  String? title;
  String? description;
  int? durationValue;
  String? durationUnit;
  String? type;
  bool? trial;
  int? order;
  int? amountusd;
  int? amount;
  int? discount;
  List<String>? features;
  int? maxShops;

  Package(
      {this.title,
      this.id,
      this.type,
      this.order,
      this.trial,
      this.amountusd,
      this.discount,
      this.features,
      this.amount,
      this.description,
      this.durationValue,
      this.maxShops});

  Package.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    amountusd = json['amountusd'] ?? 0;
    discount = json['discount'] ?? 0;
    discount = json['discount'] ?? 0;
    order = json['order'] ?? 0;
    features = json['features'].cast<String>();
    type = json['type'];
    trial = json['type'] == 'trial' ? true : false;
    amount = json['amount'];
    description = json['description'];
    durationUnit = json['durationUnit'];
    durationValue = json['durationValue'];
    maxShops = json['maxShops'];
  }
}
