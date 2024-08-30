class Customer {
  String? name;
  int? totalDebt;
  int? wallet;
  String? shopId;
  String? attendantId;
  String? phoneNumber;
  int? customerNo;
  String? address;
  String? email;
  String? sId;
  String? createAt;

  Customer(
      {this.name,
      this.wallet,
      this.totalDebt,
      this.shopId,
      this.attendantId,
      this.sId,
      this.address,
      this.customerNo,
      this.phoneNumber,
      this.email,
      this.createAt});

  Customer.fromJson(Map<String, dynamic> json) {
    //check if wallet is double
    name = json['name'];
    wallet = json['wallet'] ?? 0;
    totalDebt = json['totalDebt'];
    shopId = json['shopId'];
    customerNo = json['customerNo'] ?? 0;
    address = json['address'] ?? '';
    phoneNumber = json['phonenumber'] ?? '';
    email = json['email'] ?? '';
    attendantId = json['attendantId'];
    sId = json['_id'];
    createAt = json['createAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['wallet'] = wallet;
    data['totalDebt'] = totalDebt;
    data['customerNo'] = customerNo;
    data['address'] = address;
    data['email'] = email;
    data['shopId'] = shopId;
    data['attendantId'] = attendantId;
    data['phonenumber'] = phoneNumber;
    data['_id'] = sId;
    data['createAt'] = createAt;
    return data;
  }
}
