import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/salescontroller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';

import '../../../controllers/ordercontroller.dart';
import '../../../utils/colors.dart';
import '../../../utils/themer.dart';

class OrderPreview extends StatelessWidget {
  OrderPreview({super.key});

  final OrderController orderController = Get.find<OrderController>();
  final SalesController salesController = Get.find<SalesController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Order Preview",
              style: TextStyle(
                color: Colors.black,
              )),
          leading: IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                Get.back();
              })),
      body: ListView(
        children: [
          DottedBorder(
              borderPadding: const EdgeInsets.all(10),
              radius: const Radius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  children: [
                    const Text(
                      "Total Cost",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(htmlPrice(
                        salesController.receipt.value?.totalWithDiscount)),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 30, left: 30),
                        decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                              )
                            ]),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Edit Order",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Text(
                                salesController.receipt.value?.items?.length
                                        .toString() ??
                                    "0",
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Obx(
                  () => Row(
                    children: [
                      const Text(
                        "Payment Method : ",
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.mainColor),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          "${orderController.currentOrderMethod['value']}",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              children: List.generate(
                                  orderController.orderMethods.length,
                                  (index) => SimpleDialogOption(
                                        onPressed: () {
                                          orderController
                                                  .currentOrderMethod.value =
                                              orderController
                                                  .orderMethods[index];
                                          Get.back();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text(
                                            "${orderController.orderMethods[index]['value']}",
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      )),
                            );
                          });
                    },
                    child: const Text("Change",
                        style: TextStyle(color: Colors.red)))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          DottedBorder(
              borderPadding: const EdgeInsets.all(10),
              radius: const Radius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Column(
                  children: [
                    const Text(
                      "Contact Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (userController.currentUser.value == null)
                      Column(
                        children: [
                          Text(orderController.currentCustomer.value == null
                              ? orderController.nameController.text
                              : orderController.currentCustomer.value!.name!),
                          Text(orderController.currentCustomer.value == null
                              ? orderController.emailController.text
                              : orderController.currentCustomer.value!.email!),
                          Text(orderController.currentCustomer.value == null
                              ? orderController.phoneController.text
                              : orderController
                                  .currentCustomer.value!.phoneNumber!),
                        ],
                      ),
                    if (userController.currentUser.value != null)
                      Center(
                        child: Column(
                          children: [
                            Text(userController.currentUser.value!.username!),
                            Text(userController.currentUser.value!.email!),
                          ],
                        ),
                      ),
                  ],
                ),
              )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                Obx(
                  () => orderController.creatingorder.isTrue
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          style: ThemeHelper().buttonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                            child: Text(
                              "Place the order",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onPressed: () {
                            orderController.placeOrder();
                          },
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
