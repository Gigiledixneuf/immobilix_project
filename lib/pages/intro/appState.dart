// create a state class for the home page

import '../../business/models/user/user.dart';

class AppState {
  User? user;
  bool? isLoading = false;
  String? error;

  AppState({this.user, this.isLoading, this.error});

  AppState copyWith({User? user, bool? isLoading, String? error}) {
    return AppState(user: user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error ?? this.error);
  }
  
  
}


