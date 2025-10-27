import '../../models/user/authentication.dart';
import '../../models/user/user.dart';

abstract class UserNetworkService {
  Future<User> login(String email, String password);
  Future<User> register(String fullName, String email, String portable, String password, String passwordConfirmation);
  Future<User> recupererInfoUtilisateur();
}
