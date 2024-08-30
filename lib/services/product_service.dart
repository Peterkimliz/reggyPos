import 'dart:convert';

import '../main.dart';
import 'client.dart';
import 'end_points.dart';

class ProductService {
  getProductCategories(String admin) async {
    var response = await DbBase().databaseRequest(
      "${EndPoints.productcategories}?admin=$admin",
      DbBase().getRequestType,
    );
    return response;
  }

  static String getPathForProductImage(String id, int index) {
    String path = "products/images/$id";
    return "${path}_$index";
  }

  static updateProductsImages(String productId, List<dynamic> imgUrl) async {
    var respinse = await DbBase().databaseRequest(
        EndPoints.updateproductimages + productId, DbBase().putRequestType,
        body: {"images": imgUrl});
    return jsonDecode(respinse);
  }

  createProduct(Map<String, Object?> product) async {
    var response = await DbBase().databaseRequest(
        EndPoints.products, DbBase().postRequestType,
        body: product);
    return response;
  }

  static updateProducts(List<Map<String, dynamic>> products) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.products}/sync", DbBase().putRequestType,
        body: {"products": products});
    return response;
  }

  static updateProduct(Map<String, dynamic> product, String productid) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.products}/$productid", DbBase().putRequestType,
        body: product);
    return response;
  }

  static getProductsBySort(
      {String? type = "",
      String? text = "",
      int? limit = 100,
      int? page = 1,
      String? productType = "",
      String? productid = "",
      String? shopId = "",
      String? sort = "",
      String? reason = "",
      String barcodeid = ""}) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.products}?page=1&reason=$reason&limit=$limit&name=$text&shopid=$shopId&type=$type&sort=$sort&productid=$productid&barcodeid=$barcodeid&productType=$productType",
        DbBase().getRequestType);
    return response;
  }

  static getProductsAnalysis(
      {String? type = "", String? text = "", String? shopId = ""}) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.analysis}?shopid=$shopId", DbBase().getRequestType);
    return response;
  }

  static Future countProduct(Map<String, dynamic> data) async {
    var response = await DbBase().databaseRequest(
        EndPoints.productCount, DbBase().postRequestType,
        body: data);
    return response;
  }

  static getCountHistory(
      {String? shop, String? fromDate, String? toDate}) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.shopproductCount}/$shop?fromDate=$fromDate&toDate=$toDate",
        DbBase().getRequestType);
    return response;
  }

  static saveBadStock(Map<String, dynamic> data) async {
    var response = await DbBase().databaseRequest(
        EndPoints.badstock, DbBase().postRequestType,
        body: data);
    return response;
  }

  static Future<List> getBadStock(
      {String? product = "", String? fromDate, String? toDate}) async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.badstock}?shopId=${userController.currentUser.value?.primaryShop?.id}&product=$product&startDate=$fromDate&endDate=$toDate",
        DbBase().getRequestType);
    return response;
  }

  transferProduct(Map<String, Object?> transferData) async {
    String url = EndPoints.transfer;
    var response = await DbBase()
        .databaseRequest(url, DbBase().postRequestType, body: transferData);
    return response;
  }

  getTransferHistory(
      {String? startDate = "",
      String? toDate = "",
      String? shopid = "",
      String? direction = ""}) async {
    String url =
        "${EndPoints.transferfilter}?shopId=$shopid&direction=$direction&startDate=$startDate&endDate=$toDate";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getProductPurchasesGroupedByMonth({
    required String product,
    String? startDate = "",
    String? toDate = "",
  }) async {
    String url =
        "${EndPoints.purchasefilter}?startDate=$startDate&product=$product&endDate=$toDate";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getProductPurchasesHistory({
    required String product,
    String? startDate = "",
    String? toDate = "",
  }) async {
    String url =
        "${EndPoints.productpurchase}?startDate=$startDate&product=$product&endDate=$toDate";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static getBadStockGroupedByMonth(
      {required String product, required String year}) async {
    String url = "${EndPoints.summarybadstock}?year=$year&product=$product";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static Future<List> getProductsCountsHistory(String product) async {
    String url = "${EndPoints.countsproduct}/product/$product";
    var response = await DbBase().databaseRequest(url, DbBase().getRequestType);
    return response;
  }

  static deleteProductCount(String sId) async {
    String url = "${EndPoints.productCount}/$sId";
    var response =
        await DbBase().databaseRequest(url, DbBase().deleteRequestType);
    return response;
  }

  importProducts(List<Map<String, dynamic>> products) async {
    String url = EndPoints.productimport;
    var response = await DbBase().databaseRequest(url, DbBase().postRequestType,
        body: {'products': products});
    return response;
  }

  static transferProducts(List<Map<String, dynamic>> products) async {
    String url = EndPoints.producttransferimport;
    var response = await DbBase().databaseRequest(url, DbBase().postRequestType,
        body: {'products': products});
    return response;
  }

  static createCategory(Map<String, String> map) async {
    String url = EndPoints.productcategories;
    var response = await DbBase()
        .databaseRequest(url, DbBase().postRequestType, body: map);
    return response;
  }
}
