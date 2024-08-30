import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/product/components/service_card.dart';
import 'package:reggypos/screens/receipts/pdf/products/productsexpirypdflist.dart';
import 'package:reggypos/utils/constants.dart';
import 'package:reggypos/widgets/alert.dart';
import 'package:reggypos/widgets/no_items_found.dart';
import 'package:printing/printing.dart';

import '../../controllers/productcontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../functions/functions.dart';
import '../../models/product.dart';
import '../../utils/colors.dart';
import '../../widgets/major_title.dart';
import '../../widgets/minor_title.dart';
import '../receipts/pdf/products/productspdflist.dart';
import 'components/product_card.dart';

class ProductPage extends StatelessWidget {
  ProductPage({Key? key}) : super(key: key) {
    productController.searchProductController.text = "";
  }

  final ShopController createShopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0.3,
        titleSpacing: 0.0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
            productController.filterProductsLocally('');
            productController.searchProductController.clear();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                showBottomSheet(context);
              },
              icon: const Icon(
                Icons.download,
                color: AppColors.mainColor,
              )),
          IconButton(
              onPressed: () async {
                productController.getProductsBySort(type: "all");
              },
              icon: const Icon(
                Icons.refresh,
                color: AppColors.mainColor,
              ))
        ],
        title: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  majorTitle(
                      title: "Products", color: Colors.black, size: 16.0),
                  minorTitle(
                      title:
                          "${userController.currentUser.value?.primaryShop?.name}",
                      color: Colors.grey)
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: productController.searchProductController,
                    onChanged: (value) {
                      productController.filterProductsLocally(
                          productController.searchProductController.text);
                    },
                    decoration: InputDecoration(
                      suffixIconConstraints:
                          const BoxConstraints(maxWidth: 100),
                      suffixIcon: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              productController.getProductsBySort(
                                  type: "search",
                                  text: productController
                                      .searchProductController.text,
                                  page: 1,
                                  limit: 50);
                            },
                            child: const Text(
                              "Search",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                      hintText: "Quick Search Item",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      productController.scanQR(
                          type: "product", context: context);
                    },
                    icon: const Icon(Icons.qr_code))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort List By"),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return SimpleDialog(
                          children: List.generate(
                              Constants().sortOrder.length,
                              (index) => SimpleDialogOption(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      productController
                                              .selectedSortOrder.value =
                                          Constants()
                                              .sortOrder
                                              .elementAt(index);
                                      productController
                                              .selectedSortOrderSearch.value =
                                          Constants()
                                              .sortOrderList
                                              .elementAt(index);
                                      productController.getProductsBySort(
                                          type: "",
                                          sort: productController
                                              .selectedSortOrderSearch.value);
                                    },
                                    child: Text(
                                      Constants().sortOrder.elementAt(index),
                                    ),
                                  )),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Obx(() {
                        return Text(productController.selectedSortOrder.value,
                            style: const TextStyle(color: AppColors.mainColor));
                      }),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.mainColor,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              return productController.loadingproducts.value
                  ? const Center(child: CircularProgressIndicator())
                  : productController.filteredProducts.isEmpty
                      ? noItemsFound(context, true)
                      : ListView.builder(
                          itemCount: productController.filteredProducts.length,
                          itemBuilder: ((context, index) {
                            Product productModel = productController
                                .filteredProducts
                                .elementAt(index);
                            if (productModel.type == "service") {
                              return serviceCard(product: productModel);
                            }
                            return productCard(product: productModel);
                          }),
                        );
            }),
          ),
        ],
      ),
    );
  }

  productOperions(context, product, shopId) {
    List<Map<String, dynamic>> data = [
      {"title": "Product History", "icon": Icons.list, "value": "history"},
      {"title": "Edit", "icon": Icons.edit, "value": "edit"},
      {"title": "Delete", "icon": Icons.delete, "value": "delete"},
      {"title": "Cancel", "icon": Icons.clear, "value": "clear"},
    ];
    return data
        .map((e) => PopupMenuItem(
              value: e["value"],
              child:
                  ListTile(leading: Icon(e["icon"]), title: Text(e["title"])),
            ))
        .toList();
  }

  showBottomSheet(
    BuildContext context,
  ) {
    return showModalBottomSheet(
        context: context,
        backgroundColor:
            isSmallScreen(context) ? Colors.white : Colors.transparent,
        builder: (_) {
          return Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.5,
            margin: EdgeInsets.only(
                left: isSmallScreen(context)
                    ? 0
                    : MediaQuery.of(context).size.width * 0.2),
            child: Column(
              children: [
                Container(
                  color: AppColors.mainColor.withOpacity(0.1),
                  width: double.infinity,
                  child: const ListTile(
                    title: Text("Choose what to download"),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  onTap: () async {
                    Get.back();

                    generalAlert(
                        message: "Which type of document you want to download?",
                        positiveText: "Excel Sheet",
                        negativeText: "PDF",
                        negativeCallback: () async {
                          await productController.getProductsBySort(
                              type: "all", reason: "download");

                          Get.to(() => Scaffold(
                                appBar: AppBar(
                                  title: const Text("All Products"),
                                ),
                                body: PdfPreview(
                                  build: (context) => productsListPdf(
                                      productController.productDownloadss,
                                      "All PRODUCTS"),
                                ),
                              ));
                        },
                        function: () async {
                          List<List<Object?>> data = [
                            [
                              'Name',
                              'Bp',
                              'Sp',
                              "qty",
                              "category",
                              "expiry date",
                              'min price',
                              "wholesale price",
                              "dealer price",
                              "supplier",
                            ],
                          ];
                          data.addAll(productController.products
                              .map((element) => [
                                    element.name,
                                    element.buyingPrice,
                                    element.sellingPrice,
                                    element.quantity,
                                    element.productCategoryId?.name,
                                    element.expiryDate,
                                    element.minSellingPrice,
                                    element.wholesalePrice,
                                    element.dealerPrice,
                                    element.supplierId?.name
                                  ])
                              .toList());

                          String? filePath =
                              await exportToExcel(data, "products");
                          await openFile(filePath!);
                        });
                  },
                  title: const Text("All"),
                ),
                ListTile(
                  leading: const Icon(Icons.hourglass_empty),
                  onTap: () async {
                    List<List<Object?>> data = [
                      ['Name', 'Bp', 'Sp', "qty", "category"],
                    ];
                    await productController.getProductsBySort(
                        type: "all", sort: "outofstock", reason: "download");
                    data.addAll(productController.productDownloadss
                        .map((element) => [
                              element.name,
                              element.buyingPrice,
                              element.sellingPrice,
                              element.quantity,
                              element.productCategoryId?.name
                            ])
                        .toList());

                    String? filePath = await exportToExcel(data, "outofstock");
                    await openFile(filePath!);
                  },
                  title: const Text("Out of stock"),
                ),
                ListTile(
                  leading: const Icon(Icons.downhill_skiing_sharp),
                  onTap: () async {
                    List<List<Object?>> data = [
                      ['Name', 'Bp', 'Sp', "qty", "category"],
                    ];
                    await productController.getProductsBySort(
                        type: "runninglow", reason: "download");
                    data.addAll(productController.productDownloadss
                        .map((element) => [
                              element.name,
                              element.buyingPrice,
                              element.sellingPrice,
                              element.quantity,
                              element.productCategoryId?.name
                            ])
                        .toList());

                    String? filePath = await exportToExcel(data, "runninglow");
                    await openFile(filePath!);
                  },
                  title: const Text("Running Low on Stock"),
                ),
                ListTile(
                  leading: const Icon(Icons.data_exploration),
                  onTap: () async {
                    await productController.getProductsBySort(
                        type: "expired", reason: "download");

                    Get.to(() => Scaffold(
                          appBar: AppBar(
                            title: const Text("Expired Products"),
                          ),
                          body: PdfPreview(
                            build: (context) => productsExpiryListPdf(
                                productController.productDownloadss,
                                "EXPIRED PRODUCTS"),
                          ),
                        ));
                  },
                  title: const Text("Expired"),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.clear,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Get.back();
                  },
                  title: const Text("Cancel "),
                ),
              ],
            ),
          );
        });
  }
}
