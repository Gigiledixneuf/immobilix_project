
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../business/services/gestion/gestionNetworkService.dart';
import '../../main.dart';
import '../../utils/http/HttpRequestException.dart';
import 'homeState.dart';

class HomeCtrl  extends StateNotifier<HomeState>{
  var gestionNetworkService=getIt<GestionNetworkService>();

  HomeCtrl() : super(HomeState());

  void fetchArticles() async {
    state = state.copyWith(isLoading: true);
    try {
      var articles = await gestionNetworkService.recupererArticles();
      state = state.copyWith(articles: articles, isLoading: false);
    }  catch (e, stackTrace) {
      if(e is HttpRequestException){
        state = state.copyWith(error: e.body);
      }else{
        state = state.copyWith(error: e.toString());
      }
    }finally{
      state = state.copyWith(isLoading: false);
    }
  }
}


final homeCtrlProvider = StateNotifierProvider<HomeCtrl, HomeState>((ref) => HomeCtrl());
