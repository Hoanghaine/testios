import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:checklist_management/core/config/app_config.dart';
import 'package:checklist_management/core/constants/storage_keys.dart';
import 'package:checklist_management/features/auth/data/models/auth_request.dart';
import 'package:checklist_management/features/auth/data/models/auth_token.dart';
import 'package:checklist_management/features/auth/data/models/user_info.dart';

class AuthService {
  AuthService(this._storage);

  final FlutterSecureStorage _storage;
  final _dio = Dio();

  /// Build Keycloak auth URL with PKCE
  AuthRequest buildAuthRequest() {
    final verifier = _generateCodeVerifier();
    final challenge = _generateCodeChallenge(verifier);
    final state = _generateState();

    final url = Uri.parse(AppConfig.keycloakAuthUrl)
        .replace(
          queryParameters: {
            'client_id': AppConfig.keycloakClientId,
            'redirect_uri': AppConfig.redirectUrl,
            'response_type': 'code',
            'scope': 'openid profile email',
            'code_challenge': challenge,
            'code_challenge_method': 'S256',
            'state': state,
          },
        )
        .toString();

    if (kDebugMode) {
      debugPrint('[AUTH] Client ID: ${AppConfig.keycloakClientId}');
      debugPrint('[AUTH] Redirect URI: ${AppConfig.redirectUrl}');
    }

    return AuthRequest(url: url, codeVerifier: verifier, state: state);
  }

  /// Exchange authorization code for tokens
  Future<AuthToken> exchangeCode(
    AuthRequest request,
    String redirectUrl,
  ) async {
    final resultUri = Uri.parse(redirectUrl);
    final code = resultUri.queryParameters['code'];

    if (code == null || code.isEmpty) {
      throw Exception('Không nhận được authorization code');
    }

    try {
      final requestData = {
        'grant_type': 'authorization_code',
        'client_id': AppConfig.keycloakClientId,
        'code': code,
        'redirect_uri': AppConfig.redirectUrl,
        'code_verifier': request.codeVerifier,
      };

      final tokenResponse = await _dio.post(
        AppConfig.keycloakTokenUrl,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
        data: requestData,
      );

      final data = tokenResponse.data as Map<String, dynamic>;
      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String? ?? '';
      final idToken = data['id_token'] as String?;
      final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;

      final userInfo = _decodeUserInfo(idToken);
      final token = AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn,
        userInfo: userInfo,
      );

      await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      await _storage.write(key: StorageKeys.userFullName, value: userInfo.fullName);
      await _storage.write(key: StorageKeys.userEmail, value: userInfo.email);

      return token;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[AUTH] Token exchange failed: ${e.response?.statusCode}');
        debugPrint('[AUTH] Response: ${e.response?.data}');
      }
      throw Exception('Trao đổi token thất bại: ${e.response?.data ?? e.message}');
    }
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;

    try {
      final response = await _dio.post(
        AppConfig.keycloakTokenUrl,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
        data: {
          'grant_type': 'refresh_token',
          'client_id': AppConfig.keycloakClientId,
          'refresh_token': refresh,
        },
      );

      final data = response.data as Map<String, dynamic>;
      await saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  /// Logout from Keycloak
  Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    try {
      await _dio.post(
        AppConfig.keycloakLogoutUrl,
        options: Options(contentType: 'application/x-www-form-urlencoded'),
        data: {
          'client_id': AppConfig.keycloakClientId,
          if (refreshToken != null) 'refresh_token': refreshToken,
        },
      );
    } catch (_) {}
    await clearTokens();
  }

  // Token storage
  Future<String?> getAccessToken() async =>
      _storage.read(key: StorageKeys.accessToken);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
  }

  Future<void> clearTokens() async => _storage.deleteAll();

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored token for auto-login
  Future<AuthToken?> getStoredToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await getRefreshToken() ?? '';
    final fullName = await _storage.read(key: StorageKeys.userFullName) ?? '';
    final email = await _storage.read(key: StorageKeys.userEmail) ?? '';
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: 0,
      userInfo: UserInfo(fullName: fullName, email: email, username: ''),
    );
  }

  // PKCE helpers
  UserInfo _decodeUserInfo(String? idToken) {
    if (idToken == null || idToken.isEmpty) return UserInfo.empty;
    try {
      return UserInfo.fromTokenClaims(JwtDecoder.decode(idToken));
    } catch (_) {
      return UserInfo.empty;
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
