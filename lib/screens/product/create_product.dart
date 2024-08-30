import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/screens/product/product_categories.dart';
import 'package:reggypos/screens/suppliers/suppliers_page.dart';

import '../../../utils/colors.dart';
import '../../../widgets/major_title.dart';
import '../../../widgets/minor_title.dart';
import '../../controllers/productcontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../controllers/suppliercontroller.dart';
import '../../models/product.dart';
import '../../services/local_files_access_service.dart';
import '../../utils/constants.dart';

enum ImageType {
  local,
  network,
}

class CustomImage {
  final ImageType imgType;
  final String path;
  CustomImage({this.imgType = ImageType.local, required this.path});
  @override
  String toString() {
    return "Instance of Custom Image: {imgType: $imgType, path: $path}";
  }
}

class CreateProduct extends StatelessWidget {
  final String page;
  final Product? productModel;
  final bool? clearInputs;

  CreateProduct(
      {Key? key,
      required this.page,
      required this.productModel,
      this.clearInputs = true})
      : super(key: key) {
    if (page == "create") {
      if (clearInputs!) {
        productController.clearControllers();
      }
    } else {
      productController.assignTextFields(productModel!);
    }
  }

  final ShopController shopController = Get.find<ShopController>();
  final ProductController productController = Get.find<ProductController>();
  final SupplierController supplierController = Get.find<SupplierController>();
  void pickProductImage(BuildContext context) async {
    try {
      String path;
      path = await choseImageFromLocalFiles(context,
          aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2));
      productController.image.value = XFile(path);
    } finally {}
  }

  Future<void> addImageButtonCallback(BuildContext context,
      {int? index}) async {
    String path = "";
    path = await choseImageFromLocalFiles(context);
    if (index == null) {
      productController.selectedImages
          .add(CustomImage(imgType: ImageType.local, path: path));
    } else {
      if (index < productController.selectedImages.length) {
        productController.selectedImages[index] =
            CustomImage(imgType: ImageType.local, path: path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (val) {
        productController.managexpiry.value = false;
        productController.manageorderlevel.value = false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.1,
          titleSpacing: 0.0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              Get.back();
              productController.managexpiry.value = false;
              productController.managediscount.value = false;
              productController.manageorderlevel.value = false;
              productController.managediscount.value = false;
              productController.manageorderlevel.refresh();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              majorTitle(
                  title: page == "edit" ? "Edit Product" : "duct",
                  color: Colors.black,
                  size: 16.0),
              minorTitle(
                  title:
                      "${userController.currentUser.value?.primaryShop?.name}",
                  color: Colors.grey)
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0, top: 5.0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        productController.productType.value = "product";
                        if (productModel?.type == 'product') {
                          productController.assignTextFields(productModel!);
                        } else {
                          productController.clearControllers();
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                            color: productController.isProduct()
                                ? AppColors.mainColor
                                : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Center(
                            child: Text(
                              "Product",
                              style: TextStyle(
                                color: productController.isProduct()
                                    ? Colors.white
                                    : AppColors.mainColor,
                              ),
                            ),
                          )),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        productController.productType.value = "service";
                        if (productModel?.type == 'service') {
                          productController.assignTextFields(productModel!);
                        } else {
                          productController.clearControllers();
                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey),
                            color: productController.isProduct() == false
                                ? AppColors.mainColor
                                : Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Center(
                              child: Text(
                            "Service",
                            style: TextStyle(
                              color: productController.isProduct() == false
                                  ? Colors.white
                                  : AppColors.mainColor,
                            ),
                          ))),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Obx(
                  () => ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 10),
                      Text(productController.isProduct()
                          ? "Product Name"
                          : "Service Name *"),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: productController.itemNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          labelStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 3),
                          if (productController.isProduct())
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Buying Price *"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller:
                                        productController.buyingPriceController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                      hintText: "0",
                                      fillColor: Colors.white,
                                      filled: true,
                                      labelStyle: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (productController.isProduct())
                            const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(productController.isProduct()
                                    ? "Selling Price *"
                                    : "Service Cost"),
                                const SizedBox(height: 5),
                                TextFormField(
                                  controller:
                                      productController.sellingPriceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "0",
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelStyle: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Obx(() => productController.addminPrice.isFalse &&
                              productController.isProduct()
                          ? InkWell(
                              onTap: () {
                                productController.addminPrice.value =
                                    !productController.addminPrice.value;
                              },
                              child: const Text(
                                "+ Add min selling price",
                                style: TextStyle(color: Colors.blue),
                              ),
                            )
                          : productController.isProduct() == false
                              ? Container()
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Min Selling price "),
                                          const SizedBox(height: 5),
                                          TextFormField(
                                            controller: productController
                                                .minsellingPriceController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: InputDecoration(
                                              hintText: "0",
                                              fillColor: Colors.white,
                                              filled: true,
                                              labelStyle: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          productController.addminPrice.value =
                                              !productController
                                                  .addminPrice.value;
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ))
                                  ],
                                )),
                      const SizedBox(height: 10),
                      if (productController.isProduct())
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Quantity *"),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: productController.qtyController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r"[0-9.]")),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        final text = newValue.text;
                                        return text.isEmpty
                                            ? newValue
                                            : double.tryParse(text) == null
                                                ? oldValue
                                                : newValue;
                                      }),
                                    ],
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: "0",
                                      labelStyle: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Unit of Measure "),
                                  const SizedBox(width: 5),
                                  TextFormField(
                                    controller:
                                        productController.measureController,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      labelStyle: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      if (productController.managediscount.value == true)
                        const SizedBox(height: 10),
                      Row(
                        children: [
                          Obx(
                            () => productController.managediscount.value ==
                                    false
                                ? Container(
                                    height: 0,
                                  )
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Max Discount "),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: productController
                                              .discountController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "0",
                                            labelStyle: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Obx(() => productController.managediscount.value &&
                                  productController.manageorderlevel.value
                              ? const SizedBox(width: 15)
                              : Container()),
                          Obx(
                            () => productController.manageorderlevel.value ==
                                    false
                                ? Container()
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Re-Order Level "),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: productController
                                              .reOrderController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "0",
                                            labelStyle: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      if (productController.managediscount.value == true)
                        const SizedBox(height: 10),
                      Row(
                        children: [
                          Obx(
                            () => productController.managewholesale.value ==
                                    false
                                ? Container()
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        const Text("Wholesale Price"),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: productController
                                              .wholeSalePriceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "0",
                                            labelStyle: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Obx(() => productController.managedealer.value &&
                                  productController.managewholesale.value
                              ? const SizedBox(width: 15)
                              : Container()),
                          Obx(
                            () => productController.managedealer.value == false
                                ? Container(
                                    height: 0,
                                  )
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text("Dealer Price"),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: productController
                                              .dealerPriceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            hintText: "0",
                                            labelStyle: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      if (productController.managewholesale.value == true ||
                          productController.managexpiry.value == true)
                        const SizedBox(height: 10),
                      Obx(() => productController.managexpiry.isFalse
                          ? Container(
                              height: 0,
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Expiry Date"),
                                      const SizedBox(height: 5),
                                      TextFormField(
                                        onTap: () async {
                                          DateTime? expirydate =
                                              await showDatePicker(
                                            context: Get.context!,
                                            initialDate: DateTime.now(),
                                            firstDate:
                                                DateTime(1900, 5, 5, 20, 50),
                                            lastDate:
                                                DateTime(2030, 6, 7, 05, 09),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data: ThemeData.dark().copyWith(
                                                  colorScheme:
                                                      const ColorScheme.dark(
                                                    onPrimary: Colors.white,
                                                    onSurface: Colors.white,
                                                  ),
                                                  dialogBackgroundColor:
                                                      Colors.white,
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          productController.expiryDate.value =
                                              expirydate!;
                                          productController
                                                  .expiryController.text =
                                              DateFormat("yyyy-MM-dd")
                                                  .format(expirydate);
                                        },
                                        controller:
                                            productController.expiryController,
                                        readOnly: true,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          prefixIcon:
                                              const Icon(Icons.calendar_month),
                                          filled: true,
                                          hintText: DateFormat("yyyy-MM-dd")
                                              .format(DateTime.now()),
                                          labelStyle: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  child: const Center(
                                      child: Icon(Icons.delete,
                                          color: Colors.red)),
                                  onTap: () {
                                    productController.managexpiry.value =
                                        !productController.managexpiry.value;
                                  },
                                ),
                              ],
                            )),
                      if (productController.manufacturer.value == true)
                        const SizedBox(height: 10),
                      if (productController.manufacturer.value == true)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Manufacturer"),
                            const SizedBox(height: 5),
                            TextFormField(
                              controller:
                                  productController.manufacturerController,
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: 'Manufacturer',
                                labelStyle: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      DottedBorder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        radius: const Radius.circular(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => InkWell(
                                onTap: () {
                                  productController.taxable.value =
                                      !productController.taxable.value;
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Text("Taxable? $tax%"),
                                    Checkbox(
                                        value: productController.taxable.value,
                                        onChanged: (v) {
                                          productController.taxable.value = v!;
                                        }),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              "By ticking this box, the system assumes the ${productController.isProduct() ? "selling price" : "cost"} is tax inclusive",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => productController.pickedSupplier.value == null
                            ? Container(
                                height: 0,
                              )
                            : Row(
                                children: [
                                  const Text(
                                    "Supplier: ",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    productController
                                        .pickedSupplier.value!.name!,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        productController.pickedSupplier.value =
                                            null;
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      )),
                                ],
                              ),
                      ),
                      const SizedBox(height: 10),
                      Obx(
                        () => productController.selecteProductCategoty.value ==
                                null
                            ? Container()
                            : Row(
                                children: [
                                  const Text(
                                    "Category: ",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    productController
                                        .selecteProductCategoty.value!.name!,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        productController.selecteProductCategoty
                                            .value = null;
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      )),
                                ],
                              ),
                      ),
                      if (productController.selecteProductCategoty.value !=
                          null)
                        const SizedBox(height: 10),
                      if (productController.isProduct())
                        Wrap(
                          spacing: 10,
                          runSpacing: 5,
                          children: [
                            InkWell(
                              child: Obx(
                                  () => productController.manufacturer.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Manufacturer",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.manufacturer.value =
                                    !productController.manufacturer.value;
                              },
                            ),
                            InkWell(
                              child: Obx(
                                  () => productController.managewholesale.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Wholesale Price",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.managewholesale.value =
                                    !productController.managewholesale.value;
                              },
                            ),
                            InkWell(
                              child: Obx(
                                  () => productController.managedealer.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Dealer Price",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.managedealer.value =
                                    !productController.managedealer.value;
                              },
                            ),
                            InkWell(
                              child: Obx(() => productController
                                          .selecteProductCategoty.value !=
                                      null
                                  ? Container(
                                      width: 0,
                                    )
                                  : Text(
                                      "+ add category",
                                      style: TextStyle(
                                          color: productController
                                                      .selecteProductCategoty
                                                      .value !=
                                                  null
                                              ? Colors.red
                                              : Colors.blue),
                                    )),
                              onTap: () {
                                if (productController
                                        .selecteProductCategoty.value ==
                                    null) {
                                  Get.to(() => ProductCategories());
                                } else {
                                  productController
                                      .selecteProductCategoty.value = null;
                                }
                              },
                            ),
                            InkWell(
                              child: Obx(() =>
                                  productController.pickedSupplier.value != null
                                      ? Container(
                                          width: 0,
                                        )
                                      : Text(
                                          "+ add supplier",
                                          style: TextStyle(
                                              color: productController
                                                          .pickedSupplier
                                                          .value !=
                                                      null
                                                  ? Colors.red
                                                  : Colors.blue),
                                        )),
                              onTap: () {
                                if (productController.pickedSupplier.value ==
                                    null) {
                                  Get.to(() => Suppliers(
                                        from: "addproduct",
                                      ));
                                } else {
                                  productController.pickedSupplier.value = null;
                                }
                              },
                            ),
                            InkWell(
                              child:
                                  Obx(() => productController.managexpiry.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Expiry Date",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.managexpiry.value =
                                    !productController.managexpiry.value;
                              },
                            ),
                            InkWell(
                              child: Obx(() =>
                                  productController.manageorderlevel.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Reorder Level",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.manageorderlevel.value =
                                    !productController.manageorderlevel.value;
                              },
                            ),
                            InkWell(
                              child: Obx(
                                  () => productController.managediscount.isTrue
                                      ? Container(
                                          width: 0,
                                        )
                                      : const Text(
                                          "+ Discount",
                                          style: TextStyle(color: Colors.blue),
                                        )),
                              onTap: () {
                                productController.managediscount.value =
                                    !productController.managediscount.value;
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      const Text("Description"),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: productController.descriptionController,
                        keyboardType: TextInputType.text,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "optional",
                          labelStyle: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      buildUploadImagesTile(context),
                      if (productController.isProduct())
                        Obx(
                          () => InkWell(
                            onTap: () {
                              productController.generateBarcodeOnSave.value =
                                  !productController
                                      .generateBarcodeOnSave.value;
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Generate Barcode on save?"),
                                Checkbox(
                                    value: productController
                                        .generateBarcodeOnSave.value,
                                    onChanged: (v) {
                                      productController
                                          .generateBarcodeOnSave.value = v!;
                                      authController.storage.write(
                                          key: "print_barcode",
                                          value: v.toString());
                                    }),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Obx(() => productController.creatingProductLoad.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : InkWell(
                              splashColor: Colors.transparent,
                              onTap: () async {
                                if (page == "edit") {
                                  await productController.updateProducts(
                                      productData: productModel);
                                } else {
                                  await productController.saveProducts(
                                      productData: productModel);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3, color: AppColors.mainColor),
                                    borderRadius: BorderRadius.circular(40)),
                                child: Center(
                                    child: majorTitle(
                                        title: page == "create"
                                            ? productController.isProduct()
                                                ? "Add Product"
                                                : "Add Service"
                                            : "Update",
                                        color: AppColors.mainColor,
                                        size: 18.0)),
                              )))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildUploadImagesTile(BuildContext context) {
    return ExpansionTile(
      maintainState: true,
      iconColor: AppColors.mainColor,
      initiallyExpanded: true,
      collapsedIconColor: AppColors.mainColor,
      title: Text(
        productController.isProduct() ? "Product Images" : "Service Images",
        style: const TextStyle(
            color: AppColors.mainColor,
            fontSize: 18,
            fontWeight: FontWeight.w600),
      ),
      leading: const Icon(Icons.image, color: AppColors.mainColor),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: IconButton(
              icon: const Icon(Icons.add_a_photo, color: AppColors.mainColor),
              color: AppColors.lightDeepPurple,
              onPressed: () {
                addImageButtonCallback(context);
              }),
        ),
        Obx(() => SizedBox(
              height: productController.selectedImages.isEmpty ? 0 : 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: productController.selectedImages.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 90,
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          addImageButtonCallback(context, index: index);
                        },
                        child: productController
                                    .selectedImages[index].imgType ==
                                ImageType.local
                            ? Image.memory(
                                File(productController
                                        .selectedImages[index].path)
                                    .readAsBytesSync(),
                                fit: BoxFit.fitWidth,
                              )
                            : Image.network(
                                productController.selectedImages[index].path),
                      ),
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }
}
