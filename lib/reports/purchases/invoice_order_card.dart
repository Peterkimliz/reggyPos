import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/screens/receipts/view/invoice_screen.dart';
import 'package:reggypos/widgets/minor_title.dart';

import '../../models/invoice.dart';
import '../../widgets/normal_text.dart';

Widget invoiceCard({required Invoice invoice, String? tab, String? type}) {
  return InkWell(
    onTap: () {
      Get.to(() => InvoiceScreen(
            invoice: invoice,
            type: type,
          ));
    },
    child: Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Invoice# ${invoice.purchaseNo}".toUpperCase(),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold),
                        ),
                        if (invoice.outstandingBalance! > 0)
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            child: Column(
                              children: [
                                minorTitle(
                                    title:
                                        "Unpaid: ${htmlPrice(invoice.outstandingBalance)}",
                                    color: Colors.red),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        normalText(
                            title:
                                "Amount: ${htmlPrice(invoice.items!.fold(0.0, (previousValue, element) => previousValue + element.quantity! * element.unitPrice!))}",
                            color: Colors.black,
                            size: 14.0),
                        // const SizedBox(width: 30),
                        // minorTitle(
                        //     title:
                        //         "Products: ${invoice.items!.fold(0.0, (previousValue, element) => previousValue + element.quantity!) > 0 ? invoice.items!.fold(0.0, (previousValue, element) => previousValue + element.quantity!) : 0}",
                        //     color: Colors.black),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              normalText(
                  title:
                      "On :${DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.parse(invoice.createdAt!).toLocal())}",
                  color: Colors.black,
                  size: 14.0),
              const Spacer(),
              if (invoice.paymentType == "credit")
                const Text(
                  "payment type : Credit",
                ),
              if (invoice.paymentType == "cash")
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  decoration: BoxDecoration(
                      color: chechPaymentColor(invoice),
                      borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    chechPayment(invoice),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          )
        ],
      ),
    ),
  );
}

String chechPayment(Invoice salesModel) {
  if (salesModel.invoiceType == "return") return "RETURNED";
  if (salesModel.outstandingBalance == 0) return "PAID";
  if (salesModel.outstandingBalance! > 0) return "NOT PAID";
  return "";
}

Color chechPaymentColor(Invoice invoice) {
  if (invoice.invoiceType == "return") return Colors.red;
  if (invoice.outstandingBalance == 0) return Colors.green;
  if (invoice.outstandingBalance! > 0) return Colors.red;
  return Colors.black;
}
