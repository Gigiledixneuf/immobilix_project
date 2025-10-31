import '../../models/article/article.dart';

abstract class GestionLocalService {
  Future<bool> sauvegarderArticleFavoris(Article article);
  Future<List<Article>> recupererArticlesFavoris();
  Future<bool> supprimerArticleFavoris(Article article);
}
