import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/homecontroller.dart';
import 'package:reggypos/pdfFiles/pdf/productmonthlypdf/product_monthly_report.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:printing/printing.dart';

import '../../../models/product.dart';
import '../../../screens/product/product_history.dart';

class MonthlyPreviewPage extends StatelessWidget {
 final  List<dynamic> ?sales;
  final String? type;
 final String? title;
  final double? total;
  final Product? product;

  const MonthlyPreviewPage(
      {Key? key,
       this.sales,
      this.type,
      required this.product,
      this.title,
      this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              isSmallScreen(context)
                  ? Get.back()
                  : Get.find<HomeController>().selectedWidget.value =
                      ProductHistory(product: product!);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: isSmallScreen(context) ? Colors.white : Colors.black,
            )),
        backgroundColor:
            isSmallScreen(context) ? AppColors.mainColor : Colors.white,
        title: Text(
          type ?? "",
          style: TextStyle(
              color: isSmallScreen(context) ? Colors.white : Colors.black),
        ),
      ),
      body: PdfPreview(
        build: (context) => productMonthlyReport(sales,
            product: product!, title: title, total: total),
      ),
    );
  }
}
