import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/shop.dart';

import '../../../../controllers/reports_controller.dart';
import '../../../../models/productcount.dart';

Future<Uint8List> salesTakeReportPdf(
    List<ProductCount> productsCount, type) async {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(" ${shop.name!}",
                          style: const TextStyle(fontSize: 21)),
                      Text(" ${shop.location ?? ""}",
                          style: const TextStyle(fontSize: 21))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ],
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                        child: Text(type,
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    SizedBox(height: 10),
                    Text(
                      "Between ${reportsController.filterStartDate.value} and ${reportsController.filterEndDate.value}",
                    ),
                  ]),
              SizedBox(height: 20),
              TableHelper.fromTextArray(
                  border: TableBorder.all(width: 1), //table border
                  headers: [
                    "Item",
                    "System Count",
                    "Physical Count",
                    "Variance",
                  ],
                  data: productsCount
                      .map((e) => [
                            e.items!.first.name!,
                            e.items!.first.initialCount!.toString(),
                            e.items!.first.physicalCount!.toString(),
                            e.items!.first.physicalCount! -
                                        e.items!.first.initialCount! >
                                    0
                                ? "+${e.items!.first.variance!}"
                                : "-${e.items!.first.variance!}",
                          ])
                      .toList()),
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
