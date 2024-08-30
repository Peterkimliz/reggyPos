import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/widgets/no_items_found.dart';

import '../../controllers/productcontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../models/product.dart';
import '../../widgets/major_title.dart';
import '../sales/components/product_select.dart';

class ProductsScreen extends StatelessWidget {
  final String? type;
  final Function? function;

  ProductsScreen({Key? key, required this.type, this.function})
      : super(key: key);
  final ProductController productController = Get.find<ProductController>();
  final ShopController shopController = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: majorTitle(
            title: "Select Product", color: Colors.black, size: 16.0),
        elevation: 0.5,
        leading: IconButton(
            onPressed: () {
              Get.back();
              productController.filterProductsLocally('');
              productController.searchProductController.clear();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        actions: [
          InkWell(
            onTap: () {
              productController.getProductsBySort(type: "all");
            },
            child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.mainColor,
                  size: 30,
                )),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: TextFormField(
                controller: productController.searchProductController,
                onChanged: (value) {
                  productController.filterProductsLocally(
                      productController.searchProductController.text);
                },
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  suffixIconConstraints: const BoxConstraints(maxWidth: 100),
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
                  hintText: "Quick Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
          ),
          Expanded(
            child: Obx(
              () => productController.loadingproducts.isTrue
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : productController.filteredProducts.isEmpty
                      ? noItemsFound(context, true)
                      : ListView.builder(
                          itemCount: productController.filteredProducts.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            Product productModel = productController
                                .filteredProducts
                                .elementAt(index);

                            return productListItemCard(
                                product: productModel,
                                type: type,
                                function: function != null
                                    ? (Product product) {
                                        return function!(product);
                                      }
                                    : (Product product) {
                                        Get.back();
                                      });
                          }),
            ),
          ),
        ],
      ),
    );
  }
}
