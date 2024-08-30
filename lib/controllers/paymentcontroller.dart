import 'package:get/get.dart';
import 'package:reggypos/controllers/customercontroller.dart';
import 'package:reggypos/models/customer.dart';
import 'package:reggypos/services/payment.dart';

import '../models/awards.dart';
import '../models/payment.dart';

class PaymentController extends GetxController {
  RxBool isPaymentLoading = false.obs;
  RxList<Payment> payments = RxList([]);
  RxList<Awards> awardpayments = RxList([]);

  getSalesPaymentByPurchaseId(String id) async {
    isPaymentLoading.value = true;
    List<dynamic> response =
        await PaymentService.getSalesPaymentByPurchaseId(id);
    List<Payment> paymentData =
        response.map((e) => Payment.fromJson(e)).toList();
    paymentData.sort((a, b) => b.date!.compareTo(a.date!));
    payments.assignAll(paymentData);
    isPaymentLoading.value = false;
  }

  getAwardTransactions(String id) async {
    isPaymentLoading.value = true;
    List<dynamic> response = await PaymentService.getAwardTransactions(id);
    List<Awards> paymentData = response.map((e) => Awards.fromJson(e)).toList();
    paymentData.sort((a, b) => b.date!.compareTo(a.date!));
    awardpayments.assignAll(paymentData);
    isPaymentLoading.value = false;
  }

  getPaymentsByShopAndDate(String shop, String fromDate, String toDate) async {
    isPaymentLoading.value = true;
    List<dynamic> response = await PaymentService.getPaymentsByShopAndDate(
      shop,
      fromDate,
      toDate,
    );
    List<Payment> paymentData =
        response.map((e) => Payment.fromJson(e)).toList();
    payments.assignAll(paymentData);
    isPaymentLoading.value = false;
  }

  deleteReceipt(Payment payment) async {
    isPaymentLoading.value = true;
    var response = await PaymentService.deleteReceipt(payment.sId!);
    Get.find<CustomerController>().currentCustomer.value =
        Customer.fromJson(response);
    isPaymentLoading.value = false;
    Get.find<CustomerController>().currentCustomer.refresh();
    Get.find<CustomerController>().getTransactions(
        "deposit", Get.find<CustomerController>().currentCustomer.value!.sId!);
  }

  getSalesPaymentBySaleId(String id) async {
    isPaymentLoading.value = true;
    List<dynamic> response = await PaymentService.getSalesPaymentBySaleId(id);
    List<Payment> paymentData =
        response.map((e) => Payment.fromJson(e)).toList();
    payments.assignAll(paymentData);
    isPaymentLoading.value = false;
  }
}
