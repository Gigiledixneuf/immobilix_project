import '../../utils/http/localHttpUtils.dart';
import '../gestionNetworkServiceImpl.dart';

void main() async{
  var gestionNetworkService = GestionNetworkServiceImpl(baseUrl: 'local://', httpUtils: LocalHttpUtils());
  var articles = await gestionNetworkService.recupererArticles();
  articles.forEach((element) {
    print(element.toJson());
  });
}