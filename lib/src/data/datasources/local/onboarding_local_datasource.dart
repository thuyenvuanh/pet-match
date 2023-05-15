import 'package:shared_preferences/shared_preferences.dart';

class OnboardingLocalDatasource {
  OnboardingLocalDatasource(this.localStorage);

  final SharedPreferences localStorage;
  final String onboardingEnabled = "onboardingEnabled";

  bool get isOnboardingEnable =>
      localStorage.getBool(onboardingEnabled) ?? true;

  void disableOnboardingScreen() {
    localStorage.setBool(onboardingEnabled, false);
  }
}
