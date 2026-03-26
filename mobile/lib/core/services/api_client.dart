import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checklist_management/core/config/app_config.dart';
import 'package:checklist_management/core/services/auth_service.dart';
import 'package:checklist_management/features/auth/providers/auth_providers.dart';

// Error event types for global handling
enum ApiErrorType { sessionExpired, serverError, networkError }

class ApiError {
  final ApiErrorType type;
  final String message;
  ApiError(this.type, this.message);
}

// Global error stream
final _apiErrorController = StreamController<ApiError>.broadcast();
final apiErrorStreamProvider = Provider<Stream<ApiError>>((_) => _apiErrorController.stream);

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiClient(authService: authService);
});

class ApiClient {
  late final Dio _dio;
  final AuthService authService;

  ApiClient({required this.authService}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        sendTimeout: AppConfig.sendTimeout,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'vi',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(authService, _dio));
    _dio.interceptors.add(_GlobalErrorInterceptor());

    // Only log API calls in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[API] $obj'),
      ));
    }
  }

  Dio get dio => _dio;

  // === GET ===
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  // === POST ===
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  // === POST (FormData) ===
  Future<ApiResponse<T>> postFormData<T>(
    String path, {
    required FormData formData,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.post(
      path,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return ApiResponse.fromJson(response.data, fromJson);
  }

  // === PUT ===
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.put(path, data: data);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  // === DELETE ===
  Future<ApiResponse<void>> delete(String path) async {
    final response = await _dio.delete(path);
    return ApiResponse.fromJson(response.data, (_) => null);
  }
}

// === Auth Interceptor ===
class _AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final Dio _dio;
  bool _isRefreshing = false;

  _AuthInterceptor(this._authService, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      final success = await _authService.refreshAccessToken();
      _isRefreshing = false;

      if (success) {
        final token = await _authService.getAccessToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      } else {
        // Refresh failed → session expired
        _apiErrorController.add(ApiError(
          ApiErrorType.sessionExpired,
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        ));
      }
    }
    handler.next(err);
  }
}

// === Global Error Interceptor ===
class _GlobalErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Connection errors (backend down, no internet, DNS fail)
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      _apiErrorController.add(ApiError(
        ApiErrorType.networkError,
        'Kết nối tới máy chủ bị timeout. Vui lòng kiểm tra kết nối mạng.',
      ));
    } else if (err.type == DioExceptionType.connectionError) {
      _apiErrorController.add(ApiError(
        ApiErrorType.networkError,
        'Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối mạng hoặc liên hệ quản trị viên.',
      ));
    } else if (err.response != null && err.response!.statusCode != null) {
      final status = err.response!.statusCode!;
      if (status >= 500) {
        _apiErrorController.add(ApiError(
          ApiErrorType.serverError,
          'Hệ thống đang gặp sự cố (lỗi $status). Vui lòng thử lại sau hoặc liên hệ quản trị viên.',
        ));
      }
    }

    handler.next(err);
  }
}

// === API Response Wrapper ===
class ApiResponse<T> {
  final T data;
  final String? message;

  ApiResponse({required this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      data: fromJson(json['data']),
      message: json['message'] as String?,
    );
  }
}

// === Paged Response ===
class PagedResponse<T> {
  final List<T> elements;
  final int totalPages;
  final int totalElements;
  final bool hasNext;
  final bool hasPrevious;

  PagedResponse({
    required this.elements,
    required this.totalPages,
    required this.totalElements,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse(
      elements: (json['elements'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalElements: json['totalElements'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}
