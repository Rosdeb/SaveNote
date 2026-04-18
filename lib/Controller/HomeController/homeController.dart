import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart' as pic;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../Models/UserProfileResponse/userprofile.dart';
import '../../Services/Auth/Api_Services.dart';
import '../../Services/Auth/Auth_Services.dart';
import '../../Utils/Logger/logger.dart';
import '../../Utils/TokenServices/token_services.dart';

class Homecontroller extends GetxController {
  final RxString name = 'Guest User'.obs;
  final RxString email = 'No email'.obs;
  final RxString image = ''.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isLoggingOut = false.obs;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData({bool refresh = true}) async {
    await _loadCachedUserData();

    if (!refresh) {
      return;
    }
    try {
      isLoadingProfile.value = true;

      final response = await _apiService.get(
        endpoint: '/user/self/in',
        requiresAuth: true,
      );

      if (response != null) {
        final profile = UserProfileResponse.fromJson(response);

        name.value = profile.data.name;
        email.value = profile.data.email;
        image.value = profile.data.avatar;

        await _tokenService.saveUserId(profile.data.id);
        await _tokenService.saveName(profile.data.name);
        await _tokenService.saveEmail(profile.data.email);
        await _tokenService.saveAvatar(profile.data.avatar);

        AppLogger.log('User name: ${profile.data.name}');
      }
    } catch (e) {
      AppLogger.log('Load profile error: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<bool?> pickAndUploadProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) {
      return null;
    }

    final file = File(pickedFile.path);
    final ext = pic.extension(file.path).toLowerCase();

    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    if (!allowedExtensions.contains(ext)) {
      AppLogger.log('Unsupported avatar file type: $ext', type: 'warning');
      return false;
    }

    return uploadProfileImage(file);
  }

  Future<bool> uploadProfileImage(File file) async {
    try {
      isUploadingImage.value = true;
      final ext = pic.extension(file.path).toLowerCase().replaceAll('.', '');
      final subtype = ext == 'jpg' ? 'jpeg' : ext;

      final multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        file.path,
        contentType: MediaType('image', subtype),
      );

      final response = await _apiService.patchWithMultipart(
        endpoint: '/user/self/update',
        files: [multipartFile],
      );

      final user = _extractUser(response);
      if (user != null) {
        await _applyUser(user, persist: true);
      }

      return response != null;
    } catch (e) {
      AppLogger.log('Profile image upload error: $e');
      return false;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoggingOut.value = true;
      await AuthService.logout();
      return true;
    } catch (e) {
      AppLogger.log('Logout error: $e');
      return false;
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> _loadCachedUserData() async {
    final cachedEmail = _cleanString(_tokenService.getEmail());
    final cachedName = _cleanString(_tokenService.getName());
    final cachedAvatar = _cleanString(_tokenService.getAvatar());

    if (cachedEmail != null) {
      email.value = cachedEmail;
    }

    if (cachedName != null) {
      name.value = cachedName;
    } else if (cachedEmail != null) {
      name.value = _fallbackNameFromEmail(cachedEmail);
    }

    image.value = cachedAvatar ?? '';
  }

  Future<void> _applyUser(
    Map<String, dynamic> user, {
    bool persist = false,
  }) async {
    final resolvedEmail =
        _cleanString(user['email']) ?? _cleanString(_tokenService.getEmail());
    final resolvedName =
        _cleanString(user['name']) ??
        _cleanString(user['username']) ??
        _cleanString(user['fullName']) ??
        (resolvedEmail != null ? _fallbackNameFromEmail(resolvedEmail) : null);
    final resolvedAvatar =
        _cleanString(user['avatar']) ??
        _cleanString(user['image']) ??
        _cleanString(user['profileImage']) ??
        '';
    final resolvedUserId =
        _cleanString(user['id']) ?? _cleanString(user['_id']) ?? '';

    if (resolvedName != null) {
      name.value = resolvedName;
    }

    if (resolvedEmail != null) {
      email.value = resolvedEmail;
    }

    image.value = resolvedAvatar;

    if (!persist) {
      return;
    }

    if (resolvedUserId.isNotEmpty) {
      await _tokenService.saveUserId(resolvedUserId);
    }
    if (resolvedName != null) {
      await _tokenService.saveName(resolvedName);
    }
    if (resolvedEmail != null) {
      await _tokenService.saveEmail(resolvedEmail);
    }
    await _tokenService.saveAvatar(resolvedAvatar);
  }

  Map<String, dynamic>? _extractUser(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }

    final dynamic responseNode =
        response['response'] ?? response['data'] ?? response;
    if (responseNode is! Map<String, dynamic>) {
      return null;
    }

    final dynamic dataNode =
        responseNode['data'] ?? responseNode['user'] ?? responseNode;
    if (dataNode is! Map<String, dynamic>) {
      return null;
    }

    return Map<String, dynamic>.from(dataNode);
  }

  String? _cleanString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') {
      return null;
    }

    return text;
  }

  String _fallbackNameFromEmail(String email) {
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) {
      return 'Guest User';
    }

    return localPart;
  }
}
