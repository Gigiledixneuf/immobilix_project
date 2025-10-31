import '../../business/models/user/user.dart';

class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUpdating; // Pour gérer l'état de la mise à jour

  ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isUpdating,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Permettre de réinitialiser l'erreur
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
