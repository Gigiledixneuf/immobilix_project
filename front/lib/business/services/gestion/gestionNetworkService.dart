import '../../models/article/article.dart';

abstract class GestionNetworkService {
  Future<List<Article>> recupererArticles();
  Future<Article> recupererArticle(int id);
}
