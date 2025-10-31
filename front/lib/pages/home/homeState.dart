// create a state class for the home page

import '../../business/models/article/article.dart';

class HomeState {
  List<Article>? articles;
  bool? isLoading = false;
  String? error;

  HomeState({this.articles, this.isLoading, this.error});

  HomeState copyWith({List<Article>? articles, bool? isLoading, String? error}) {
    return HomeState(articles: articles ?? this.articles, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  }
  
  
}


