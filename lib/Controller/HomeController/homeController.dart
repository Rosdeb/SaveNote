import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../Models/Note/noteitem.dart';
import '../../Models/UserProfileResponse/userprofile.dart';
import '../../Services/Auth/Api_Services.dart';
import '../../Services/Auth/Auth_Services.dart';
import '../../Utils/Logger/logger.dart';
import '../../Utils/SuccessBar/successbar.dart';
import '../../Utils/TokenServices/token_services.dart';
import '../NetworkService/networkservice.dart';

/// Manages home screen state: user profile, notes (with pagination),
/// image upload, and session lifecycle.
class HomeController extends GetxController {
  // ─── Dependencies ──────────────────────────────────────────────────────────

  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  final ImagePicker _imagePicker = ImagePicker();

  // ─── User Profile ──────────────────────────────────────────────────────────

  final RxString name = 'Guest User'.obs;
  final RxString email = 'No email'.obs;
  final RxString avatarUrl = ''.obs;
  final RxString deletingId = ''.obs;

  // ─── Notes ─────────────────────────────────────────────────────────────────

  final RxList<NoteModel> notesList = <NoteModel>[].obs;

  // ─── Loading States ────────────────────────────────────────────────────────

  final RxBool isLoadingProfile = false.obs;
  final RxBool isLoadingNotes = false.obs;
  final RxBool isLoadingMoreNotes = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isSavingNote = false.obs;
  final RxBool isDeletingNote = false.obs;

  // ─── Pagination ────────────────────────────────────────────────────────────

  final RxInt _currentPage = 1.obs;
  final RxBool hasMoreNotes = true.obs;
  static const int _pageSize = 10;

  // ─── Scroll ────────────────────────────────────────────────────────────────

  final ScrollController scrollController = ScrollController();

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
    loadUserData();
    _attachScrollListener();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ─── Scroll Listener ───────────────────────────────────────────────────────

  void _attachScrollListener() {
    scrollController.addListener(() {
      final position = scrollController.position;
      final nearBottom = position.pixels >= position.maxScrollExtent - 200;
      if (nearBottom && !isLoadingMoreNotes.value && hasMoreNotes.value) {
        fetchNotes(loadMore: true);
      }
    });
  }

  // ─── Fetch Notes ───────────────────────────────────────────────────────────

  /// Loads notes from the API. Pass [loadMore] = true to append the next page.
  Future<void> fetchNotes({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreNotes.value || isLoadingMoreNotes.value) return;
      isLoadingMoreNotes.value = true;
      _currentPage.value++;
    } else {
      if (isLoadingNotes.value) return;
      isLoadingNotes.value = true;
      _currentPage.value = 1;
      notesList.clear();
      hasMoreNotes.value = true;
    }

    try {
      final response = await _apiService.get(
        endpoint: '/notes/all?page=${_currentPage.value}&limit=$_pageSize',
        requiresAuth: true,
      );

      if (response == null) return;

      final data = NotesResponse.fromJson(response);
      notesList.addAll(data.data.docs);
      hasMoreNotes.value = _currentPage.value < data.data.totalPages;
    } catch (e, stackTrace) {
      AppLogger.log('fetchNotes error: $e\n$stackTrace');
    } finally {
      isLoadingNotes.value = false;
      isLoadingMoreNotes.value = false;
    }
  }

  // ─── Load User Profile ─────────────────────────────────────────────────────

  /// Populates user data from cache immediately, then refreshes from the API.
  Future<void> loadUserData({bool refresh = true}) async {
    _applyCachedProfile();
    if (!refresh) return;

    isLoadingProfile.value = true;
    try {
      final response = await _apiService.get(
        endpoint: '/user/self/in',
        requiresAuth: true,
      );

      if (response == null) return;

      final profile = UserProfileResponse.fromJson(response);
      _applyProfile(profile.data);
      await _persistProfile(profile.data);
    } catch (e, stackTrace) {
      AppLogger.log('loadUserData error: $e\n$stackTrace');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void _applyCachedProfile() {
    final cachedEmail = _sanitize(_tokenService.getEmail());
    final cachedName = _sanitize(_tokenService.getName());
    final cachedAvatar = _sanitize(_tokenService.getAvatar());

    if (cachedEmail != null) email.value = cachedEmail;
    name.value = cachedName ?? (cachedEmail != null ? _nameFromEmail(cachedEmail) : 'Guest User');
    avatarUrl.value = cachedAvatar ?? '';
  }

  void _applyProfile(dynamic data) {
    name.value = data.name;
    email.value = data.email;
    avatarUrl.value = data.avatar;
  }

  Future<void> _persistProfile(dynamic data) async {
    await Future.wait([
      _tokenService.saveUserId(data.id),
      _tokenService.saveName(data.name),
      _tokenService.saveEmail(data.email),
      _tokenService.saveAvatar(data.avatar),
    ]);
  }

  // ─── Create Note ───────────────────────────────────────────────────────────

  Future<void> createNote(
      BuildContext context, {
        required String title,
        required String description,
      }) async {
    final network = Get.find<NetworkController>();
    if (!network.isOnline.value) {
      _showError(context, 'No internet connection. Please try again.');
      return;
    }

    isSavingNote.value = true;
    try {
      final response = await _apiService.post(
        endpoint: '/notes/create',
        body: {'title': title, 'description': description},
      );

      if (response == null) return;

      await fetchNotes();
      if (context.mounted) {
        FloatingSuccessBar.show(context, message: 'Note created successfully');
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      AppLogger.log('createNote error: $e\n$stackTrace');
    } finally {
      isSavingNote.value = false;
    }
  }

  // ─── Edit Note ─────────────────────────────────────────────────────────────

  Future<void> editNote(
      BuildContext context, {
        required String id,
        required int index,
        required String title,
        required String description,
      }) async {
    isSavingNote.value = true;
    try {
      final response = await _apiService.patch(
        endpoint: '/notes/update/$id',
        body: {'title': title, 'description': description},
      );

      if (response == null) return;

      final existing = notesList[index];
      notesList[index] = NoteModel(
        id: id,
        title: title,
        description: description,
        createdBy: existing.createdBy,
      );

      if (context.mounted) {
        FloatingSuccessBar.show(context, message: 'Note updated successfully');
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      AppLogger.log('editNote error: $e\n$stackTrace');
    } finally {
      isSavingNote.value = false;
    }
  }

  // ─── Delete Note ───────────────────────────────────────────────────────────

  Future<void> deleteNote(
      BuildContext context, {
        required String id,
        required int index,
      }) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (!confirmed) return;

    isDeletingNote.value = true;
    try {
      final success = await _apiService.delete(endpoint: '/notes/delete/$id');
      if (!success) return;

      notesList.removeAt(index);
      if (context.mounted) {
        FloatingSuccessBar.show(context, message: 'Note deleted successfully');
      }
    } catch (e, stackTrace) {
      AppLogger.log('deleteNote error: $e\n$stackTrace');
    } finally {
      isDeletingNote.value = false;
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
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
    return result ?? false;
  }

  // ─── Avatar Upload ─────────────────────────────────────────────────────────

  /// Opens the gallery, validates the file type, then uploads.
  /// Returns `null` if cancelled, `false` on invalid type, `true/false` on upload result.
  Future<bool?> pickAndUploadAvatar() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return null;

    final file = File(picked.path);
    final ext = path.extension(file.path).toLowerCase();
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

    if (!allowedExtensions.contains(ext)) {
      AppLogger.log('Unsupported avatar file type: $ext', type: 'warning');
      return false;
    }

    return _uploadAvatar(file);
  }

  Future<bool> _uploadAvatar(File file) async {
    isUploadingAvatar.value = true;
    try {
      final ext = path.extension(file.path).toLowerCase().replaceAll('.', '');
      final mimeSubtype = ext == 'jpg' ? 'jpeg' : ext;

      final multipartFile = await http.MultipartFile.fromPath(
        'avatar',
        file.path,
        contentType: http.MediaType('image', mimeSubtype),
      );

      final response = await _apiService.patchWithMultipart(
        endpoint: '/user/self/update',
        files: [multipartFile],
      );

      final user = _extractUserFromResponse(response);
      if (user != null) {
        await _applyUserMap(user, persist: true);
      }

      return response != null;
    } catch (e, stackTrace) {
      AppLogger.log('_uploadAvatar error: $e\n$stackTrace');
      return false;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<bool> logout() async {
    isLoggingOut.value = true;
    try {
      await AuthService.logout();
      return true;
    } catch (e, stackTrace) {
      AppLogger.log('logout error: $e\n$stackTrace');
      return false;
    } finally {
      isLoggingOut.value = false;
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Map<String, dynamic>? _extractUserFromResponse(dynamic response) {
    if (response is! Map<String, dynamic>) return null;

    final responseNode = response['response'] ?? response['data'] ?? response;
    if (responseNode is! Map<String, dynamic>) return null;

    final dataNode = responseNode['data'] ?? responseNode['user'] ?? responseNode;
    if (dataNode is! Map<String, dynamic>) return null;

    return Map<String, dynamic>.from(dataNode);
  }

  Future<void> _applyUserMap(
      Map<String, dynamic> user, {
        bool persist = false,
      }) async {
    final resolvedEmail =
        _sanitize(user['email']) ?? _sanitize(_tokenService.getEmail());
    final resolvedName =
        _sanitize(user['name']) ??
            _sanitize(user['username']) ??
            _sanitize(user['fullName']) ??
            (resolvedEmail != null ? _nameFromEmail(resolvedEmail) : null);
    final resolvedAvatar =
        _sanitize(user['avatar']) ??
            _sanitize(user['image']) ??
            _sanitize(user['profileImage']) ??
            '';
    final resolvedId =
        _sanitize(user['id']) ?? _sanitize(user['_id']) ?? '';

    if (resolvedName != null) name.value = resolvedName;
    if (resolvedEmail != null) email.value = resolvedEmail;
    avatarUrl.value = resolvedAvatar;

    if (!persist) return;

    await Future.wait([
      if (resolvedId.isNotEmpty) _tokenService.saveUserId(resolvedId),
      if (resolvedName != null) _tokenService.saveName(resolvedName),
      if (resolvedEmail != null) _tokenService.saveEmail(resolvedEmail),
      _tokenService.saveAvatar(resolvedAvatar),
    ]);
  }

  /// Trims and returns `null` for empty/`"null"` strings.
  String? _sanitize(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return (text.isEmpty || text == 'null') ? null : text;
  }

  /// Derives a display name from the local part of an email address.
  String _nameFromEmail(String email) {
    final local = email.split('@').first.trim();
    return local.isNotEmpty ? local : 'Guest User';
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600),
    );
  }
}