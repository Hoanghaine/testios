import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/checklist/data/models/record_models.dart';
import 'package:checklist_management/features/checklist/providers/checklist_providers.dart';
import 'package:checklist_management/features/checklist/data/repositories/record_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class RecordListScreen extends ConsumerStatefulWidget {
  final String? templateId;
  const RecordListScreen({super.key, this.templateId});

  @override
  ConsumerState<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends ConsumerState<RecordListScreen> {
  int _page = 0;
  final int _pageSize = 10;
  String? _templateFilter;
  String? _schoolFilter;
  final List<ChecklistRecord> _allRecords = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _templateFilter = widget.templateId;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _page++;
      });
    }
  }

  void _resetList() {
    setState(() {
      _allRecords.clear();
      _page = 0;
      _hasMore = true;
      _isLoadingMore = false;
    });
    ref.invalidate(recordListProvider);
  }

  static const _statusMap = {
    'DRAFT': ('Bản nháp', Color(0xFF94A3B8)),
    'COMPLETED': ('Hoàn thành', Color(0xFF10B981)),
    'EXPORTED': ('Đã xuất', Color(0xFF3B82F6)),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recordsAsync = ref.watch(
      recordListProvider((
        page: _page,
        size: _pageSize,
        templateId: _templateFilter,
        schoolId: _schoolFilter,
      )),
    );
    final templatesAsync = ref.watch(
      templateListProvider((page: 0, size: 100, search: null)),
    );
    final schoolsAsync = ref.watch(schoolListProvider);

    // Accumulate records when data arrives
    recordsAsync.whenData((pagedData) {
      final existingIds = _allRecords.map((r) => r.id).toSet();
      for (final record in pagedData.elements) {
        if (!existingIds.contains(record.id)) {
          _allRecords.add(record);
        }
      }
      _hasMore = pagedData.hasNext;
      _isLoadingMore = false;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lịch sử kiểm tra',
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetList,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: templatesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (templates) => _FilterDropdown(
                      value: _templateFilter,
                      hint: 'Lọc checklist',
                      icon: Icons.description_outlined,
                      items: templates.elements
                          .map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        _templateFilter = v;
                        _resetList();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: schoolsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (schools) => _FilterDropdown(
                      value: _schoolFilter,
                      hint: 'Lọc trường',
                      icon: Icons.school_outlined,
                      items: schools
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        _schoolFilter = v;
                        _resetList();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Records List with infinite scroll
          Expanded(
            child: _allRecords.isEmpty && !recordsAsync.isLoading
                ? recordsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.expense),
                          const SizedBox(height: 12),
                          Text('Không thể tải dữ liệu', style: GoogleFonts.nunito(fontSize: 16)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _resetList,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                    data: (_) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded, size: 64,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                          const SizedBox(height: 12),
                          Text('Chưa có phiếu kiểm tra nào',
                            style: GoogleFonts.nunito(fontSize: 16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                        ],
                      ),
                    ),
                  )
                : _allRecords.isEmpty && recordsAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () async => _resetList(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _allRecords.length + (_hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _allRecords.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final record = _allRecords[index];
                            return _RecordCard(
                              record: record,
                              onTap: () => context.push('/records/form?recordId=${record.id}'),
                              onExport: () => _exportRecord(record),
                              onDownload: record.exportedFileS3Key != null
                                  ? () => _downloadRecord(record)
                                  : null,
                              onDelete: () => _confirmDelete(record),
                            ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final query = _templateFilter != null ? '?templateId=$_templateFilter' : '';
          context.push('/records/form$query');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo phiếu'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _exportRecord(ChecklistRecord record) async {
    final success = await ref
        .read(recordActionsProvider.notifier)
        .exportRecord(record.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xuất Excel thành công')),
      );
    }
  }

  Future<void> _downloadRecord(ChecklistRecord record) async {
    try {
      final repo = ref.read(recordRepositoryProvider);
      final url = await repo.getRecordDownloadUrl(record.id);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải file')),
        );
      }
    }
  }

  void _confirmDelete(ChecklistRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá phiếu kiểm tra?'),
        content: const Text('Bạn có chắc muốn xoá phiếu kiểm tra này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(recordActionsProvider.notifier)
                  .deleteRecord(record.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xoá phiếu kiểm tra')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// === Record Card ===

class _RecordCard extends StatelessWidget {
  final ChecklistRecord record;
  final VoidCallback onTap;
  final VoidCallback? onExport;
  final VoidCallback? onDownload;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.onTap,
    this.onExport,
    this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (statusLabel, statusColor) =
        _RecordListScreenState._statusMap[record.status] ??
            ('N/A', Colors.grey);
    final dateStr = record.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm')
            .format(DateTime.parse(record.createdAt!).toLocal())
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.name ?? record.templateName ?? 'Không rõ',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.school_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(
                    record.schoolName ?? '-',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (record.templateVersion != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'v${record.templateVersion}',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    dateStr,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ActionChip(
                    icon: Icons.visibility_outlined,
                    label: 'Xem/Sửa',
                    color: AppColors.primary,
                    onTap: onTap,
                  ),
                  if (onExport != null) ...[
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.upload_file_rounded,
                      label: record.exportedFileS3Key != null ? 'Xuất lại' : 'Xuất Excel',
                      color: AppColors.warning,
                      onTap: onExport!,
                    ),
                  ],
                  if (record.exportedFileS3Key != null && onDownload != null) ...[
                    const SizedBox(width: 8),
                    _ActionChip(
                      icon: Icons.download_rounded,
                      label: 'Tải Excel',
                      color: AppColors.info,
                      onTap: onDownload!,
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: AppColors.expense, size: 20),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    this.value,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.dividerLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hint,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Tất cả',
                  style: GoogleFonts.nunito(fontSize: 13)),
            ),
            ...items,
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
