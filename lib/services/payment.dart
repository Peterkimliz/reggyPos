
import 'client.dart';
import 'end_points.dart';

class PaymentService {
  static getSalesPaymentBySaleId(String id) async {
    String url = "${EndPoints.payments}?saleId=$id";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getSalesPaymentByPurchaseId(id) async {
    String url = "${EndPoints.payments}?purchaseId=$id";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getAwardTransactions(id) async {
    String url = "${EndPoints.awardstransactions}?user=$id";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getPaymentsByShopAndDate(
      String shop, String fromDate, String toDate) async {
    String url =
        "${EndPoints.payments}?shop=$shop&fromDate=$fromDate&toDate=$toDate";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static deleteReceipt(id) async {
    String url = "${EndPoints.payments}/$id";
    var response =
        await DbBase().databaseRequest(url, DbBase().deleteRequestType);
    return response;
  }

  static deletePayment(id) async {
    String url = "${EndPoints.payments}?purchaseId=$id";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }
}
