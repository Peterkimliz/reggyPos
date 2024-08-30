// TODO Implement this library.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/ordercontroller.dart';
import 'package:reggypos/controllers/paymentcontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/package.dart';

import '../models/shop.dart';
import '../models/shoptype.dart';
import '../screens/home/home.dart';
import '../screens/shop/create_shop.dart';
import '../services/client.dart';
import '../services/end_points.dart';
import '../services/shop_services.dart';
import '../sqlite/helper.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';
import '../widgets/alert.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/snackbars.dart';

class ShopController {
  RxBool gettingShopsLoad = RxBool(false);
  RxList<Shop> allShops = RxList([]);
  RxList<Shop> expiredShops = RxList([]);
  RxBool loadingcateries = RxBool(false);
  RxInt shopSubscribed = RxInt(0);
  RxList<Shop> shopsRenew = RxList([]);
  RxBool subscribing = RxBool(false);
  RxBool showReportssettings = RxBool(false);

  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  TextEditingController contactController = TextEditingController();
  TextEditingController paybillAcc = TextEditingController();
  TextEditingController paybillTill = TextEditingController();
  TextEditingController address = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController backupemail = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController reqionController = TextEditingController();
  TextEditingController latitude = TextEditingController();
  TextEditingController longitude = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  RxList excludefeatures = RxList(["usage", 'stock', "support"]);
  RxBool createShopLoad = RxBool(false);
  RxBool updateEmail = RxBool(false);
  RxBool showbackupsettings = RxBool(false);
  RxBool allowOnlineSelling = RxBool(true);
  RxBool allownegativesales = RxBool(false);
  RxBool allowBackup = RxBool(false);
  RxBool onlinesellingsettings = RxBool(false);
  Rxn<ShopTypes> selectedCategory = Rxn(null);
  RxList<ShopTypes> selectedDiscoverCategories = RxList([]);
  RxList<Shop> shopsAround = RxList([]);
  RxString currency = RxString("");
  RxDouble currentDistance = RxDouble(100);
  RxBool updateShopLoad = RxBool(false);
  RxBool isBacking = RxBool(false);
  RxBool shopsAroundLoad = RxBool(false);
  RxBool deleteShopLoad = RxBool(false);
  RxString shopLocation = RxString("");
  RxBool terms = RxBool(false);
  RxList<ShopTypes> categories = RxList([]);

  RxMap selectedbackupsendinterval =
      RxMap({"name": "end_of_month", "value": "Every End of Month"});
  RxList backupsendinterval = RxList([
    {"name": "daily", "value": "Every day"},
    {"name": "end_of_month", "value": "Every End of Month"},
    {"name": "yearly", "value": "Every End of Year"},
  ]);

  createShop({required page, required context}) async {
    if (nameController.text.trim().isEmpty) {
      generalAlert(title: "Error", message: "Please enter  name");
      return;
    }
    if (selectedCategory.value == null) {
      generalAlert(title: "Error", message: "Please select business type");
      return;
    }
    if (reqionController.text.trim().isEmpty) {
      generalAlert(title: "Error", message: "Please enter location");
      return;
    }
    createShopLoad.value = true;
    var shop = {
      "name": nameController.text,
      "location": reqionController.text,
      "address": reqionController.text,
      "latitude": latitude.text,
      "backupInterval": selectedbackupsendinterval['name'],
      "allowOnlineSelling": allowOnlineSelling.value,
      "backupemail": userController.currentUser.value?.email,
      "longitude": longitude.text,
      "shopCategoryId": selectedCategory.value?.id,
      "currency":
          currency.isEmpty ? Constants.currenciesData[0] : currency.value,
      "adminId": userController.currentUser.value?.id
    };
    var response = await ShopService().createShop(shop);
    clearTextFields();
    await getShops();
    if (userController.currentUser.value!.primaryShop == null) {
      userController.currentUser.value!.primaryShop = Shop.fromJson(response);
    }
    await authController.initUser();
    if (page == "home" || page == "reg") {
      Get.off(() => const Home());
    } else {
      Get.back();
    }

    createShopLoad.value = false;
  }

  getShops({String name = ""}) async {
    try {
      if (gettingShopsLoad.value == true) return;
      gettingShopsLoad.value = true;
      allShops.clear();
      expiredShops.clear();
      bool connected = await isConnected();
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<dynamic> response;
      if (!connected) {
        response = await databaseHelper.getAllShops();
      } else {
        response = await ShopService.getShops(
            userController.currentUserId.value,
            name: name);
      }
      gettingShopsLoad.value = false;
      if (response.isNotEmpty) {
        allShops.addAll(response.map((e) => Shop.fromJson(e)).toList());
        expiredShops.addAll(allShops
            .where((element) =>
                checkDaysRemaining(shop: element) <= 0 ||
                element.subscription?.package?.type == "trial")
            .toList());
        if (connected) {
          for (var element in response) {
            await databaseHelper.insertShop(element);
          }
        }
      }
      clearTextFields();
    } catch (e) {
      gettingShopsLoad.value = false;
    }
  }

  clearTextFields() {
    nameController.text = "";
    businessController.text = "";
    reqionController.text = "";
    terms.value = false;
  }

  checkDaysRemaining({Shop? shop}) {
    if (allowSubscription == false) return 999999;
    shop ??= userController.currentUser.value?.primaryShop;
    if (shop?.subscription == null) {
      return 0;
    }
    DateTime endDate = DateTime.parse(shop!.subscription!.endDate!).toLocal();

    int days = shop.subscription == null
        ? 0
        : endDate.difference(DateTime.now().toLocal()).inDays;
    if (days < 0 || days == 0) {
      int hoursDifference =
          endDate.difference(DateTime.now().toLocal()).inHours;
      if (hoursDifference > 0) {
        days = 1;
      }
    }
    return days < 0 ? 0 : days;
  }

  checkSubscription({Shop? shop}) {
    if (allowSubscription == false) return !allowSubscription;
    return checkDaysRemaining(shop: shop) > 0;
  }

  checkIfTrial() {
    if (allowSubscription == false) return allowSubscription;
    if (userController.currentUser.value?.primaryShop?.subscription == null ||
        userController.currentUser.value?.primaryShop!.subscription!.package ==
            null) {
      return true;
    }
    return userController
        .currentUser.value?.primaryShop!.subscription!.package?.trial!;
  }

  getCurrentPackage() {
    if (allowSubscription == false) return allowSubscription;
    return userController.currentUser.value!.primaryShop!.subscription!.package;
  }

  isCurrentPackage(Package package) {
    if (allowSubscription == false) return allowSubscription;
    if (userController.currentUser.value!.primaryShop!.subscription == null) {
      return false;
    }
    return userController
            .currentUser.value!.primaryShop!.subscription!.package?.id ==
        package.id;
  }

  subscribe(Shop shop,
      {required Package package, String type = "mpesa"}) async {
    try {
      subscribing.value = true;

      var data = {
        "userId": userController.currentUser.value!.id,
        "shops": shopsRenew.map((element) => element.id).toList(),
        "email": userController.currentUser.value!.email,
        "phonenumber": userController.phoneController.text,
        "package": package.id,
        "paymentType": type,
        "shop": shop.id,
        "amount": package.amount
      };
      var response = await ShopService().subscribe(data);

      subscribing.value = false;
      if (response["status"] != 200) {
        generalAlert(
          title: "Error",
          message: response["message"],
        );
      } else {
        Get.back();
        if (type == "mpesa") {
          var subscriptionid = response['subscriptionid'];
          await paymentCall(subscriptionid, shop: shop);
        } else {
          await openStripe(response, Get.context!);
        }
      }
      subscribing.value = false;
    } catch (e) {
      subscribing.value = false;
    }
  }

  paymentCall(subscriptionid,
      {String message =
          "Check your phone and enter your mpesa pin and click confirmed on this page payment",
      Shop? shop}) async {
    generalAlert(
        title: "Please wait...",
        message: message,
        positiveText: "Confirm Payment",
        function: () async {
          LoadingDialog.showLoadingDialog(
              context: Get.context!, title: "Please wait...", key: _keyLoader);
          var response = await ShopService().confirmPayment(
              subscriptionid,
              shop != null
                  ? shop.id!
                  : userController.currentUser.value!.primaryShop!.id!,
              shops: shopsRenew.map((element) => element.id).toList());
          Get.back();
          if (response["status"] == false) {
            generalAlert(
                title: "Error",
                message: response["message"],
                function: () {
                  paymentCall(subscriptionid, shop: shop);
                });
          } else {
            generalAlert(
              title: "Success",
              message: response["message"],
              function: () async {
                shopsRenew.clear();
                Get.back();
                // showSnackBar(message: response["message"], color: Colors.green);
                await authController.initUser();
                Get.back();
              },
            );
          }
        },
        negativeCallback: () {
          Get.back();
        });
  }

  openStripe(var response, context) async {
    try {
      stripe.Stripe.publishableKey = stripePublishKey;
      stripe.Stripe.setReturnUrlSchemeOnAndroid = true;
      await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
        paymentIntentClientSecret: response['client_secret'],
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'US',
          testEnv: false,
        ),
        style: ThemeMode.light,
        merchantDisplayName: 'Pay',
      ));
      await stripe.Stripe.instance.presentPaymentSheet();
      await checkStripeStatus(response['client_secret'],
          subscriptionid: response['subscriptionid']);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> checkStripeStatus(String clientSecret,
      {Function? completeOrder, String? subscriptionid}) async {
    await stripe.Stripe.instance
        .retrievePaymentIntent(clientSecret)
        .then((value) async {
      if (value.status.name == "Succeeded") {
        try {
          if (completeOrder != null) {
            completeOrder();
          } else {
            Get.defaultDialog(
                title: "Please wait",
                contentPadding: const EdgeInsets.all(10),
                content: const CircularProgressIndicator(),
                barrierDismissible: false);
            var responseData = await DbBase().databaseRequest(
                EndPoints.updatestripesubscriptions, DbBase().putRequestType,
                body: {
                  "subscriptionid": subscriptionid,
                  "transaction_code": value.id,
                });
            if (responseData["status"] == 200) {
              generalAlert(
                  title: "Success",
                  message: responseData["message"],
                  function: () {
                    authController.initUser();
                  });
            }
          }

          return true;
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      } else if (value.status.name == "requires_payment_method") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_confirmation") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "requires_action") {
        await checkStripeStatus(clientSecret);
      } else if (value.status.name == "processing") {
        await checkStripeStatus(clientSecret);
      }
    });
  }

  getCategories() async {
    try {
      loadingcateries.value = true;
      List<dynamic> response = await ShopService().getShopTypes();
      categories.value = response.map((e) => ShopTypes.fromJson(e)).toList();
      loadingcateries.value = false;
    } catch (e) {
      loadingcateries.value = false;
    }
  }

  updateShop(
      {Shop? shop,
      String backup = "",
      String backupemail = "",
      String? location = "",
      String latitude = "",
      bool? allowBackup,
      bool? allowOnlineSelling,
      String longitude = ""}) async {
    try {
      updateShopLoad.value = true;
      if (backup.isNotEmpty ||
          backupemail.isNotEmpty ||
          location != null ||
          allowOnlineSelling != null ||
          allowBackup != null) {
        if (allowOnlineSelling != null) {
          await ShopService().updateShop(
              shop!.id!, {"allowOnlineSelling": allowOnlineSelling});
        }
        if (allowBackup != null) {
          await ShopService()
              .updateShop(shop!.id!, {"allowBackup": allowBackup});
        }
        if (location != "") {
        } else if (backup.isNotEmpty) {
        } else if (backupemail.isNotEmpty) {
        } else {
          await ShopService().updateShop(shop!.id!, {
            "name": nameController.text,
            "backupInterval": selectedbackupsendinterval['name'],
            "currency": currency.value == ""
                ? Constants.currenciesData[0]
                : currency.value,
            "shopCategoryId":
                Get.find<ShopController>().selectedCategory.value?.id,
          });
        }
      } else {
        await ShopService().updateShop(shop!.id!, {
          "name": nameController.text,
          "backupInterval": selectedbackupsendinterval['name'],
          "currency": currency.value == ""
              ? Constants.currenciesData[0]
              : currency.value,
          "shopCategoryId":
              Get.find<ShopController>().selectedCategory.value?.id,
        });
        getShops();
        Get.back();
      }

      showSnackBar(message: "shop updated", color: Colors.green);
      updateShopLoad.value = false;
    } catch (e) {
      updateShopLoad.value = false;
    }
  }

  deleteShopData({required Shop shop}) async {
    try {
      LoadingDialog.showLoadingDialog(
          context: Get.context!, title: "Please wait...", key: _keyLoader);
      await ShopService().deleteDataShop(shop.id!);
      Get.back();
      await authController.initUser();
      await getShops();
      if (userController.currentUser.value?.primaryShop == null) {
        Get.off(() => CreateShop(page: "home"));
      } else {
        Get.back();
      }

      generalAlert(
        title: "Success",
        message: "Data deleted successfully",
        function: () {
          Get.back();
        },
      );
    } catch (e) {
      Get.back();
    }
  }

  deleteShop({required Shop shop}) async {
    LoadingDialog.showLoadingDialog(
        context: Get.context!, title: "Please wait...", key: _keyLoader);
    await ShopService().deleteShop(shop.id!);
    await getShops();
    if (userController.currentUser.value?.primaryShop == null) {
      Get.off(() => CreateShop(page: "home"));
    } else {
      Get.back();
    }

    showSnackBar(message: "shop deleted", color: Colors.green);
  }

  Future<void> getShopsAround() async {
    shopsAroundLoad.value = true;
    shopsAround.value = [];
    double? latitude = 0;
    double? longitude = 0;
    OrderController orderController = Get.find<OrderController>();
    if (orderController.locationData.value != null) {
      latitude = orderController.locationData.value!.latitude;
      longitude = orderController.locationData.value!.longitude;
    }
    var response = await ShopService().getShopsAround(
      categories:
          selectedDiscoverCategories.map((element) => element.id).toList(),
      radius: currentDistance.value,
      lat: latitude,
      lng: longitude,
    );
    shopsAroundLoad.value = false;
    List shops = response;
    shopsAround.value = shops.map((e) => Shop.fromJson(e)).toList();
  }

  void backupNow({required Shop shopModel}) async {
    isBacking.value = true;
    var response = await ShopService().backupNow(shopModel.id!);
    isBacking.value = false;
    generalAlert(
      title: "Backup",
      message: response["message"],
    );
  }

  void redeemUsage({String? shopId, required int days}) async {
    Get.back();
    LoadingDialog.showLoadingDialog(
        context: Get.context!, title: "Please wait...", key: _keyLoader);
    var response = await ShopService().redeemUsage(shopId!, days);
    if (response["error"] != null) {
      Get.back();
      generalAlert(
        title: "Error",
        message: response["error"],
      );
      return;
    }

    await authController.initUser();
    Get.back();
    Get.back();

    Get.find<PaymentController>()
        .getAwardTransactions(userController.currentUser.value!.id!);

    generalAlert(
      title: "Usage",
      message: response["message"],
    );
  }
}
