import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _email ="user_email";

  //----====---- initialize the SharedPreferences when this class call ----====----//
  SharedPreferences? _prefs;
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //----===---- save the access token when the user is login ----====----//
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_accessTokenKey, token);
  }

  //----===---- save the refresh token when the user is login ----====----//
  Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(_refreshTokenKey, token);
  }

  //------=====--- get token when call the api and check the validations ----====----//
  String? getToken() {
    return _prefs?.getString(_accessTokenKey);
  }

  //------=====--- get refresh token for token refresh ----====----//
  String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  //----====--- remove token when use logout ----====-----//
  Future<void> removeToken() async {
    await _prefs?.remove(_accessTokenKey);
  }

  //----====--- remove refresh token when use logout ----====-----//
  Future<void> removeRefreshToken() async {
    await _prefs?.remove(_refreshTokenKey);
  }

  Future<void> saveUserId(String id) async {
    await _prefs?.setString(_userIdKey, id);
  }

  String? getUserId() {
    return _prefs?.getString(_userIdKey);
  }

  Future<void> removeUserId() async {
    await _prefs?.remove(_userIdKey);
  }
  Future<void> saveEmail(String email)async{
    await _prefs?.setString(_email, email);
  }
  String? getEmail() {
    return _prefs?.getString(_email);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
  Future<void> reloadTokens() async {
    _prefs = await SharedPreferences.getInstance();
  }
}