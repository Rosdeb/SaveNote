import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:notesave/Utils/Logger/logger.dart';

import '../../Controller/NetworkService/networkservice.dart';
import '../../Utils/AppConstant/app_constant.dart';
import '../../Utils/TokenServices/token_services.dart';
import 'Auth_Services.dart';

/// Service class for handling all API communications with automatic token management
/// and error handling.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final TokenService _tokenService = TokenService();

  /// Makes a GET request to the specified endpoint
  ///
  /// [endpoint] The API endpoint to call (e.g., '/users/profile')
  /// [headers] Additional headers to include in the request
  /// [requiresAuth] Whether authentication token is required for this request
  ///
  /// Returns the parsed JSON response or null if the request fails
  /// Throws exceptions for network connectivity issues
  Future<Map<String, dynamic>?> get({
    required String endpoint,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      AppLogger.log('Making GET request to: $url', type: 'info');

      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      AppLogger.log('GET Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('GET Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.get(
            Uri.parse(url),
            headers: retryHeaders,
          );

          AppLogger.log('Retry GET Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200) {
            return json.decode(retryResponse.body);
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making GET request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> post({
    required String endpoint,
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      String bodyString = body != null ? json.encode(body) : '';

      AppLogger.log('Making POST request to: $url', type: 'info');
      AppLogger.log('POST Request Body: $bodyString', type: 'info');

      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: bodyString,
      );

      AppLogger.log('POST Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('POST Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.post(
            Uri.parse(url),
            headers: retryHeaders,
            body: bodyString,
          );

          AppLogger.log('Retry POST Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200) {
            return json.decode(retryResponse.body);
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making POST request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> put({
    required String endpoint,
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      String bodyString = body != null ? json.encode(body) : '';

      AppLogger.log('Making PUT request to: $url', type: 'info');
      AppLogger.log('PUT Request Body: $bodyString', type: 'info');

      final response = await http.put(
        Uri.parse(url),
        headers: requestHeaders,
        body: bodyString,
      );

      AppLogger.log('PUT Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('PUT Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.put(
            Uri.parse(url),
            headers: retryHeaders,
            body: bodyString,
          );

          AppLogger.log('Retry PUT Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200) {
            return json.decode(retryResponse.body);
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making PUT request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> delete({
    required String endpoint,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      AppLogger.log('Making DELETE request to: $url', type: 'info');

      final response = await http.delete(
        Uri.parse(url),
        headers: requestHeaders,
      );

      AppLogger.log('DELETE Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('DELETE Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.delete(
            Uri.parse(url),
            headers: retryHeaders,
          );

          AppLogger.log('Retry DELETE Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200 || response.statusCode ==201) {
            return true;
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return false;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return false;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return false;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making DELETE request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> _handleTokenRefresh() async {
    AppLogger.log('Attempting to refresh token using AuthService...', type: 'info');

    // Use the enhanced AuthService to handle token validation and refresh
    bool result = await AuthService.validateAndRefreshToken();

    if (result) {
      AppLogger.log('Token validated and/or refreshed successfully via AuthService', type: 'success');
      return true;
    } else {
      AppLogger.log('Failed to validate and refresh token via AuthService', type: 'error');
      return false;
    }
  }

  /// Handle 401 unauthorized error
  /// This typically means we need to log out the user
  Future<void> _handleUnauthorized() async {
    AppLogger.log('401 Unauthorized - Logging out user', type: 'warning');

    // Clear all stored tokens and user data
    await AuthService.logout();

    // Navigate to login screen or show appropriate UI
    AppLogger.log('User logged out due to unauthorized access', type: 'info');
  }

  /// Validates if the response status indicates success
  bool _isSuccessfulStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Creates standardized error response
  Map<String, dynamic> _createErrorResponse(int statusCode, String message) {
    return {
      'error': true,
      'statusCode': statusCode,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Helper method to handle error responses
  void _handleErrorResponse(int statusCode, String responseBody) {
    AppLogger.log('Request failed with status: $statusCode', type: 'error');
    AppLogger.log('Response body: $responseBody', type: 'error');

    switch (statusCode) {
      case 400:
        AppLogger.log('Bad Request', type: 'error');
        break;
      case 401:
        AppLogger.log('Unauthorized - Invalid or expired token', type: 'error');
        break;
      case 403:
        AppLogger.log('Forbidden', type: 'error');
        break;
      case 404:
        AppLogger.log('Not Found', type: 'error');
        break;
      case 500:
        AppLogger.log('Internal Server Error', type: 'error');
        break;
      default:
        AppLogger.log('Unknown error with status code: $statusCode', type: 'error');
    }
  }

  Future<dynamic> getRaw({
    required String endpoint,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      AppLogger.log('Making GET request to: $url', type: 'info');

      final response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      AppLogger.log('GET Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('GET Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200) {
        // Return either Map or List depending on the response
        var decoded = json.decode(response.body);
        return decoded;
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.get(
            Uri.parse(url),
            headers: retryHeaders,
          );

          AppLogger.log('Retry GET Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200) {
            var decoded = json.decode(retryResponse.body);
            return decoded;
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making GET request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> patch({
    required String endpoint,
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    await _tokenService.init(); // Ensure token service is initialized
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      Map<String, String> requestHeaders = {};
      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        requestHeaders['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      requestHeaders['Content-Type'] = 'application/json';

      String bodyString = body != null ? (body is String ? body : json.encode(body)) : '';

      AppLogger.log('Making PATCH request to: $url', type: 'info');
      AppLogger.log('PATCH Request Body: $bodyString', type: 'info');

      final response = await http.patch(
        Uri.parse(url),
        headers: requestHeaders,
        body: bodyString,
      );

      AppLogger.log('PATCH Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('PATCH Response Body: ${response.body}', type: 'info');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          Map<String, String> retryHeaders = {};
          if (requiresAuth) {
            String? newToken = await _tokenService.getToken();
            if (newToken != null && newToken.isNotEmpty) {
              retryHeaders['Authorization'] = 'Bearer $newToken';
            }
          }

          if (headers != null) {
            retryHeaders.addAll(headers);
          }
          retryHeaders['Content-Type'] = 'application/json';

          final retryResponse = await http.patch(
            Uri.parse(url),
            headers: retryHeaders,
            body: bodyString,
          );

          AppLogger.log('Retry PATCH Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200) {
            final decoded = json.decode(retryResponse.body);
            return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
          } else {
            _handleErrorResponse(retryResponse.statusCode, response.body);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, response.body);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, response.body);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making PATCH request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> patchWithMultipart({
    required String endpoint,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final networkController = Get.find<NetworkController>();

    if (!networkController.isOnline.value) {
      throw Exception('No internet connection');
    }

    String url = '${AppConstants.BASE_URL}$endpoint';

    try {
      var request = http.MultipartRequest('PATCH', Uri.parse(url));

      if (requiresAuth) {
        String? token = await _tokenService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('No access token available');
        }
        request.headers['Authorization'] = 'Bearer $token';
      }

      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files);
      }

      AppLogger.log('Making PATCH multipart request to: $url', type: 'info');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      AppLogger.log('PATCH multipart Response Status: ${response.statusCode}', type: 'info');
      AppLogger.log('PATCH multipart Response Body: $responseBody', type: 'info');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else if (response.statusCode == 401) {
        bool refreshed = await _handleTokenRefresh();
        if (refreshed) {
          var retryRequest = http.MultipartRequest('PATCH', Uri.parse(url));

          String? newToken = await _tokenService.getToken();
          if (newToken != null && newToken.isNotEmpty) {
            retryRequest.headers['Authorization'] = 'Bearer $newToken';
          }

          if (headers != null) {
            retryRequest.headers.addAll(headers);
          }

          if (fields != null) {
            retryRequest.fields.addAll(fields);
          }

          if (files != null) {
            retryRequest.files.addAll(files);
          }

          final retryResponse = await retryRequest.send();
          final retryResponseBody = await retryResponse.stream.bytesToString();

          AppLogger.log('Retry PATCH multipart Response Status: ${retryResponse.statusCode}', type: 'info');

          if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
            return json.decode(retryResponseBody);
          } else {
            _handleErrorResponse(retryResponse.statusCode, retryResponseBody);
            return null;
          }
        } else {
          await _handleUnauthorized();
          _handleErrorResponse(response.statusCode, responseBody);
          return null;
        }
      } else {
        _handleErrorResponse(response.statusCode, responseBody);
        return null;
      }
    } on SocketException {
      AppLogger.log('Socket exception (no internet connection)', type: 'error');
      throw Exception('No internet connection');
    } on HttpException {
      AppLogger.log('HTTP exception occurred', type: 'error');
      throw Exception('HTTP error occurred');
    } catch (e) {
      AppLogger.log('Error making PATCH multipart request: $e', type: 'error');
      throw Exception('Network error: $e');
    }
  }
}