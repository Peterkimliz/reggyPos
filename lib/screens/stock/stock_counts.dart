import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/stockcontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/stock/product_cout_preview.dart';
import 'package:reggypos/utils/constants.dart';
import 'package:reggypos/widgets/no_items_found.dart';

import '../../controllers/homecontroller.dart';
import '../../controllers/productcontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../models/product.dart';
import '../../reports/stocktake_report.dart';
import '../../utils/colors.dart';
import '../../widgets/major_title.dart';
import '../../widgets/minor_title.dart';
import '../product/components/product_card.dart';

class CartButton extends StatelessWidget {
  final StockController stockController = Get.find<StockController>();

   CartButton({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.to(() => ProductCountPreview());
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.shopping_cart),
          // if (itemCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Obx(
                () => Text(
                  '${stockController.productsCountCart.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StockCount extends StatelessWidget {
  StockCount({Key? key}) : super(key: key) {
    productController.searchProductCountController.text = "";
  }

  final ProductController productController = Get.find<ProductController>();
  final StockController stockController = Get.find<StockController>();
  final ShopController shopController = Get.find<ShopController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 0.3,
          titleSpacing: 0.0,
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  majorTitle(
                      title: "Stock Count", color: Colors.black, size: 16.0),
                  minorTitle(
                      title:
                          "${userController.currentUser.value?.primaryShop?.name}",
                      color: Colors.grey)
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: InkWell(
                      onTap: () {
                        productController.getProductsBySort(type: 'all');
                      },
                      child: const Icon(Icons.refresh,
                          color: AppColors.mainColor))),
            ],
          ),
        ),
        floatingActionButton: CartButton(),
        body: ListView(children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              controller: productController.searchProductCountController,
              onChanged: (query) {
                if (query.isEmpty) {
                  stockController.productsCount.value =
                      productController.products;
                  productController.getProductsBySort(
                      type: "search",
                      text: productController.searchProductCountController.text,
                      page: 1,
                      limit: 50);
                } else {
                  stockController.productsCount.value = productController
                      .products
                      .where((product) => product.name!
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                }
              },
              decoration: InputDecoration(
                suffixIconConstraints: const BoxConstraints(maxWidth: 100),
                contentPadding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                suffixIcon: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        productController.getProductsBySort(
                            type: "search",
                            text: productController
                                .searchProductCountController.text,
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
                hintText: "Quick Search Item",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items Available'),
                Obx(() {
                  return Text("${stockController.productsCount.length}");
                })
              ],
            ),
          ),
          if (userController.currentUser.value?.usertype == "admin")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Count History'),
                  InkWell(
                    onTap: () {
                      if (isSmallScreen(context)) {
                        Get.to(() => StockTakeReport());
                      } else {
                        Get.find<HomeController>().selectedWidget.value =
                            StockTakeReport();
                      }
                    },
                    child:
                        minorTitle(title: "View", color: AppColors.mainColor),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sort By"),
                sortWidget(context),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            return productController.loadingproducts.isTrue
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : stockController.productsCount.isEmpty
                    ? noItemsFound(context, false)
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: stockController.productsCount.length,
                        itemBuilder: (context, index) {
                          Product product =
                              stockController.productsCount.elementAt(index);
                          return productCard(
                              type: "count",
                              product: product,
                              counted: stockController.productsCountCart
                                          .indexWhere((element) =>
                                              element.sId == product.sId) ==
                                      -1
                                  ? false
                                  : true,
                              function: (Product product) {
                                return stockController.incrementQuantityWidget(
                                    context, product);
                              });
                        });
          })
        ]));
  }

  Widget sortWidget(context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return SimpleDialog(
              children: List.generate(
                  Constants().sortOrderCaunt.length,
                  (index) => SimpleDialogOption(
                        onPressed: () {
                          productController.selectedSortOrderCount.value =
                              Constants().sortOrderCaunt.elementAt(index);
                          productController.selectedSortOrderCountSearch.value =
                              Constants().sortOrderCauntList.elementAt(index);
                          productController.getProductsBySort(
                              type: Constants()
                                  .sortOrderCauntList
                                  .elementAt(index));
                          Navigator.pop(context);
                        },
                        child: Text(
                          Constants().sortOrderCaunt.elementAt(index),
                        ),
                      )),
            );
          },
        );
      },
      child: Row(
        children: [
          Obx(() {
            return Text(productController.selectedSortOrderCount.value,
                style: const TextStyle(color: AppColors.mainColor));
          }),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.mainColor,
          )
        ],
      ),
    );
  }
}
