import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/homecontroller.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../controllers/salescontroller.dart';
import '../models/product.dart';
import '../screens/product/tabs/bad_stock_history.dart';
import '../screens/product/tabs/receipts_sales.dart';
import '../screens/product/tabs/stockin_history.dart';
import '../screens/sales/all_sales.dart';
import 'colors.dart';

class DateFilter extends StatelessWidget {
  final String from;
  final String? page;
  final String? headline;
  final Function? function;
  final Product? product;
 final int? i;

  DateFilter(
      {Key? key,
      this.function,
      this.product,
      this.i,
      required this.from,
      this.page,
      this.headline})
      : super(key: key);
  final SalesController salesController = Get.find<SalesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isSmallScreen(context) ? AppColors.mainColor : Colors.white,
        elevation: 0.2,
        leading: IconButton(
            onPressed: () {
              isSmallScreen(context) ? Get.back() : backPress();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: isSmallScreen(context) ? Colors.white : Colors.black,
            )),
      ),
      body: SfDateRangePicker(
          showActionButtons: true,
          confirmText: "Filter",
          selectionMode: DateRangePickerSelectionMode.range,
          maxDate: DateTime.now(),
          monthViewSettings: const DateRangePickerMonthViewSettings(),
          headerStyle: const DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainColor,
                  fontSize: 18)),
          onSubmit: (value) {
            // debugPrint(e)(value);
            function!(value);

            if (isSmallScreen(context)) {
              Get.back();
            } else {
              backPress();
            }


          }),
    );
  }

  backPress() {

    if (from == "ProductReceiptsSales") {
      Get.find<HomeController>().selectedWidget.value =
          ProductReceiptsSales(product: product!, i: i!);
    } else if (from == "ProductStockHistory") {
      Get.find<HomeController>().selectedWidget.value =
          ProductStockHistory(product: product!, i: i!);
    } else if (from == "ProfitPage") {
      // Get.find<HomeController>().selectedWidget.value = ProfitPage(
      //   page: page,
      //   headline: headline,
      // );
    } else if (from == "AllSalesPage") {
      Get.find<HomeController>().selectedWidget.value = AllSalesPage(
        page: page,
      );
    } else {
      Get.find<HomeController>().selectedWidget.value =
          BadStockHistory(product: product!, i: i!);
    }
  }
}
