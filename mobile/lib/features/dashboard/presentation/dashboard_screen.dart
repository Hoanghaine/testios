import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/checklist/data/repositories/checklist_repository.dart';
import 'package:checklist_management/features/checklist/data/repositories/record_repository.dart';

// Providers for dashboard data
final _dashboardDataProvider = FutureProvider<_DashboardData>((ref) async {
  final checklistRepo = ref.watch(checklistRepositoryProvider);
  final recordRepo = ref.watch(recordRepositoryProvider);

  final templates = await checklistRepo.getTemplates(page: 0, size: 100);
  final records = await recordRepo.getRecords(page: 0, size: 1000);

  return _DashboardData(
    templates: templates.elements,
    records: records.elements,
  );
});

class _DashboardData {
  final List<dynamic> templates;
  final List<dynamic> records;
  _DashboardData({required this.templates, required this.records});
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(_dashboardDataProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 48,
                    color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text('Không thể tải dữ liệu',
                    style: GoogleFonts.nunito(fontSize: 16)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => ref.invalidate(_dashboardDataProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (data) => _DashboardContent(data: data),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final _DashboardData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final totalTemplates = data.templates.length;
    final totalRecords = data.records.length;
    final completedRecords = data.records
        .where((r) => r.status == 'COMPLETED')
        .length;

    // Stats per template
    final templateStats = data.templates.map((t) {
      final tRecords = data.records.where((r) => r.templateId == t.id);
      return _TemplateStat(
        id: t.id,
        name: t.name,
        version: t.currentVersion,
        total: tRecords.length,
        completed: tRecords.where((r) => r.status == 'COMPLETED').length,
      );
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Will be handled by invalidation in parent
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            '📊 Thống kê',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Checklist',
                  value: totalTemplates,
                  icon: Icons.description_rounded,
                  gradient: const [Color(0xFFD71717), Color(0xFFEF4444)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Phiếu kiểm tra',
                  value: totalRecords,
                  icon: Icons.checklist_rounded,
                  gradient: const [Color(0xFFB91C1C), Color(0xFFDC2626)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'Hoàn thành',
                  value: completedRecords,
                  icon: Icons.check_circle_rounded,
                  gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Template breakdown
          Text(
            'Chi tiết theo Checklist',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          if (templateStats.isEmpty)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Chưa có checklist nào',
                    style: GoogleFonts.nunito(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          else
            ...templateStats.map((stat) => _TemplateStatCard(stat: stat)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 24),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: GoogleFonts.nunito(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateStat {
  final String id;
  final String name;
  final int version;
  final int total;
  final int completed;

  _TemplateStat({
    required this.id,
    required this.name,
    required this.version,
    required this.total,
    required this.completed,
  });
}

class _TemplateStatCard extends StatelessWidget {
  final _TemplateStat stat;
  const _TemplateStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionRate =
        stat.total > 0 ? (stat.completed / stat.total) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.push('/records?templateId=${stat.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stat.name,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'v${stat.version}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionRate == 1.0
                        ? const Color(0xFF52c41a)
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Stats row
              Row(
                children: [
                  _MiniStat(
                    label: 'Tổng',
                    value: stat.total,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 16),
                  _MiniStat(
                    label: 'Xong',
                    value: stat.completed,
                    color: const Color(0xFF52c41a),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
