import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/home/home_page.dart';

import '../../controllers/customercontroller.dart';
import '../../controllers/homecontroller.dart';
import '../../controllers/productcontroller.dart';
import '../../controllers/salescontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../models/salemodel.dart';
import '../../utils/colors.dart';
import '../../widgets/major_title.dart';
import '../../widgets/no_items_found.dart';
import 'components/sales_card.dart';

class CreateSale extends StatelessWidget {
  final String? page;

  CreateSale({Key? key, this.page}) : super(key: key);

  final SalesController salesController = Get.find<SalesController>();
  final ShopController shopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  final CustomerController customersController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvoked: (val) async {
          salesController.receipt.value = null;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.3,
            titleSpacing: 0.0,
            actions: [
              IconButton(
                  onPressed: () {
                    salesController.receipt.value = null;
                  },
                  icon: const Icon(
                    Icons.notification_add,
                    color: AppColors.mainColor,
                  ))
            ],
            leading: IconButton(
                onPressed: () {
                  if (isSmallScreen(context)) {
                    Get.back();
                  } else {
                    Get.find<HomeController>().selectedWidget.value =
                        HomePage();
                  }

                  salesController.receipt.value = null;
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                )),
            title:
                majorTitle(title: "New Sale", color: Colors.black, size: 18.0),
          ),
          body: Obx(
            () => salesController.isUpdating.isTrue
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : salesController.onholdSales.isEmpty
                    ? Center(child: noItemsFound(context, false))
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: salesController.onholdSales.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          SaleModel salesModel =
                              salesController.onholdSales.elementAt(index);
                          return salesCard(salesModel: salesModel);
                        }),
          ),
        ));
  }

  confirmPayment(context, status) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isSmallScreen(context) ? Colors.white : Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            margin: EdgeInsets.only(
                left: isSmallScreen(context)
                    ? 0
                    : MediaQuery.of(context).size.width * 0.2),
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  majorTitle(
                      title:
                          "Total Amount ${htmlPrice(salesController.receipt.value?.totalWithDiscount)}",
                      color: Colors.black,
                      size: 14.0),
                  const SizedBox(height: 10),
                  majorTitle(
                      title: "Amount paid", color: Colors.black, size: 14.0),
                  const SizedBox(height: 10),
                  TextFormField(
                      controller: salesController.amountPaid,
                      onChanged: (value) {
                        salesController.getTotalCredit();
                        salesController.receipt.refresh();
                      },
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefix: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(userController
                                .currentUser.value!.primaryShop!.currency!),
                          ))),
                  const SizedBox(height: 10),
                  Obx(
                    () => majorTitle(
                        title:
                            "${salesController.changeText.value} ${htmlPrice(salesController.change.value)}",
                        color: Colors.black,
                        size: 14.0),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            Get.back();
                          },
                          child: majorTitle(
                              title: "Cancel",
                              color: AppColors.mainColor,
                              size: 16.0)),
                      TextButton(
                          onPressed: () {
                            salesController.saveSale(
                                screen: page ?? "admin", status: status);
                          },
                          child: majorTitle(
                              title: "Confirm payment",
                              color: AppColors.mainColor,
                              size: 16.0)),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
