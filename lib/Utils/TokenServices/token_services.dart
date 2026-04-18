import 'package:notesave/Utils/Logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../JWT/jwt_utils.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _email = 'user_email';
  static const String _name = 'user_name';
  static const String _avatar = 'user_avatar';

  //----====---- initialize the SharedPreferences when this class call ----====----//
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize SharedPreferences - MUST be called at app startup
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      AppLogger.log('TokenService initialized successfully', type: 'success');
    } catch (e) {
      AppLogger.log('Failed to initialize TokenService: $e', type: 'error');
      throw Exception('TokenService initialization failed');
    }
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

  Future<void> saveEmail(String email) async {
    await _prefs?.setString(_email, email);
  }

  String? getEmail() {
    return _prefs?.getString(_email);
  }

  Future<void> saveName(String name) async {
    await _prefs?.setString(_name, name);
  }

  String? getName() {
    return _prefs?.getString(_name);
  }

  Future<void> saveAvatar(String avatar) async {
    await _prefs?.setString(_avatar, avatar);
  }

  String? getAvatar() {
    return _prefs?.getString(_avatar);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    bool expired = JwtUtils.isTokenExpired(token);
    if (expired) {
      AppLogger.log('Access token is expired', type: 'warning');
    }

    return !expired;
  }

  Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return true;
    }
    return JwtUtils.isTokenExpired(token);
  }

  Future<bool> tokenExpiresWithin(int minutes) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return true;
    }

    bool expiresSoon = JwtUtils.expiresWithin(token, minutes);
    if (expiresSoon) {
      AppLogger.log('Token expires within $minutes minutes', type: 'warning');
    }

    return expiresSoon;
  }

  /// Get the expiration time of the access token
  Future<DateTime?> getTokenExpiration() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return JwtUtils.getTokenExpiration(token);
  }

  /// Get seconds until token expires
  Future<int?> getSecondsUntilExpiration() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    return JwtUtils.getSecondsUntilExpiration(token);
  }

  /// Force refresh - just an alias for consistency
  Future<void> forceRefresh() async {
    // No need to reload, SharedPreferences is already synced
    AppLogger.log('Token service refreshed', type: 'info');
  }

  Future<void> reloadTokens() async {
    // SharedPreferences automatically syncs, but we can reinitialize if needed
    if (!_isInitialized) {
      await init();
    }
  }




}
