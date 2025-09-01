import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    _checkOnboardingStatus();
  }

  // Utilise GetStorage pour vérifier l'état d'onboarding
  Future<void> _checkOnboardingStatus() async {
    final box = GetStorage();
    final onboardingCompleted = box.read('onboarding_completed') ?? false;
    state = onboardingCompleted;
  }

  // Utilise GetStorage pour marquer l'onboarding comme terminé
  Future<void> completeOnboarding() async {
    final box = GetStorage();
    await box.write('onboarding_completed', true);
    state = true;
  }
}
