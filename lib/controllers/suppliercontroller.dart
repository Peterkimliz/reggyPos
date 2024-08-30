import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/productcontroller.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/saleitem.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/suppliers/suppliers_page.dart';
import 'package:reggypos/widgets/snackBars.dart';

import '../functions/functions.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/supplier.dart';
import '../screens/product/create_product.dart';
import '../screens/sales/create_sale.dart';
import '../services/supplier_service.dart';
import '../widgets/loading_dialog.dart';
import 'homecontroller.dart';

class SupplierController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ProductController productController = Get.find<ProductController>();
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  RxList<InvoiceItem> suppliersupplies = RxList([]);
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController namesController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  RxBool loadingImportedSuppliers = RxBool(false);

  RxBool creatingSupplierLoad = RxBool(false);
  RxBool getSupplierReturnsLoad = RxBool(false);
  RxBool getsupplierLoad = RxBool(false);
  RxBool isLoadingSupplies = RxBool(false);
  RxBool loadingsuppliers = RxBool(false);
  RxBool supliesReturnedLoad = RxBool(false);
  RxList<Supplier> suppliers = RxList([]);
  RxList<Supplier> filteredSuppliers = RxList([]);
  RxList<SaleItem> returnedPurchases = RxList([]);
  Rxn<Supplier> supplier = Rxn(null);
  RxBool suppliersOnCreditLoad = RxBool(false);

  RxBool savesupplierLoad = RxBool(false);
  RxBool getSinglesupplier = RxBool(false);
  RxBool updatesupplierLoad = RxBool(false);
  RxBool deletesupplierLoad = RxBool(false);
  RxBool gettingSupplierSupliesLoad = RxBool(false);
  RxBool gettingSuppliesLoad = RxBool(false);
  RxBool returningLoad = RxBool(false);
  RxBool getSupplierLoad = RxBool(false);
  RxBool gettingSupliesReturnerLoad = RxBool(false);
  var purchaseOrder = [].obs;
  var returnedProducts = [].obs;
  var supplies = [].obs;
  Rxn<Customer> singleSupplier = Rxn(null);
  RxInt totals = RxInt(0);
  RxInt totalsReturn = RxInt(0);
  RxInt initialPage = RxInt(0);
  late TabController tabController;
  var sType = 'debtors'.obs;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  createSupplier({required BuildContext context, required page}) async {
    try {
      LoadingDialog.showLoadingDialog(
          context: context, title: "Creating supplier...", key: _keyLoader);
      creatingSupplierLoad.value = true;
      var supplier = {
        "name": nameController.text,
        "shopId": userController.currentUser.value?.primaryShop?.id,
        "phoneNumber": phoneController.text,
      };
      await SupplierService().createSupplier(supplier);
      await getSuppliers('');
      clearTexts();
      Get.back();
      if (!isSmallScreen(Get.context!)) {
        debugPrintMessage(page);
        if (page == "suppliersPage") {
          Get.find<HomeController>().selectedWidget.value = SuppliersPage();
        }
        if (page == "createSale") {
          Get.find<HomeController>().selectedWidget.value = CreateSale();
        }
        if (page == "createProduct") {
          Get.find<HomeController>().selectedWidget.value = CreateProduct(
            page: "create",
            productModel: null,
            clearInputs: false,
          );
        }
        if (page == "createPurchase") {
          // Get.find<HomeController>().selectedWidget.value = CreatePurchase();
        }
      } else {
        Get.back();
      }

      creatingSupplierLoad.value = false;
    } catch (e) {
      debugPrintMessage(e);
      creatingSupplierLoad.value = false;
    }
  }

  clearTexts() {
    nameController.text = "";
    phoneController.text = "";
    genderController.text = "";
    emailController.text = "";
    addressController.text = "";
    amountController.text = "";
  }

  getSuppliers(type, {String? name, String? shop}) async {
    loadingsuppliers.value = true;
    suppliers.clear();
    List<dynamic> suppliersList = await SupplierService().getSuppliers(
        name: name,
        shop: userController.currentUser.value?.primaryShop?.id.toString(),
        type: type);
    suppliers.addAll(suppliersList.map((e) => Supplier.fromJson(e)).toList());
    filteredSuppliers.value = suppliers;
    loadingsuppliers.value = false;
  }

  assignTextFields(Supplier supplierModel) {
    nameController.text = supplierModel.name ?? "";
    phoneController.text = supplierModel.phoneNumber ?? "";
    emailController.text = supplierModel.email ?? "";
    addressController.text = supplierModel.address ?? "";
  }

  updateSupplier(Supplier supplierModel) async {
    LoadingDialog.showLoadingDialog(
        context: Get.context!, title: "Please wait...", key: _keyLoader);
    var data = {
      "name": nameController.text,
      "phoneNumber": phoneController.text,
      "email": emailController.text,
      "address": addressController.text
    };
    var response = await SupplierService.updateSupplier(supplierModel, data);
    Get.back();
    if (response["error"] != null) {
      showSnackBar(message: response["error"], color: Colors.red);
      return;
    }
    showSnackBar(
        message: "supplier info updated successfully", color: Colors.green);
    supplier.value = Supplier.fromJson(response);
    supplier.refresh();
    debugPrintMessage(response);
  }

  deleteSuppler(Supplier supplier) {
    // if (supplier.balance! < 0) {
    //   generalAlert(
    //       title: "Error",
    //       message: "you cannot delete a supplier with a negative balance");
    //   return;
    // }
    // SupplierService().deleteSupplier(supplier);
    // isSmallScreen(Get.context)
    //     ? Get.back()
    //     : Get.find<HomeController>().selectedWidget.value = SuppliersPage();
  }

  // importContacts() async {
  //   if (await FlutterContacts.requestPermission()) {
  //     loadingImportedSuppliers.value = true;
  //
  //     List<Contact> contacts = await FlutterContacts.getContacts(
  //         withProperties: true, withPhoto: true);
  //     await getSuppliers("");
  //     loadingImportedSuppliers.value = false;
  //
  //     importedSuppliers.addAll(contacts);
  //     filteredSuppliers.value = importedSuppliers;
  //     for (var cust in filteredSuppliers) {
  //       int index = suppliers.indexWhere((element) =>
  //           element.phoneNumber.toString() ==
  //           cust.phones[0].normalizedNumber.trim());
  //       if (index != -1) {
  //         importedSuppliers.removeAt(index);
  //         filteredSuppliers.removeAt(index);
  //       }
  //     }
  //     importedSuppliers.refresh();
  //     filteredSuppliers.refresh();
  //   }
  // }
  //
  // importSupplier({required Contact contact}) async {
  //   try {
  //     LoadingDialog.showLoadingDialog(
  //         context: Get.context!, title: "Saving Supplier", key: _keyLoader);
  //     var supplier = {
  //       "address":
  //           contact.addresses.isNotEmpty ? contact.addresses[0].address : "",
  //       "email": emailController.text,
  //       "phoneNumber": contact.phones[0].normalizedNumber,
  //       "attendantId": userController.currentUser.value?.attendantId?.sId,
  //       "name": contact.displayName,
  //       "shopId": userController.currentUser.value?.primaryShop?.id,
  //     };
  //     await SupplierService().createSupplier(supplier);
  //     Get.back();
  //     generalAlert(
  //       title: "Success",
  //       message: "Supplier ${contact.displayName} successfully",
  //     );
  //
  //     importedSuppliers.removeWhere((element) => element.id == contact.id);
  //     importedSuppliers.refresh();
  //   } catch (e) {
  //     Get.back();
  //     print("Error is ${e}");
  //   }
  // }
}
