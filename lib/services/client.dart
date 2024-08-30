import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:reggypos/functions/functions.dart';

import '../widgets/snackBars.dart';

class DbBase {
  final postRequestType = "POST";
  final getRequestType = "GET";
  final putRequestType = "PUT";
  final patchRequestType = "PATCH";
  final deleteRequestType = "DELETE";

  final Dio _dio = Dio();

  DbBase() {
    // _dio.httpClientAdapter = IOHttpClientAdapter()
    //   ..onHttpClientCreate = (HttpClient client) {
    //     client.badCertificateCallback =  (X509Certificate cert, String host, int port) => true;
    //     return client;
    //   };

    _dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final HttpClient client =
          HttpClient(context: SecurityContext(withTrustedRoots: false));
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    });

    _dio.options.validateStatus = (_) => true;
    _dio.options.headers['Connection'] = 'keep-alive';
    // Add other headers and configurations as needed
  }

  Future databaseRequest(String link, String type,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      headers ??= {
        'Content-Type': 'application/json',
      };

      int maxRetries = 3; // Maximum number of retry attempts
      int retryDelayInSeconds = 3; // Delay in seconds between retries

      Response response;
      debugPrintMessage(link);

      for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
        try {
          switch (type) {
            case "GET":
              response = await _dio.get(link, queryParameters: body);
              break;
            case "POST":
              response = await _dio.post(link, data: body);
              break;
            case "PUT":
              response = await _dio.put(link, data: body);
              break;
            case "PATCH":
              response = await _dio.patch(link, data: body);
              break;
            case "DELETE":
              response = await _dio.delete(link, data: body);
              break;
            default:
              throw DioException(
                  requestOptions: RequestOptions(path: link),
                  error: "Invalid request type");
          }

          return response.data;
        } on DioException catch (e) {
          debugPrintMessage('Dio Error: $e');
          // Retry only for certain DioError conditions, you can customize this
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            await Future.delayed(Duration(seconds: retryDelayInSeconds));
          } else {
            // Do not retry for other DioError conditions
            break;
          }
        } catch (e) {
          showSnackBar(
            message: "$e",
            color: Colors.red,
          );
          break;
        }
      }
      throw Exception("Failed to connect after multiple retries");
    } catch (e) {
      debugPrintMessage(e);
    }
  }
}
