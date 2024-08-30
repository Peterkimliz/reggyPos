import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/reports/purchases/invoice_order_card.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/widgets/no_items_found.dart';
import 'package:printing/printing.dart';

import '../../../controllers/purchase_controller.dart';
import '../../../controllers/shopcontroller.dart';
import '../../../models/invoice.dart';
import '../../functions/functions.dart';
import '../../screens/receipts/pdf/sales/purchases_report.dart';
import '../../widgets/textbutton.dart';

class PurchasesReport extends StatelessWidget {
  final String? title;
  final String? type;
  PurchasesReport({Key? key, this.title, this.type}) : super(key: key);

  final ShopController shopController = Get.find<ShopController>();
  final PurchaseController purchaseController = Get.find<PurchaseController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 0.4,
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.clear,
              color: AppColors.mainColor,
            ),
          ),
          title: Text(
            title!,
            style: const TextStyle(color: AppColors.mainColor),
          ),
          actions: [
            Center(
                child: textBtn(
                    vPadding: 5,
                    hPadding: 20,
                    text: "Print",
                    bgColor: AppColors.mainColor,
                    color: Colors.white,
                    onPressed: () {
                      Get.to(() => Scaffold(
                            appBar: AppBar(
                              title: Text(
                                  "${type.toString().capitalizeFirst} Purchases"),
                            ),
                            body: PdfPreview(
                              build: (context) => purchasesReportPdf("receipts",
                                  "${type!.toUpperCase()} PURCHASES"),
                            ),
                          ));
                    })),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: purchaseController.searchInvoiceController,
                      onChanged: (value) {
                        if (value == "") {
                          purchaseController.filteredInvoices.value =
                              purchaseController.invoices
                                  .where((p0) =>
                                      p0.paymentType ==
                                      purchaseController.selectedItem.value)
                                  .toList();
                        } else {
                          purchaseController.filteredInvoices.value =
                              purchaseController
                                  .invoices
                                  .where((p0) =>
                                      p0.paymentType ==
                                              purchaseController
                                                  .selectedItem.value &&
                                          p0.purchaseNo
                                              .toString()
                                              .toLowerCase()
                                              .contains(value.toLowerCase()) ||
                                      p0.items!.any((element) => element
                                          .product!.name!
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                  .toList();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search),
                        ),
                        hintText: ""
                            "Search by invoice number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (type!.toLowerCase() != "credit")
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() => Wrap(
                        direction: Axis.horizontal,
                        spacing: 8,
                        runSpacing: 12,
                        children: List.generate(
                            purchaseController.reportpaymentMethods.length,
                            (index) => InkWell(
                                  onTap: () {
                                    purchaseController.selectedItem.value =
                                        purchaseController
                                            .reportpaymentMethods[index]
                                            .toString()
                                            .toLowerCase();
                                    purchaseController.filteredInvoices.value =
                                        purchaseController.invoices
                                            .where((p0) =>
                                                p0.paymentType ==
                                                purchaseController
                                                    .reportpaymentMethods[index]
                                                    .toString()
                                                    .toLowerCase())
                                            .toList();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.mainColor),
                                        color: purchaseController
                                                    .selectedItem.value ==
                                                purchaseController
                                                    .reportpaymentMethods[index]
                                                    .toString()
                                                    .toLowerCase()
                                            ? AppColors.mainColor
                                            : Colors.white),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${purchaseController.reportpaymentMethods[index]}:",
                                          style: TextStyle(
                                              color: purchaseController
                                                          .selectedItem.value ==
                                                      purchaseController
                                                          .reportpaymentMethods[
                                                              index]
                                                          .toString()
                                                          .toLowerCase()
                                                  ? Colors.white
                                                  : AppColors.mainColor,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(width: 10),
                                        Obx(
                                          () => Text(
                                            htmlPrice(purchaseController
                                                .totals[purchaseController
                                                    .reportpaymentMethods[index]
                                                    .toString()
                                                    .toLowerCase()]
                                                .toStringAsFixed(2)
                                                .toString()),
                                            style: TextStyle(
                                                color: purchaseController
                                                            .selectedItem
                                                            .value ==
                                                        purchaseController
                                                            .reportpaymentMethods[
                                                                index]
                                                            .toString()
                                                            .toLowerCase()
                                                    ? Colors.white
                                                    : AppColors.mainColor),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                      )),
                ),
              ),
            Obx(() {
              return purchaseController.isLoadingPurchases.isTrue
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : purchaseController.filteredInvoices.isEmpty
                      ? Center(child: noItemsFound(context, true))
                      : Expanded(
                          child: ListView.builder(
                              itemCount:
                                  purchaseController.filteredInvoices.length,
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                Invoice invoiceData = purchaseController
                                    .filteredInvoices
                                    .elementAt(index);
                                return invoiceCard(
                                    invoice: invoiceData, type: type ?? "");
                              }),
                        );
            }),
          ],
        ));
  }
}
