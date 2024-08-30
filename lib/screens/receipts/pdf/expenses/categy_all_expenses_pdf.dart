import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/shop.dart';

import '../../../../controllers/reports_controller.dart';
import '../../../../models/expensestransaction.dart';

Future<Uint8List> categoryAllExpensesPdf(
    List<ExpensesTransactionModel> expenses, type) async {
  Shop shop = userController.currentUser.value!.primaryShop!;
  ReportsController reportsController = Get.find<ReportsController>();
  final pdf = Document();
  final imageLogo = MemoryImage(
      (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List());
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
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Image(imageLogo),
                  ),
                  Column(
                    children: [
                      Text("Shop : ${shop.name!}",
                          style: const TextStyle(fontSize: 21)),
                      Text("Address: ${shop.location ?? ""}",
                          style: const TextStyle(fontSize: 21))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                  child: TableHelper.fromTextArray(
                      border: TableBorder.all(width: 1), //table border
                      headers: [
                        "Comment",
                        "Date",
                        "Amount",
                      ],
                      data: expenses
                          .map((e) => [
                                e.description,
                                DateFormat("MMM dd yyyy hh:mm a")
                                    .format(DateTime.parse(e.createdAt!)),
                                htmlPrice(e.amount),
                              ])
                          .toList())),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                    width: 200,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Totals ${htmlPrice(expenses.fold(0, (previousValue, element) => previousValue + element.amount!))}",
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
