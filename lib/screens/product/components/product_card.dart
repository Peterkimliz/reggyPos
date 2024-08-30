import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/widgets/minor_title.dart';
import 'package:reggypos/widgets/product_image.dart';
import 'package:reggypos/widgets/snackBars.dart';

import '../../../controllers/homecontroller.dart';
import '../../../controllers/productcontroller.dart';
import '../../../controllers/salescontroller.dart';
import '../../../functions/functions.dart';
import '../../../models/product.dart';
import '../../../responsive/responsiveness.dart';
import '../../../utils/colors.dart';
import '../../../widgets/delete_dialog.dart';
import '../create_product.dart';
import '../product_history.dart';
import '../tabs/receipts_sales.dart';
import 'barcodegenerator.dart';

Widget productCard(
    {required Product product,
    Function? function,
    bool? counted = false,
    String? type = "all"}) {
  return InkWell(
    onTap: () {
      if (userController.internetConected.isFalse) {
        showSnackBar(message: "No internet connection", color: Colors.red);
        return;
      }
      if (function != null) {
        function(product);
      } else {
        showProductModal(Get.context!, product);
      }
    },
    child: Padding(
      padding: const EdgeInsets.all(3.0),
      child: Card(
        color: type == "count"
            ? Colors.white
            : product.type == "service"
                ? AppColors.mainColor
                : product.quantity == 0
                    ? Colors.red
                    : product.quantity! <= product.reorderLevel!
                        ? Colors.amber
                        : Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ProductImage(
                element: product.images != null && product.images!.isNotEmpty
                    ? product.images![0].path
                    : "",
                radius: 10,
                size: 50,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${product.name!.capitalizeFirst!} ${product.measureUnit ?? ""}",
                            style: const TextStyle(fontSize: 16.0),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: counted == true
                                ? AppColors.mainColor
                                : Colors.transparent,
                          ),
                          child: Text(
                            counted == true ? "Counted" : "",
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.white,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        if (product.productCategoryId != null)
                          minorTitle(
                              title: "${product.productCategoryId?.name},",
                              color: Colors.black,
                              size: 11),
                        if (product.productCategoryId != null)
                          const SizedBox(width: 5),
                        if (product.manufacturer!.isNotEmpty)
                          Text(
                            product.manufacturer ?? "",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.reorderLevel! > 0)
                              minorTitle(
                                  title:
                                      "Restock @ ${product.reorderLevel} ~ Qty: ${product.quantity?.toStringAsFixed(2)}",
                                  color: Colors.black,
                                  size: 11),
                            if (product.reorderLevel == 0 ||
                                product.reorderLevel == null)
                              minorTitle(
                                  title:
                                      "Qty: ${product.quantity?.toStringAsFixed(2)}",
                                  color: Colors.black,
                                  size: 11),
                            const SizedBox(height: 5),
                            if (product.attendantId != null && type == "all")
                              minorTitle(
                                  title:
                                      "By ~ ${product.attendantId?.username}",
                                  color: Colors.black,
                                  size: 11),
                          ],
                        ),
                        if (type == "all")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "BP/= ${htmlPrice(product.buyingPrice?.toStringAsFixed(2))}",
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              minorTitle(
                                  title:
                                      "SP/= ${htmlPrice(product.sellingPrice?.toStringAsFixed(2))}",
                                  color: Colors.black),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

showProductModal(context, Product product) {
  ProductController productController = Get.find<ProductController>();
  SalesController salesController = Get.find<SalesController>();

  return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              if (userController.currentUser.value?.usertype == "admin")
                ListTile(
                    leading: const Icon(Icons.list),
                    onTap: () {
                      Get.back();

                      getYearlyRecords(product, function:
                          (Product product, String firstday, String lastday) {
                        salesController.filterStartDate.value = firstday;
                        salesController.filterEndDate.value = lastday;
                        salesController.getSalesByProductId(
                            product: product,
                            fromDate: firstday,
                            toDate: lastday);
                        productController.getProductPurchasesGroupedByMonth(
                          product.sId!,
                          fromDate: firstday,
                          toDate: lastday,
                        );
                      }, year: salesController.currentYear.value);

                      Get.to(() => ProductHistory(product: product));
                    },
                    title: const Text('History')),
              ListTile(
                  leading: const Icon(Icons.list),
                  onTap: () {
                    Get.back();
                    var firstday =
                        DateFormat("yyy-MM-dd").format(DateTime.now());
                    var lastday =
                        DateFormat("yyy-MM-dd").format(DateTime.now());
                    salesController.getProductSales(
                        product: product.sId,
                        fromDate: firstday,
                        toDate: lastday);
                    salesController.getReturns(
                        product: product,
                        fromDate: firstday,
                        shopid:
                            userController.currentUser.value!.primaryShop!.id!,
                        toDate: lastday,
                        type: "return");

                    isSmallScreen(context)
                        ? Get.to(() => ProductReceiptsSales(
                              product: product,
                              i: DateTime.now().month,
                            ))
                        : Get.find<HomeController>().selectedWidget.value =
                            ProductReceiptsSales(
                            product: product,
                            i: DateTime.now().month,
                          );
                  },
                  title: const Text('Sales')),
              if (verifyPermission(category: "products", permission: "manage"))
                ListTile(
                    leading: const Icon(Icons.edit),
                    onTap: () {
                      Get.back();
                      Get.to(() => CreateProduct(
                            page: "edit",
                            productModel: product,
                          ));
                    },
                    title: const Text('Edit')),
              if (userController.currentUser.value?.usertype == "admin")
                ListTile(
                    leading: const Icon(Icons.code),
                    onTap: () {
                      Get.back();
                      Get.to(() => BarcodeGenerator(
                            product: product,
                          ));
                    },
                    title: const Text('Generate Barcode')),
              if (verifyPermission(category: "products", permission: "manage"))
                ListTile(
                    leading: const Icon(Icons.delete),
                    onTap: () {
                      deleteDialog(
                          context: context,
                          onPressed: () {
                            productController.deleteProduct(
                              product: product,
                            );
                          });
                    },
                    title: const Text('Delete')),
              ListTile(
                  leading: const Icon(Icons.clear),
                  onTap: () {
                    Get.back();
                  },
                  title: const Text('Close')),
            ],
          ),
        );
      });
}
