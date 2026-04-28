class AuthSession {
  const AuthSession({
    required this.userId,
    required this.token,
    required this.displayName,
  });

  final String userId;
  final String token;
  final String displayName;
}

  