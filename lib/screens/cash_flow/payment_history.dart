import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/customers/components/cash_receipt.dart';
import 'package:reggypos/widgets/no_items_found.dart';

import '../../controllers/paymentcontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../models/customer.dart';
import '../../models/payment.dart';

class PaymentHistory extends StatelessWidget {
  final String? id;
  final String? type;
  final Customer? customerModel;

  PaymentHistory({Key? key, this.id, this.customerModel, this.type})
      : super(key: key);
  final ShopController shopController = Get.find<ShopController>();
  final PaymentController paymentController = Get.find<PaymentController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: const Text(
          "Payment History",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
      ),
      body: ResponsiveWidget(
        largeScreen: Container(),
        smallScreen: Obx(() {
          return paymentController.isPaymentLoading.value
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : paymentController.payments.isEmpty
                  ? noItemsFound(context, false)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListView.builder(
                          itemCount: paymentController.payments.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            Payment payHistory =
                                paymentController.payments.elementAt(index);
                            return InkWell(
                              onTap: () {
                                Get.to(() => CashReceipt(receipt: payHistory));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3)
                                        .copyWith(bottom: 5),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(1, 1),
                                          blurRadius: 1)
                                    ]),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Paid: ",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              htmlPrice(payHistory.amount ?? 0),
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (payHistory.balance! > 0)
                                          Row(
                                            children: [
                                              const Text(
                                                "Balance: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                "-${htmlPrice(payHistory.balance ?? 0)}",
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (payHistory.date != null)
                                          Text(
                                              "On: ${DateFormat("dd-MM-yyyy HH:mm").format(DateTime.parse(payHistory.date!).toLocal())}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11)),
                                        if (payHistory.attendantId?.username !=
                                            null)
                                          Text(
                                              "by: ${payHistory.attendantId!.username}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11)),
                                        if (payHistory.paymentType!.isNotEmpty)
                                          Text(
                                              "paid via : ${payHistory.paymentType}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11)),
                                        if (payHistory.mpesaCode!.isNotEmpty)
                                          Text(
                                              "Mpesa Code: ${payHistory.mpesaCode}",
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
        }),
      ),
    );
  }
}
