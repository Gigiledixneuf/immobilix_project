import 'dart:convert';

import '../../business/models/article/article.dart';
import '../../business/services/gestion/gestionNetworkService.dart';
import '../../utils/http/HttpUtils.dart';

class GestionNetworkServiceImpl implements GestionNetworkService {
  String baseUrl;
  HttpUtils httpUtils;

  GestionNetworkServiceImpl({required this.baseUrl, required this.httpUtils});

  @override
  Future<Article> recupererArticle(int id) {
    // TODO: implement recupererArticle
    throw UnimplementedError();
  }

  @override
  Future<List<Article>> recupererArticles() async {
    var url = '$baseUrl/articles';
    var response = await httpUtils.getData(url);
    var listData = jsonDecode(response);
    var listArticles =
        listData.map<Article>((e) => Article.fromJson(e)).toList();
    return listArticles;
  }
}
