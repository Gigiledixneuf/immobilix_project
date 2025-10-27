import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/business/services/user/userLocalService.dart';
import 'package:immobilx/business/services/user/userNetworkService.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/pages/intro/appCtrl.dart';
import 'login_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final UserNetworkService _userNetworkService;
  final UserLocalService _userLocalService;
  final AppCtrl _appCtrl;

  AuthController(this._userNetworkService, this._userLocalService, this._appCtrl) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userNetworkService.login(email, password);
      await _userLocalService.enregistrerUser(user);
      _appCtrl.getUser();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String fullName, String email, String portable, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userNetworkService.register(fullName, email, portable, password, passwordConfirmation);
      await _userLocalService.enregistrerUser(user);
      _appCtrl.getUser();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _userLocalService.supprimerUser();
    _appCtrl.getUser();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final userNetworkService = getIt<UserNetworkService>();
  final userLocalService = getIt<UserLocalService>();
  final appCtrl = ref.read(appCtrlProvider.notifier);
  return AuthController(userNetworkService, userLocalService, appCtrl);
});
