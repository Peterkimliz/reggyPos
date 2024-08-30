import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/authcontroller.dart';
import 'package:reggypos/controllers/homecontroller.dart';
import 'package:reggypos/controllers/shopcontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/shop/shop_address.dart';
import 'package:reggypos/screens/shop/shop_cagories.dart';
import 'package:reggypos/screens/shop/shops_page.dart';
import 'package:reggypos/utils/constants.dart';
import 'package:reggypos/widgets/alert.dart';

import '../../models/shop.dart';
import '../../models/shoptype.dart';
import '../../services/place_service.dart';
import '../../services/shop_services.dart';
import '../../utils/colors.dart';
import '../../utils/themer.dart';
import '../../widgets/major_title.dart';
import '../../widgets/shop_widget.dart';

class EditShopDetails extends StatelessWidget {
  final Shop shopModel;

  EditShopDetails({Key? key, required this.shopModel}) : super(key: key) {
    shopController.nameController.text = shopModel.name ?? "";
    shopController.businessController.text =
        shopModel.shopCategoryId?.name ?? "";
    shopController.businessController.text =
        shopModel.shopCategoryId?.name ?? "";
    shopController.reqionController.text = shopModel.location ?? "";
    shopController.currencyController.text = shopModel.currency ?? "";
    shopController.selectedCategory.value = shopModel.shopCategoryId;
    shopController.currency.value = shopModel.currency ?? "";
    shopController.allownegativesales.value =
        shopModel.allownegativeselling ?? false;
  }

  final ShopController shopController = Get.find<ShopController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.3,
        leading: IconButton(
          onPressed: () {
            if (isSmallScreen(context)) {
              Get.back();
            } else {
              Get.find<HomeController>().selectedWidget.value = ShopsPage();
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          if (!isSmallScreen(context))
            InkWell(
              onTap: () {
                shopController.updateShop(shop: shopModel);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10)
                    .copyWith(right: 10),
                height: kTextTabBarHeight * 0.5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.mainColor),
                    borderRadius: BorderRadius.circular(5)),
                child: const Text(
                  "Update Shop",
                  style: TextStyle(
                    color: AppColors.mainColor,
                  ),
                ),
              ),
            )
        ],
        title: majorTitle(
            title: "${shopModel.name}", color: Colors.black, size: 16.0),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              shopWidget(
                  controller: shopController.nameController, name: "Shop Name"),
              const SizedBox(height: 10),
              const Text(
                "Business Type",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  if (isSmallScreen(context)) {
                    Get.to(() => ShopCategories(
                          shopModel: shopModel,
                          page: "details",
                          selectedItemsCallback: (ShopTypes s) async {
                            Get.back();
                            shopController.selectedCategory.value = s;
                            shopController.selectedCategory.refresh();
                            await shopController.updateShop(shop: shopModel);
                          },
                        ));
                  } else {
                    Get.find<HomeController>().selectedWidget.value =
                        ShopCategories(
                      shopModel: shopModel,
                      page: "details",
                      selectedItemsCallback: (ShopTypes s) async {
                        Get.find<HomeController>().selectedWidget.value =
                            EditShopDetails(shopModel: shopModel);
                        shopController.selectedCategory.value = s;
                        shopController.selectedCategory.refresh();
                        await shopController.updateShop(shop: shopModel);
                      },
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ), // Set border width
                    borderRadius: const BorderRadius.all(Radius.circular(
                        10.0)), // Set rounded Make rounded corner of border
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text(shopController.selectedCategory.value == null
                            ? ""
                            : shopController.selectedCategory.value!.name!),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              majorTitle(
                  title: "Where is your shop located",
                  color: Colors.black,
                  size: 16.0),
              const SizedBox(height: 10),
              TextFormField(
                controller: shopController.reqionController,
                readOnly: true,
                onTap: () async {
                  // generate a new token here
                  final Suggestion? result = await showSearch(
                    context: context,
                    delegate: AddressSearch("sessionToken"),
                  );
                  if (result != null) {
                    shopController.reqionController.text = result.description;
                    locationFromAddress(result.description).then((value) {
                      shopController.latitude.text =
                          value.first.latitude.toString();
                      shopController.longitude.text =
                          value.first.longitude.toString();
                    });
                  }
                },
                decoration: ThemeHelper().textInputDecorationDesktop(
                    // 'Shop Address',
                    // 'Enter your shop address',
                    ),
              ),
              const SizedBox(height: 20.0),
              Card(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Allow Negative Selling?",
                            style: TextStyle(color: Colors.black, fontSize: 13),
                          ),
                          Obx(
                            () => CupertinoSwitch(
                              value: shopController.allownegativesales.value,
                              activeColor: AppColors.mainColor,
                              onChanged: (value) {
                                generalAlert(
                                  title: "Are you sure?",
                                  message: value == false
                                      ? "Switching off negative selling, you cannot sell items with negative stock"
                                      : "By allowing negative sales, you can sell items with negative stock",
                                  function: () async {
                                    shopModel.allownegativeselling = value;
                                    shopController.allownegativesales.value =
                                        value;

                                    await ShopService()
                                        .updateShop(shopModel.id!, {
                                      "allownegativeselling": shopController
                                          .allownegativesales.value,
                                    });

                                    var response = await ShopService.getShop(
                                        shopModel.id!);
                                    userController.currentUser.value
                                        ?.primaryShop = Shop.fromJson(response);
                                    userController.currentUser.refresh();
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Only allow this feature if you know what you are doing",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              majorTitle(title: "Currency", color: Colors.black, size: 16.0),
              const SizedBox(height: 5),
              Card(
                elevation: 1,
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            children: List.generate(
                                Constants.currenciesData.length,
                                (index) => SimpleDialogOption(
                                      onPressed: () {
                                        shopController.currency.value =
                                            Constants.currenciesData
                                                .elementAt(index);

                                        Navigator.pop(context);
                                      },
                                      child: Text(Constants.currenciesData
                                          .elementAt(index)),
                                    )),
                          );
                        });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Obx(() {
                          return Text(shopController.currency.value,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12.0));
                        }),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Obx(() {
                return shopController.updateShopLoad.isTrue ||
                        shopController.deleteShopLoad.isTrue
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          await shopController.updateShop(shop: shopModel);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: 3, color: AppColors.mainColor),
                              borderRadius: BorderRadius.circular(40)),
                          child: Center(
                              child: majorTitle(
                                  title: "Update Shop",
                                  color: AppColors.mainColor,
                                  size: 18.0)),
                        ),
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}
