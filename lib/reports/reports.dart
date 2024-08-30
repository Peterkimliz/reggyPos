import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/reports/expenses/expense_page.dart';
import 'package:reggypos/reports/net_profit_report.dart';
import 'package:reggypos/reports/sales/discount_sales_report.dart';
import 'package:reggypos/reports/sales/product_sales_report.dart';
import 'package:reggypos/reports/sales/sales_report.dart';
import 'package:reggypos/reports/stockreport.dart';
import 'package:reggypos/reports/stocktake_report.dart';
import 'package:reggypos/reports/summary/purchases_summary.dart';
import 'package:reggypos/reports/summary/sales_summary.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/utils/helper.dart';

import '../../widgets/major_title.dart';
import '../../widgets/minor_title.dart';
import '../screens/finance/graph_analysis.dart';
import '../screens/finance/product_comparison.dart';
import '../utils/colors.dart';
import 'debtorsreport.dart';

class Reports extends StatelessWidget {
  Reports({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> operations = [
    {
      "title": "Sales Report",
      "subtitle": "How much did you sell",
      "key": "sales",
      "color": Colors.amber.shade100,
      "icon": Icons.today,
    },
    {
      "title": "Due Sales",
      "subtitle": "Credit Sales which are due to be collected",
      "key": "dues",
      "color": Colors.amber.shade100,
      "icon": Icons.shop_two_outlined,
    },
    {
      "title": "Sales by Products",
      "subtitle": "sales by products",
      "key": "productsales",
      "color": Colors.amber.shade100,
      "icon": Icons.today,
    },
    {
      "title": "Discount Report",
      "subtitle": "discount report by products",
      "key": "discoutedsales",
      "color": Colors.amber.shade100,
      "icon": Icons.today,
    },
    {
      "title": "Debtors Reports",
      "subtitle": "All your debtors and total owed",
      "key": "debtors",
      "color": Colors.amber.shade100,
      "icon": Icons.shop_two_outlined,
    },
    {
      "title": "Purchases Report",
      "subtitle": "How much did you buy",
      "key": "purchases",
      "color": Colors.amber.shade100,
      "icon": Icons.shop_two_outlined,
    },
    {
      "title": "Expenses Report",
      "subtitle": "How much did you spend",
      "key": "expenses",
      "color": Colors.blue.shade100,
      "icon": Icons.payment,
    },
    {
      "title": "Stock Take Report",
      "subtitle": "Stock taking report for your shop",
      "color": Colors.blue.shade100,
      "key": "stocktake",
      "icon": Icons.analytics,
    },
    {
      "title": "Income Report",
      "subtitle": "Net and gross profit report for your shop",
      "color": Colors.blue.shade100,
      "key": "netprofit",
      "icon": Icons.auto_graph,
    },
    {
      "title": "Stock Report",
      "subtitle": "Stock report for your shop",
      "key": "stockreport",
      "color": Colors.blue.shade100,
      "icon": Icons.sell_rounded,
    },
    {
      "title": "Products Movement",
      "subtitle": "Productwise sales report for your shop",
      "key": "productmovement",
      "color": Colors.blue.shade100,
      "icon": Icons.sell_rounded,
    },
    {
      "title": "Sales,Profit and Expenses Graphical Analysis",
      "subtitle": "Sales,Profit and expenses Graphical Analysis",
      "key": "profitanalysis",
      "color": Colors.blue.shade100,
      "icon": Icons.show_chart,
    },
  ];

  clickOperation(title, context) {
    switch (title) {
      case "sales":
        {
          Get.to(() => SalesSummary());
        }
        break;
      case "productsales":
        {
          Get.to(() => ProductSalesReport(
                title: "Sales by Products",
                keyFrom: "productsales",
              ));
        }
      case "discoutedsales":
        {
          Get.to(() => DiscountSalesReport(
                title: "Discount Reports",
                keyFrom: "discoutedsales",
              ));
        }
      case "purchases":
        {
          Get.to(() => PurchasesSummary());
        }
      case "stockreport":
        {
          Get.to(() => StockReportScreen());
        }

        break;
      case "expenses":
        {
          Get.to(() =>
              ExpensePage(firstday: DateTime.now(), lastday: DateTime.now()));
        }
        break;
      case "stocktake":
        {
          Get.to(() => StockTakeReport());
        }
      case "netprofit":
        {
          Get.to(() => NetProfitReport());
        }
      case "productmovement":
        {
          Get.to(() => const ProductAnalysis());
        }
      case "profitanalysis":
        {
          Get.to(() => const GraphAnalysis());
        }
      case "dues":
        {
          Get.to(() => SalesReport(title: "Due Sales", keyFrom: "dues"));
        }
      case "debtors":
        {
          Get.to(() => DebtorsReportScreen());
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Helper(
      widget: Container(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: operations.length,
          itemBuilder: (context, index) {
            return financeCards(
                title: operations[index]["title"],
                subtitle: operations[index]["subtitle"],
                icon: operations[index]["icon"],
                onPresssed: () {
                  clickOperation(operations[index]["key"], context);
                },
                color: operations[index]["color"],
                amount: operations[index]["amount"]);
          },
        ),
      ),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: majorTitle(title: "Reports", color: Colors.black, size: 16.0),
      ),
    );
  }

  Widget financeCards(
      {required title,
      required subtitle,
      required icon,
      bool? showsummary = true,
      required onPresssed,
      required Color color,
      required amount}) {
    return InkWell(
      onTap: () {
        onPresssed();
      },
      child: Container(
        margin: EdgeInsets.only(
            top: 10,
            right: isSmallScreen(Get.context) ? 0 : 15,
            left: isSmallScreen(Get.context) ? 0 : 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color:  AppColors.mainColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Icon(icon)),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      majorTitle(title: title, color: Colors.black, size: 16.0),
                      const SizedBox(height: 5),
                      minorTitle(title: subtitle, color: Colors.grey)
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
