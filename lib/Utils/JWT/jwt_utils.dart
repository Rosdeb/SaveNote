import 'dart:convert';

class JwtUtils {
  /// Decode JWT token and return payload as Map
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      // Split the token to get the payload part (middle part)
      List<String> parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid token');
      }

      String payload = parts[1];

      // Add padding if needed
      String normalizedPayload = base64Url.normalize(payload);

      // Decode the payload
      String payloadString = utf8.decode(base64Url.decode(normalizedPayload));
      
      return json.decode(payloadString);
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      Map<String, dynamic>? payload = decodeToken(token);
      if (payload == null) {
        return true; // If we can't decode, assume expired
      }

      // Get the expiration time (exp claim)
      int? exp = payload['exp'];
      if (exp == null) {
        return false; // If no exp claim, assume not expired
      }

      // Convert to DateTime and compare with current time
      DateTime expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      DateTime now = DateTime.now();

      return now.isAfter(expirationTime);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // If error, assume expired for safety
    }
  }

  /// Get token expiration time
  static DateTime? getTokenExpiration(String token) {
    try {
      Map<String, dynamic>? payload = decodeToken(token);
      if (payload == null) {
        return null;
      }

      int? exp = payload['exp'];
      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      print('Error getting token expiration: $e');
      return null;
    }
  }

  /// Get seconds until token expires
  static int? getSecondsUntilExpiration(String token) {
    DateTime? expiration = getTokenExpiration(token);
    if (expiration == null) {
      return null;
    }

    Duration difference = expiration.difference(DateTime.now());
    return difference.inSeconds;
  }

  /// Check if token expires within specified minutes
  static bool expiresWithin(String token, int minutes) {
    int? seconds = getSecondsUntilExpiration(token);
    if (seconds == null) {
      return true; // If we can't determine, assume it will expire
    }
    
    return seconds <= (minutes * 60);
  }
}