import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/shop.dart';

import '../../../../controllers/reports_controller.dart';

Future<Uint8List> productsalesReportPdf(String printby, String type) async {
  Shop shop = userController.currentUser.value!.primaryShop!;
  ReportsController reportsController = Get.find<ReportsController>();
  final pdf = Document();
  pdf.addPage(
    Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(shop.name!.toUpperCase(),
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              Text(shop.location ?? "",
                  style: const TextStyle(fontSize: 13),
                  softWrap: true,
                  maxLines: 2),
              SizedBox(height: 10),
              Text(
                  "Between ${reportsController.filterStartDate.value} and ${reportsController.filterEndDate.value}",
                  style: const TextStyle(fontSize: 13)),
              SizedBox(height: 20),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                        child: Text(type,
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                  ]),
              SizedBox(height: 20),
              TableHelper.fromTextArray(
                  border: TableBorder.all(width: 1), //table border
                  headers: [
                    "Receipt No",
                    "Date",
                    "Sale",
                    "Total",
                  ],
                  data: reportsController.productsReportFiltered
                      .map((e) => [
                            e.receiptNo,
                            Text(
                                DateFormat("MMM dd yyyy HH:mm")
                                    .format(DateTime.parse(e.createdAt!)),
                                style: const TextStyle(fontSize: 9)),
                            Text(
                              '${e.quantity!} x ${e.unitPrice!}',
                            ),
                            htmlPrice(e.totalLinePrice),
                          ])
                      .toList()),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                    width: 200,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (printby == "receipts")
                            Text(
                              "Mpesa ${htmlPrice(reportsController.filterPaymentTypeTotals['mpesa'] ?? 0.0)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          if (printby == "receipts")
                            Text(
                              "Bank ${htmlPrice(reportsController.filterPaymentTypeTotals['bank'] ?? 0.0)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          if (printby == "receipts")
                            Text(
                              "Cash ${htmlPrice(reportsController.filterPaymentTypeTotals['cash'] ?? 0.0)}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          Divider(
                              thickness: 1,
                              color: const PdfColor.fromInt(0xFF000000)),
                          if (printby == "receipts")
                            Text(
                              "Totals ${htmlPrice(reportsController.productsReport.fold(0.0, (previousValue, element) => previousValue + element.totalLinePrice!))}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          if (printby == "products")
                            Text(
                              "Totals ${htmlPrice(reportsController.productsReport.fold(0.0, (previousValue, element) => previousValue + (element.unitPrice! * element.quantity!)))}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          Divider(
                              thickness: 1,
                              color: const PdfColor.fromInt(0xFF000000))
                        ])),
              ),
              SizedBox(height: 10),
              Text(
                  "Printed by : ${userController.currentUser.value!.username ?? ""}"),
              Spacer(),
              Align(
                  alignment: Alignment.center,
                  child:
                      Text("Thank you!", style: const TextStyle(fontSize: 28)))
            ],
          ),
        );
      },
    ),
  );
  return pdf.save();
}
