import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/customercontroller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/utils/helper.dart';
import 'package:reggypos/widgets/minor_title.dart';
import 'package:reggypos/widgets/textbutton.dart';

import '../controllers/salescontroller.dart';
import '../models/customer.dart';
import '../screens/customers/customer_info_page.dart';
import '../utils/colors.dart';
import 'major_title.dart';

Widget customerWidget(
    {required Customer customerModel,
    required context,
    String? type,
    Function? function}) {
  return InkWell(
    onTap: () async {
      Get.find<CustomerController>().currentCustomer.value = customerModel;
      if (function != null) {
        function(customerModel);
      }
      if (await isConnected()) {
        Get.to(() => CustomerInfoPage());
      }
    },
    child: Card(
        child: Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_outline,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      majorTitle(
                          title: "Name: ${customerModel.name}",
                          color: Colors.black,
                          size: 15.0),
                      const SizedBox(
                        height: 10,
                      ),
                      if (customerModel.totalDebt! > 0 &&
                          customerModel.wallet! > 0)
                        minorTitle(
                            title: "Due: ${htmlPrice(customerModel.totalDebt)}",
                            color: Colors.red),
                      const SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          type == "sale"
              ? textBtn(onPressed: () {
                  Get.back();
                  Get.find<SalesController>().receipt.value?.customerId =
                      customerModel;
                  Get.find<SalesController>().currentCustomer.value =
                      customerModel;
                  Get.find<SalesController>().selectedCustomerController.text =
                      customerModel.name!;

                  Get.find<SalesController>().receipt.refresh();
                  if (function != null) {
                    function(customerModel);
                  }
                })
              : Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.find<CustomerController>().currentCustomer.value =
                            customerModel;
                        if (function != null) {
                          function(customerModel);
                        }
                        Get.to(() => CustomerInfoPage());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: (BorderRadius.circular(10)),
                            border: Border.all(
                                color: AppColors.mainColor, width: 1)),
                        child: majorTitle(
                            title: "View Account",
                            color: AppColors.mainColor,
                            size: 12.0),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (customerModel.wallet != null &&
                        customerModel.wallet! < 0)
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: minorTitle(
                            title:
                                "Unpaid ${htmlPrice(customerModel.wallet!.abs() + customerModel.totalDebt!)}",
                            color: Colors.red),
                      )
                  ],
                )
        ],
      ),
    )),
  );
}
