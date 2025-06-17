import 'dart:convert';

import 'package:odc_mobile_template/utils/localManager.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userLocalService.dart';

class UserLocalServiceImpl implements UserLocalService {
  LocalManager? box;

  UserLocalServiceImpl({this.box});

  @override
  Future<User?> recupererUser() async {
    var data = await box?.readData("USER_KEY");
    return data != null ? User.fromJson(jsonDecode(data)) : null;
  }

  @override
  Future<bool> sauvegarderUser(User user) async {
    await box?.writeData("USER_KEY", jsonEncode(user.toJson()));
    return true;
  }

  @override
  Future<bool> supprimerUser() async {
    await box?.deleteData("USER_KEY");
    return true;
  }
}
