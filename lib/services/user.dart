import 'package:reggypos/main.dart';
import 'package:reggypos/models/usermodel.dart';
import 'package:reggypos/sqlite/helper.dart';
import 'package:reggypos/utils/helper.dart';

import 'client.dart';
import 'end_points.dart';

class User {
  Future getSettings() async {
    try {
      if (!await isConnected()) {
        return await DatabaseHelper().getOfflineSettings();
      }
      var response = await DbBase()
          .databaseRequest(EndPoints.setting, DbBase().getRequestType);
      return response;
    } catch (e) {
      return null;
    }
  }

  profileUpdate(var json) async {
    String? id = userController.currentUser.value!.id!;
    // if (userController.currentUser.value!.usertype == "attendant") {
    //   json['usertype'] = "attendant";
    // }
    var response = await DbBase().databaseRequest(
        "${EndPoints.profile}$id", DbBase().putRequestType,
        body: json);
    return response;
  }

  static deleteAccount() async {
    var response = await DbBase().databaseRequest(
        "${EndPoints.profile}${userController.currentUser.value!.id!}",
        DbBase().deleteRequestType,
        body: {"adminId": userController.currentUser.value?.id});
    return response;
  }

  static getAttendants() async {
    var response = await DbBase().databaseRequest(
      "${EndPoints.attendantsfilter}?adminId=${userController.currentUser.value?.id}",
      DbBase().getRequestType,
    );
    return response;
  }

  static createAttendant(Map<String, dynamic> map) async {
    var response = await DbBase().databaseRequest(
        EndPoints.attendants, DbBase().postRequestType,
        body: map);
    return response;
  }

  atendantUpdate(Map<String, dynamic> map, String id) async {
    var response = await DbBase().databaseRequest(
        EndPoints.attendants + id, DbBase().putRequestType,
        body: map);
    return response;
  }

  static deleteUser(UserModel userModel) async {
    var response = await DbBase().databaseRequest(
        EndPoints.attendants + userModel.id!, DbBase().deleteRequestType);
    return response;
  }

  Future<void> updateLastSeen() async {
    var response = await DbBase()
        .databaseRequest(EndPoints.lastseen, DbBase().putRequestType, body: {
      "type": userController.currentUser.value!.usertype,
      "userid": userController.currentUser.value!.id
    });
    return response;
  }

  static sendVerificationEmail() async {
    var response = await DbBase().databaseRequest(
        EndPoints.sendverificationemail, DbBase().postRequestType,
        body: {"userid": userController.currentUser.value!.id});
    return response;
  }
}
