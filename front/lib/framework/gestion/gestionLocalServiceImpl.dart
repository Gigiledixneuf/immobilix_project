
import '../../business/models/article/article.dart';
import '../../business/services/gestion/gestionLocalService.dart';

class GestionLocalServiceImpl implements GestionLocalService {
  

  @override
  Future<List<Article>> recupererArticlesFavoris() async {
    // TODO: implement recupererArticlesFavoris
    throw UnimplementedError();
  }

  @override
  Future<bool> sauvegarderArticleFavoris(Article article) {
    // TODO: implement sauvegarderArticleFavoris
    throw UnimplementedError();
  }

  @override
  Future<bool> supprimerArticleFavoris(Article article) {
    // TODO: implement supprimerArticleFavoris
    throw UnimplementedError();
  }
  
}