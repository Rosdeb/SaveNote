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

/// Controller for sign-in functionality.
class Authcontroller extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();

  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool accepted = false.obs;
  final RxBool googleLoading = false.obs;
  final RxBool appleLoading = false.obs;

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
        await TokenService().saveName(
          '${user['name'] ?? user['username'] ?? user['fullName'] ?? ''}',
        );
        await TokenService().saveAvatar(
          '${user['avatar'] ?? user['image'] ?? user['profileImage'] ?? ''}',
        );

        AppLogger.log('Login success');
        AppLogger.log('Token: $accessToken');
        FloatingSuccessBar.show(
          context,
          message: 'Login successful! Welcome back 👋',
        );

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

  //---------> signupdate screen create <-----------//
  final TextEditingController registernameController = TextEditingController();
  final TextEditingController registerpasswordController =
      TextEditingController();
  final TextEditingController registeremailController = TextEditingController();

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
        body: jsonEncode({
          'username': name,
          'email': email,
          'password': password,
        }),
      );

      AppLogger.log('Status Code: ${response.statusCode}');
      AppLogger.log('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await TokenService().saveToken(token);
        AppLogger.log('Login success');
        AppLogger.log('Token: $token');
        FloatingSuccessBar.show(
          context,
          message: 'Login successful! Welcome back 👋',
        );

        if (context.mounted) {
          //Get.offAll(BottomMenuWrappers(), transition: Transition.cupertino);
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
}
