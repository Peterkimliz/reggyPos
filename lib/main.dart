import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:reggypos/bindings.dart';
import 'package:reggypos/controllers/authcontroller.dart';
import 'package:reggypos/controllers/customercontroller.dart';
import 'package:reggypos/controllers/plancontroller.dart';
import 'package:reggypos/controllers/productcontroller.dart';
import 'package:reggypos/controllers/purchase_controller.dart';
import 'package:reggypos/controllers/reports_controller.dart';
import 'package:reggypos/controllers/suppliercontroller.dart';
import 'package:reggypos/controllers/usercontroller.dart';
import 'package:reggypos/responsive/appbehaviour.dart';
import 'package:reggypos/screens/authentication/landing.dart';
import 'package:reggypos/utils/colors.dart';
import 'package:reggypos/utils/constants.dart';

import 'controllers/cashflowcontroller.dart';
import 'controllers/ordercontroller.dart';
import 'controllers/paymentcontroller.dart';
import 'controllers/shopcontroller.dart';
import 'controllers/stockcontroller.dart';
import 'firebase_options.dart';

AndroidNotificationChannel channel = channel;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AuthController authController = Get.put(AuthController());
UserController userController = Get.put<UserController>(UserController());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (stripePublishKey.isNotEmpty) {
    Stripe.publishableKey = stripePublishKey;
    Stripe.merchantIdentifier = 'reggypos';
    await Stripe.instance.applySettings();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthController authController = Get.put<AuthController>(AuthController());

  PlanController planController = Get.put<PlanController>(PlanController());

  ShopController shopController = Get.put<ShopController>(ShopController());

  ProductController productController =
      Get.put<ProductController>(ProductController());

  CustomerController customerController =
      Get.put<CustomerController>(CustomerController());

  SupplierController supplierController =
      Get.put<SupplierController>(SupplierController());

  PurchaseController purchaseController =
      Get.put<PurchaseController>(PurchaseController());

  PaymentController paymentController =
      Get.put<PaymentController>(PaymentController());

  StockController stockController = Get.put<StockController>(StockController());

  CashFlowController cashFlowController =
      Get.put<CashFlowController>(CashFlowController());

  ReportsController reportsController =
      Get.put<ReportsController>(ReportsController());

  OrderController orderController = Get.put<OrderController>(OrderController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ReggyPos',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
          primarySwatch: AppColors.mainColor,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        cardTheme: CardTheme(
          color: Colors.white
        )

      
      ),
      initialBinding: AuthBinding(),
      home: const Landing(),
    );
  }
}
