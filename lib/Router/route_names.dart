abstract class AppRouteName {
  // Auth
  static const splash   = 'splash';
  static const login    = 'login';
  static const register = 'register';

  // Shell (bottom-nav tabs)
  static const home     = 'home';
  static const search   = 'search';
  static const profile  = 'profile';
  static const settings = 'settings';

  // Detail screens
  static const itemDetail = 'item-detail';
  static const userDetail = 'user-detail';
}

abstract class AppPath {
  static const splash     = '/splash_screen';
  static const login      = '/LoginScreen';
  static const register   = '/RegistrationScreen';

  static const home       = '/home';
  static const search     = '/search';
  static const profile    = '/profile';
  static const settings   = '/settings';

}