import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/reports_controller.dart';
import 'package:reggypos/models/stockreport.dart';
import 'package:printing/printing.dart';

import '../functions/functions.dart';
import '../main.dart';
import '../screens/receipts/pdf/stock_report_pdf.dart';
import '../utils/colors.dart';

class StockReportScreen extends StatelessWidget {
  StockReportScreen({super.key}) {
    reportsController.getStockReport(
        shopid: userController.currentUser.value!.primaryShop!.id);
  }
  final ReportsController reportsController = Get.find<ReportsController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Stock Report",
          style: TextStyle(color: AppColors.mainColor),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => Scaffold(
                      appBar: AppBar(
                        title: const Text("Stock Report"),
                      ),
                      body: PdfPreview(
                        build: (context) => stockReportPdf(
                            reportsController.stockReports, "Stock Report"),
                      ),
                    ));
              },
              icon: const Icon(
                Icons.picture_as_pdf,
                color: AppColors.mainColor,
              ))
        ],
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.clear,
            color: AppColors.mainColor,
          ),
        ),
      ),
      body: Obx(
        () => DataTable2(
          columnSpacing: 5,
          horizontalMargin: 5,
          minWidth: 400,
          columns: const [
            DataColumn2(
              label: Text('Product'),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text('Sold '),
            ),
            DataColumn(
              label: Text('Remaining'),
            ),
            DataColumn(
              label: Text('Sales'),
            ),
            DataColumn(
              label: Text('Profit'),
            ),
          ],
          rows: List<DataRow>.generate(reportsController.stockReports.length,
              (index) {
            StockReport? stockReport =
                reportsController.stockReports.elementAt(index);

            return DataRow(cells: [
              DataCell(Text(stockReport.name!)),
              DataCell(Text(stockReport.totalSoldQuantity.toString())),
              DataCell(Text(stockReport.inStockQuantity.toString())),
              DataCell(Text(htmlPrice(stockReport.totalSales))),
              DataCell(Text(htmlPrice(stockReport.totalProfit))),
            ]);
          }),
          fixedLeftColumns: 1,
        ),
      ),
    );
  }
}
