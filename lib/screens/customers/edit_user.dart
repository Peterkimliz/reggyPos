import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reggypos/responsive/responsiveness.dart';
import 'package:reggypos/screens/customers/customer_info_page.dart';
import 'package:reggypos/utils/colors.dart';

import '../../controllers/customercontroller.dart';
import '../../controllers/homecontroller.dart';

class EditCustomer extends StatelessWidget {
  final String ? userType;

  EditCustomer({Key? key, this.userType}):super(key:key);

 final  CustomerController customersController = Get.find<CustomerController>();

  @override
  Widget build(BuildContext context) {
    customersController.nameController.text =
        customersController.currentCustomer.value?.name ?? '';
    customersController.phoneController.text =
        customersController.currentCustomer.value?.phoneNumber ?? '';
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "Edit ${userType ?? "Customer"}".capitalize!,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              if (isSmallScreen(context)) {
                Get.back();
              } else {
                Get.find<HomeController>().selectedWidget.value =
                    CustomerInfoPage();
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        backgroundColor: Colors.transparent,
        actions: [
          if (!isSmallScreen(context))
            TextButton(
                onPressed: () {
                  Get.find<HomeController>().selectedWidget.value =
                      CustomerInfoPage();
                  customersController.updateCustomer(
                      context, customersController.currentCustomer.value!);
                },
                child: Text("Save Changes".toUpperCase(),
                    style: const TextStyle(
                        color:AppColors.mainColor, fontWeight: FontWeight.bold)))
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(
            left: isSmallScreen(context) ? 10 : 25,
            right: isSmallScreen(context) ? 10 : 25,
            top: 10,
            bottom: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: customersController.nameController,
              decoration: InputDecoration(
                  hintText: "name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            SizedBox(
              height: isSmallScreen(context) ? 7 : 25,
            ),
            TextFormField(
              controller: customersController.phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                  hintText: "phone number",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            SizedBox(
              height: isSmallScreen(context) ? 7 : 25,
            ),
            TextFormField(
              controller: customersController.emailController,
              decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            SizedBox(
              height: isSmallScreen(context) ? 7 : 25,
            ),
            TextFormField(
              controller: customersController.addressController,
              decoration: InputDecoration(
                  hintText: "Address",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5))),
            ),
            const SizedBox(
              height: 10,
            ),
            if (isSmallScreen(context))
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                          color:AppColors.mainColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        customersController.updateCustomer(context,
                            customersController.currentCustomer.value!);
                      },
                      child: Text("Save Changes".toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.mainColor,
                              fontWeight: FontWeight.bold)))
                ],
              )
          ],
        ),
      ),
    );
  }
}
