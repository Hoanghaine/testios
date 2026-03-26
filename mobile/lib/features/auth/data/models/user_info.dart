import 'package:equatable/equatable.dart';

class UserInfo extends Equatable {
  const UserInfo({
    required this.fullName,
    required this.email,
    required this.username,
  });

  final String fullName;
  final String email;
  final String username;

  static const empty = UserInfo(fullName: '', email: '', username: '');

  bool get isEmpty => fullName.isEmpty && email.isEmpty;

  factory UserInfo.fromTokenClaims(Map<String, dynamic> claims) => UserInfo(
    fullName:
        claims['name'] as String? ??
        '${claims['given_name'] ?? ''} ${claims['family_name'] ?? ''}'.trim(),
    email: claims['email'] as String? ?? '',
    username: claims['preferred_username'] as String? ?? '',
  );

  @override
  List<Object?> get props => [fullName, email, username];
}
