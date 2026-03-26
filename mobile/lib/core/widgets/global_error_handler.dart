import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checklist_management/core/services/api_client.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/auth/providers/auth_providers.dart';

class GlobalErrorHandler extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalErrorHandler({super.key, required this.child});

  @override
  ConsumerState<GlobalErrorHandler> createState() => _GlobalErrorHandlerState();
}

class _GlobalErrorHandlerState extends ConsumerState<GlobalErrorHandler> {
  StreamSubscription<ApiError>? _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Defer subscription to avoid reading providers during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscription = ref.read(apiErrorStreamProvider).listen(_handleError);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleError(ApiError error) {
    if (_isDialogShowing || !mounted) return;

    switch (error.type) {
      case ApiErrorType.sessionExpired:
        _showSessionExpiredDialog(error.message);
        break;
      case ApiErrorType.serverError:
        _showErrorSnackBar(error.message, Icons.cloud_off_rounded);
        break;
      case ApiErrorType.networkError:
        _showErrorSnackBar(error.message, Icons.wifi_off_rounded);
        break;
    }
  }

  void _showSessionExpiredDialog(String message) {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_clock_rounded, size: 40, color: AppColors.warning),
        ),
        title: Text(
          'Phiên đã hết hạn',
          style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textSecondaryLight),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              _isDialogShowing = false;
              ref.read(authNotifierProvider.notifier).logout();
            },
            icon: const Icon(Icons.login_rounded, size: 18),
            label: const Text('Đăng nhập lại'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    ).then((_) => _isDialogShowing = false);
  }

  void _showErrorSnackBar(String message, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
