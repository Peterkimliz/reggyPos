import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reggypos/main.dart';

import '../utils/colors.dart';
import 'major_title.dart';

logoutAccountDialog(context) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Logout"),
          content: majorTitle(
              title: "You will be logout from you account",
              color: Colors.grey,
              size: 14.0),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: majorTitle(
                    title: "Cancel", color: AppColors.mainColor, size: 16.0)),
            TextButton(
                onPressed: () async {
                  await authController.logOut();
                },
                child: majorTitle(
                    title: "Logout", color: AppColors.mainColor, size: 16.0))
          ],
        );
      });
}
