import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/controllers/salescontroller.dart';
import 'package:reggypos/controllers/stockcontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/invoice.dart';
import 'package:reggypos/models/saleitem.dart';
import 'package:reggypos/screens/product/create_product.dart';
import 'package:reggypos/screens/product/products_page.dart';
import 'package:reggypos/services/product_service.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/widgets/snackBars.dart';

import '../models/badstock.dart';
import '../models/counthistory.dart';
import '../models/product.dart';
import '../models/productcategory.dart';
import '../models/supplier.dart';
import '../models/transferitems.dart';
import '../screens/product/components/barcodegenerator.dart';
import '../services/firestore_files_access_service.dart';
import '../sqlite/helper.dart';
import '../utils/helper.dart';
import '../widgets/alert.dart';
import '../widgets/async_progress_dialog.dart';
import '../widgets/loading_dialog.dart';

class ProductController extends GetxController {
  RxList<Product> products = RxList([]);
  RxList<Product> productDownloadss = RxList([]);
  RxList<ProductCategory> productCategories = RxList([]);
  RxList<TransferItem> productHistoryList = RxList([]);
  RxList<SaleItem> productInvoices = RxList([]);
  RxList<CountHistory> countHistory = RxList([]);
  RxList<InvoiceItem> productPurchases = RxList([]);
  RxList<Map<String, dynamic>> productMonthPurchases = RxList([]);
  RxList<Map<String, dynamic>> monthlyBadStocks = RxList([]);
  Rxn<Supplier> pickedSupplier = Rxn(null);
  RxBool loadingproducts = RxBool(false);
  RxBool showBadStockWidget = RxBool(false);
  RxBool transferAll = RxBool(false);
  RxBool loadingproductCategories = RxBool(false);
  RxBool saveBadstockLoad = RxBool(false);
  Rxn<Product> selectedBadStock = Rxn(null);
  Rxn<ProductCategory> selecteProductCategoty = Rxn(null);
  RxList<BadStock> badstocks = RxList([]);
  RxString productType = RxString("product");
  RxString fromDate = RxString("");
  RxString toDate = RxString("");

  RxString badstockFromDate = RxString("");
  RxString badstockToDate = RxString("");

  RxList<List<Object?>> sampledata = RxList([
    [
      'Name',
      'buyingPrice',
      'sellingPrice',
      "wholesalePrice",
      "measureUnit",
      "reorderLevel",
      "maxDiscount",
      "description",
      "supplier",
      "category",
      "quantity",
      "manufacturer",
    ],
    [
      'Nike',
      2000,
      3000,
      2500,
      "10kg",
      5,
      10,
      "test",
      "adidas",
      "shoes",
      20,
      'adidas'
    ],
    [
      "Milk",
      200,
      300,
      250,
      "10kg",
      5,
      10,
      "test",
      "brookside",
      "shoes",
      20,
      'brookside'
    ],
  ]);

  RxList<CustomImage> selectedImages = RxList([]);
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  RxInt currentYear = RxInt(DateTime.now().year);
  RxBool creatingProductLoad = RxBool(false);
  RxBool getProductLoad = RxBool(false);
  RxBool getProductCountLoad = RxBool(false);
  RxBool loadingCountHistory = RxBool(false);
  RxInt stockValue = RxInt(0);
  RxInt totalProfitEstimate = RxInt(0);
  RxString selectedSortOrder = RxString("All");
  RxString selectedSortOrderCount = RxString("All");
  RxString selectedSortOrderSearch = RxString("all");
  RxString selectedSortOrderCountSearch = RxString("all");
  RxString supplierName = RxString("None");
  Rxn<Supplier> supplierId = Rxn(null);
  Rxn<Map<String, dynamic>> productAnalysis =
      Rxn({'profitEstimate': 0, 'totalStockValue': 0});

  RxInt initialProductValue = RxInt(0);
  RxInt productHistoryTabIndex = RxInt(0);
  var filterStartDate = DateFormat("yyy-MM-dd").format(DateTime.now()).obs;
  var filterEndDate = DateFormat("yyy-MM-dd")
      .format(DateTime.now().add(const Duration(days: 1)))
      .obs;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController spoiltreasonController = TextEditingController();
  TextEditingController buyingPriceController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController minsellingPriceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController wholeSalePriceController = TextEditingController();
  TextEditingController dealerPriceController = TextEditingController();
  TextEditingController reOrderController = TextEditingController();
  TextEditingController measureController = TextEditingController();
  TextEditingController expiryController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryName = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController searchProductController = TextEditingController();
  TextEditingController searchProductCountController = TextEditingController();
  Rx<XFile> image = Rx(XFile(""));
  var expiryDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).obs;
  RxInt barcodeCounts = RxInt(3);
  RxBool taxable = RxBool(false);
  RxBool generateBarcodeOnSave = RxBool(true);
  RxBool addminPrice = RxBool(false);
  RxBool managexpiry = RxBool(false);
  RxBool managewholesale = RxBool(false);
  RxBool manufacturer = RxBool(false);
  RxBool managedealer = RxBool(false);
  RxBool manageorderlevel = RxBool(false);
  RxBool managediscount = RxBool(false);
  Rxn<ImagePicker> picker = Rxn(ImagePicker());
  var filteredProducts = <Product>[].obs;

  void filterProductsLocally(String query) {
    if (query.isEmpty) {
      filteredProducts.value = products;
      getProductsBySort(
          type: "all", text: query, page: 1, limit: 100, showLoader: false);
    } else {
      filteredProducts.value = products
          .where((product) =>
              product.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> importProducts(List<List<dynamic>> excelData) async {
    excelData.removeAt(0);
    List<Map<String, dynamic>> products = [];
    for (var element in excelData) {
      if (element[0].isNotEmpty && element[0] != null) {
        products.add({
          "name": element[0],
          "buyingPrice": element[1] ?? 0.0,
          "sellingPrice": element[2] ?? 0.0,
          "wholesalePrice": element[3] ?? 0.0,
          "measure": element[4],
          "reorderLevel": element[5],
          "maxDiscount": element[6],
          "description": element[7],
          "supplierId": element[8],
          "productCategoryId": element[9],
          "quantity": element[10] ?? 0.0,
          "manufacturer": element[11],
          "shopId": userController.currentUser.value!.primaryShop!.id,
          "attendantId": userController.currentUser.value!.attendantId?.sId,
          "adminId": userController.currentUser.value!.id,
          "deleted": false
        });
      }
    }

    generalAlert(
        title: "Warning",
        message: 'Do you want to import ${products.length - 1} products?',
        negativeCallback: () {
          Get.back();
        },
        function: () async {
          LoadingDialog.showLoadingDialog(
              context: Get.context!,
              title: "Importing products please wait",
              key: _keyLoader);
          var response = await ProductService().importProducts(products);
          Get.back();
          if (response['error'] != null) {
            generalAlert(message: response['error'], title: "Error");
            return;
          }
          generalAlert(
            message: response['message'],
            title: "Success",
          );
        });
  }

  updateProducts({Product? productData}) async {
    var name = itemNameController.text;
    var buying = buyingPriceController.text;
    var selling = sellingPriceController.text;
    var minSelling = minsellingPriceController.text;
    var reorder = reOrderController.text;
    var discount = discountController.text;
    if (validateProduct() == false) {
      return;
    }
    creatingProductLoad.value = true;
    try {
      var product = {
        "name": name,
        "quantity": qtyController.text,
        "productType": productType.value,
        "buyingPrice": double.parse(buying),
        "taxable": taxable.value,
        "manufacturer": manufacturerController.text,
        "sellingPrice": double.parse(selling),
        "wholesalePrice": wholeSalePriceController.text,
        "dealerPrice": dealerPriceController.text,
        "expiryDate": expiryController.text.isNotEmpty
            ? expiryDate.value.toIso8601String()
            : '',
        "minSellingPrice": minSelling == "" || addminPrice.value == false
            ? 0.0
            : double.parse(minSelling),
        "measure": measureController.text,
        "productCategoryId": selecteProductCategoty.value?.id,
        "reorderLevel": reorder == "" ? 0.0 : double.parse(reorder),
        "maxDiscount": discount == "" ? 0.0 : double.parse(discount),
        "description": descriptionController.text,
        "supplierId": pickedSupplier.value?.id,
      };

      var response =
          await ProductService.updateProduct(product, productData!.sId!);
      creatingProductLoad.value = false;
      if (response["error"] != null) {
        showSnackBar(message: response["Error"], color: Colors.red);
        return;
      } else {
        List<CustomImage> images = selectedImages
            .where((element) => element.imgType == ImageType.local)
            .toList();
        if (images.isNotEmpty) {
          Product product = Product.fromJson(response);
          await uploadImage(product);
        } else {
          Get.back();
        }
        showSnackBar(
            message: "Updated product successfully", color: Colors.green);
        await getProductsBySort(type: "all", showLoader: false);
      }
    } catch (e) {
      creatingProductLoad.value = false;
    }
  }

  bool validateProduct() {
    var name = itemNameController.text;
    var qty = qtyController.text;
    var buying = buyingPriceController.text;
    var selling = sellingPriceController.text;
    var minSelling = minsellingPriceController.text;
    String dealerPrice = dealerPriceController.text;
    String wholesalePrice = wholeSalePriceController.text;
    var discount = discountController.text;
    if (name.isEmpty ||
        (productType.value == "product" &&
            (qty.isEmpty || buying.isEmpty || selling.isEmpty))) {
      showSnackBar(
          message: "Please fill all fields marked by *", color: Colors.red);
      return false;
    } else if (productType.value == "product" &&
        double.parse(buying) > double.parse(selling)) {
      showSnackBar(
          message: "Selling price cannot be lower than buying price",
          color: Colors.red);
      return false;
    } else if (productType.value == "product" &&
        minSelling != "" &&
        double.parse(minSelling) > double.parse(selling)) {
      showSnackBar(
          message: "minimum selling price cannot be greater than selling price",
          color: Colors.red);
      return false;
    } else if (productType.value == "product" &&
        dealerPrice.isNotEmpty &&
        double.parse(dealerPrice) > 0 &&
        dealerPrice != "" &&
        double.parse(dealerPrice) < double.parse(buying)) {
      generalAlert(
          title: "Error",
          message: "Dealer price cannot be less than buying price");
      return false;
    } else if (productType.value == "product" &&
        wholesalePrice.isNotEmpty &&
        double.parse(wholesalePrice) > 0 &&
        wholesalePrice != "" &&
        double.parse(wholesalePrice) < double.parse(buying)) {
      generalAlert(
          title: "Error",
          message: "Wholesale price cannot be less than buying price");
      return false;
    } else if (productType.value == "product" &&
        minSelling != "" &&
        double.parse(buying) > double.parse(minSelling)) {
      showSnackBar(
          message: "minimum selling price cannot be less than buying price",
          color: Colors.red);
      return false;
    } else if (productType.value == "product" &&
        discount != "" &&
        double.parse(discount) > double.parse(selling)) {
      showSnackBar(
          message: "discount cannot be greater than selling price",
          color: Colors.red);
      return false;
    } else if (productType.value == "product" &&
        minSelling.isNotEmpty &&
        discount.isNotEmpty &&
        double.parse(minSelling) > 0 &&
        double.parse(discount) > 0) {
      showSnackBar(
          message: "you cannot have both min selling price and discount",
          color: Colors.red);
      return false;
    } else {
      if (expiryController.text.isNotEmpty) {
        if (!expiryDate.value.isAfter(DateTime.now())) {
          generalAlert(
            title: "Error",
            message: "Expiry date can only be in the future",
          );
          return false;
        }
      }

      if (discount.isNotEmpty && minSelling.isNotEmpty) {
        if (double.parse(discount) > 0 && double.parse(minSelling) > 0) {
          double newSellingPrice =
              double.parse(selling) - double.parse(discount);
          if (newSellingPrice < double.parse(minSelling)) {
            generalAlert(
                message:
                    "discount cannot be more than ${double.parse(selling) - double.parse(minSelling)}",
                title: "Error");
            return false;
          }
        }
      }
    }
    return true;
  }

  isProduct({String? type = ""}) {
    if (type!.isEmpty) {
      return productType.value == "product" ? true : false;
    }
    if (productType.value == "product") {
      return true;
    } else {
      return false;
    }
  }

  saveProducts({Product? productData}) async {
    var name = itemNameController.text;
    var buying =
        buyingPriceController.text.isEmpty ? "0" : buyingPriceController.text;
    var selling =
        sellingPriceController.text.isEmpty ? "0" : sellingPriceController.text;
    var minSelling = minsellingPriceController.text.isEmpty
        ? "0"
        : minsellingPriceController.text;
    String dealerPrice =
        dealerPriceController.text.isEmpty ? "0" : dealerPriceController.text;
    String wholesalePrice = wholeSalePriceController.text.isEmpty
        ? "0"
        : wholeSalePriceController.text;
    var reorder = reOrderController.text;
    var discount = discountController.text;
    if (validateProduct() == false) {
      return;
    }

    try {
      creatingProductLoad.value = true;

      var product = {
        "name": name,
        "productType": productType.value,
        "quantity": qtyController.text,
        "wholesalePrice":
            double.parse(wholesalePrice.isEmpty ? "0.0" : wholesalePrice),
        "dealerPrice": double.parse(dealerPrice.isEmpty ? "0.0" : dealerPrice),
        "expiryDate": expiryController.text.isNotEmpty
            ? expiryDate.value.toUtc().toIso8601String()
            : null,
        "buyingPrice": double.parse(buying),
        "sellingPrice": double.parse(selling),
        "taxable": taxable.value,
        "minSellingPrice": minSelling == "" ? null : double.parse(minSelling),
        "shopId": userController.currentUser.value!.primaryShop!.id,
        "measure": measureController.text,
        "manufacturer": manufacturerController.text,
        "productCategoryId": selecteProductCategoty.value?.id,
        "attendantId": userController.currentUser.value!.attendantId,
        "reorderLevel": reorder == "" ? 0 : double.parse(reorder),
        "maxDiscount": discount == "" ? 0 : double.parse(discount),
        "description": descriptionController.text,
        "supplierId": pickedSupplier.value == null
            ? ""
            : pickedSupplier.value!.id.toString(),
        "deleted": false
      };
      if (product["supplierId"] == "") {
        product["supplierId"] = null;
      }
      var response = await ProductService().createProduct(product);
      creatingProductLoad.value = false;
      pickedSupplier.value = null;

      if (response["error"] != null) {
        showSnackBar(message: response['error'], color: Colors.red);
      } else {
        List<CustomImage> images = selectedImages
            .where((element) => element.imgType == ImageType.local)
            .toList();
        if (images.isNotEmpty) {
          Product product = Product.fromJson(response);
          await uploadImage(product);
        } else {
          Get.back();
        }
        if (generateBarcodeOnSave.isTrue && productType.value == "product") {
          Get.to(() => BarcodeGenerator(
                product: Product.fromJson(response),
              ));
          return;
        }

        getProductsAnalysis(type: "all");
        getProductsBySort(type: "all");

        Get.back();
        Get.to(() => ProductPage());
      }
    } catch (e) {
      creatingProductLoad.value = false;
    } finally {
      clearControllers();
    }
  }

  Future<void> uploadImage(Product product) async {
    await uploadProductImages(product.sId!, Get.context!);

    List<dynamic> downloadUrls = selectedImages
        .map((e) => e.imgType == ImageType.network ? e.path : null)
        .toList();

    String snackbarMessage = "";
    try {
      final updateProductFuture =
          ProductService.updateProductsImages(product.sId!, downloadUrls);
      await showDialog(
        context: Get.context!,
        builder: (context) {
          return AsyncProgressDialog(
            updateProductFuture,
            message: const Text("Updating Product"),
          );
        },
      );
    }  catch (e) {
      snackbarMessage = e.toString();
    } finally {
      Get.back();
      selectedImages.clear();
      if (snackbarMessage.isNotEmpty) {
        showSnackBar(message: snackbarMessage, color: Colors.red);
      }
    }
  }

  Future<bool> uploadProductImages(
      String productId, BuildContext context) async {
    bool allImagesUpdated = true;
    for (int i = 0; i < selectedImages.length; i++) {
      if (selectedImages[i].imgType == ImageType.local) {
        String? downloadUrl;
        try {
          final imgUploadFuture = FirestoreFilesAccess().uploadFileToPath(
              File(selectedImages[i].path),
              ProductService.getPathForProductImage(productId, i));
          downloadUrl = await showDialog(
            context: context,
            builder: (context) {
              return AsyncProgressDialog(
                imgUploadFuture,
                message: const Text("uploading images..."),
              );
            },
          );
        } finally {
          if (downloadUrl != null) {
            selectedImages[i] =
                CustomImage(imgType: ImageType.network, path: downloadUrl);
          } else {
            allImagesUpdated = false;
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text(
                  "error",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.mainColor,
              ),
            );
          }
        }
      }
    }
    return allImagesUpdated;
  }

  clearControllers() {
    itemNameController.text = "";
    expiryController.text = "";
    wholeSalePriceController.text = "";
    dealerPriceController.text = "";
    managewholesale.value = false;
    taxable.value = false;
    managedealer.value = false;
    managexpiry.value = false;
    managediscount.value = false;
    manageorderlevel.value = false;
    manageorderlevel.value = false;
    qtyController.text = "";
    buyingPriceController.text = "";
    sellingPriceController.text = "";
    reOrderController.text = "";
    discountController.text = "";
    descriptionController.text = "";
    category.text = "";
    minsellingPriceController.text = "";
    supplierName.value = "None";
    measureController.clear();
    selecteProductCategoty.value = null;
    selectedBadStock.value = null;
    selectedImages.value = [];
  }

  getProductsBySort(
      {required String type,
      String text = "",
      String sort = "",
      String productType = "",
      String scanningFrom = "",
      String shop = "",
      int page = 1,
      int limit = 100,
      String reason = "",
      String productid = "",
      bool showLoader = true,
      String barcodeId = ""}) async {
    if (reason != "download") {
      if (showLoader == true) {
        products.clear();
      }
      loadingproducts.value = showLoader;
    } else {
      productDownloadss.clear();
    }
    bool connected = await isConnected();
    List<dynamic> allproducts;
    Map<String,dynamic> response;
    if (connected &&
        userController.currentUser.value?.primaryShop?.id != null) {
      response = await ProductService.getProductsBySort(
          type: type,
          text: text,
          productType: productType,
          productid: productid,
          limit: limit,
          page: page,
          sort: sort,
          barcodeid: barcodeId,
          shopId: shop == ""
              ? userController.currentUser.value?.primaryShop?.id
              : shop,
          reason: reason);
      allproducts = response['data'];
      // Save fetched products to SQLite
      //do not insert products to SQLite if user is searching
      if (type != "search") {
        for (var product in allproducts) {
          await DatabaseHelper().insertProduct(product);
        }
      }
    } else {
      // Fetch products from SQLite when offline
      allproducts = await DatabaseHelper().getProducts();
    }

    if (reason == "download") {
      productDownloadss
          .addAll(allproducts.map((e) => Product.fromJson(e)).toList());
    } else {
      if (!await isConnected()) {
        products.value = allproducts.map((e) {
          Product product = Product.fromJson(e);
          product.sId = e['id'];
          return product;
        }).toList();
      } else {
        products.value = allproducts.map((e) {
          return Product.fromJson(e);
        }).toList();
      }
      //if its searching do not overwrite the filtered products
      // if (type != "search") {
      filteredProducts.value = products;
      // }
      Get.find<StockController>().productsCount.value = products;
      if (scanningFrom == "salescan" && products.isNotEmpty) {
        Get.find<SalesController>().addToCart(products.first);
      }
    }
    loadingproducts.value = false;
  }

  getProductsAnalysis({required String type, String text = ""}) async {
    loadingproducts.value = true;
    var productAnalysisResponse = await ProductService.getProductsAnalysis(
        shopId: userController.currentUser.value!.primaryShop?.id);
    productAnalysis.value = productAnalysisResponse;
    loadingproducts.value = false;
  }

  getProductsCountsHistory({required String product}) async {
    countHistory.clear();
    List allproducts = await ProductService.getProductsCountsHistory(product);
    List<CountHistory> products =
        allproducts.map((e) => CountHistory.fromJson(e)).toList();
    countHistory.addAll(products);
    countHistory.refresh();
  }

  Future<void> scanQR({required type, required context}) async {
    String barcodeScanRes;
    try {
      var result = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      barcodeScanRes = result == "-1" ? '' : result;

      if (type == "count") {
        searchProductCountController.text = barcodeScanRes;
      }

      getProductsBySort(
          type: "all", barcodeId: barcodeScanRes, scanningFrom: type);
    } on PlatformException {
      showSnackBar(
          message: 'Failed to get platform version.', color: Colors.red);
    }
  }

  deleteProduct({required Product product}) async {
    await ProductService.updateProduct({
      'deleted': true,
    }, product.sId!);
    if (product.images != null && product.images!.isNotEmpty) {
      for (int i = 0; i < product.images!.length; i++) {
        FirestoreFilesAccess().deleteFileFromPath("${product.sId!}_$i");
      }
    }
    getProductsBySort(type: "all");
  }

  assignTextFields(Product productModel) async {
    itemNameController.text = productModel.name!;
    qtyController.text = productModel.quantity!.toStringAsFixed(2);
    buyingPriceController.text = productModel.buyingPrice!.toStringAsFixed(2);
    wholeSalePriceController.text = productModel.wholesalePrice != null
        ? productModel.wholesalePrice!.toStringAsFixed(2)
        : "";
    dealerPriceController.text = productModel.dealerPrice != null
        ? productModel.dealerPrice!.toStringAsFixed(2)
        : "";
    selectedImages.value = productModel.images ?? [];
    sellingPriceController.text = productModel.sellingPrice!.toStringAsFixed(2);
    reOrderController.text = productModel.reorderLevel!.toStringAsFixed(2);
    minsellingPriceController.text = productModel.minSellingPrice == 0 ||
            productModel.minSellingPrice == null
        ? ""
        : productModel.minSellingPrice!.toStringAsFixed(2);
    expiryController.text = productModel.expiryDate != null &&
            productModel.expiryDate!.isNotEmpty
        ? DateFormat("yyyy-MM-dd")
            .format(DateTime.parse(productModel.expiryDate!.toString()).toUtc())
        : "";
    discountController.text = productModel.maxDiscount!.toStringAsFixed(2);
    descriptionController.text = productModel.description!;
    addminPrice.value = minsellingPriceController.text.isNotEmpty;
    taxable.value = productModel.taxable!;
    managediscount.value =
        productModel.maxDiscount != null && productModel.maxDiscount! > 0
            ? true
            : false;
    manageorderlevel.value =
        productModel.reorderLevel != null && productModel.reorderLevel! > 0
            ? true
            : false;
    managexpiry.value =
        productModel.expiryDate != null && productModel.expiryDate!.isNotEmpty
            ? true
            : false;
    managewholesale.value = wholeSalePriceController.text.isNotEmpty &&
        double.parse(wholeSalePriceController.text) > 0;
    managedealer.value = dealerPriceController.text.isNotEmpty &&
        double.parse(dealerPriceController.text) > 0;
    selecteProductCategoty.value = productModel.productCategoryId;
    generateBarcodeOnSave.value =
        (await authController.storage.read(key: "print_barcode") ?? false)
            as bool;
    measureController.text = productModel.measureUnit ?? "";
    productType.value = productModel.type!;
    selectedImages.value = productModel.images ?? [];
  }

  updateQuantity(Map<String, dynamic> data,
      {required String productId, required int index}) async {
    countHistory.removeAt(index);
    countHistory.refresh();
    await ProductService.updateProduct(data, productId);
  }

  saveBadStock({required page, required context}) async {
    try {
      saveBadstockLoad.value = true;
      var data = {
        "productId": selectedBadStock.value?.sId,
        "shopId": userController.currentUser.value?.primaryShop?.id,
        "attendantId": userController.currentUser.value?.attendantId,
        "quantity": double.parse(qtyController.text),
        "unitPrice": selectedBadStock.value?.buyingPrice,
        "reason": spoiltreasonController.text
      };
      var response = await ProductService.saveBadStock(data);
      if (response["error"] != null) {
        showSnackBar(message: response["error"], color: Colors.red);
      }
      spoiltreasonController.clear();
      selectedBadStock.value = null;
      qtyController.clear();

      getBadStock(
          fromDate: DateFormat('yyyy-MM-dd')
              .format(DateTime(DateTime.now().year, DateTime.now().month, 1)),
          toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()));
      showBadStockWidget.value = false;
      saveBadstockLoad.value = false;
      clearControllers();
    } catch (e) {
      saveBadstockLoad.value = false;
    }
  }

  getBadStock(
      {shopId,
      String? attendant,
      String? product = "",
      String? fromDate,
      String? toDate}) async {
    try {
      saveBadstockLoad.value = true;
      badstocks.clear();
      List<dynamic> response = await ProductService.getBadStock(
          product: product, fromDate: fromDate, toDate: toDate);
      badstocks.addAll(response.map((e) => BadStock.fromJson(e)).toList());
      saveBadstockLoad.value = false;
    } catch (e) {
      saveBadstockLoad.value = false;
    }
  }

  getProductPurchasesGroupedByMonth(String product,
      {String? fromDate, String? toDate}) async {
    productMonthPurchases.clear();
    var productsHistory =
        await ProductService.getProductPurchasesGroupedByMonth(
            product: product, startDate: fromDate, toDate: toDate);
    List result = productsHistory;
    productMonthPurchases.addAll(result
        .map((e) => {
              "month": e["month"],
              "totalBuyingPrice": e["totalPurchases"],
              "count": e["count"],
              "totalQuantity": e["totalQuantity"]
            })
        .toList());
    productMonthPurchases.refresh();
  }

  Future<void> getProductCategiories() async {
    loadingproductCategories.value = true;
    productCategories.clear();
    List<dynamic> productCategoriesResponse = await ProductService()
        .getProductCategories(userController.currentUser.value!.id!);
    productCategories.addAll(productCategoriesResponse
        .map((e) => ProductCategory.fromJson(e))
        .toList());
    loadingproductCategories.value = false;
  }

  Future<void> getProductPurchaseHistory(Product? product,
      {required String fromDate, required String toDate}) async {
    var response = await ProductService.getProductPurchasesHistory(
        startDate: fromDate, toDate: toDate, product: product!.sId!);
    if (response["error"] != null) {
      showSnackBar(message: response["error"], color: Colors.red);
    } else {
      List purchses = response["purchases"];
      productPurchases.value =
          purchses.map((e) => InvoiceItem.fromJson(e)).toList();
    }
  }

  Future<void> getBadStockGroupedByMonth(
      {required String year, required String product}) async {
    monthlyBadStocks.clear();
    var productsHistory = await ProductService.getBadStockGroupedByMonth(
      product: product,
      year: year,
    );
    List result = productsHistory["result"];
    monthlyBadStocks.addAll(result
        .map((e) => {
              "month": e["month"],
              "totalLost": e["totalLost"],
              "count": e["count"],
            })
        .toList());
    monthlyBadStocks.refresh();
  }

  Future<void> deleteProductCount(String sId) async {
    countHistory.removeWhere((element) => element.sId == sId);
    countHistory.refresh();
    await ProductService.deleteProductCount(sId);
  }

  Future<void> transferProducts(List<Map<String, dynamic>> value) async {
    LoadingDialog.showLoadingDialog(
      context: Get.context!,
      title: "Please wait...",
      key: _keyLoader,
    );
    var response = await ProductService.transferProducts(value);
    Get.back();
    generalAlert(
        title: "Success",
        message: response["message"],
        negativeCallback: () {
          Get.back();
        },
        function: () {
          Get.back();
        });
  }

  void createCategory() async {
    LoadingDialog.showLoadingDialog(
      context: Get.context!,
      title: "Adding please wait...",
      key: _keyLoader,
    );
    if (categoryName.text.isEmpty) {
      showSnackBar(message: "enter category name", color: Colors.red);
      return;
    }
    var response = await ProductService.createCategory({
      "name": categoryName.text,
      "admin": userController.currentUser.value!.id!
    });
    Get.back();
    if (response["message"] != null) {
      generalAlert(
          title: "Success",
          message: response["message"],
          negativeCallback: () {
            Get.back();
          },
          function: () {
            Get.back();
          });
      getProductCategiories();
    } else {
      showSnackBar(message: response["error"], color: Colors.red);
    }
  }
}
