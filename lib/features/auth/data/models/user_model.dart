class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.token,
    this.avatarUrl,
    this.role,
    this.userData,
    this.history,
  });

  final String id;
  final String email;
  final String name;
  final String? token;
  final String? avatarUrl;
  final String? role;
  final Map<String, dynamic>? userData;
  final List<dynamic>? history;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id']?.toString() ?? '').isEmpty 
          ? '' 
          : json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      token: json['token'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String?,
      userData: json['user_data'] as Map<String, dynamic>?,
      history: json['history'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (token != null) 'token': token,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (role != null) 'role': role,
      if (userData != null) 'user_data': userData,
      if (history != null) 'history': history,
    };
  }
}
