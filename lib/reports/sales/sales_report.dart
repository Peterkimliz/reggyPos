import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/utils/helper.dart';
import 'package:printing/printing.dart';

import '../../../controllers/homecontroller.dart';
import '../../../controllers/salescontroller.dart';
import '../../../controllers/shopcontroller.dart';
import '../../../widgets/bottom_widget_count_view.dart';
import '../../controllers/reports_controller.dart';
import '../../models/salemodel.dart';
import '../../screens/receipts/pdf/sales/sales_report.dart';
import '../../screens/sales/components/sales_card.dart';
import '../../utils/colors.dart';
import '../../widgets/filter_dates.dart';
import '../../widgets/no_items_found.dart';
import '../../widgets/textbutton.dart';

class SalesReport extends StatefulWidget {
  final String? title;
  final String? keyFrom;
  SalesReport({Key? key, this.title, this.keyFrom})
      : super(
          key: key,
        ) {
    SalesController salesController = Get.find<SalesController>();
    if (keyFrom == "dues") {
      salesController.getSalesByDate(
        dueDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        paymentType: "credit",
        shop: userController.currentUser.value!.primaryShop!.id!,
      );
    } else {
      salesController.getSalesByCashSaleFilter(
          type: salesController.cashsalesfilterSelected.value);
      salesController.getfilterTotals();
    }
  }

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  SalesController salesController = Get.find<SalesController>();

  ShopController shopController = Get.find<ShopController>();

  HomeController homeController = Get.find<HomeController>();

  ReportsController reportsController = Get.find<ReportsController>();
  @override
  Widget build(BuildContext context) {
    return Helper(
      floatButton: Container(),
      bottomNavigationBar: _bottomView(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: false,
        actions: [
          if (userController.currentUser.value?.usertype == "admin")
            Center(
              child: textBtn(
                vPadding: 5,
                hPadding: 20,
                text: "Print",
                bgColor: AppColors.mainColor,
                color: Colors.white,
                onPressed: () {
                  if (widget.keyFrom == "dues") {
                    Get.to(() => Scaffold(
                          appBar: AppBar(
                            title: const Text("Due Sales Report"),
                          ),
                          body: PdfPreview(
                            build: (context) =>
                                salesReportPdf("dues", "DUE SALES REPORT"),
                          ),
                        ));
                  } else {
                    Get.to(() => Scaffold(
                          appBar: AppBar(
                            title: const Text("Sales Report"),
                          ),
                          body: PdfPreview(
                            build: (context) =>
                                salesReportPdf("receipts", "SALES REPORT "),
                          ),
                        ));
                  }
                },
              ),
            ),
          const SizedBox(
            width: 10,
          )
        ],
        title: Text(
          widget.title!,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      widget: Obx(() {
        return Column(
          children: [
            filterByDates(onFilter: (start, end, type) {
              reportsController.activeFilter.value = type;
              reportsController.filterStartDate.value = DateFormat(
                "yyyy-MM-dd",
              ).format(start);
              reportsController.filterEndDate.value = DateFormat(
                "yyyy-MM-dd",
              ).format(end);

              if (widget.keyFrom == "dues") {
                salesController.getSalesByDate(
                    dueDate: reportsController.filterStartDate.value,
                    fromDate: reportsController.filterStartDate.value,
                    toDate: reportsController.filterEndDate.value,
                    paymentType: "credit",
                    shop: userController.currentUser.value!.primaryShop!.id!);
              } else {
                if (widget.keyFrom == "hold") {
                  salesController.getSalesByDate(
                      fromDate: reportsController.filterStartDate.value,
                      toDate: reportsController.filterEndDate.value,
                      shop: userController.currentUser.value!.primaryShop!.id!,
                      status: "hold");
                } else {
                  if (widget.keyFrom == "cash") {
                    salesController.getSalesByDate(
                        fromDate: reportsController.filterStartDate.value,
                        toDate: reportsController.filterEndDate.value,
                        shop:
                            userController.currentUser.value!.primaryShop!.id!,
                        status: "cashed");
                  } else {
                    salesController.getSalesByDate(
                        fromDate: reportsController.filterStartDate.value,
                        toDate: reportsController.filterEndDate.value,
                        paymentType: widget.keyFrom.toString().trim(),
                        shop:
                            userController.currentUser.value!.primaryShop!.id!,
                        status: widget.keyFrom.toString().trim() == "cash" ||
                                widget.keyFrom.toString().trim() == "credit" ||
                                widget.keyFrom.toString().trim() == "wallet"
                            ? "cashed"
                            : "");
                  }
                }
              }
            }),
            searchWidget(),
            if (widget.keyFrom == "cash")
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
                            salesController.cashsalesfilter.length,
                            (index) => InkWell(
                                  onTap: () {
                                    salesController
                                            .cashsalesfilterSelected.value =
                                        salesController.cashsalesfilter[index];

                                    salesController.getSalesByCashSaleFilter(
                                        type: salesController
                                            .cashsalesfilter[index]);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, left: 10, right: 15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: AppColors.mainColor),
                                        color: salesController
                                                    .cashsalesfilterSelected
                                                    .value ==
                                                salesController
                                                    .cashsalesfilter[index]
                                            ? AppColors.mainColor
                                            : Colors.white),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${salesController.cashsalesfilter[index]}:",
                                          style: TextStyle(
                                              color: salesController
                                                          .cashsalesfilterSelected
                                                          .value ==
                                                      salesController
                                                              .cashsalesfilter[
                                                          index]
                                                  ? Colors.white
                                                  : AppColors.mainColor,
                                              fontSize: 12),
                                        ),
                                        const SizedBox(width: 10),
                                        Obx(
                                          () => Text(
                                            htmlPrice(salesController
                                                .cashsalesfilterTotals[
                                                    salesController
                                                        .cashsalesfilter[index]]
                                                .toStringAsFixed(2)
                                                .toString()),
                                            style: TextStyle(
                                                color: salesController
                                                            .cashsalesfilterSelected
                                                            .value ==
                                                        salesController
                                                                .cashsalesfilter[
                                                            index]
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
            salesController.loadingSales.isTrue
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : widget.keyFrom == "cash"
                    ? Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                salesController.allSalesCashFiltered.length,
                            itemBuilder: (context, index) {
                              SaleModel salesModel = salesController
                                  .allSalesCashFiltered
                                  .elementAt(index);
                              return salesCard(
                                  salesModel: salesModel, from: widget.keyFrom);
                            }),
                      )
                    : salesController.allSales.isEmpty
                        ? Expanded(child: noItemsFound(context, true))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: salesController.allSales.length,
                            itemBuilder: (context, index) {
                              SaleModel salesModel =
                                  salesController.allSales.elementAt(index);
                              return salesCard(
                                  salesModel: salesModel, from: widget.keyFrom);
                            }),
          ],
        );
      }),
    );
  }

  Widget searchWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: salesController.searchSaleReceiptController,
              onChanged: (value) {
                if (value == "") {
                  salesController.allSalesCashFiltered.clear();
                  salesController.allSalesCashFiltered
                      .addAll(salesController.allSalesCash);
                  return;
                }
                salesController.allSalesCashFiltered.clear();
                salesController.allSalesCashFiltered.addAll(salesController
                    .allSalesCash
                    .where((p0) =>
                        p0.receiptNo
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        p0.items!.any((element) => element.product!.name!
                            .toLowerCase()
                            .contains(value.toLowerCase())))
                    .toList());
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(10, 2, 0, 2),
                hintText: ""
                    "Search by receipt number",
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
    );
  }

  _bottomView() {
    return Obx(
      () => SizedBox(
        height: 40,
        child: bottomWidgetCountView(
            count: salesController.allSales.length.toString(),
            qty: salesController.allSales
                .fold(
                    0.0,
                    (previousValue, element) =>
                        previousValue +
                        element.items!.fold(
                            0.0,
                            (previousValue, element) =>
                                previousValue + element.quantity!))
                .toString(),
            onCredit: htmlPrice(salesController.allSales.fold(
                0.0,
                (previousValue, element) =>
                    previousValue + element.outstandingBalance!)),
            cash: htmlPrice(salesController.allSales.fold(
                0.0,
                (previousValue, element) =>
                    previousValue + element.totalWithDiscount!))),
      ),
    );
  }
}
