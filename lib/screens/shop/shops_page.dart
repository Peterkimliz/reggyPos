import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/shopcontroller.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/widgets/alert.dart';

import '../../controllers/authcontroller.dart';
import '../../models/shop.dart';
import '../../utils/colors.dart';
import '../../widgets/minor_title.dart';
import '../../widgets/no_items_found.dart';
import '../../widgets/shop_card.dart';
import 'create_shop.dart';

class ShopsPage extends StatelessWidget {
  final ShopController shopController = Get.find<ShopController>();
  final AuthController authController = Get.find<AuthController>();

  ShopsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: createShopContainer(context),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: searchWidget(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          return shopController.gettingShopsLoad.value
              ? loadingWidget(context)
              : shopController.allShops.isEmpty
                  ? noItemsFound(context, true)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shopController.allShops.length,
                      itemBuilder: (context, index) {
                        Shop shopModel =
                            shopController.allShops.elementAt(index);
                        return shopCard(
                            shopModel: shopModel,
                            page: "shop",
                            context: context);
                      });
        })
      ],
    )));
  }

  Widget createShopContainer(context) {
    return InkWell(
      onTap: () {
        if (shopController.allShops.length > 1 &&
            shopController.allShops
                .where((element) =>
                    shopController.checkDaysRemaining(shop: element) > 0)
                .isEmpty) {
          generalAlert(
            title: "Error",
            message:
                "You have more than 1 shops and non of them has active subscription, please upgrade at least one shop to continue creating more shops",
          );
          return;
        }
        Get.to(CreateShop(
          page: "shop",
          clearInputs: true,
        ));
      },
      child: Container(
          padding: isSmallScreen(context)
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSmallScreen(context) ? Colors.white : AppColors.mainColor,
            borderRadius: isSmallScreen(context)
                ? BorderRadius.circular(10)
                : BorderRadius.circular(8),
            border: Border.all(color: AppColors.mainColor, width: 2),
          ),
          child: minorTitle(
              title: "+ Add Shop",
              color:
                  isSmallScreen(context) ? AppColors.mainColor : Colors.white)),
    );
  }

  Widget searchWidget() {
    return TextFormField(
      controller: shopController.searchController,
      onChanged: (value) {
        shopController.getShops(name: value.trim().toLowerCase());
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        suffixIcon: IconButton(
          onPressed: () {
            shopController.getShops(
                name:
                    shopController.searchController.text.trim().toLowerCase());
          },
          icon: const Icon(Icons.search),
        ),
        hintText: "Search Shop",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              10,
            ),
            borderSide: const BorderSide(color: Colors.grey, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1)),
      ),
    );
  }

  Widget loadingWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
