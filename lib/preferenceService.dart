import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {

  // Setters
  Future<void> setLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", value);
  }

  // Getters
  Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }



}
