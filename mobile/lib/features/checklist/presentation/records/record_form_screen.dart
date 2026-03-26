import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checklist_management/core/constants/form_constants.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/checklist/data/models/record_models.dart';
import 'package:checklist_management/features/checklist/providers/checklist_providers.dart';
import 'package:checklist_management/features/checklist/presentation/widgets/dynamic_form_renderer.dart';
import 'package:checklist_management/features/auth/providers/auth_providers.dart';

class RecordFormScreen extends ConsumerStatefulWidget {
  final String? templateId;
  final String? recordId;

  const RecordFormScreen({super.key, this.templateId, this.recordId});

  @override
  ConsumerState<RecordFormScreen> createState() => _RecordFormScreenState();
}

class _RecordFormScreenState extends ConsumerState<RecordFormScreen> {
  String? _selectedTemplateId;
  String? _selectedSchoolId;
  Map<String, dynamic> _formData = {};
  bool _isSaving = false;

  bool get _isEditMode => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    _selectedTemplateId = widget.templateId;
  }

  @override
  Widget build(BuildContext context) {

    // Load templates for selector
    final templatesAsync = ref.watch(
      templateListProvider((page: 0, size: 100, search: null)),
    );

    // Load schools for selector
    final schoolsAsync = ref.watch(schoolListProvider);

    // Load template detail (for schema)
    final templateDetailAsync = _selectedTemplateId != null
        ? ref.watch(templateDetailProvider(_selectedTemplateId!))
        : null;

    // Load record detail (for editing)
    final recordDetailAsync = _isEditMode
        ? ref.watch(recordDetailProvider(widget.recordId!))
        : null;

    // Pre-fill form data from record (edit mode)
    if (_isEditMode && recordDetailAsync != null) {
      recordDetailAsync.whenData((record) {
        if (_formData.isEmpty && record.data.isNotEmpty) {
          _formData = Map<String, dynamic>.from(record.data);
          _selectedTemplateId = record.templateId;
          _selectedSchoolId = record.schoolId;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditMode ? 'Sửa phiếu kiểm tra' : 'Tạo phiếu kiểm tra',
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: [
          // Complete
          FilledButton.icon(
            onPressed: _isSaving ? null : () => _handleSave('COMPLETED'),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 18),
            label: const Text('Hoàn thành'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template + School Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Template selector
                    templatesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Lỗi tải checklist'),
                      data: (templates) {
                        final validId = templates.elements.any((t) => t.id == _selectedTemplateId)
                            ? _selectedTemplateId
                            : null;
                        return DropdownButtonFormField<String>(
                          value: validId,
                          decoration: const InputDecoration(
                            labelText: 'Checklist',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          isExpanded: true,
                          items: templates.elements
                              .map((t) => DropdownMenuItem(
                                    value: t.id,
                                    child: Text(t.name,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: _isEditMode
                              ? null
                              : (v) {
                                  setState(() {
                                    _selectedTemplateId = v;
                                    _formData = {};
                                  });
                                },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // School selector
                    schoolsAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Lỗi tải trường'),
                      data: (schools) {
                        final validSchoolId = schools.any((s) => s.id == _selectedSchoolId)
                            ? _selectedSchoolId
                            : null;
                        return DropdownButtonFormField<String>(
                          value: validSchoolId,
                          decoration: const InputDecoration(
                            labelText: 'Trường / Bếp (bắt buộc)',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          isExpanded: true,
                          items: [
                            ...schools.map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name,
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (v) {
                              final schoolName = v != null
                                  ? schools.firstWhere((s) => s.id == v).name
                                  : null;
                              setState(() {
                                _selectedSchoolId = v;
                                if (schoolName != null) {
                                  _formData[FormConstants.fieldKeySchoolName] = schoolName;
                                } else {
                                  _formData.remove(FormConstants.fieldKeySchoolName);
                                }
                              });
                            },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Dynamic Form
            if (_isEditMode && recordDetailAsync != null)
              recordDetailAsync.when(
                loading: () => _buildLoadingState(),
                error: (err, _) => _buildErrorState('Lỗi tải phiếu kiểm tra'),
                data: (record) {
                  if (record.schemaData == null) {
                    return _buildEmptyState(
                        'Không tìm thấy schema cho phiếu này');
                  }
                  return DynamicFormRenderer(
                    schema: record.schemaData!,
                    formData: _formData,
                    currentUserName: ref.read(authNotifierProvider).valueOrNull?.userInfo.fullName,
                    onChanged: (data) => setState(() => _formData = data),
                  );
                },
              )
            else if (_selectedTemplateId != null && templateDetailAsync != null)
              templateDetailAsync.when(
                loading: () => _buildLoadingState(),
                error: (err, stack) {
                    return _buildErrorState('Lỗi tải checklist: $err');
                },
                data: (detail) {
                  final schema = detail.latestVersion?.schemaData;
                  if (schema == null) {
                    return _buildEmptyState(
                        'Checklist này chưa có schema. Vui lòng kiểm tra lại.');
                  }
                  return DynamicFormRenderer(
                    schema: schema,
                    formData: _formData,
                    currentUserName: ref.read(authNotifierProvider).valueOrNull?.userInfo.fullName,
                    onChanged: (data) => setState(() => _formData = data),
                  );
                },
              )
            else
              _buildEmptyState('Vui lòng chọn checklist để bắt đầu điền dữ liệu'),

            // Export button (edit mode only)
            if (_isEditMode) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _handleExport,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Xuất Excel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.expense),
            const SizedBox(height: 8),
            Text(message, style: GoogleFonts.nunito(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Center(
          child: Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(String status) async {
    if (_selectedTemplateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn checklist')),
      );
      return;
    }
    if (_selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn Trường / Bếp')),
      );
      return;
    }

    if (_isEditMode) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ghi đè phiếu kiểm tra?'),
          content: const Text('Bạn có muốn ghi đè lại thông tin phiếu kiểm tra này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huỷ'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text('Ghi đè'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSaving = true);

    // Auto-fill hidden fields
    _formData[FormConstants.fieldKeyDateTime] = DateTime.now().toIso8601String();

    try {
      bool success;
      if (_isEditMode) {
        success = await ref
            .read(recordActionsProvider.notifier)
            .updateRecord(widget.recordId!, RecordUpdateReq(
              schoolId: _selectedSchoolId,
              data: _formData,
              status: status,
            ));
      } else {
        final templateDetail =
            await ref.read(templateDetailProvider(_selectedTemplateId!).future);
        success = await ref
            .read(recordActionsProvider.notifier)
            .createRecord(RecordCreateReq(
              templateId: _selectedTemplateId!,
              templateVersionId: templateDetail.latestVersion?.id,
              schoolId: _selectedSchoolId,
              data: _formData,
            ));
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã hoàn thành'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleExport() async {
    if (widget.recordId == null) return;

    setState(() => _isSaving = true);

    try {
      // Save first, then export
      await ref.read(recordActionsProvider.notifier).updateRecord(
            widget.recordId!,
            RecordUpdateReq(
              schoolId: _selectedSchoolId,
              data: _formData,
              status: 'COMPLETED',
            ),
          );

      await ref
          .read(recordActionsProvider.notifier)
          .exportRecord(widget.recordId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xuất Excel thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
