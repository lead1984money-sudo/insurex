import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


class SpUtil {
  //pref- value
  static const String IS_LOGGED_IN = 'is_logged_in';
  static const String IS_SLIDER_SHOWN = 'IS_SLIDER';
  static const String ACCESS_TOKEN = "access_token";
  static const String MEMBER_TOKEN = "member_token";
  static const String USERNAME = "userName";
  static const String MEMBER_ID = "member_id";
  static const String FCM_TOKEN = 'fcm_token';
  static const String DEVICE_TYPE = 'device_type';
  static const String IS_SUBSCRIPTION = 'isSubscription';
  static const String IsCity = 'City';
  static const String pinCode = 'pinCode';
  static const String LANGUAGE_LOCAL = 'ChangeLanguage';
  static const String State = 'state';
  static const String ADDRESS1 = 'address1';
  static const String ADDRESS2 = 'address2';
  static const String Qualification = 'qualification';
  //static const String ReferCode = 'referCode';
  static const String referCode = 'referCode';
  static const String ISMEMBER = "is_member";
  static const String isSelectedLanguage = 'isSelectedLanguage';
  static const String NOTIFICATION_COUNT = "count";

  static const String DARK_MODE = "dark";

  static SpUtil? _instance;

  static Future<SpUtil> get instance async {
    return await getInstance();
  }

  static SharedPreferences? _spf;

  SpUtil._();

  Future _init() async {
    _spf = await SharedPreferences.getInstance();
  }

  static Future<SpUtil> getInstance() async {
    _instance ??= SpUtil._();
    if (_spf == null) {
      await _instance!._init();
    }
    return _instance!;
  }

  bool hasKey(String key) {
    Set keys = getKeys();
    return keys.contains(key);
  }

  Set<String> getKeys() {
    return _spf!.getKeys();
  }

  get(String key) {
    return _spf!.get(key);
  }

  getString(String key) {
    return _spf!.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _spf!.setString(key, value);
  }

  Future<bool> putString(String key, String value) {
    return _spf!.setString(key, value);
  }

  bool? getBool(String key) {
    return _spf!.getBool(key);
  }

  Future<bool> putBool(String key, bool value) {
    return _spf!.setBool(key, value);
  }

  int? getInt(String key) {
    return _spf!.getInt(key);
  }

  Future<bool> putInt(String key, int value) {
    return _spf!.setInt(key, value);
  }

  double? getDouble(String key) {
    return _spf!.getDouble(key);
  }

  Future<bool> putDouble(String key, double value) {
    return _spf!.setDouble(key, value);
  }

  List<String>? getStringList(String key) {
    return _spf!.getStringList(key);
  }

  Future<bool> putStringList(String key, List<String> value) {
    return _spf!.setStringList(key, value);
  }

  dynamic getDynamic(String key) {
    return _spf!.get(key);
  }

  Future<bool> remove(String key) {
    return _spf!.remove(key);
  }

  Future<bool> clear() {
    return _spf!.clear();
  }

  clearImportantKeys() {
    remove(IS_SLIDER_SHOWN);
    remove(ACCESS_TOKEN);
    remove(MEMBER_TOKEN);
    remove(ISMEMBER);
    remove(IS_LOGGED_IN);
    remove(MEMBER_ID);
    remove(IsCity);
    remove(pinCode);
    remove(State);
    remove(ADDRESS1);
    remove(ADDRESS2);
    remove(Qualification);
    //remove(ReferCode);
    remove(USERNAME);
    // remove(referCode);

  }
}
