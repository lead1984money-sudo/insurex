import 'package:shared_preferences/shared_preferences.dart';
import '../../screen/login/model/VerifyOtpModel.dart';


class PreferenceManager {
  static const String loginDataKey = "login_data";

  static Future<void> saveLoginData(
      VerifyOtpModel model) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      loginDataKey,
      model.toRawJson(),
    );
  }

  static Future<VerifyOtpModel?> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(loginDataKey);

    if (data == null) return null;

    return VerifyOtpModel.fromRawJson(data);
  }

  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginDataKey);
  }
}