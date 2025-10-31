
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: unused_import
import '../../business/models/user/user.dart';
import '../../business/services/user/userLocalService.dart';
import '../../main.dart';
import 'appState.dart';

class AppCtrl  extends StateNotifier<AppState>{
  var userLocalService=getIt<UserLocalService>();

  AppCtrl() : super(AppState());

  Future<void> getUser() async {
    try {
      var user = await userLocalService.recupererUser();
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    await userLocalService.supprimerUser();
    state = state.copyWith(user: null);
  }
}


final appCtrlProvider = StateNotifierProvider<AppCtrl, AppState>((ref) {
  ref.keepAlive();
  return AppCtrl();
});
