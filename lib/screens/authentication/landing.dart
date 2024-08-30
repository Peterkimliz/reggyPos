import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/authcontroller.dart';
import 'package:reggypos/controllers/shopcontroller.dart';
import 'package:reggypos/controllers/usercontroller.dart';

import '../../services/dynamic_link_services.dart';
import '../../services/user.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/textbutton.dart';
import '../discover/shop_tags.dart';
import 'admin/admin_login.dart';
import 'attendant/attendant_login.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();
  ShopController shopController = Get.find<ShopController>();
  var loading = true;

  Future<void> loadTasks() async {
    await authController.initUser();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks();

    User().getSettings().then((value) async {
      if (value == null) {
        return;
      }
      settingsData = value;
      if (settingsData['offlineEnabled'] == false) {
        userController.enableOffline.value = false;
      } else {
        userController.enableOffline.value = true;
      }
    });
    DynamicLinkService().handleDynamicLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        landingContent(),
        const SizedBox(
          height: 50,
        ),
        loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30),
                    child: InkWell(
                      onTap: () {
                        Get.to(AdminLogin());
                      },
                      child: customButton(
                          onTap: () {
                            Get.to(AdminLogin());
                          },
                          color: Colors.white,
                          title: "Business Owner",
                          textColor: AppColors.mainColor,
                          icon: Icons.person),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30),
                    child: InkWell(
                      onTap: () {
                        Get.to(AttendantLogin());
                      },
                      child: customButton(
                          onTap: () {
                            Get.to(AttendantLogin());
                          },
                          color: AppColors.mainColor,
                          title: "Attendant",
                          textColor: Colors.white,
                          icon: Icons.people_alt_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Or",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, right: 30),
                    child: InkWell(
                      onTap: () {
                        Get.to(AdminLogin());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          textBtn(
                              onPressed: () {
                                shopController.selectedDiscoverCategories
                                    .clear();
                                Get.to(() => ShopTags());
                              },
                              color: AppColors.mainColor,
                              text: "Shop Around you",
                              bgColor: Colors.transparent,
                              fontSize: 12),
                          const Icon(Icons.location_on,
                              color: AppColors.mainColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
        const Spacer(),
      ],
    ));
  }

  Widget landingImage() {
    return Container();
  }

  Widget landingContent() {
    return Column(
      children: [
        Image.asset(
          "assets/images/logo.png",
          width: 250,
          height: 100,
        ),
        loading ? const Text("") : const Text("An enterprise in your hands."),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget customButton(
      {required onTap,
      required Color color,
      required title,
      required Color textColor,
      required icon,
      double fontSize = 17}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
        },
        hoverColor: Colors.transparent,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 2 / 3,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: AppColors.mainColor, width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: textColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$title".toUpperCase(),
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize),
                  )
                ]),
          ),
        ),
      ),
    );
  }
}
