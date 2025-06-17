
import '../../business/models/user/authentication.dart';

import '../../business/models/user/user.dart';

import '../../business/services/user/userNetworkService.dart';
import '../../utils/http/HttpUtils.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  final String baseUrl;
  final HttpUtils httpUtils;

  UserNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<User> recupererInfoUtilisateur() {
    // TODO: implement recupererInfoUtilisateur
    throw UnimplementedError();
  }

  @override
  Future<User> seConnecter(Authentication authentication) {
    // TODO: implement seConnecter
    throw UnimplementedError();
  }

  
}