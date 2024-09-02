import 'dart:async';
import 'dart:io' show Platform;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reggypos/controllers/customercontroller.dart';
import 'package:reggypos/controllers/productcontroller.dart';
import 'package:reggypos/controllers/salescontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/screens/authentication/admin/admin_login.dart';
import 'package:reggypos/screens/authentication/landing.dart';
import 'package:reggypos/screens/home/home.dart';
import 'package:url_launcher/url_launcher.dart';

import '../functions/functions.dart';
import '../models/usermodel.dart';
import '../responsive/responsiveness.dart';
import '../screens/authentication/verify_email.dart';
import '../screens/home/home_page.dart';
import '../screens/shop/create_shop.dart';
import '../services/authentication.dart';
import '../services/user.dart';
import '../sqlite/helper.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';
import '../widgets/alert.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/snackbars.dart';
import 'expensecontroller.dart';

class AuthController {
  RxBool signuserLoad = RxBool(false);
  GlobalKey<FormState> signupkey = GlobalKey();
  GlobalKey<FormState> loginKey = GlobalKey();
  RxBool showPassword = true.obs;
  RxBool resetPassword = RxBool(false);
  RxBool loginuserLoad = RxBool(false);
  GlobalKey<FormState> adminresetPassWordFormKey = GlobalKey();
  Rxn<CountryCode> selectedCountry = Rxn(CountryCode.fromCountryCode("KE"));

  TextEditingController attendantUidController = TextEditingController();
  TextEditingController attendantPasswordController = TextEditingController();
  RxBool showingUpdateAlert = RxBool(false);
  RxBool loginAttendantLoad = RxBool(false);
  GlobalKey<FormState> loginAttendantKey = GlobalKey();
  FlutterSecureStorage storage = const FlutterSecureStorage();
  TextEditingController passwordControllerConfirm = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController referalController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();

  getToken() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    return await storage.read(key: 'user_token');
  }

  initUser({String type = ""}) async {
    bool connected = await isConnected();
    try {
      if (connected) {
        if ((await storage.read(key: 'id')) == null) return;
        userController.currentUserId.value = (await storage.read(key: 'id'))!;
        if (userController.currentUserId.value.isEmpty) logOut();
        var usertype = await storage.read(key: 'user_type');
        Map<String,dynamic> response;
        if (usertype == "admin") {
          response =
              await Authentication.getAdmin(userController.currentUserId.value);
          if (response["error"] != null) {
            logOut();
          }
          response["usertype"] = usertype;

          DatabaseHelper().insertUser(response);
          userController.currentUser.value = UserModel.fromJson(response);
        } else if (usertype == "attendant") {
          var response = await Authentication.getAttendant(
              userController.currentUserId.value);
          if (response["error"] != null) {
            logOut();
          }
          response["usertype"] = usertype;
          userController.currentUser.value = UserModel.fromJson(response);
          userController.getRoles(userController.currentUser.value!);
        }
      } else {
        String id = await storage.read(key: 'id') ?? "";
        if (id.isEmpty) return;
        final dbHelper = DatabaseHelper();
        final user = await dbHelper.getUserByEmail(id: id);
        if (user != null) {
          user['primaryShop']['_id'] = user['primaryShop']['id'];
          user['attendantId']['_id'] = user['attendantId']['id'];
          user['_id'] = user['id'];
          userController.currentUser.value = UserModel.fromJson(user);
        } else {
          await logOut();
          return;
        }
      }

      var user = userController.currentUser.value;
      if (user != null) {
        if (user.usertype == "attendant") {
          Get.off(() => HomePage());
        } else {
          final DateTime now = DateTime.now();
          int days = DateTime.parse(
                  userController.currentUser.value!.emailVerificationDate!)
              .difference(DateTime(now.year, now.month, now.day))
              .inDays;
          if (days <= 0 &&
              userController.currentUser.value!.emailVerified == false) {
            Get.off(() => EmailVerificationPage());
            return;
          }
          if (userController.currentUser.value?.primaryShop != null) {
            if (type == "auth") {
              Get.offAll(() => const Home());
            } else {
              Get.off(() => const Home());
            }
          } else {
            Get.off(() => CreateShop(page: "reg"));
          }
        }
      }
    } catch (e) {
      debugPrintMessage(e);
      await logOut();
    } finally {
      if (await isConnected()) {
        if (userController.currentUser.value != null &&
            userController.currentUser.value!.primaryShop != null) {
          Get.find<SalesController>().getSalesByDate(
              type: "today",
              shop: userController.currentUser.value!.primaryShop!.id!);
          Get.find<SalesController>().getNetAnalysis(
              fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              type: "today",
              shopId: userController.currentUser.value!.primaryShop!.id!);

          Get.find<ExpenseController>().getExpenses(
            fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            shop: userController.currentUser.value?.primaryShop!.id!,
          );
          checkForUpdate();
          User().updateLastSeen();
        }
      }

      Get.find<ProductController>().getProductsBySort(type: "all");
      Get.find<CustomerController>().getCustomersInShop('');

      //ask user to rate the app
      rateApp();
    }
  }

  rateApp() async {
    try {
      if (userController.currentUser.value == null) {
        return;
      }
      //check last time this prompt was shown if its greater less than 7 days then break
      if (userController.currentUser.value!.lastAppRatingDate != null) {
        final DateTime now = DateTime.now();
        int days =
            DateTime.parse(userController.currentUser.value!.lastAppRatingDate!)
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;
        if (days <= 7) {
          return;
        }
      }

      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        // The review dialog can be displayed
        await inAppReview.requestReview();
      } else {
        // Optionally, you can redirect the user to the app store page
        await inAppReview.openStoreListing(appStoreId: appstoreId);
      }
      if (userController.currentUser.value!.usertype == "admin") {
        userController.profileUpdate(
            lastAppRatingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()));
      } else {
        userController.updateAttendant(
            userModel: UserModel(
              id: userController.currentUser.value!.id,
            ),
            type: "other",
            lastAppRatingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()));
      }
    } catch (e) {
      debugPrintMessage(e);
    }
  }



  Future<void> checkForUpdate({String? app}) async {
    User().getSettings().then((value) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      settingsData = value;
      if (Platform.isAndroid) {
        String latestVersion = value['android_version'];
        String buildNumber = packageInfo.buildNumber;
        if (latestVersion.compareTo(buildNumber) > 0 &&
            showingUpdateAlert.isFalse) {
          showingUpdateAlert.value = true;
          showUpdateAlert(value['forceUpdate']);
        }
      } else if (Platform.isIOS) {
        String latestVersion = value['ios_version'];
        String buildNumber = packageInfo.buildNumber;
        if (latestVersion.compareTo(buildNumber) > 0 &&
            showingUpdateAlert.isFalse) {
          showingUpdateAlert.value = true;
          showUpdateAlert(value['forceUpdate']);
        }
      }
    });
  }

  void showUpdateAlert(bool forceUpdate) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: const Text(
              'ReggyPos has new updated features, please update to get the most out of it.'),
          actions: [
            if (forceUpdate == false)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showingUpdateAlert.value = false;
                },
                child: const Text('Not Now'),
              ),
            TextButton(
              onPressed: () {
                launchStore();
                Navigator.of(context).pop();
                showingUpdateAlert.value = false;
              },
              child: const Text('Update Now'),
            ),
          ],
        );
      },
    );
  }

  void launchStore() async {
    String appPackageName = '';
    if (Platform.isAndroid) {
      appPackageName = androidLink;
    } else if (Platform.isIOS) {
      appPackageName = iosLink;
    }

    if (await canLaunchUrl(Uri.parse(appPackageName))) {
      await launchUrl(Uri.parse(appPackageName));
    }
  }

  attendantLogin(context) async {
    if (attendantPasswordController.text.isEmpty ||
        attendantUidController.text.isEmpty) {
      generalAlert(title: "Error", message: "Enter user id");
      return;
    }
    try {
      loginAttendantLoad.value = true;
      var password = attendantPasswordController.text;
      var uid = attendantUidController.text;
      var response =
          await Authentication.loginAttendant(uid: uid, password: password);
      if (response["error"] != null) {
        loginAttendantLoad.value = false;
        generalAlert(title: "Error", message: response["error"]);
        return;
      }

      userController.currentUser.value =
          UserModel.fromJson(response["userdata"]);
      await storage.write(key: 'user_token', value: response["token"]);
      await storage.write(key: 'user_type', value: "attendant");
      await storage.write(
          key: 'id', value: userController.currentUser.value?.id);
      userController.currentUser.refresh();

      await initUser();
      loginuserLoad.value = false;
      loginAttendantLoad.value = false;
    } catch (e) {
      loginAttendantLoad.value = false;
      generalAlert(title: "Error", message: "UID supplied does not exist");
    }
  }

  getReferer() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    return await storage.read(key: 'refer') ?? "";
  }

  registerAdmin(context) async {
    if (nameController.text == "" ||
        emailController.text == "" ||
        phoneController.text == "") {
      generalAlert(title: "Error", message: "Fill all required fields");
      return;
    }
    try {
      if (passwordController.text.toString().trim().length < 6) {
        generalAlert(
            title: "Error", message: "Password must be more than 6 characters");
        return;
      }
      signuserLoad.value = true;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String buildNumber = packageInfo.buildNumber;
      var response = {
        "email": emailController.text,
        "password": passwordController.text,
        "username": nameController.text,
        "phone": selectedCountry.value!.dialCode! + phoneController.text,
        "platform": Platform.isIOS ? "ios" : "android",
        "app_version": buildNumber,
        "referal": await getReferer(),
        "affliate": referalController.text,
      };
      var adminResponse = await Authentication.registerAdmin(response);

      if (adminResponse["status"] == false) {
        signuserLoad.value = false;
        showSnackBar(message: adminResponse["error"], color: Colors.red);
        return;
      }
      userController.currentUser.value =
          UserModel.fromJson(adminResponse["userdata"]);

      await storage.write(key: 'user_token', value: adminResponse["token"]);
      await storage.write(key: 'user_type', value: "admin");
      await storage.write(
          key: 'id', value: userController.currentUser.value?.id);
      userController.currentUser.refresh();
      await initUser();

      clearDataFromTextFields();
      if (userController.currentUser.value?.primaryShop == null) {
        if (isSmallScreen(context)) {
          Get.off(() => CreateShop(
                page: "home",
                clearInputs: true,
              ));
        } else {
          Get.off(() => CreateShop(page: "home", clearInputs: true));
        }
      }

      signuserLoad.value = false;
    } catch (e) {
      showSnackBar(
          message: "error creating account, try another email",
          color: Colors.red);
      signuserLoad.value = false;
    }
  }



  Future<void> logOut() async {
    String id = userController.currentUserId.value;
    await storage.deleteAll();
    userController.currentUser.value = null;
    userController.currentUserId.value = "";
    loginKey.currentState?.reset();
    Get.offAll(() => const Landing());
    await storage.write(key: 'sqlite_db_key', value: id);
  }

  validateEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> resetPasswordEmail(
      {required String email, required String password, required type}) async {
    resetPassword.value = false;
    LoadingDialog.showLoadingDialog(
        context: Get.context!, title: "Please wait", key: _keyLoader);
    var response = await Authentication.requestPasswordReset(
      emailController.text,
    );
    Get.back();
    if (response["error"] != null) {
      generalAlert(message: response["error"]);
      return;
    }
    resetPassword.value = true;
  }

  Future<void> resetPasswordOtp() async {
    if (passwordController.text != passwordControllerConfirm.text) {
      generalAlert(message: "Password does not match");
      return;
    }
    if (otpController.text.isEmpty) {
      generalAlert(message: "Please enter OTP");
      return;
    }
    LoadingDialog.showLoadingDialog(
        context: Get.context!, title: "Please wait", key: _keyLoader);
    var response = await Authentication.passwordReset(
      emailController.text,
      otpController.text,
      passwordController.text,
    );
    Get.back();
    if (response["error"] != null) {
      generalAlert(message: response["error"], title: "Error");
      return;
    }
    resetPassword.value = false;
    Get.to(() => AdminLogin());
  }

  login(context, {String type = ""}) async {
    if (emailController.text == "" || passwordController.text == "") {
      generalAlert(title: "Error", message: "Please enter email and password");
      return;
    }
    loginuserLoad.value = true;
    bool connected = await isConnected();
    Map<String,dynamic> response;

    // Handle offline login

    if (connected) {
      response = await Authentication.login(
          type: "admin",
          email: emailController.text,
          password: passwordController.text);

      if (response["error"] != null) {
        loginuserLoad.value = false;
        showSnackBar(message: response["error"], color: Colors.red);
        return;
      }
      userController.currentUserId.value = response["userdata"]['_id'];
      DatabaseHelper dbHelper = DatabaseHelper();
      response["userdata"]['usertype'] = 'admin';
      dbHelper.insertUser(response["userdata"]);

      await storage.write(key: 'user_token', value: response["token"]);
      await storage.write(key: 'user_type', value: "admin");
      await storage.write(key: 'id', value: response["userdata"]['_id']);
      await initUser(type: type);
    } else {
      DatabaseHelper dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmail(email: emailController.text);
      if (user != null) {
        await storage.write(key: 'user_type', value: "admin");
        await storage.write(key: 'id', value: user['id']);
        userController.currentUserId.value = user['id'];
        await initUser(type: type);
      } else {
        showSnackBar(
            message: "no user with that email and password", color: Colors.red);
      }
    }
    loginuserLoad.value = false;
    clearDataFromTextFields();
  }

  clearDataFromTextFields() {
    nameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
  }
}
