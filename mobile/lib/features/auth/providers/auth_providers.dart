import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:checklist_management/core/services/auth_service.dart';
import 'package:checklist_management/features/auth/data/models/auth_token.dart';
import 'package:checklist_management/features/auth/presentation/auth_webview_page.dart';
import 'package:checklist_management/core/config/app_config.dart';

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(_secureStorageProvider)),
);

class AuthNotifier extends AsyncNotifier<AuthToken> {
  @override
  Future<AuthToken> build() async {
    final stored = await ref.read(authServiceProvider).getStoredToken();
    return stored ?? AuthToken.empty;
  }

  Future<void> login(BuildContext context) async {
    final service = ref.read(authServiceProvider);
    final authRequest = service.buildAuthRequest();

    if (kIsWeb) {
      // On web: open Keycloak in same window (redirect back)
      await launchUrl(
        Uri.parse(authRequest.url),
        webOnlyWindowName: '_self',
      );
      return;
    }

    // On mobile: use WebView
    final redirectUrl = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AuthWebViewPage(
          authUrl: authRequest.url,
          redirectScheme: AppConfig.redirectScheme,
        ),
      ),
    );

    if (redirectUrl == null || redirectUrl.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => service.exchangeCode(authRequest, redirectUrl),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(AuthToken.empty);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthToken>(
  AuthNotifier.new,
);

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.valueOrNull?.isAuthenticated ?? false;
});
