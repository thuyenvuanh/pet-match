import 'package:pet_match/src/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalDatasource {
  OnboardingLocalDatasource(this.localStorage);

  final SharedPreferences localStorage;
  final String onboardingEnabled = "onboardingEnabled";

  bool get isOnboardingEnable =>
      localStorage.getFromGlobalStorage(onboardingEnabled) as bool? ?? true;

  Future<void> disableOnboardingScreen() async {
    await localStorage.addToGlobalStorage(onboardingEnabled, false);
  }
}
