import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/widgets/alert.dart';

import '../models/salemodel.dart';

class PrinterController extends GetxController {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  RxBool connected = RxBool(false);
  RxBool printing = RxBool(false);
  RxBool searchingPrinters = RxBool(false);

  RxString tips = RxString('no device connect');
  Rxn<BluetoothDevice>? device = Rxn(null);

  printSaleReceipt(
      {required String title, required SaleModel salesModel}) async {
    try {
      Map<String, dynamic> config = {};
      List<LineText> list = [];

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: title,
          weight: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: salesModel.shopId?.name ?? "",
          weight: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(linefeed: 1));

      if (salesModel.shopId?.location != null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Address: ${salesModel.shopId?.location ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }

      if (salesModel.shopId?.contact == null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Contacts: ${salesModel.shopId?.owner?.phone ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }
      if (salesModel.shopId?.contact != null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Contacts: ${salesModel.shopId?.contact ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }

      if (salesModel.shopId?.paybillTill != null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content:
                "${salesModel.shopId?.paybillAccount != null ? "PayBill" : "Buy Goods"}: ${salesModel.shopId?.paybillTill ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }
      if (salesModel.shopId?.paybillAccount != null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "A/c: ${salesModel.shopId?.paybillAccount ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }

      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '**********************************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(linefeed: 1));
      for (var i = 0; i < salesModel.items!.length; i++) {
        final productName = salesModel.items![i].product!.name!;
        final quantity = salesModel.items![i].quantity;
        final unitPrice = htmlPrice(salesModel.items![i].unitPrice! +
            salesModel.items![i].lineDiscount!);
        final totalPrice = htmlPrice(
            (salesModel.items![i].unitPrice! * salesModel.items![i].quantity!) +
                salesModel.items![i].lineDiscount!);

        // Create LineText objects for each line of the item
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: productName,
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "$quantity X $unitPrice",
            weight: 1,
            align: LineText.ALIGN_RIGHT,
            linefeed: 1));
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: totalPrice,
            weight: 1,
            align: LineText.ALIGN_RIGHT,
            linefeed: 1));
      }

      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '**********************************************',
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(linefeed: 1));

      if (salesModel.outstandingBalance! > 0 &&
          salesModel.saleType != "Order") {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Unpaid ${htmlPrice(salesModel.outstandingBalance!)}",
            weight: 1,
            align: LineText.ALIGN_RIGHT,
            linefeed: 1));
      }

      if (salesModel.outstandingBalance! > 0) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content:
                "Total paid ${htmlPrice(salesModel.totalWithDiscount! - salesModel.outstandingBalance!)}",
            weight: 1,
            align: LineText.ALIGN_RIGHT,
            linefeed: 1));
      }

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
              "Sub Total : ${htmlPrice(salesModel.totalAmount! - salesModel.totaltax!)}",
          weight: 1,
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));

      if (salesModel.totalDiscount != null && salesModel.totalDiscount! > 0) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Discount : ${htmlPrice(salesModel.totalDiscount!)}",
            weight: 1,
            align: LineText.ALIGN_RIGHT,
            linefeed: 1));
      }
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "VAT : ${htmlPrice(salesModel.totaltax)}",
          weight: 1,
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "Total : ${htmlPrice(salesModel.totalWithDiscount!)}",
          weight: 1,
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));

      list.add(LineText(linefeed: 1));

      if (salesModel.attendant != null) {
        list.add(LineText(
            type: LineText.TYPE_TEXT,
            content: "Served by : ${salesModel.attendant!.username ?? ""}",
            weight: 1,
            align: LineText.ALIGN_LEFT,
            linefeed: 1));
      }

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "Paid via : ${salesModel.paymentType ?? ""}",
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "Thank You!",
          weight: 1,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
              "RECEIPT # ${salesModel.receiptNo ?? ""}    ${DateFormat("yyy-MM-dd h:mm a").format(DateTime.parse(salesModel.createdAt!).toUtc())}",
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "  ",
          weight: 1,
          align: LineText.ALIGN_LEFT,
          linefeed: 5));

      printing.value = true;
      await bluetoothPrint.printReceipt(config, list);
      printing.value = false;
    } catch (e) {
      printing.value = false;
      generateWarningAlert(title: "Printing error occurred$e");
    }
  }
}
