import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/src/data/datasources/local/onboarding_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String onboardingEnabled = "onboardingEnabled";

  test("get isOnboarding data return true if local storage is null", () async {
    SharedPreferences.setMockInitialValues({});
    var localStorage = await SharedPreferences.getInstance();
    var localDatasource = OnboardingLocalDatasource(localStorage);
    var res = localDatasource.isOnboardingEnable;
    expect(res, true);
  });
  test("get isOnboarding data return false if local storage save false",
      () async {
    SharedPreferences.setMockInitialValues({"onboardingEnabled": false});
    var localStorage = await SharedPreferences.getInstance();
    var localDatasource = OnboardingLocalDatasource(localStorage);
    var res = localDatasource.isOnboardingEnable;
    expect(res, false);
  });
  test("set isOnboarding sucessful", () async {
    SharedPreferences.setMockInitialValues({});
    var localStorage = await SharedPreferences.getInstance();
    var localDatasource = OnboardingLocalDatasource(localStorage);
    localDatasource.disableOnboardingScreen();
    expect(localStorage.containsKey(onboardingEnabled), true);
    expect(localStorage.getBool(onboardingEnabled), false);
  });
}
