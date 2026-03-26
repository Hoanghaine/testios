import 'package:equatable/equatable.dart';
import 'package:checklist_management/features/auth/data/models/user_info.dart';

class AuthToken extends Equatable {
  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.userInfo = UserInfo.empty,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserInfo userInfo;

  bool get isAuthenticated => accessToken.isNotEmpty;

  static const empty = AuthToken(
    accessToken: '',
    refreshToken: '',
    expiresIn: 0,
    userInfo: UserInfo.empty,
  );

  @override
  List<Object?> get props => [accessToken, refreshToken, userInfo];
}
