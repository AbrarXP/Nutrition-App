import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {

  // Setters
  Future<void> setLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", value);
  }

  Future<void> setUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", value);
  }

  Future<void> setUserID(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userID", value);
  }

  Future<void> setBeratBadan(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("bb", value);
  }

  Future<void> setTinggiBadan(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("tb", value);
  }
  
  Future<void> setUsia(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("usia", value);
  }

  Future<void> setJenisKelamin(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("jenis_kelamin", value);
  }


  // Getters
  Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("username") ?? "Username belum diatur";
  }

  Future<int> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userID") ?? 0;
  }

  Future<int> getBeratBadan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("bb") ?? 0;
  }

  Future<int> getTinggiBadan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("tb") ?? 0;
  }

  Future<int> getUsia() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("usia") ?? 0;
  }

  Future<String> getJenisKelamin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jenis_kelamin") ?? "";
  }




}
