class UserProfileResponse {
  final bool success;
  final int status;
  final String message;
  final UserProfileData data;

  UserProfileResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.data,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: UserProfileData.fromJson(
        json['response']?['data'] ?? <String, dynamic>{},
      ),
    );
  }
}

class UserProfileData {
  final String id;
  final String email;
  final String name;
  final String avatar;
  final String role;
  final bool isEmailVerified;
  final bool isOnline;

  UserProfileData({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
    required this.role,
    required this.isEmailVerified,
    required this.isOnline,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
    );
  }
}
