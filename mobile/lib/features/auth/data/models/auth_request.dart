class AuthRequest {
  const AuthRequest({
    required this.url,
    required this.codeVerifier,
    required this.state,
  });

  final String url;
  final String codeVerifier;
  final String state;
}
