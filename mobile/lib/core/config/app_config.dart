import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'Checklist Management';

  // API Configuration (from .env, falls back to dev defaults)
  static String get baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      // Remove trailing slash and /api/ suffix if present
      return envUrl.replaceAll(RegExp(r'/api/?$'), '');
    }
    if (kIsWeb) return 'http://localhost:8080';
    return 'http://10.0.2.2:8080';
  }

  static const String apiPrefix = '/api/';
  static String get apiBaseUrl => '$baseUrl$apiPrefix';

  // Keycloak Configuration (from .env)
  static String get keycloakBaseUrl =>
      dotenv.env['KEYCLOAK_BASE_URL'] ?? 'https://accounts.banmaivietnam.com.vn';

  static String get keycloakRealm =>
      dotenv.env['KEYCLOAK_REALM'] ?? 'banmai-prod';

  static String get keycloakClientId =>
      dotenv.env['KEYCLOAK_CLIENT_ID'] ?? 'checklist-mobile';

  static String get keycloakIssuer =>
      '$keycloakBaseUrl/realms/$keycloakRealm';

  static String get keycloakTokenUrl =>
      '$keycloakIssuer/protocol/openid-connect/token';

  static String get keycloakAuthUrl =>
      '$keycloakIssuer/protocol/openid-connect/auth';

  static String get keycloakLogoutUrl =>
      '$keycloakIssuer/protocol/openid-connect/logout';

  // Redirect URI for PKCE flow — must match Keycloak client config
  static const String redirectScheme = 'vn.com.banmaivietnam.app';
  static const String redirectUrl = '$redirectScheme://callback';

  // HTTP Timeouts
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
  static const sendTimeout = Duration(seconds: 30);

  // API Endpoints
  static const String templatesEndpoint = 'checklist/templates';
  static const String recordsEndpoint = 'checklist/records';
  static const String schoolsEndpoint = 'schools';
}
