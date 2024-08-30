import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reggypos/models/saleitem.dart';
import 'package:reggypos/models/stockreport.dart';
import 'package:reggypos/services/end_points.dart';
import 'package:reggypos/services/reports.dart';

import '../main.dart';
import '../models/debtor.dart';
import '../models/payment.dart';

class ReportsController extends GetxController {
  RxBool isLoadingReports = RxBool(false);
  RxMap<String, dynamic> salesReportData = RxMap({});

  RxMap<String, dynamic> grossProfit = RxMap({"gross": 0, "netprofit": 0});
  List<Map<String, dynamic>> salesCard = [];
  List<Map<String, dynamic>> purchasesCard = [];
  List<StockReport> stockReports = RxList([]);
  TextEditingController textStartDate = TextEditingController();
  TextEditingController searchProductSoldController = TextEditingController();
  TextEditingController textEndDate = TextEditingController();

  RxList<String> salesFilter = RxList(['Wholesale', 'Retail', 'Dealer']);
  RxList<String> paymentypes = RxList(['cash', 'mpesa', 'bank']);
  RxString cashsalesfilterSelected = RxString("cash");
  RxString salesFilterSelected = RxString("Retail");
  RxMap<String, dynamic> filterPaymentTypeTotals =
      RxMap({'cash': 0, 'mpesa': 0, 'bank': 0});
  RxString activeFilter = RxString('today');
  RxInt totalSales = RxInt(0);
  var filterStartDate = DateFormat("yyy-MM-dd").format(DateTime.now()).obs;
  var filterEndDate = DateFormat("yyy-MM-dd").format(DateTime.now()).obs;
  RxList<Payment> payments = RxList([]);
  RxList<Debtor> debtors = RxList([]);
  RxList<SaleItem> productsReport = RxList([]);
  RxList<SaleItem> discountsReport = RxList([]);
  RxList<SaleItem> productsReportFiltered = RxList([]);
  RxList<SaleItem> discountReportFiltered = RxList([]);
  RxBool isPaymentLoading = false.obs;
  getStockReport({
    String? shopid,
  }) async {
    isLoadingReports.value = true;
    List respose = await ReportsService().getStockReport(shopid: shopid);
    List<StockReport> stockreports =
        respose.map((e) => StockReport.fromJson(e)).toList();
    stockReports.assignAll(stockreports);
    isLoadingReports.value = false;
  }

  getPurchasesReport({
    String? startDate,
    String? toDate,
    String? shopid,
  }) async {
    var types = [
      {
        "title": "Total Purchases",
        "key": "cash",
        "amount": 0,
        "description": "Click to view more details"
      },
      {
        "title": "Credit Purchases",
        "key": "credit",
        "amount": 0,
        "description": "Purchases made on credit"
      },
      // {
      //   "title": "Paid Debt",
      //   "key": "paid",
      //   "amount": 0,
      //   "description": "Total debt paid to creditors"
      // },
      {
        "title": "Returns",
        "key": "returns",
        "amount": 0,
        "description": "Purchases returned to suppliers"
      },
      // {
      //   "title": "Wallet Sales",
      //   "key": "wallet",
      //   "amount": 0,
      //   "description": "Sales sold through customer wallets"
      // },
      {
        "title": "On hold sales",
        "key": "hold",
        "amount": 0,
        "description": "Sales that has not been cashed in"
      },
    ];
    isLoadingReports.value = true;
    var respose = await ReportsService().getPurchasesReport(
        startDate: startDate, toDate: toDate, shopid: shopid);
    salesCard.clear();
    totalSales.value = 0;
    for (var element in types) {
      if (respose[element["key"]] != null) {
        element["amount"] = respose[element["key"]];
        salesCard.add(element);
        if (element["key"] == "cash" ||
            element["key"] == "credit" ||
            // element["key"] == "paid" ||
            element["key"] == "wallet") {
          totalSales.value += respose[element["key"]] as int;
        }
      }
    }
    salesReportData.value = respose;
    isLoadingReports.value = false;
  }

  getGrossProfit({
    String? startDate,
    String? toDate,
    String? shopid,
  }) async {
    isLoadingReports.value = true;
    var respose = await ReportsService()
        .getGrossProfit(startDate: startDate, toDate: toDate, shopid: shopid);
    grossProfit.value = respose;
    isLoadingReports.value = false;
  }

  getSalesReport({
    String? startDate,
    String? toDate,
    String? shopid,
  }) async {
    var types = [
      {
        "title": "Cash Sales",
        "key": "cash",
        "amount": 0,
        "description": "All Sales made on cash"
      },
      // {
      //   "title": "Mpesa Sales",
      //   "key": "mpesa",
      //   "amount": 0,
      //   "description": "All Sales made to mpesa account"
      // },
      // {
      //   "title": "Banks Sales",
      //   "key": "bank",
      //   "amount": 0,
      //   "description": "All Sales made to mpesa account"
      // },
      {
        "title": "Credit Sales",
        "key": "credit",
        "amount": 0,
        "description": "Sales made on credit"
      },
      {
        "title": "Collected Debt",
        "key": "paid",
        "amount": 0,
        "description": "Total credit paid by debtors"
      },
      {
        "title": "Returns",
        "key": "returns",
        "amount": 0,
        "description": "Sales returned from customers"
      },
      {
        "title": "Wallet Sales",
        "key": "wallet",
        "amount": 0,
        "description": "Sales sold through customer wallets"
      },
      {
        "title": "On hold sales",
        "key": "hold",
        "amount": 0,
        "description": "Sales that has not been cashed in"
      },
    ];
    isLoadingReports.value = true;
    var respose = await ReportsService()
        .getSalesReport(startDate: startDate, toDate: toDate, shopid: shopid);
    salesCard.clear();
    totalSales.value = 0;
    for (var element in types) {
      if (respose[element["key"]] != null) {
        element["amount"] = respose[element["key"]];
        salesCard.add(element);
        if (element["key"] == "cash" ||
            element["key"] == "credit" ||
            element["key"] == "paid" ||
            element["key"] == "mpesa" ||
            element["key"] == "bank" ||
            element["key"] == "wallet") {
          totalSales.value += respose[element["key"]] as int;
        }
      }
    }
    salesReportData.value = respose;
    isLoadingReports.value = false;
  }

  void getDebtors({String? shopid}) async {
    debtors.clear();
    isLoadingReports.value = true;
    var response = await ReportsService().getDebtors(shopid: shopid!);
    if (response['message'] != null) {
      debtors.value = [];
      isLoadingReports.value = false;
      return;
    }
    List result = response['data'];
    debtors.addAll(result.map((e) => Debtor.fromJson(e)).toList());
    isLoadingReports.value = false;
  }

  Future<void> downloadExcelFile() async {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          return;
        }
      }

      final dio.Dio dioInstance = dio.Dio();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/customers_with_debt.xlsx';

      // Download the file
      dio.Response response = await dioInstance.get(
        '${EndPoints.debtorexcel}?shopId=${userController.currentUser.value!.primaryShop!.id!}',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      // Ensure the response data is not empty
      if (response.data != null && response.data is List<int>) {
        File file = File(filePath);
        await file.writeAsBytes(response.data);
      await OpenFile.open(filePath);
      }

  }


  void getDebtorExcel() async {
    isLoadingReports.value = true;
    var response = await ReportsService().getDebtorExcel(
        shopid: userController.currentUser.value!.primaryShop!.id!);
    if (response['message'] != null) {
      debtors.value = [];
      isLoadingReports.value = false;
      return;
    }
    List result = response['data'];
    debtors.addAll(result.map((e) => Debtor.fromJson(e)).toList());
    isLoadingReports.value = false;
  }

  getProductSaleFilter({String? type}) {
    productsReportFiltered.clear();
    if (type == "mpesa") {
      productsReportFiltered.addAll(productsReport
          .where((element) =>
              element.currentSale != null &&
              element.currentSale!.mpesatotal! > 0)
          .toList());
    }
    if (type == "bank") {
      productsReportFiltered.addAll(productsReport
          .where((element) =>
              element.currentSale != null &&
              element.currentSale!.banktotal! > 0)
          .toList());
    }
    if (type == "cash") {
      productsReportFiltered.addAll(productsReport
          .where((element) =>
              element.currentSale != null &&
              element.totalLinePrice! > 0 &&
              element.currentSale!.paymentTag == "cash")
          .toList());
    }
  }

  void productsWisereport(
      {String? shop,
      String? fromDate,
      String? toDate,
      String? product,
      String? saleType = "Retail",
      showLoader = true}) async {
    if (showLoader == true) {
      if (isLoadingReports.isTrue) {
        return;
      }
      isLoadingReports.value = true;
    }
    productsReport.clear();
    productsReportFiltered.clear();
    var response = await ReportsService().productsWisereport(
        shop: shop,
        fromDate: fromDate,
        toDate: toDate,
        product: product,
        saleType: saleType);
    List result = response['items'];
    productsReport.addAll(result.map((e) => SaleItem.fromJson(e)).toList());
    for (var element in productsReport) {
      if (element.currentSale != null) {
        productsReportFiltered.add(element);
      }
    }

    isLoadingReports.value = false;

    getTotals();
    getProductSaleFilter(type: cashsalesfilterSelected.value);
  }

  void discountReport(
      {String? shop,
      String? fromDate,
      String? toDate,
      String? product,
      String? saleType = "Retail",
      showLoader = true}) async {
    if (showLoader == true) {
      if (isLoadingReports.isTrue) {
        return;
      }
      isLoadingReports.value = true;
    }
    discountsReport.clear();
    discountReportFiltered.clear();
    var response = await ReportsService().discountReport(
        shop: shop,
        fromDate: fromDate,
        toDate: toDate,
        product: product,
        saleType: saleType);
    List result = response['items'];
    discountsReport.addAll(result.map((e) => SaleItem.fromJson(e)).toList());
    for (var element in discountsReport) {
      if (element.currentSale != null) {
        discountReportFiltered.add(element);
      }
    }

    isLoadingReports.value = false;

    getTotals();
    getProductSaleFilter(type: cashsalesfilterSelected.value);
  }

  getTotals() {
    var data = {"total": 0.0, "mpesa": 0.0, "bank": 0.0, "cash": 0.0};
    for (var element in productsReportFiltered) {
      if (element.currentSale != null) {
        if (element.currentSale!.mpesatotal! > 0) {
          data["mpesa"] = element.currentSale!.mpesatotal! + data["mpesa"]!;
        }
        if (element.currentSale!.banktotal! > 0) {
          data["bank"] = element.currentSale!.banktotal! + data["bank"]!;
        }
        if (element.totalLinePrice! > 0 &&
            element.currentSale!.paymentTag == "cash") {
          data["cash"] = element.totalLinePrice! + data["cash"]!;
        }
        data["total"] = data["total"]! + 1;
      }
    }
    filterPaymentTypeTotals.value = data;
  }
}
