import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:notesave/Utils/Logger/logger.dart';
import '../../Utils/AppConstant/app_constant.dart';
import '../../Utils/TokenServices/token_services.dart';

class AuthService {
  static Timer? _tokenRefreshTimer;
  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  static Future<void> init() async {
    AppLogger.log('Initializing AuthService...', type: 'info');

    bool isAuthenticated = await TokenService().isAuthenticated();

    if (isAuthenticated) {
      AppLogger.log('User is authenticated', type: 'success');
      startTokenRefreshTimer();
    } else {
      AppLogger.log(' User is not authenticated', type: 'warning');
    }

    AppLogger.log('AuthService initialized successfully', type: 'success');
  }


  static Future<bool> refreshToken() async {
    if (_isRefreshing) {
      AppLogger.log('⏳ Token refresh already in progress, waiting...', type: 'info');
      return await _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await TokenService().getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.log("No refresh token available", type: "error");
        _completeRefresh(false);
        return false;
      }

      final url = "${AppConstants.BASE_URL}/api/auth/renew-access-token";
      AppLogger.log("🔄 Attempting to refresh token...", type: "info");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      ).timeout(const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Token refresh request timed out');
        },
      );

      AppLogger.log("Refresh Response Status: ${response.statusCode}", type: "info");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['data']?["accessToken"] ?? data["access_token"];
        final newRefreshToken = data['data']?["refreshToken"] ?? data["refresh_token"];

        if (newAccessToken != null && newRefreshToken != null) {
          await TokenService().saveToken(newAccessToken);
          await TokenService().saveRefreshToken(newRefreshToken);
          AppLogger.log("Token refreshed successfully!", type: "success");
          _completeRefresh(true);
          return true;
        } else {
          AppLogger.log("New tokens not found in response", type: "warning");
          _completeRefresh(false);
          return false;
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        AppLogger.log("Refresh token invalid/expired, clearing all tokens", type: "warning");
        await TokenService().clearAll();
        stopTokenRefreshTimer();
        _completeRefresh(false);
        return false;
      } else {
        AppLogger.log("Token refresh failed with status: ${response.statusCode}", type: "error");
        _completeRefresh(false);
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.log("Token refresh error: $e", type: "error");
      AppLogger.log("Stack trace: $stackTrace", type: "error");
      _completeRefresh(false);
      return false;
    }
  }

  static void _completeRefresh(bool success) {
    _isRefreshing = false;
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(success);
    }
    _refreshCompleter = null;
  }


  static Future<bool> validateAndRefreshToken() async {
    AppLogger.log('🔍 Starting token validation and refresh process', type: 'info');

    final tokenService = TokenService();
    bool tokenExists = await tokenService.isAuthenticated();

    if (!tokenExists) {
      bool hasRefresh = await tokenService.hasRefreshToken();
      if (hasRefresh) {
        AppLogger.log('🔄 Access token expired, attempting to refresh...', type: 'info');
        bool refreshSuccess = await refreshToken();

        if (refreshSuccess) {
          AppLogger.log('Token successfully refreshed', type: 'success');
          return true;
        } else {
          AppLogger.log('Failed to refresh token', type: 'error');
          return false;
        }
      } else {
        AppLogger.log('No valid tokens available', type: 'warning');
        return false;
      }
    }

    bool expiresSoon = await tokenService.tokenExpiresWithin(5);
    if (expiresSoon) {
      AppLogger.log('Access token expires soon, attempting proactive refresh...', type: 'info');
      bool refreshSuccess = await refreshToken();

      if (refreshSuccess) {
        AppLogger.log('Token successfully refreshed', type: 'success');
        return true;
      }
      return false;
    }

    AppLogger.log('Token is valid and not expiring soon', type: 'success');
    return true;
  }


  static Future<bool> ensureValidToken() async {
    return await validateAndRefreshToken();
  }


  static Future<void> logout() async {
    await TokenService().clearAll();
    AppLogger.log("User logged out successfully", type: "info");
    stopTokenRefreshTimer();
  }


  static void startTokenRefreshTimer() {
    stopTokenRefreshTimer();

    _tokenRefreshTimer = Timer.periodic(Duration(minutes: 4), (timer) async {
      AppLogger.log('Automatic token refresh check triggered', type: 'info');

      try {
        bool isAuthenticated = await TokenService().isAuthenticated();

        if (!isAuthenticated) {
          AppLogger.log('User not authenticated, stopping timer', type: 'warning');
          stopTokenRefreshTimer();
          return;
        }

        bool expiresSoon = await TokenService().tokenExpiresWithin(5);
        if (expiresSoon) {
          AppLogger.log('Token expires soon, refreshing...', type: 'info');
          await refreshToken();
        } else {
          AppLogger.log('Token is still valid, no refresh needed', type: 'info');
        }
      } catch (e) {
        AppLogger.log('Error during automatic token refresh: $e', type: 'error');
      }
    });

    AppLogger.log('Automatic token refresh timer started', type: 'info');
  }


  static void stopTokenRefreshTimer() {
    if (_tokenRefreshTimer != null) {
      _tokenRefreshTimer!.cancel();
      _tokenRefreshTimer = null;
      AppLogger.log('Automatic token refresh timer stopped', type: 'info');
    }
  }


  static bool isTokenRefreshTimerActive() {
    return _tokenRefreshTimer != null && _tokenRefreshTimer!.isActive;
  }
}