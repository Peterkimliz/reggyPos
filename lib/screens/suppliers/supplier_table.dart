import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../models/supplier.dart';

Widget supplierTable(
    {required customers, required context, Function? function}) {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.grey),
        child: DataTable(
          decoration: BoxDecoration(
              border: Border.all(
            width: 1,
            color: Colors.black,
          )),
          columnSpacing: 50.0,
          columns: const [
            DataColumn(label: Text('Name', textAlign: TextAlign.center)),
            DataColumn(label: Text('Phone', textAlign: TextAlign.center)),
            DataColumn(label: Text('Action', textAlign: TextAlign.center)),
          ],
          rows: List.generate(customers.length, (index) {
            Supplier supplierModel = customers.elementAt(index);
            final y = supplierModel.name;
            const x = "0";

            return DataRow(cells: [
              DataCell(Text(y!)),
              DataCell(Text(x.toString())),
              DataCell(
                InkWell(
                  onTap: () {
                    // if (function != null) {
                    //   Get.find<PurchaseController>().invoice.value?.supplier =
                    //       supplierModel;
                    //   Get.find<HomeController>().selectedWidget.value =
                    //       CreatePurchase();
                    //   function();
                    // } else {
                    //   Get.find<HomeController>().selectedWidget.value =
                    //       SupplierInfoPage(
                    //     supplierModel: supplierModel,
                    //   );
                    // }
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(3)),
                        width: 75,
                        child: Text(
                          function != null ? "Select" : "View",
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          }),
        ),
      ),
    ),
  );
}
