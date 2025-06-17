import '../../models/user/user.dart';

abstract class UserLocalService {
  Future<User?> recupererUser();
  Future<bool> sauvegarderUser(User user);
  Future<bool> supprimerUser();
}


