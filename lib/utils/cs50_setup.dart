import 'dart:io';

import 'package:cs50sdkupdate/cs50sdkupdate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../functions/functions.dart';
import '../main.dart';
import '../models/salemodel.dart';
import 'constants.dart';

class Cs50PrinterSetup {
  final _cs50sdkupdatePlugin = Cs50sdkupdate();
  Future<void> _initPrinter() async {
    try {
      await _cs50sdkupdatePlugin.printInit();
    } catch (e) {}
  }

  Future<void> _printText(String str) async {
    try {
      await _cs50sdkupdatePlugin.printStr('$str\n');
    } catch (e) {
      _showSnackBar('Failed to print text: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _printQRCode(text) async {
    try {
      await _cs50sdkupdatePlugin.printQrCode(text, 200, 200, 'QR_CODE');
    } catch (e) {
      _showSnackBar('Failed to print QR Code: $e');
    }
  }

  // print one structure
  Future<void> printReceipt(
      {required SaleModel saleModel, String? receiptTitle}) async {
    await _initPrinter();

    await _cs50sdkupdatePlugin.printSetAlign(1);
    await _printText(receiptTitle ?? "Cash Receipt");
    await _cs50sdkupdatePlugin.printSetAlign(1);
    await _printText(
      userController.currentUser.value?.primaryShop?.name ?? "Pointify",
    );
    await _printText("Phone No: ${saleModel.shopId?.owner?.phone ?? "000000"}");
    await _printText(
        "Email: ${saleModel.shopId?.owner?.email ?? "email@email.com"}");
    if (saleModel.shopId?.owner?.primaryShop?.paybillAccount != null) {
      await _printText(
          "A/C: ${saleModel.shopId?.owner?.primaryShop?.paybillAccount}");
      await _printText(
          "Paybill: ${saleModel.shopId?.owner?.primaryShop?.paybillTill}");
    } else if (saleModel.shopId?.owner?.primaryShop?.paybillTill != null) {
      await _printText(
          "Till Number: ${saleModel.shopId?.owner?.primaryShop?.paybillTill}");
    }
    await _printText("Receipt No: ${saleModel.receiptNo ?? "000000"}");
    await _printText(
        "Date: ${DateFormat("MMM dd yyyy hh:mm a").format(DateTime.parse(saleModel.createdAt ?? "0000-00-00 00:00:00").toUtc())} ");
    if (saleModel.customerId?.name != null) {
      await _printText("Customer: ${saleModel.customerId?.name}");
    }

    await _printText(" ");
    await _printText(" ");

    const int totalWidth = 40;

    // Define the widths for each column
    final int col1Width = (totalWidth * 0.3).round(); // 50% width
    final int col2Width = (totalWidth * 0.3).round(); // 20% width
    final int col3Width = (totalWidth * 0.2).round(); // 30% width

    String header = '${'Product'.padRight(col1Width)}'
        '${'Quantity'.padRight(col2Width)}'
        '${'Price'.padRight(col3Width)}';
    await _cs50sdkupdatePlugin.printStr(header);
// Function to truncate text to fit within the column width
    String truncate(String text, int width) {
      return (text.length > width)
          ? '${text.substring(0, width - 3)}...'
          : text.padRight(width);
    }

    saleModel.items?.forEach((item) async {
      String product = truncate(item.product?.name ?? '', col1Width);
      String quantity = item.quantity.toString().padLeft(col2Width);
      String price = item.totalLinePrice.toString().padLeft(col3Width);

      // Print each item with padding for alignment
      String line = '$product$quantity$price';
      await _cs50sdkupdatePlugin.printStr(line);
    });

    await _cs50sdkupdatePlugin.printSetAlign(0);
    await _cs50sdkupdatePlugin.printSetAlign(2);
    await _printText(" ");
    await _printText(" ");
    await _printText("Sub total: ${htmlPrice(saleModel.totalAmount)}");
    await _printText("Discount: ${htmlPrice(saleModel.totalDiscount)}");
    await _printText("Tax: ${htmlPrice(saleModel.totaltax)}");
    await _printText("Total: ${htmlPrice(saleModel.totalWithDiscount)}");
    await _printText(" ");
    await _printText(" ");
    await _cs50sdkupdatePlugin.printSetAlign(1);
    String url = "";
    if (Platform.isAndroid) {
      url = androidLink;
    } else if (Platform.isIOS) {
      url = iosLink;
    }
    if (url != "") {
      await _printQRCode(url);
    }
    await _printText("Paid by: ${saleModel.paymentType?.toUpperCase()}");
    await _printText("Served By: ${saleModel.attendant?.username ?? "admin"}");
    await _printText("Thank you for shopping with us");
    await _printText("Powered by Pointify POS");
    await _printText("contacts  ${settingsData["contact"]}");
    await _printText(" ");
    await _printText(" ");
    await _printText(" ");
    await _printText(" ");
    await _cs50sdkupdatePlugin.printStart();
  }
}
