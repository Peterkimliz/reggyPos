import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/ordercontroller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/saleitem.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/discover/orders/order_preview.dart';
import 'package:reggypos/widgets/alert.dart';

import '../../../controllers/customercontroller.dart';
import '../../../controllers/homecontroller.dart';
import '../../../controllers/productcontroller.dart';
import '../../../controllers/salescontroller.dart';
import '../../../controllers/shopcontroller.dart';
import '../../../models/product.dart';
import '../../../models/shop.dart';
import '../../../utils/colors.dart';
import '../../../widgets/major_title.dart';
import '../../product/products_screen.dart';
import '../../sales/components/sales_container.dart';
import '../customer_signup.dart';

class CreateOrder extends StatelessWidget {
  final String? page;
  final Shop? shop;

  CreateOrder({Key? key, this.page, this.shop}) : super(key: key) {
    if (shop != null) {
      orderController.currentShop.value = shop;
    }
  }

  final SalesController salesController = Get.find<SalesController>();
  final OrderController orderController = Get.find<OrderController>();
  final ShopController shopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  final CustomerController customersController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (val, Object? result) {
          salesController.receipt.value = null;
        },
        child: Obx(
          () => Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.back();
                            salesController.receipt.value = null;
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.mainColor,
                          )),
                      Text(
                        "Order Items from\n${shop!.name!.capitalizeFirst}",
                        style: const TextStyle(
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Material(
                          elevation: 1,
                          child: Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          productController.getProductsBySort(
                                              type: "all",
                                              shop: shop!.id ?? "");
                                          Get.to(() => ProductsScreen(
                                              type: "sale",
                                              function: (Product product) {
                                                salesController
                                                    .addToCart(product);
                                              }));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              5, 10, 5, 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: AppColors.lightDeepPurple),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Search ${salesController.receipt.value != null ? "more items" : "items to buy"}",
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                              const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 18,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            return salesController.receipt.value == null
                                ? InkWell(
                                    onTap: () {
                                      productController.getProductsBySort(
                                        type: "all",
                                        shop: shop!.id ?? "",
                                      );
                                      if (isSmallScreen(context)) {
                                        Get.to(() => ProductsScreen(
                                            type: "sale",
                                            function: (Product product) {
                                              salesController
                                                  .addToCart(product);
                                            }));
                                      } else {
                                        Get.find<HomeController>().selectedWidget.value =
                                            ProductsScreen(
                                                type: "sale",
                                                function: (Product product) {
                                                  salesController
                                                      .addToCart(product);
                                                });
                                      }
                                    },
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline_outlined,
                                          size: 40,
                                          color: AppColors.mainColor,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "add items",
                                          style: TextStyle(
                                              color: AppColors.mainColor,
                                              fontSize: 21),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: salesController
                                                .receipt.value!.items?.length,
                                            itemBuilder: (context, index) {
                                              SaleItem receiptItem =
                                                  salesController
                                                          .receipt.value!.items
                                                          ?.elementAt(index)
                                                      as SaleItem;
                                              return salesContainer(
                                                  receiptItem: receiptItem,
                                                  index: index,
                                                  type: "order");
                                            }),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    const Text("Total : "),
                                                    Text(
                                                      htmlPrice(
                                                        salesController
                                                                .receipt
                                                                .value
                                                                ?.totalWithDiscount ??
                                                            0,
                                                      ),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    const Text("Items : "),
                                                    Text(
                                                      salesController.receipt
                                                                      .value ==
                                                                  null ||
                                                              salesController
                                                                  .receipt
                                                                  .value!
                                                                  .items!
                                                                  .isEmpty
                                                          ? "0"
                                                          : salesController
                                                              .receipt
                                                              .value!
                                                              .items!
                                                              .fold(
                                                                  0.0,
                                                                  (previousValue,
                                                                          element) =>
                                                                      previousValue +
                                                                      element
                                                                          .quantity!)
                                                              .toString(),
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (salesController
                                                            .receipt.value ==
                                                        null ||
                                                    salesController
                                                        .receipt
                                                        .value!
                                                        .items!
                                                        .isEmpty) {
                                                  generalAlert(
                                                      title: "No items to pay");
                                                  return;
                                                }

                                                confirmPayment(
                                                    context, "sales");
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15),
                                                decoration: BoxDecoration(
                                                    color: AppColors.mainColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: majorTitle(
                                                      title: "Order Now",
                                                      color: Colors.white,
                                                      size: 18.0),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  confirmPayment(context, toPage) {
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
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Choose payment method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderController.orderMethods.length,
                  itemBuilder: (context, index) {
                    var ordemethod = orderController.orderMethods[index];
                    return InkWell(
                      onTap: () {
                        orderController.currentOrderMethod.value = ordemethod;
                        Get.back();
                        if (orderController.currentCustomer.value == null &&
                            userController.currentUser.value == null) {
                          Get.to(() => CustomerSignUp(toPage: toPage));
                        } else {
                          Get.to(() => OrderPreview());
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ordemethod["value"],
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  needCustomer() {
    return salesController.paymentType.value == "Credit" ||
        salesController.paymentType.value == "Wallet";
  }
}
