import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reggypos/controllers/expensecontroller.dart';
import 'package:reggypos/controllers/reports_controller.dart';
import 'package:reggypos/functions/functions.dart';
import 'package:reggypos/main.dart';
import 'package:reggypos/models/expense.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/finance/financial_page.dart';
import 'package:reggypos/screens/receipts/pdf/expenses/expenses_summary_pdf.dart';
import 'package:reggypos/widgets/textbutton.dart';
import 'package:printing/printing.dart';

import '../../controllers/homecontroller.dart';
import '../../controllers/salescontroller.dart';
import '../../controllers/shopcontroller.dart';
import '../../screens/expenses/components/expense_card.dart';
import '../../screens/expenses/create_expense.dart';
import '../../utils/colors.dart';
import '../../widgets/major_title.dart';
import '../../widgets/filter_dates.dart';
import 'expenses_categories.dart';

class ExpensePage extends StatelessWidget {
  final DateTime firstday;
  final DateTime lastday;
  ExpensePage({Key? key, required this.firstday, required this.lastday})
      : super(key: key) {
    expenseController.getExpenses(
        fromDate: DateFormat("yyyy-MM-dd").format(firstday),
        toDate: DateFormat("yyyy-MM-dd").format(lastday));
  }
  final SalesController salesController = Get.find<SalesController>();
  final ExpenseController expenseController = Get.find<ExpenseController>();
  final  ShopController shopController = Get.find<ShopController>();
  final  ReportsController reportsController = Get.find<ReportsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (!isSmallScreen(context)) {
              Get.find<HomeController>().selectedWidget.value = FinancialPage();
            } else {
              Get.back();
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.mainColor,
          ),
        ),
        title: majorTitle(
            title: "Expenses", color: AppColors.mainColor, size: 16.0),
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
                    _printPdf();
                  }),
            ),
          const SizedBox(width: 10)
        ],
      ),
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  filterByDates(onFilter: (start, end, type) {
                    reportsController.activeFilter.value = type;
                    reportsController.filterStartDate.value = DateFormat(
                      "yyyy-MM-dd",
                    ).format(start);
                    reportsController.filterEndDate.value = DateFormat(
                      "yyyy-MM-dd",
                    ).format(end);

                    expenseController.getExpenses(
                      fromDate: reportsController.filterStartDate.value,
                      toDate: reportsController.filterEndDate.value,
                      shop: userController.currentUser.value!.primaryShop!.id!,
                    );
                  }),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.credit_card,
                              color: AppColors.mainColor),
                          const SizedBox(width: 10),
                          Obx(
                            () => Text(
                              htmlPrice(expenseController.expenses.fold(
                                  0,
                                  (previousValue, element) =>
                                      previousValue + element.amount!)),
                              style: const TextStyle(
                                  color: AppColors.mainColor, fontSize: 21),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.only(right: 10, left: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: addExpenseContainer(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Obx(() {
                return majorTitle(
                    title: "${expenseController.expenses.length} Entries",
                    color: Colors.black,
                    size: 15.0);
              }),
            ),
            const SizedBox(
              height: 10,
            ),
            Obx(() {
              return expenseController.expenses.isEmpty
                  ? Center(
                      child: majorTitle(
                          title: "No Entries found",
                          color: Colors.grey,
                          size: 13.0),
                    )
                  : isSmallScreen(context)
                      ? Expanded(
                          child: ListView.builder(
                              itemCount: expenseController.expenses.length,
                              itemBuilder: (context, index) {
                                ExpenseModel expenseModel =
                                    expenseController.expenses.elementAt(index);

                                return expenseCard(
                                    context: context, expense: expenseModel);
                              }),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          width: double.infinity,
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.grey),
                            child: DataTable(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                width: 1,
                                color: Colors.black,
                              )),
                              columnSpacing: 30.0,
                              columns: [
                                const DataColumn(
                                    label: Text('Name',
                                        textAlign: TextAlign.center)),
                                const DataColumn(
                                    label: Text('Category',
                                        textAlign: TextAlign.center)),
                                DataColumn(
                                    label: Text(
                                        'Amount(${userController.currentUser.value!.primaryShop?.currency})',
                                        textAlign: TextAlign.center)),
                              ],
                              rows: List.generate(
                                  expenseController.expenses.length, (index) {
                                ExpenseModel expenseModel =
                                    expenseController.expenses.elementAt(index);
                                final y = expenseModel.name;
                                final x = expenseModel.category!.name;

                                return DataRow(cells: [
                                  DataCell(Text(y!)),
                                  DataCell(Text(x.toString())),
                                  DataCell(Text("${expenseModel.amount}")),
                                ]);
                              }),
                            ),
                          ),
                        );
            }),
          ],
        ),
      ),
    );
  }

  Widget addExpenseContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            if (isSmallScreen(Get.context)) {
              Get.to(() => CreateExpense());
            } else {
              Get.find<HomeController>().selectedWidget.value = CreateExpense(
                from: "ExpensePage",
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColors.mainColor, width: 3)),
            child: majorTitle(
                title: "Add Expenses", color: AppColors.mainColor, size: 12.0),
          ),
        ),
        const SizedBox(
          width: 30,
        ),
        InkWell(
          onTap: () {
            if (isSmallScreen(Get.context)) {
              Get.to(() => ExpensesCategories());
            } else {
              Get.find<HomeController>().selectedWidget.value =
                  ExpensesCategories();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.mainColor, width: 3)),
            child: Row(
              children: [
                majorTitle(
                    title: "By Categories",
                    color: AppColors.mainColor,
                    size: 12.0),
                const Icon(
                  Icons.filter_list,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _printPdf() {
    Get.to(() => Scaffold(
          appBar: AppBar(
            title: const Text("Sales summary report"),
          ),
          body: PdfPreview(
            build: (context) =>
                expensesPdf(expenseController.expenses, "EXPENSES REPORT"),
          ),
        ));
  }
}
