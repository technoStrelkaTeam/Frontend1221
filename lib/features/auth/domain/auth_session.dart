class AuthSession {
  const AuthSession({
    required this.userId,
    required this.token,
    required this.displayName,
    this.password,
  });

  final String userId;
  final String token;
  final String displayName;
  final String? password;
}

  