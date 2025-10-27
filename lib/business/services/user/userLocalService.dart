import '../../models/user/user.dart';

abstract class UserLocalService {
  Future<User?> recupererUser();
  Future<bool> enregistrerUser(User user);
  Future<bool> supprimerUser();
}


