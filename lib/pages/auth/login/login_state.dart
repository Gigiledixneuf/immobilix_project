class AuthState {
  final bool isLoading;
  final String? error;

  AuthState({this.isLoading = false, this.error});

  AuthState copyWith({bool? isLoading, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
