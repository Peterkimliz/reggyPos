// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/controllers/homecontroller.dart';
import 'package:reggypos/controllers/shopcontroller.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/home/home_page.dart';
import 'package:reggypos/widgets/no_items_found.dart';

import '../../../../utils/colors.dart';
import '../../../main.dart';
import '../../../models/usermodel.dart';
import '../../../widgets/attendant_card.dart';
import '../../../widgets/minor_title.dart';
import 'attendant_details.dart';

class AttendantsPage extends StatelessWidget {
  final String? type;

  AttendantsPage({super.key, this.type});

 final ShopController shopController = Get.find<ShopController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                createAttendantWidget(context),
                const Divider(),
                Obx(() {
                  return userController.attendants.isEmpty
                      ? noItemsFound(context, true)
                      : isSmallScreen(context)
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: userController.attendants.length,
                              itemBuilder: (context, index) {
                                UserModel attendantModel =
                                    userController.attendants.elementAt(index);
                                return attendantCard(
                                    userModel: attendantModel,
                                    function: type != "switch"
                                        ? null
                                        : (UserModel userModel) {
                                            switchInit(usermodel: userModel);
                                          });
                              })
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
                                  columns: const [
                                    DataColumn(
                                        label: Text('Name',
                                            textAlign: TextAlign.center)),
                                    DataColumn(
                                        label: Text('Id',
                                            textAlign: TextAlign.center)),
                                    DataColumn(
                                        label: Text('',
                                            textAlign: TextAlign.center)),
                                  ],
                                  rows: List.generate(
                                      userController.attendants.length,
                                      (index) {
                                    UserModel attendantModel = userController
                                        .attendants
                                        .elementAt(index);
                                    final y = attendantModel.username;
                                    final x = attendantModel.uniqueDigits;

                                    return DataRow(cells: [
                                      DataCell(Text(y!)),
                                      DataCell(Text(x.toString())),
                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            Get.find<HomeController>()
                                                    .selectedWidget
                                                    .value =
                                                AttendantDetails(
                                                    userModel: attendantModel);
                                          },
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                margin: const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: AppColors.mainColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3)),
                                                width: 75,
                                                child: const Text(
                                                  "Edit",
                                                  style: TextStyle(
                                                      color: Colors.white),
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
                            );
                })
              ],
            ),
          ),
        )));
  }

  Future<void> switchInit({UserModel? usermodel}) async {
    userController.switcheduser.value = usermodel;

    await authController.initUser();
    Get.back();
    userController.switcheduser.refresh();
  }

  Widget createAttendantWidget(context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: InkWell(
        onTap: () {
          if (type == "switch") {
            userController.switcheduser.value = null;
            switchInit();
            isSmallScreen(context)
                ? Get.back()
                : Get.find<HomeController>().selectedWidget.value = HomePage();
          } else {
            if (!isSmallScreen(context)) {
              userController.nameController.clear();
              userController.passwordController.clear();
              Get.find<HomeController>().selectedWidget.value =
                  AttendantDetails(
                userModel: null,
              );
            } else {
              userController.nameController.clear();
              userController.passwordController.clear();

              Get.to(() => AttendantDetails(
                    userModel: null,
                  ));
            }
          }
        },
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.mainColor, width: 2),
            ),
            child: minorTitle(
                title: type == "switch" ? "Back to Admin" : "+ Add attendant",
                color: AppColors.mainColor),
          ),
        ),
      ),
    );
  }
}
