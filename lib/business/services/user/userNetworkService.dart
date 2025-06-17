import '../../models/user/authentication.dart';
import '../../models/user/user.dart';

abstract class UserNetworkService {
  Future<User> seConnecter(Authentication authentication);
  Future<User> recupererInfoUtilisateur();
}
