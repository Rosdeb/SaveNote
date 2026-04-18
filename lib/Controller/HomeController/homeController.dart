import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' as pic;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../Models/Note/noteitem.dart';
import '../../Models/UserProfileResponse/userprofile.dart';
import '../../Services/Auth/Api_Services.dart';
import '../../Services/Auth/Auth_Services.dart';
import '../../Utils/AppConstant/app_constant.dart';
import '../../Utils/Logger/logger.dart';
import '../../Utils/SuccessBar/successbar.dart';
import '../../Utils/TokenServices/token_services.dart';
import '../NetworkService/networkservice.dart';

class Homecontroller extends GetxController {
  final RxString name = 'Guest User'.obs;
  final RxString email = 'No email'.obs;
  final RxString image = ''.obs;
  RxString deletingId = ''.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isLogginNoteCreate = false.obs;
  final RxBool isDeleting = false.obs;
  RxList notesList = <NoteModel>[].obs;
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    fetchNotes();
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

  Future<void> fetchNotes() async {
    try {
      isLoadingProfile.value = true;

      final response = await _apiService.get(
        endpoint: '/notes/all',
        requiresAuth: true,
      );

      if (response != null) {
          final data = NotesResponse.fromJson(response);
          notesList.value = data.data.docs;

      }
    } catch (e) {
      AppLogger.log('Load profile error: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> editNote(
      BuildContext context, {
        required String id,
        required int index,
        required String title,
        required String description,
      }) async {
    try {
      isLogginNoteCreate.value = true;

      final response = await _apiService.patch(
        endpoint: '/notes/update/$id',
        body: {
          'title': title,
          'description': description,
        },
      );

      if (response != null) {
        // update local list directly
        notesList[index] = NoteModel(
          id: id,
          title: title,
          description: description,
          createdBy: (notesList[index] as NoteModel).createdBy,
        );

        if (context.mounted) {
          FloatingSuccessBar.show(context, message: 'Note updated successfully');
          Navigator.pop(context);
        }
      }
    } catch (e) {
      AppLogger.log('Edit note error: $e');
    } finally {
      isLogginNoteCreate.value = false;
    }
  }

  Future<void> deleteNote(
      BuildContext context, {
        required String id,
        required int index,
      }) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Note'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
      isDeleting.value = true;
      final response = await _apiService.delete(endpoint: '/notes/delete/$id');

      if (response) {
        notesList.removeAt(index);
        isDeleting.value = false;
        if (context.mounted) {
          FloatingSuccessBar.show(context, message: 'Note deleted successfully');
        }
      }
    } catch (e) {
      isDeleting.value = false;
      AppLogger.log('Delete note error: $e');
    }finally{
      isDeleting.value = true;
    }
  }

  Future<void> noteCreate({
    required BuildContext context,
    String? title,
    String? description,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }
    final url = '${AppConstants.BASE_URL}/auth/login';

    try {
      isLogginNoteCreate.value = true;
      final response = await ApiService().post(
        endpoint:"/notes/create",
        body:{
          "title": title,
          "description": description
        });

      if (response != null) {
        await fetchNotes();
        FloatingSuccessBar.show(context, message: 'Successful! Create Note',);
        if (context.mounted) {
          context.pop();
        }
        return;
      } else {
        isLogginNoteCreate.value = false;
        AppLogger.log('Server error');
        return;
      }
    } catch (e) {
      isLogginNoteCreate.value = false;
      AppLogger.log('Exception: $e');
      return;
    } finally {
      isLogginNoteCreate.value = false;
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
