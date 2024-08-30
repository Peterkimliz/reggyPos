import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/controllers/salescontroller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/screens/discover/orders/order_details.dart';
import 'package:reggypos/widgets/minor_title.dart';

import '../../../models/salemodel.dart';
import '../../../responsive/responsiveness.dart';
import '../../../utils/colors.dart';
import '../../../widgets/major_title.dart';
import '../../../widgets/delete_dialog.dart';
import '../../../widgets/normal_text.dart';

showBottomSheet(BuildContext context, SaleModel salesModel) {
  SalesController salesController = Get.find<SalesController>();
  return showModalBottomSheet(
      context: context,
      backgroundColor:
          isSmallScreen(context) ? Colors.white : Colors.transparent,
      builder: (_) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Container(
                color: AppColors.mainColor.withOpacity(0.1),
                width: double.infinity,
                child: const ListTile(
                  title: Text("Manage Receipt"),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                onTap: () {
                  Get.back();
                  salesController.updateSaleReceipt(
                      data: {"status": "cashed"}, salesModel: salesModel);
                },
                title: const Text("Cash in"),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                onTap: () {
                  salesController.receipt.value = salesModel;
                  salesController.amountPaid.clear();
                  salesController.receipt.refresh();
                  salesController.selectedCustomerController.clear();

                  for (var element in salesModel.items!) {
                    salesController.changeSaleItem(element, status: "onHold");
                  }
                  Get.back();
                  Get.back();
                },
                title: const Text("Edit"),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                onTap: () {
                  deleteDialog(
                      context: context,
                      onPressed: () {
                        salesController.voidReceipt(salesModel);
                      });
                },
                title: const Text("Void"),
              ),
              ListTile(
                leading: const Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                onTap: () {
                  Get.back();
                },
                title: const Text("Cancel "),
              ),
            ],
          ),
        );
      });
}

Widget orderCard({required SaleModel salesModel, String? from = ""}) {
  return InkWell(
    onTap: () {
      if (salesModel.status! == "hold") {
        showBottomSheet(Get.context!, salesModel);
      } else {
        Get.to(() => OrderDetails(
              salesModel: salesModel,
              type: "",
              from: from,
            ));
      }
    },
    child: Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      width:
          MediaQuery.of(Get.context!).size.width < 600 ? double.infinity : 400,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              majorTitle(
                  title: "Order#${(salesModel.receiptNo)?.toUpperCase()}",
                  color: Colors.black,
                  size: 12.0),
              const SizedBox(height: 3),
              normalText(
                  title:
                      "Total: ${htmlPrice(salesModel.items!.fold(0.0, (previousValue, element) => previousValue + element.quantity!) > 0 ? salesModel.totalWithDiscount?.toStringAsFixed(2) : 0)}",
                  color: Colors.black,
                  size: 14.0),
              const SizedBox(height: 3),
              minorTitle(
                title:
                    "Date: ${DateFormat("yyyy-MM-dd hh:mm").format(DateTime.parse(salesModel.createdAt!).toLocal())}",
                color: Colors.black,
                size: 11,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              minorTitle(
                  title: "Paid via: ${salesModel.paymentType}",
                  color: Colors.black),
              const SizedBox(height: 3),
              minorTitle(
                  title: "Shop: ${salesModel.shopId?.name}",
                  color: Colors.black),
              const SizedBox(height: 3),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: _chechPaymentColor(salesModel)),
                    borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: minorTitle(
                    title: _chechPayment(salesModel),
                    color: _chechPaymentColor(salesModel)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Color _chechPaymentColor(SaleModel salesModel) {
  if (salesModel.order == 'pending') return Colors.amber;
  if (salesModel.order == 'cancelled') return Colors.red;
  if (salesModel.order == 'completed') return Colors.green;
  return Colors.black;
}

String _chechPayment(SaleModel salesModel) {
  if (salesModel.order == 'pending') return "PENDING";
  if (salesModel.order == 'cancelled') return "CANCELLED";
  if (salesModel.order == 'completed') return "PROCESSED";
  return "PENDING";
}
