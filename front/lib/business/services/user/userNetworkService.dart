import '../../models/user/user.dart';

abstract class UserNetworkService {
  Future<User> login(String email, String password);
  Future<User> register(String fullName, String email, String portable, String password, String passwordConfirmation);
  // Gestion du profil
  Future<User> getProfile();
  Future<User> updateProfile(Map<String, dynamic> data);
}
