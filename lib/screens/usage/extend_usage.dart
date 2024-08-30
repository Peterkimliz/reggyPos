import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/widgets/minor_title.dart';
import 'package:reggypos/widgets/shop_list_bottomsheet.dart';

import '../../controllers/plancontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../functions/functions.dart';
import '../../models/package.dart';
import '../../models/shop.dart';
import '../../widgets/major_title.dart';
import 'ShopsRenew.dart';

class ExtendUsage extends StatelessWidget {
  final Shop? shop;
  ExtendUsage({
    Key? key,
    this.shop,
  }) : super(key: key) {
    userController.phoneController.text =
        userController.currentUser.value!.phone ?? "";
    planController.getPlans();
  }

  final ShopController shopController = Get.find<ShopController>();
  final PlanController planController = Get.find<PlanController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.clear,
              color: AppColors.mainColor,
            )),
        title: const Text(
          "Extend usage",
          style: TextStyle(color: AppColors.mainColor),
        ),
      ),
      body: Column(
        children: [
          shop != null
              ? Column(
                  children: [
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: Text(
                            "Extend Usage for ${shop!.name} for you to be able to switch to this shop.",
                            style: const TextStyle(
                              fontSize: 20,
                            ))),
                    const Divider(
                      thickness: 2,
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      majorTitle(
                          title: "Current Shop",
                          color: Colors.black,
                          size: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            return minorTitle(
                                title: userController
                                            .currentUser.value!.primaryShop ==
                                        null
                                    ? ""
                                    : userController
                                        .currentUser.value!.primaryShop!.name,
                                color: AppColors.mainColor);
                          }),
                          Obx(
                            () => InkWell(
                              onTap: shopController.gettingShopsLoad.isTrue
                                  ? null
                                  : () async {
                                      await shopController.getShops();
                                      showShopModalBottomSheet(Get.context);
                                    },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: AppColors.mainColor, width: 2),
                                ),
                                child: minorTitle(
                                    title: "Switch Shop",
                                    color: AppColors.mainColor),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
          Expanded(
            child: Obx(
              () => planController.isLoadingPackages.isTrue
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: planController.plans.length,
                      itemBuilder: (BuildContext c, int i) {
                        Package plan = planController.plans[i];
                        return _usageCard(plan, context);
                      }),
            ),
          )
        ],
      ),
    );
  }

  _usageCard(Package plan, context) {
    return Obx(
      () => InkWell(
        onTap: (shopController.isCurrentPackage(plan) &&
                shopController.checkDaysRemaining(shop: shop) > 0)
            ? null
            : () {
                shopController.shopsRenew.clear();
                shopController.getShops();
                Get.to(() => ShopsToRenew(plan: plan, shop: shop));
              },
        child: Container(
          padding:
              const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
          decoration: BoxDecoration(
            color: shopController.isCurrentPackage(plan) &&
                    shopController.checkDaysRemaining(shop: shop) > 0
                ? Colors.green
                : Colors.transparent,
            border: const Border(
              bottom: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    majorTitle(
                        title: "${plan.title}",
                        color: Colors.black,
                        size: 18.0),
                    Row(
                      children: [
                        Text(
                          userController.currentUser.value?.primaryShop!
                                      .currency !=
                                  "KES"
                              ? "USD"
                              : "@ ${htmlPrice('')}",
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.mainColor),
                        ),
                        if (plan.discount! == 0)
                          Text(
                            userController.currentUser.value?.primaryShop!
                                        .currency !=
                                    "KES"
                                ? "${plan.amountusd}"
                                : plan.amount!.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                color: AppColors.mainColor),
                          ),
                        if (plan.discount! > 0 &&
                            userController
                                    .currentUser.value?.primaryShop!.currency !=
                                "KES")
                          Text(
                            userController.currentUser.value?.primaryShop!
                                        .currency !=
                                    "KES"
                                ? "${plan.amountusd}"
                                : plan.amount!.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                color: AppColors.mainColor),
                          ),
                        if (plan.discount! > 0 &&
                            userController
                                    .currentUser.value?.primaryShop!.currency ==
                                "KES")
                          Row(
                            children: [
                              Text(
                                "${plan.amount} ~ ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough),
                              ),
                              Text(
                                "${plan.discount}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23,
                                    color: AppColors.mainColor),
                              ),
                            ],
                          ),
                      ],
                    ),
                    plan.features!.isNotEmpty
                        ? Wrap(
                            children: List.generate(
                                plan.features!.length,
                                (index) => minorTitle(
                                    title: "${plan.features?[index]}",
                                    color: Colors.black,
                                    size: 12.0)).toList(),
                          )
                        : Text(plan.description!),
                    if (shopController.isCurrentPackage(plan) &&
                        shopController.checkDaysRemaining(shop: shop) > 0)
                      Text(
                        "${shopController.checkDaysRemaining(shop: shop)} days remaining",
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              if (plan.type != "free")
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: shopController.isCurrentPackage(plan) &&
                            shopController.checkDaysRemaining(shop: shop) > 0
                        ? AppColors.lightDeepPurple
                        : AppColors.mainColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: minorTitle(
                      title: shopController.isCurrentPackage(plan) &&
                              shopController.checkDaysRemaining(shop: shop) > 0
                          ? "Active"
                          : "Subscribe",
                      color: shopController.isCurrentPackage(plan) &&
                              shopController.checkDaysRemaining(shop: shop) > 0
                          ? Colors.white
                          : Colors.white),
                )
            ],
          ),
        ),
      ),
    );
  }
}
