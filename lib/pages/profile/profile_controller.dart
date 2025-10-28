import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immobilx/business/services/user/userNetworkService.dart';
import 'package:immobilx/main.dart';
import 'package:immobilx/pages/profile/profile_state.dart';

import '../../business/models/user/user.dart';


class ProfileController extends StateNotifier<ProfileState> {
  final UserNetworkService _userNetworkService;

  ProfileController(this._userNetworkService) : super(ProfileState()) {
    // Charger le profil dès l'initialisation du contrôleur
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _userNetworkService.getProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedUser = await _userNetworkService.updateProfile(data);
      // Mettre à jour l'état avec le nouvel utilisateur et garder l'ancien token
      final newUserWithToken = User.fromJson({
        ...updatedUser.toJson(),
        'token': state.user?.token,
      });
      state = state.copyWith(user: newUserWithToken, isUpdating: false);
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      return false;
    }
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final userNetworkService = getIt<UserNetworkService>();
  return ProfileController(userNetworkService);
});
