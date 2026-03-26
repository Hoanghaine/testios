import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/checklist/data/models/checklist_models.dart';
import 'package:checklist_management/features/checklist/providers/checklist_providers.dart';

class TemplateListScreen extends ConsumerStatefulWidget {
  const TemplateListScreen({super.key});

  @override
  ConsumerState<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends ConsumerState<TemplateListScreen> {
  int _page = 0;
  final int _pageSize = 20;
  String? _search;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templatesAsync = ref.watch(
      templateListProvider(
        (page: _page, size: _pageSize, search: _search),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách Checklist',
          style: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(templateListProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm checklist...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _search != null && _search!.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _search = null;
                            _page = 0;
                          });
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.isEmpty ? null : value;
                  _page = 0;
                });
              },
            ),
          ),

          // Template List
          Expanded(
            child: templatesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.expense),
                    const SizedBox(height: 12),
                    Text(
                      'Không thể tải dữ liệu',
                      style: GoogleFonts.nunito(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(templateListProvider),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (pagedData) {
                if (pagedData.elements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 64,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có checklist nào',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(templateListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: pagedData.elements.length,
                    itemBuilder: (context, index) {
                      final template = pagedData.elements[index];
                      return _TemplateCard(
                        template: template,
                        onTap: () =>
                            context.push('/records?templateId=${template.id}'),
                        onEdit: () => _showEditDialog(template),
                        onVersions: () =>
                            context.push('/templates/${template.id}/versions'),
                        onDelete: () => _confirmDelete(template),
                        onCreateRecord: () => context
                            .push('/records/form?templateId=${template.id}'),
                      )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .slideX(begin: 0.05);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo mới'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtl = TextEditingController();
    final descCtl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tạo checklist mới',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Tên checklist *'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Text(
              '* Upload file Excel sẽ được hỗ trợ trong phiên bản tới',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Huỷ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement with file picker for Excel upload
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chức năng tạo checklist cần upload file Excel'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tạo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(ChecklistTemplate template) {
    final nameCtl = TextEditingController(text: template.name);
    final descCtl = TextEditingController(text: template.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sửa checklist',
              style: GoogleFonts.beVietnamPro(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(labelText: 'Tên checklist *'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtl,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Huỷ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(templateActionsProvider.notifier)
                          .updateTemplate(template.id, {
                        'name': nameCtl.text,
                        'description': descCtl.text,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã cập nhật')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Lưu'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ChecklistTemplate template) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá checklist?'),
        content: Text('Bạn có chắc muốn xoá "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(templateActionsProvider.notifier)
                  .deleteTemplate(template.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xoá checklist')),
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

// === Template Card Widget ===

class _TemplateCard extends StatelessWidget {
  final ChecklistTemplate template;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onVersions;
  final VoidCallback onDelete;
  final VoidCallback onCreateRecord;

  const _TemplateCard({
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onVersions,
    required this.onDelete,
    required this.onCreateRecord,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = template.createdAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(
            DateTime.parse(template.createdAt!).toLocal())
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
              // Title + Version badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'v${template.currentVersion}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: template.status == 'ACTIVE'
                          ? AppColors.income.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      template.status == 'ACTIVE' ? 'Hoạt động' : 'Lưu trữ',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: template.status == 'ACTIVE'
                            ? AppColors.income
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (template.description != null &&
                  template.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  template.description!,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 8),

              // Date
              Text(
                dateStr,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  _ActionChip(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Tạo bản ghi',
                    color: AppColors.primary,
                    onTap: onCreateRecord,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.edit_outlined,
                    label: 'Sửa',
                    color: AppColors.info,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.history_rounded,
                    label: 'Versions',
                    color: AppColors.accent,
                    onTap: onVersions,
                  ),
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
