
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConstants{
  //-------------- base url set here ---------------------//

  static const String BASE_URL="http://72.60.178.71:7070";
  //static const String BASE_URL="https://preferred-lie-solaris-designation.trycloudflare.com";
  //static const String BASE_URL="https://dimension-upper-bikini-kelkoo.trycloudflare.com";
  static String get APP_NAME => dotenv.env['APP_NAME'] ?? 'DefaultAppName';
  static String get Publishable_key => dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';
  static String get Secret_key => dotenv.env['STRIPE_SECRET_KEY'] ?? '';


  // share preference Key
  static String THEME ="theme";

  static const String LANGUAGE_CODE = 'language_code';
  static const String COUNTRY_CODE = 'country_code';

  static const String fcmToken = '';

  static RegExp emailValidator = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static RegExp passwordValidator = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$");

}