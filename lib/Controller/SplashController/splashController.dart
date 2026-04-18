import 'package:get/get.dart';

import '../../Router/route_names.dart';
import '../../Services/Auth/Auth_Services.dart';
import '../../Utils/Logger/logger.dart';
import '../../Utils/TokenServices/token_services.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString statusText = 'Checking your session...'.obs;

  final TokenService _tokenService = TokenService();

  Future<String> resolveInitialRoute() async {
    try {
      isLoading.value = true;
      statusText.value = 'Checking your session...';

      await _tokenService.reloadTokens();
      await Future.delayed(const Duration(milliseconds: 1000));

      final hasAccessToken = (_tokenService.getToken() ?? '').isNotEmpty;
      final hasRefreshToken = await _tokenService.hasRefreshToken();

      if (!hasAccessToken && !hasRefreshToken) {
        AppLogger.log('No session found. Routing to login.', type: 'info');
        return AppRouteName.login;
      }

      statusText.value = 'Restoring your account...';

      final isAuthenticated = await AuthService.validateAndRefreshToken();
      if (isAuthenticated) {
        if (!AuthService.isTokenRefreshTimerActive()) {
          AuthService.startTokenRefreshTimer();
        }

        AppLogger.log('Session restored. Routing to home.', type: 'success');
        return AppRouteName.home;
      }

      await AuthService.logout();
      AppLogger.log('Session invalid. Routing to login.', type: 'warning');
      return AppRouteName.login;
    } catch (e, stackTrace) {
      isLoading.value = false;
      AppLogger.log('Splash routing error: $e', type: 'error');
      AppLogger.log('Stack trace: $stackTrace', type: 'error');
      await AuthService.logout();
      return AppRouteName.login;
    } finally {
      isLoading.value = false;
    }
  }
}
