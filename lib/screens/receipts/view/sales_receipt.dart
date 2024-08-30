import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/controllers/paymentcontroller.dart';
import 'package:reggypos/controllers/printercontroller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/models/saleitem.dart';
import 'package:reggypos/screens/cash_flow/payment_history.dart';
import 'package:reggypos/widgets/textbutton.dart';
import 'package:printing/printing.dart';

import '../../../controllers/salescontroller.dart';
import '../../../controllers/shopcontroller.dart';
import '../../../models/product.dart';
import '../../../models/salemodel.dart';
import '../../../printing_page.dart';
import '../../../utils/colors.dart';
import '../../../utils/cs50_setup.dart';
import '../../../utils/sunmi.dart';
import '../../../utils/themer.dart';
import '../../../widgets/alert.dart';
import '../../../widgets/major_title.dart';
import '../../../widgets/normal_text.dart';
import '../pdf/delivery_note_pdf.dart';

class SalesReceipt extends StatelessWidget {
  final SaleModel? salesModel;
  final String? type;
  final String? from;

  SalesReceipt({Key? key, this.salesModel, this.type = "", this.from = ""})
      : super(key: key) {
    salesController.currentReceipt.value = salesModel;
  }

  final ShopController shopController = Get.find<ShopController>();
  final SalesController salesController = Get.find<SalesController>();
  final PaymentController paymentController = Get.find<PaymentController>();
  final PrinterController printerController = Get.find<PrinterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Receipt No. #${salesController.currentReceipt.value?.receiptNo ?? ""}",
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (verifyPermission(
                        category: "sales", permission: "return"))
                      InkWell(
                        onTap: () {
                          saleReceiptActions(
                              saleModel: salesController.currentReceipt.value!,
                              from: from ?? "");
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                )
                              ]),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: const Row(
                            children: [
                              Text(
                                "Refund",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (verifyPermission(
                            category: "sales", permission: "return") ==
                        false)
                      Container(),
                    InkWell(
                      onTap: () {
                        Get.to(() => Scaffold(
                              appBar: AppBar(
                                title: const Text("Delivery Note"),
                              ),
                              body: PdfPreview(
                                build: (context) => deliveryNotePdf(
                                    salesController.currentReceipt.value!,
                                    "Delivery Note"),
                              ),
                            ));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 10),
                        child: const Row(
                          children: [
                            Text(
                              "Delivery Note",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.print, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Divider(
                  height: 0,
                  thickness: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                if (salesController.currentReceipt.value!.customerId == null)
                  const SizedBox(
                    height: 10,
                  ),
                if (salesController.currentReceipt.value!.customerId != null)
                  Row(
                    children: [
                      Text(
                        "Customer: ${salesController.currentReceipt.value!.customerId!.name!}",
                        style: const TextStyle(fontSize: 13),
                      ),
                      const Spacer(),
                      if (salesController
                                  .currentReceipt.value!.outstandingBalance! >
                              0 &&
                          salesController.currentReceipt.value!.dueDate != null)
                        Row(
                          children: [
                            normalText(
                                title: "Due Date:",
                                color: Colors.black,
                                size: 14.0),
                            const SizedBox(
                              width: 5,
                            ),
                            majorTitle(
                                title: DateFormat("yyyy/MM/dd HH:mm").format(
                                    DateTime.parse(salesController
                                            .currentReceipt.value!.dueDate!)
                                        .toLocal()),
                                color: Colors.grey,
                                size: 11.0)
                          ],
                        )
                    ],
                  ),
                if (salesController.currentReceipt.value?.salesnote != null &&
                    salesController.currentReceipt.value!.salesnote!.isNotEmpty)
                  Text(
                    "Note: ${salesController.currentReceipt.value?.salesnote}",
                    style: const TextStyle(fontSize: 13),
                  ),
                if (salesController.currentReceipt.value!.customerId != null)
                  const SizedBox(
                    height: 20,
                  ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        normalText(
                            title: "Total", color: Colors.black, size: 14.0),
                        const SizedBox(
                          height: 10,
                        ),
                        majorTitle(
                            title: htmlPrice(salesController
                                .currentReceipt.value!.totalWithDiscount),
                            color: Colors.black,
                            size: 14.0)
                      ],
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    if (salesController
                            .currentReceipt.value!.outstandingBalance! >
                        0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          normalText(
                              title: "Total Paid",
                              color: Colors.black,
                              size: 14.0),
                          const SizedBox(
                            height: 10,
                          ),
                          majorTitle(
                              title: htmlPrice(salesController.currentReceipt
                                      .value!.totalWithDiscount! -
                                  salesController.currentReceipt.value!
                                      .outstandingBalance!),
                              color: Colors.black,
                              size: 14.0)
                        ],
                      ),
                    const SizedBox(
                      width: 40,
                    ),
                    if (onCredit(salesController.currentReceipt.value!) &&
                        type != "returns")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          normalText(
                              title: "Balance",
                              color: Colors.black,
                              size: 14.0),
                          const SizedBox(
                            height: 10,
                          ),
                          majorTitle(
                              title: htmlPrice(salesController
                                  .currentReceipt.value!.outstandingBalance!
                                  .abs()),
                              color: Colors.black,
                              size: 14.0)
                        ],
                      ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                          color: _chechPaymentColor(
                              salesController.currentReceipt.value!, type!),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        chechPayment(
                            salesController.currentReceipt.value!, type!),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    if (onCredit(salesController.currentReceipt.value!) &&
                        salesController.currentReceipt.value!.items!.fold(
                                0.0,
                                (previousValue, element) =>
                                    previousValue + element.quantity!) >
                            0 &&
                        type != "returns")
                      InkWell(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: _chechPaymentColor(
                                        salesController.currentReceipt.value!,
                                        type!)),
                                borderRadius: BorderRadius.circular(5)),
                            child: const Text("Pay Now")),
                        onTap: () {
                          showAmountDialog(
                              salesController.currentReceipt.value!);
                        },
                      )
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          salesController.currentReceipt.value?.items!.length,
                      itemBuilder: (BuildContext c, int i) {
                        SaleItem receiptitem =
                            salesController.currentReceipt.value!.items![i];
                        return Row(
                          children: [
                            Expanded(
                              child: Table(children: [
                                TableRow(children: [
                                  Text(
                                    receiptitem.product!.name!.capitalize!,
                                    style: TextStyle(
                                        fontSize: 12,
                                        decoration: receiptitem.quantity == 0
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  Text(
                                    "${receiptitem.quantity!} @${htmlPrice(receiptitem.unitPrice! + receiptitem.lineDiscount!)}",
                                    style: TextStyle(
                                        fontSize: 13,
                                        decoration: receiptitem.quantity == 0
                                            ? TextDecoration.lineThrough
                                            : null),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (verifyPermission(
                                          category: "sales",
                                          permission: "return")) {
                                        saleReceiptActions(
                                            saleItem: receiptitem, from: from!);
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          htmlPrice((receiptitem.unitPrice! *
                                                  receiptitem.quantity!) +
                                              receiptitem.lineDiscount!),
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  receiptitem.quantity == 0
                                                      ? TextDecoration
                                                          .lineThrough
                                                      : null),
                                        ),
                                        if (receiptitem.quantity == 0)
                                          const Icon(
                                            Icons.file_download,
                                            color: Colors.red,
                                            size: 15,
                                          )
                                      ],
                                    ),
                                  ),
                                ]),
                              ]),
                            ),
                            if (salesController.currentReceipt.value?.status !=
                                    "order" &&
                                verifyPermission(
                                    category: "sales", permission: "return"))
                              InkWell(
                                  onTap: () {
                                    saleReceiptActions(
                                        saleItem: receiptitem,
                                        from: from ?? "");
                                  },
                                  child: const Icon(
                                    Icons.undo,
                                    color: Colors.red,
                                  )),
                          ],
                        );
                      }),
                ),
                const Divider(
                  color: Colors.black,
                ),
                Expanded(
                  flex: 3,
                  child: Table(children: [
                    TableRow(children: [
                      const Text(
                        "",
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        "Sub Total: ",
                        style: TextStyle(fontSize: 13),
                      ),
                      Column(
                        children: [
                          Text(
                            htmlPrice((salesController
                                        .currentReceipt.value!.totalAmount! -
                                    salesController
                                        .currentReceipt.value!.totaltax!)
                                .toStringAsFixed(2)),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                            thickness: 0.5,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ]),
                    if (salesController.currentReceipt.value!.totaltax! > 0)
                      TableRow(children: [
                        const Text(
                          "",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          "VAT: ",
                          style: TextStyle(fontSize: 13),
                        ),
                        Column(
                          children: [
                            Text(
                              htmlPrice(salesController
                                  .currentReceipt.value!.totaltax!),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ]),
                    if (salesController.currentReceipt.value!.paymentTag ==
                            'split' &&
                        salesController.currentReceipt.value!.amountPaid! > 0)
                      TableRow(children: [
                        const Text(
                          "",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          "Cash: ",
                          style: TextStyle(fontSize: 13),
                        ),
                        Column(
                          children: [
                            Text(
                              htmlPrice(salesController
                                  .currentReceipt.value!.amountPaid!),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ]),
                    if (salesController.currentReceipt.value!.paymentTag ==
                            'split' &&
                        salesController.currentReceipt.value!.mpesatotal! > 0)
                      TableRow(children: [
                        const Text(
                          "",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          "Mpesa: ",
                          style: TextStyle(fontSize: 13),
                        ),
                        Column(
                          children: [
                            Text(
                              htmlPrice(salesController
                                  .currentReceipt.value!.mpesatotal!),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ]),
                    if (salesController.currentReceipt.value!.paymentTag ==
                            'split' &&
                        salesController.currentReceipt.value!.banktotal! > 0)
                      TableRow(children: [
                        const Text(
                          "",
                          style: TextStyle(fontSize: 16),
                        ),
                        const Text(
                          "Bank: ",
                          style: TextStyle(fontSize: 13),
                        ),
                        Column(
                          children: [
                            Text(
                              htmlPrice(salesController
                                  .currentReceipt.value!.banktotal!),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              thickness: 0.5,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ]),
                    TableRow(children: [
                      const Text(
                        "",
                        style: TextStyle(fontSize: 16),
                      ),
                      const Text(
                        "Total: ",
                        style: TextStyle(fontSize: 13),
                      ),
                      Column(
                        children: [
                          Text(
                            htmlPrice(salesController
                                .currentReceipt.value!.totalWithDiscount!),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Divider(
                            thickness: 1,
                            height: 0,
                            color: Colors.black,
                          ),
                          const Divider(
                            thickness: 2,
                            height: 5,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          normalText(
                              title: "Date", color: Colors.black, size: 12.0),
                          if (salesController.currentReceipt.value!.createdAt !=
                              null)
                            majorTitle(
                                title: DateFormat("yyyy-MM-dd hh:mm").format(
                                    DateTime.parse(salesController
                                            .currentReceipt.value!.createdAt!)
                                        .toUtc()),
                                color: Colors.black,
                                size: 12.0)
                        ],
                      ),
                      const Spacer(),
                      if (salesModel?.status != "order")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            normalText(
                                title: "Served by",
                                color: Colors.black,
                                size: 12.0),
                            majorTitle(
                                title: salesModel?.attendant?.username,
                                color: Colors.black,
                                size: 12.0)
                          ],
                        ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          normalText(
                              title: "Paid via",
                              color: Colors.black,
                              size: 12.0),
                          majorTitle(
                              title: salesModel?.paymentTag ??
                                  salesModel?.paymentType,
                              color: Colors.black,
                              size: 12.0)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    salesController.sharePdf(salesModel!);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.mainColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 3,
                            )
                          ]),
                      child: const Icon(Icons.share, color: Colors.white)),
                ),
              ),
              Center(child: Obx(() {
                return printerController.printing.value == true
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : InkWell(
                        onTap: () async {
                          showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Select Printer Type",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.back();
                                          Sunmi().printReceipt(
                                              saleModel: salesModel!,
                                              receiptTitle: "Cash Receipt");

                                          Cs50PrinterSetup().printReceipt(
                                              saleModel: salesModel!,
                                              receiptTitle: "Cash Receipt");
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: AppColors.mainColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 3,
                                                      )
                                                    ]),
                                                child: const Icon(Icons.print,
                                                    color: Colors.white)),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text("Sunmi Printer"),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.back();
                                          if (printerController.device?.value ==
                                                  null ||
                                              printerController
                                                      .connected.value ==
                                                  false) {
                                            Get.to(() => const PrintingPage());
                                          } else {
                                            printerController.printSaleReceipt(
                                              title:
                                                  "${chechPayment(salesController.currentReceipt.value!, type!)} RECEIPT",
                                              salesModel: salesModel!,
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    color: AppColors.mainColor,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 3,
                                                      )
                                                    ]),
                                                child: const Icon(Icons.print,
                                                    color: Colors.white)),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Text("Thermal/Bluetooth Printer"),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: AppColors.mainColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                  )
                                ]),
                            child:
                                const Icon(Icons.print, color: Colors.white)),
                      );
              })),
              if (salesController.currentReceipt.value?.paymentType == "credit")
                Center(
                  child: textBtn(
                      hPadding: 20,
                      fontSize: 13,
                      text: "Payments",
                      onPressed: () {
                        paymentController.getSalesPaymentBySaleId(
                            salesController.currentReceipt.value!.sId!);
                        Get.to(() => PaymentHistory());
                      },
                      radius: 10,
                      bgColor: Colors.red,
                      color: Colors.white),
                ),
              if (verifyPermission(category: "sales", permission: "delete") &&
                  salesController.currentReceipt.value!.status != "order")
                Center(
                  child: InkWell(
                    onTap: () {
                      saleReceiptActions(
                          saleModel: salesController.currentReceipt.value!,
                          delete: true,
                          from: from!);
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                              )
                            ]),
                        child: const Icon(Icons.delete, color: Colors.white)),
                  ),
                ),
            ],
          )),
    );
  }
}

String chechPayment(SaleModel salesModel, String? type) {
  if (salesModel.totalWithDiscount == 0 || type == "returns") {
    return type == "returns" ? "RETURNED ITEMS" : "RETURNED";
  }
  if (salesModel.status == 'order') return "PENDING";
  if (salesModel.outstandingBalance == 0) return "CASH SALE";
  if (onCredit(salesModel) == true) return "NOT PAID";
  return "";
}

onCredit(SaleModel salesModel) => salesModel.outstandingBalance! > 0;

Color _chechPaymentColor(SaleModel salesModel, String? type) {
  if (salesModel.totalWithDiscount! == 0 || type == "returns") {
    return Colors.red;
  }
  if (salesModel.status == 'order') return Colors.amber;
  if (salesModel.outstandingBalance == 0) return Colors.green;
  if (onCredit(salesModel) == true) return Colors.red;
  return Colors.black;
}

void saleReceiptActions(
    {SaleItem? saleItem,
    SaleModel? saleModel,
    bool delete = false,
    String from = ""}) {
  SalesController salesController = Get.find<SalesController>();
  if (saleModel != null) {
    generalAlert(
        title: "Warning",
        positiveText: "Yes",
        negativeText: "Not now",
        message:
            "Are you sure you want to ${delete ? "delete" : "return"} ${salesController.currentReceipt.value?.items!.length} items?",
        function: () {
          if (delete == true) {
            salesController.voidReceipt(salesController.currentReceipt.value!);
            return;
          }
          var items = salesController.currentReceipt.value?.items!
              .map((e) => {"product": e.product?.sId, "quantity": e.quantity})
              .toList();

          if (from == "sales") {
            Get.back();
          }
          salesController.returnSale(
              saledId: salesController.currentReceipt.value!.sId,
              returnItems: items,
              from: from,
              deleteReceipt: delete);
        });
  } else {
    if (saleItem != null && saleItem.quantity! > 0) {
      returnReceiptItem(receiptItem: saleItem);
    }
  }
}

returnReceiptItem({required SaleItem receiptItem, Product? product}) {
  SalesController salesController = Get.find<SalesController>();
  TextEditingController textEditingController = TextEditingController();
  textEditingController.text = receiptItem.quantity.toString();
  return showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text("Return Product?"),
          content: Container(
            decoration: ThemeHelper().inputBoxDecorationShaddow(),
            child: TextFormField(
              controller: textEditingController,
              decoration: ThemeHelper()
                  .textInputDecorationDesktop('Quantity', 'Enter quantity'),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Cancel".toUpperCase(),
                  style: const TextStyle(color: AppColors.mainColor),
                )),
            TextButton(
                onPressed: () {
                  if (receiptItem.quantity! <
                      double.parse(textEditingController.text.isEmpty
                          ? "0"
                          : textEditingController.text)) {
                    generalAlert(
                        title: "Error",
                        message:
                            "You cannot return more than ${receiptItem.quantity}");
                  } else if (double.parse(textEditingController.text) <= 0) {
                    generalAlert(
                        title: "Error",
                        message: "You must atleast return 1 item");
                  } else {
                    Get.back();
                    salesController
                        .returnSale(saledId: receiptItem.sale, returnItems: [
                      {
                        "product": receiptItem.product?.sId,
                        "quantity": double.parse(textEditingController.text)
                      }
                    ]);
                  }
                },
                child: Text(
                  "Okay".toUpperCase(),
                  style: const TextStyle(color: AppColors.mainColor),
                ))
          ],
        );
      });
}

showAmountDialog(SaleModel salesBody) {
  SalesController salesController = Get.find<SalesController>();
  showDialog(
      context: Get.context!,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Pay invoice",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            child: Form(
                child: Obx(() => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment via",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5)),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: Get.context!,
                                  builder: (context) {
                                    return SimpleDialog(
                                      children: List.generate(
                                          salesController
                                              .receiptpaymentMethods.length,
                                          (index) => SimpleDialogOption(
                                                onPressed: () {
                                                  salesController.paynowMethod
                                                      .value = salesController
                                                          .receiptpaymentMethods[
                                                      index];
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Text(
                                                    "${salesController.receiptpaymentMethods[index]}",
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              )),
                                    );
                                  });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(
                                  () =>
                                      Text(salesController.paynowMethod.value),
                                ),
                                const Icon(Icons.arrow_drop_down)
                              ],
                            ),
                          ),
                        ),
                        if (salesController.paynowMethod.value == "Mpesa")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mpesa Code (Last 5 Digits)",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: salesController.mpesaCode,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    hintText: "eg DV409",
                                    hintStyle: const TextStyle(fontSize: 10),
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                              ),
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Enter Amount",
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: salesController.amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              hintText: "eg ${salesBody.totalWithDiscount}",
                              hintStyle: const TextStyle(fontSize: 10),
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ],
                    ))),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                "Cancel".toUpperCase(),
                style: const TextStyle(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                var amountPaid = int.parse(
                    salesController.amountController.text.isEmpty
                        ? "0"
                        : salesController.amountController.text);
                if (salesBody.outstandingBalance! < amountPaid) {
                  generalAlert(
                      title: "Error",
                      message:
                          "You cannot pay more than ${htmlPrice(salesBody.outstandingBalance!.abs())}");
                } else {
                  if (salesController.paynowMethod.value == "Wallet") {
                    var walletBalance = (salesBody.customerId!.wallet ?? 0);
                    if (walletBalance == 0) {
                      generalAlert(
                          title: "Error",
                          message: "Wallet balance is ${htmlPrice(0)}");
                    } else {
                      if (walletBalance < amountPaid) {
                        generalAlert(
                            title: "Warning",
                            message: walletBalance < 0
                                ? "Wallet balance is not sufficient to pay ${htmlPrice(amountPaid)}"
                                : "Wallet balance can only pay ${htmlPrice(walletBalance)} continue?",
                            function: () {
                              salesController.payCredit(
                                  salesBody: salesBody, amount: amountPaid);
                            });
                      } else {
                        salesController.payCredit(
                            salesBody: salesBody, amount: amountPaid);
                      }
                    }
                  } else {
                    salesController.payCredit(
                        salesBody: salesBody, amount: amountPaid);
                  }
                }
              },
              child: Text(
                "Pay".toUpperCase(),
                style: const TextStyle(
                  color:AppColors.mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      });
}
