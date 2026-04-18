import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:notesave/Utils/Logger/logger.dart';
import 'package:notesave/Utils/SuccessBar/successbar.dart';
import 'package:notesave/Utils/floatingbar/floatingbar.dart';
import '../../Router/route_names.dart';
import '../../Utils/AppConstant/app_constant.dart';
import '../../Utils/TokenServices/token_services.dart';
import '../NetworkService/networkservice.dart';


class Authcontroller extends GetxController {

  /// bool values
  final RxBool isLoading = false.obs;
  final RxBool accepted = false.obs;
  final RxBool googleLoading = false.obs;
  final RxBool appleLoading = false.obs;


  ///------ use login TextEditingController controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();


  //---------> signupdate screen create <-----------//
  final TextEditingController registerNamecontroller = TextEditingController();
  final TextEditingController registerLastnameController = TextEditingController();
  final TextEditingController registerpasswordController = TextEditingController();
  final TextEditingController registeremailController = TextEditingController();

  final RxInt selectedIndex = 0.obs;


  void toggleAccepted(bool? value) {
    accepted.value = value ?? false;
  }

  /// Logs in user with provided credentials.
  Future<void> loginUser({
    required BuildContext context,
    String? name,
    String? password,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    final url = '${AppConstants.BASE_URL}/auth/login';

    if (!accepted.value) {
      FloatingErrorBar.show(
        context,
        message: 'You must accept the terms & conditions ⚠️',
      );
      return;
    }
    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': name, 'password': password}),
      );

      AppLogger.log('Status Code: ${response.statusCode}');
      AppLogger.log('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['response']['data'];
        final tokens = data['response']['tokens'];
        final accessToken = tokens['access']['token'];
        final refreshToken = tokens['refresh']['token'];

        await TokenService().saveToken(accessToken);
        await TokenService().saveRefreshToken(refreshToken);
        await TokenService().saveUserId('${user['id'] ?? user['_id'] ?? ''}');
        await TokenService().saveEmail('${user['email'] ?? name ?? ''}');
        await TokenService().saveName('${user['name'] ?? user['username'] ?? user['fullName'] ?? ''}',);
        await TokenService().saveAvatar('${user['avatar'] ?? user['image'] ?? user['profileImage'] ?? ''}',);

        AppLogger.log('Login success');
        AppLogger.log('Token: $accessToken');
        FloatingSuccessBar.show(context, message: 'Login successful! Welcome back 👋',);

        if (context.mounted) {
          context.goNamed(AppRouteName.home);
        }
        return;
      } else if (response.statusCode == 400) {
        isLoading.value = false;
        AppLogger.log('Invalid credentials');
        return;
      } else {
        isLoading.value = false;
        AppLogger.log('Server error');
        return;
      }
    } catch (e) {
      isLoading.value = false;
      AppLogger.log('Exception: $e');
      return;
    } finally {
      isLoading.value = false;
    }
  }



  bool isValidPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> registerUser({
    required BuildContext context,
    String? name,
    String? email,
    String? password,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }
    final url = '${AppConstants.BASE_URL}/auth/register';

    if (password == null || password.isEmpty) {
      FloatingErrorBar.show(context, message: "Password required");
      return;
    }

    if (!isValidPassword(password)) {
      FloatingErrorBar.show(
        context,
        message: "Password must contain 8 characters, 1 letter and 1 number",
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": "user"
        }),
      );

      AppLogger.log('Status Code: ${response.statusCode}');
      AppLogger.log('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        FloatingSuccessBar.show(context, message: 'Please verify your email?',);
        if (context.mounted) {
          context.goNamed(AppRouteName.verifyscreen,extra: {
            'email': email,
          });
        }
        return;
      } else if (response.statusCode == 400) {
        isLoading.value = false;
        AppLogger.log('Invalid credentials');
        return;
      } else {
        isLoading.value = false;
        final data = jsonDecode(response.body);
        String message = data['message'] ?? "Registration failed";
        FloatingErrorBar.show(context, message: message,);
        AppLogger.log('Server error');
        return;
      }
    } catch (e) {
      isLoading.value = false;
      AppLogger.log('Exception: $e');
      return;
    } finally {
      isLoading.value = false;
    }
  }

  //=====>  verify screen controller codebase ======> //
  var start = 60.obs;
  Timer? timer;
  final RxBool verifyLoading = false.obs;

  void startTimer() {
    start.value = 120;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (start.value <= 0) {
        t.cancel();
      } else {
        start.value--;
      }
    });
  }

  Future<bool> verifyUser(BuildContext context,String email, String code) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      FloatingSuccessBar.show(context, message: 'No internet connection',);
      throw Exception('No internet connection');
    }


    final url = "${AppConstants.BASE_URL}/auth/verify-account";
    final body = {
      'email': email,
      'code': code,
    };

    verifyLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        FloatingSuccessBar.show(context, message: 'Successfully verify email?',);
        if(context.mounted){
          context.goNamed(AppRouteName.login);
        }
        return true;
      } else {
        String message = "Code wrong";
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
          AppLogger.log(message);
        } catch (_) {}
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      verifyLoading.value = false;
    }
  }

  Future<bool> resendCode(BuildContext context,String email,) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      FloatingErrorBar.show(context, message: 'No internet connection',);
      throw Exception('No internet connection');
    }


    final url = "${AppConstants.BASE_URL}/auth/resend-otp";
    final body = {
      'email': email,
    };

    verifyLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        FloatingSuccessBar.show(context, message: 'Resend Otp send successfully',);
        startTimer();
        return true;
      } else {
        String message = "Code wrong";
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
          print(body);
        } catch (_) {}
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      verifyLoading.value = false;
    }
  }


}
