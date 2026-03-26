import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:checklist_management/core/constants/form_constants.dart';
import 'package:checklist_management/core/theme/app_theme.dart';
import 'package:checklist_management/features/checklist/data/models/checklist_models.dart';

class DynamicFormRenderer extends StatefulWidget {
  final ChecklistSchema schema;
  final Map<String, dynamic> formData;
  final bool readOnly;
  final String? currentUserName;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DynamicFormRenderer({
    super.key,
    required this.schema,
    required this.formData,
    this.readOnly = false,
    this.currentUserName,
    required this.onChanged,
  });

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedGroups = {};
  final Map<String, GlobalKey> _itemKeys = {};
  String _searchQuery = '';

  ChecklistSchema get schema => widget.schema;
  Map<String, dynamic> get formData => widget.formData;
  bool get readOnly => widget.readOnly;

  @override
  void initState() {
    super.initState();
    // Start with first group expanded
    if (schema.objects.isNotEmpty) {
      _expandedGroups.add(schema.objects.first.key);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateField(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(formData);
    updated[key] = value;
    widget.onChanged(updated);
  }

  void _updateNestedField(List<String> path, dynamic value) {
    final updated = Map<String, dynamic>.from(formData);
    Map<String, dynamic> current = updated;
    for (int i = 0; i < path.length - 1; i++) {
      current[path[i]] ??= <String, dynamic>{};
      current = current[path[i]] as Map<String, dynamic>;
    }
    current[path.last] = value;
    widget.onChanged(updated);
  }

  dynamic _getNestedValue(List<String> path) {
    dynamic current = formData;
    for (final key in path) {
      if (current is Map) {
        current = current[key];
      } else {
        return null;
      }
    }
    return current;
  }

  GlobalKey _getItemKey(String objectKey, String itemKey) {
    final compositeKey = '$objectKey.$itemKey';
    return _itemKeys.putIfAbsent(compositeKey, () => GlobalKey());
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase().trim());
    if (_searchQuery.isEmpty) return;

    // Find first matching item and scroll to it
    for (final obj in schema.objects) {
      for (final item in obj.items) {
        final label = (item.label ?? item.key).toLowerCase();
        if (label.contains(_searchQuery)) {
          // Expand the group
          setState(() => _expandedGroups.add(obj.key));
          // Scroll to item after frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final key = _getItemKey(obj.key, item.key);
            if (key.currentContext != null) {
              Scrollable.ensureVisible(
                key.currentContext!,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
          return;
        }
      }
    }
  }

  bool _itemMatchesSearch(SchemaItem item) {
    if (_searchQuery.isEmpty) return false;
    return (item.label ?? item.key).toLowerCase().contains(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the first row of objects/tables to split rootFields
    int firstContentRow = 999999;
    for (final obj in schema.objects) {
      if (obj.row != null && obj.row! < firstContentRow) {
        firstContentRow = obj.row!;
      }
    }
    for (final table in schema.tables) {
      if (table.row != null && table.row! < firstContentRow) {
        firstContentRow = table.row!;
      }
    }

    // Split rootFields: before first content = top, after = bottom
    final allVisible = schema.rootFields
        .where((f) => !FormConstants.hiddenAutoFillFields.contains(f.key))
        .toList();
    final topFields = allVisible
        .where((f) => f.row == null || f.row! < firstContentRow)
        .toList();
    final bottomFields = allVisible
        .where((f) => f.row != null && f.row! >= firstContentRow)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nội dung...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            onChanged: (v) {
              if (v.isEmpty) setState(() => _searchQuery = '');
            },
          ),
        ),

        // Top Root Fields (before objects/tables)
        if (topFields.isNotEmpty)
          _SectionCard(
            children: topFields
                .map((field) => _buildField(context, field, [field.key]))
                .toList(),
          ),

        // Objects (Collapsible group sections) — continuous numbering
        for (int gIdx = 0; gIdx < schema.objects.length; gIdx++) ...[
          Builder(builder: (context) {
            final obj = schema.objects[gIdx];
            // Calculate offset: sum of items in all previous groups
            int offset = 0;
            for (int p = 0; p < gIdx; p++) {
              offset += schema.objects[p].items.length;
            }
            return _CollapsibleObjectSection(
              objectKey: obj.key,
              title: obj.label ?? obj.key,
              isExpanded: _expandedGroups.contains(obj.key),
              itemCount: obj.items.length,
              onToggle: () {
                setState(() {
                  if (_expandedGroups.contains(obj.key)) {
                    _expandedGroups.remove(obj.key);
                  } else {
                    _expandedGroups.add(obj.key);
                  }
                });
              },
              children: [
                for (int i = 0; i < obj.items.length; i++)
                  KeyedSubtree(
                    key: _getItemKey(obj.key, obj.items[i].key),
                    child: _buildItem(context, obj.items[i], obj.key,
                        index: offset + i + 1,
                        highlight: _itemMatchesSearch(obj.items[i])),
                  ),
              ],
            );
          }),
        ],

        // Grouped Fields
        for (final group in schema.groupedFields)
          _SectionCard(
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: group.fields
                    .map((field) => SizedBox(
                          width: field.type == 'text' ? double.infinity : 200,
                          child: _buildField(context, field, [field.key]),
                        ))
                    .toList(),
              ),
            ],
          ),

        // Tables
        for (final table in schema.tables)
          _buildTable(context, table),

        if (bottomFields.isNotEmpty)
          _SectionCard(
            children: bottomFields
                .map((field) => _buildField(context, field, [field.key]))
                .toList(),
          ),
      ],
    );
  }

  /// Extract image/signature value from various formats:
  /// - String (base64 data URI from mobile)
  /// - List<Map> with thumbUrl/url (Ant Design Upload from frontend)
  /// - null
  String? _extractImageValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is Map) {
        return (first['thumbUrl'] ?? first['url'])?.toString();
      }
    }
    return value.toString();
  }

  Widget _buildField(BuildContext context, SchemaField field, List<String> path) {
    // Hide auto-filled fields
    if (FormConstants.hiddenAutoFillFields.contains(field.key)) {
      return const SizedBox.shrink();
    }

    final value = _getNestedValue(path);
    // Map generic keys to user-friendly labels
    String label = FormConstants.labelOverrides[field.label ?? field.key]
        ?? field.label ?? field.key;

    switch (field.type) {
      case 'radio':
        // Default to 'pass' if no value set
        final radioValue = value?.toString();
        if (radioValue == null && !readOnly) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateNestedField(path, 'pass');
          });
        }
        return _RadioField(
          label: label,
          options: field.options ?? [],
          value: radioValue ?? 'pass',
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'checkbox':
        return _CheckboxField(
          label: label,
          options: field.options ?? [],
          values: (value is List) ? value.map((e) => e.toString()).toList() : [],
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'select':
        return _SelectField(
          label: label,
          options: field.options ?? [],
          value: value?.toString(),
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'number':
        return _NumberField(
          label: label,
          value: value is num ? value.toDouble() : null,
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'vnd':
        return _VndField(
          label: label,
          value: value is num ? value.toDouble() : null,
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );


      case 'datetime':
        return _DateTimeField(
          label: label,
          value: value?.toString(),
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'date':
        return _DateOnlyField(
          label: label,
          value: value?.toString(),
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );

      case 'image':
        // Support multiple images — value can be a String, a List, or null
        List<String> currentImages = [];
        if (value is List) {
          for (final item in value) {
            final extracted = _extractImageValue(item);
            if (extracted != null) currentImages.add(extracted);
          }
        } else if (value is String && value.isNotEmpty) {
          currentImages = [value];
        }
        return _ImageField(
          label: label,
          currentImages: currentImages,
          readOnly: readOnly,
          onImagesChanged: (images) => _updateNestedField(path, images),
        );

      case 'signature':
        return _SignatureField(
          label: label,
          currentPath: _extractImageValue(value),
          readOnly: readOnly,
          onImagePicked: (base64DataUri) => _updateNestedField(path, base64DataUri),
        );

      case 'text':
      default:
        return _TextField(
          label: label,
          value: value?.toString(),
          readOnly: readOnly,
          onChanged: (v) => _updateNestedField(path, v),
        );
    }
  }

  Widget _buildItem(BuildContext context, SchemaItem item, String objectKey,
      {int? index, bool highlight = false}) {
    // Find radio field and get its current value for conditional logic
    final radioField = item.fields.where((f) => f.type == 'radio').firstOrNull;
    String? radioValue;
    if (radioField != null) {
      final itemData = _getNestedValue([objectKey, item.key]);
      if (itemData is Map) {
        radioValue = itemData[radioField.key]?.toString();
      }
    }

    // Check if a field should be visible based on its condition
    bool isFieldVisible(SchemaField field) {
      if (field.condition == null) return true;
      if (radioValue == null) return false; // no radio selected → hide
      final cond = field.condition!;
      if (cond.type == 'and') {
        return cond.values.every((v) => v == radioValue);
      }
      return cond.values.contains(radioValue); // 'or'
    }

    final visibleFields = item.fields.where(isFieldVisible).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? AppColors.primary : Colors.grey.shade200,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.label != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index != null)
                  Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    item.label!,
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          // Render visible fields only
          ...visibleFields.map((field) => _buildField(
              context, field, [objectKey, item.key, field.key])),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, SchemaTable table) {
    final rows = (formData[table.key] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
          child: Text(
            table.label ?? table.key,
            style: GoogleFonts.beVietnamPro(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Each row = a card section
        for (int index = 0; index < rows.length; index++)
          _buildTableRowCard(context, table, rows, index),

        // Add row button
        if (!readOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: () {
                final updatedRows = List.from(rows);
                final newRow = <String, dynamic>{};
                // Auto-fill nguoi_thuc_hien with current user
                for (final col in table.columns) {
                  if (col.key.contains('nguoi_thuc_hien') && widget.currentUserName != null) {
                    newRow[col.key] = widget.currentUserName;
                  }
                }
                updatedRows.add(newRow);
                _updateField(table.key, updatedRows);
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text('Thêm mục ${(table.label ?? table.key).toLowerCase()}'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTableRowCard(
    BuildContext context,
    SchemaTable table,
    List rows,
    int index,
  ) {
    final row = rows[index] as Map<String, dynamic>? ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: number + delete button
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mục ${index + 1}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!readOnly)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: AppColors.expense, size: 20),
                    onPressed: () {
                      final updatedRows = List.from(rows);
                      updatedRows.removeAt(index);
                      _updateField(table.key, updatedRows);
                    },
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    tooltip: 'Xoá mục ${index + 1}',
                  ),
              ],
            ),
            const Divider(height: 16),

            // Fields for each column
            for (final col in table.columns)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTableColumnField(context, col, rows, index, table.key),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableColumnField(
    BuildContext context,
    TableColumn col,
    List rows,
    int index,
    String tableKey,
  ) {
    final row = (rows[index] as Map<String, dynamic>?) ?? {};

    if (col.type == 'formula') {
      return Row(
        children: [
          Expanded(
            child: Text(
              col.label ?? col.key,
              style: GoogleFonts.nunito(fontSize: 13),
            ),
          ),
          Text(
            col.formula ?? '-',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      );
    }

    if (col.type == 'datetime' || col.type == 'date') {
      final curVal = row[col.key]?.toString();
      DateTime? parsed;
      if (curVal != null && curVal.isNotEmpty) {
        try { parsed = DateTime.parse(curVal); } catch (_) {}
      }

      String displayText = '';
      if (parsed != null) {
        final d = parsed.day.toString().padLeft(2, '0');
        final m = parsed.month.toString().padLeft(2, '0');
        final y = parsed.year.toString();
        displayText = '$d/$m/$y';
        if (col.type == 'datetime') {
          final h = parsed.hour.toString().padLeft(2, '0');
          final min = parsed.minute.toString().padLeft(2, '0');
          displayText = '$d/$m/$y  $h:$min';
        }
      }

      return InkWell(
        onTap: readOnly
            ? null
            : () async {
                final now = DateTime.now();
                final initial = parsed ?? now;
                final date = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                  locale: const Locale('vi'),
                );
                if (date == null) return;

                DateTime dt = date;
                if (col.type == 'datetime' && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: parsed != null
                        ? TimeOfDay(hour: parsed.hour, minute: parsed.minute)
                        : TimeOfDay.now(),
                  );
                  dt = DateTime(
                    date.year, date.month, date.day,
                    time?.hour ?? 0, time?.minute ?? 0,
                  );
                }

                final updatedRows = List.from(rows);
                final updatedRow = Map<String, dynamic>.from(updatedRows[index] ?? {});
                updatedRow[col.key] = dt.toIso8601String();
                updatedRows[index] = updatedRow;
                _updateField(tableKey, updatedRows);
              },
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: col.label ?? col.key,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
          ),
          child: Text(
            displayText.isEmpty
                ? (col.type == 'datetime' ? 'Chọn ngày giờ' : 'Chọn ngày')
                : displayText,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: displayText.isEmpty ? AppColors.textSecondaryLight : null,
            ),
          ),
        ),
      );
    }

    return TextFormField(
      initialValue: row[col.key]?.toString() ?? '',
      enabled: !readOnly,
      keyboardType: col.type == 'number'
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: col.label ?? col.key,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(),
      ),
      style: GoogleFonts.nunito(fontSize: 14),
      onChanged: (v) {
        final updatedRows = List.from(rows);
        final updatedRow = Map<String, dynamic>.from(updatedRows[index] ?? {});
        updatedRow[col.key] = col.type == 'number' ? num.tryParse(v) : v;
        updatedRows[index] = updatedRow;
        _updateField(tableKey, updatedRows);
      },
    );
  }
}

// === Collapsible Object Section ===

class _CollapsibleObjectSection extends StatelessWidget {
  final String objectKey;
  final String title;
  final bool isExpanded;
  final int itemCount;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _CollapsibleObjectSection({
    required this.objectKey,
    required this.title,
    required this.isExpanded,
    required this.itemCount,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Tappable header
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  Icon(Icons.checklist_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  // Item count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$itemCount',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Collapsible content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}


class _SectionCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _SectionCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  Icon(Icons.checklist_rounded, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title!,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// === Field Widgets ===

class _TextField extends StatelessWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value,
        enabled: !readOnly,
        maxLines: 2,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }
}

class _RadioField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final bool readOnly;
  final ValueChanged<String?> onChanged;

  const _RadioField({
    required this.label,
    required this.options,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  String _optionLabel(String opt) {
    switch (opt) {
      case 'pass':
        return 'Đạt';
      case 'fail':
        return 'Không đạt';
      case 'na':
        return 'Không check';
      default:
        return opt;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide generic labels — radio fields don't need a label
    final showLabel = label != 'check' && label != 'Check' && label != 'radio';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(label, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondaryLight)),
            ),
          Row(
            children: options.map((opt) {
              final isSelected = value == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_optionLabel(opt), style: const TextStyle(fontSize: 13)),
                  selected: isSelected,
                  onSelected: readOnly ? null : (selected) {
                    onChanged(selected ? opt : null);
                  },
                  selectedColor: opt == 'pass'
                      ? AppColors.income.withValues(alpha: 0.2)
                      : opt == 'fail'
                          ? AppColors.expense.withValues(alpha: 0.2)
                          : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                  labelStyle: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CheckboxField extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> values;
  final bool readOnly;
  final ValueChanged<List<String>> onChanged;

  const _CheckboxField({
    required this.label,
    required this.options,
    required this.values,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: options.map((opt) {
              final isChecked = values.contains(opt);
              return FilterChip(
                label: Text(opt),
                selected: isChecked,
                onSelected: readOnly
                    ? null
                    : (selected) {
                        final updated = List<String>.from(values);
                        if (selected) {
                          updated.add(opt);
                        } else {
                          updated.remove(opt);
                        }
                        onChanged(updated);
                      },
                labelStyle: GoogleFonts.nunito(fontSize: 13),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? value;
  final bool readOnly;
  final ValueChanged<String?> onChanged;

  const _SelectField({
    required this.label,
    required this.options,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure value exists in options to prevent DropdownButton crash
    final safeValue = (value != null && options.contains(value)) ? value : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: readOnly ? null : onChanged,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final double? value;
  final bool readOnly;
  final ValueChanged<double?> onChanged;

  const _NumberField({
    required this.label,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value?.toString(),
        enabled: !readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        onChanged: (v) => onChanged(double.tryParse(v)),
      ),
    );
  }
}

class _VndField extends StatelessWidget {
  final String label;
  final double? value;
  final bool readOnly;
  final ValueChanged<double?> onChanged;

  const _VndField({
    required this.label,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  String _formatVnd(double? v) {
    if (v == null) return '';
    final intVal = v.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: value != null ? value!.toInt().toString() : null,
        enabled: !readOnly,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'đ',
          hintText: _formatVnd(value),
        ),
        onChanged: (v) {
          final cleaned = v.replaceAll('.', '').replaceAll(' ', '').replaceAll('đ', '');
          onChanged(double.tryParse(cleaned));
        },
      ),
    );
  }
}


class _DateTimeField extends StatelessWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const _DateTimeField({
    required this.label,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  DateTime? _parseValue() {
    if (value == null || value!.isEmpty) return null;
    try {
      return DateTime.parse(value!);
    } catch (_) {
      return null;
    }
  }

  String _formatDisplay(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y  $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseValue();
    final displayText = _formatDisplay(parsed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: readOnly
            ? null
            : () async {
                final now = DateTime.now();
                final initial = parsed ?? now;

                final date = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                  locale: const Locale('vi'),
                  helpText: 'Chọn ngày',
                  cancelText: 'Huỷ',
                  confirmText: 'Chọn',
                );
                if (date != null && context.mounted) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: parsed != null
                        ? TimeOfDay(hour: parsed.hour, minute: parsed.minute)
                        : TimeOfDay.now(),
                    helpText: 'Chọn giờ',
                    cancelText: 'Huỷ',
                    confirmText: 'Chọn',
                  );
                  final dt = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time?.hour ?? 0,
                    time?.minute ?? 0,
                  );
                  onChanged(dt.toIso8601String());
                }
              },
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: Text(
            displayText.isEmpty ? 'Chọn ngày giờ' : displayText,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: displayText.isEmpty ? AppColors.textSecondaryLight : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateOnlyField extends StatelessWidget {
  final String label;
  final String? value;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const _DateOnlyField({
    required this.label,
    this.value,
    required this.readOnly,
    required this.onChanged,
  });

  DateTime? _parseValue() {
    if (value == null || value!.isEmpty) return null;
    try {
      return DateTime.parse(value!);
    } catch (_) {
      return null;
    }
  }

  String _formatDisplay(DateTime? dt) {
    if (dt == null) return '';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parseValue();
    final displayText = _formatDisplay(parsed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: readOnly
            ? null
            : () async {
                final now = DateTime.now();
                final initial = parsed ?? now;

                final date = await showDatePicker(
                  context: context,
                  initialDate: initial,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                  locale: const Locale('vi'),
                  helpText: 'Chọn ngày',
                  cancelText: 'Huỷ',
                  confirmText: 'Chọn',
                );
                if (date != null) {
                  // Save as YYYY-MM-DD
                  final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  onChanged(formatted);
                }
              },
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          child: Text(
            displayText.isEmpty ? 'Chọn ngày' : displayText,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: displayText.isEmpty ? AppColors.textSecondaryLight : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageField extends StatefulWidget {
  final String label;
  final List<String> currentImages;
  final bool readOnly;
  final ValueChanged<List<String>> onImagesChanged;

  const _ImageField({
    required this.label,
    this.currentImages = const [],
    required this.readOnly,
    required this.onImagesChanged,
  });

  @override
  State<_ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<_ImageField> {
  late List<String> _images; // list of data:image URIs
  late List<Uint8List?> _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.currentImages);
    _imageBytes = _images.map(_decodeImage).toList();
  }

  Uint8List? _decodeImage(String uri) {
    if (uri.startsWith('data:image')) {
      try {
        return base64Decode(uri.split(',').last);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final hasCamera = await picker.supportsImageSource(ImageSource.camera);

    // Show bottom sheet for camera vs gallery
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            if (hasCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Chọn từ thư viện (nhiều ảnh)'),
              onTap: () => Navigator.pop(ctx, 'gallery'),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    setState(() => _isLoading = true);

    try {
      if (source == 'camera') {
        final image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1200,
          imageQuality: 85,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          final mimeType = image.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
          final dataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
          setState(() {
            _images.add(dataUri);
            _imageBytes.add(bytes);
          });
          widget.onImagesChanged(List.from(_images));
        }
      } else {
        // Gallery — pick multiple
        final images = await picker.pickMultiImage(
          maxWidth: 1200,
          imageQuality: 85,
        );
        for (final image in images) {
          final bytes = await image.readAsBytes();
          final mimeType = image.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
          final dataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';
          _images.add(dataUri);
          _imageBytes.add(bytes);
        }
        if (images.isNotEmpty) {
          setState(() {});
          widget.onImagesChanged(List.from(_images));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể chọn ảnh: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _imageBytes.removeAt(index);
    });
    widget.onImagesChanged(List.from(_images));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),

          // Image grid
          if (_imageBytes.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_imageBytes.length, (i) {
                final bytes = _imageBytes[i];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: bytes != null
                          ? Image.memory(bytes, fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                    ),
                    if (!widget.readOnly)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),

          if (!widget.readOnly)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickImages,
                icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                label: Text(_images.isEmpty ? 'Chụp / Chọn ảnh' : 'Thêm ảnh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SignatureField extends StatefulWidget {
  final String label;
  final String? currentPath;
  final bool readOnly;
  final ValueChanged<String> onImagePicked;

  const _SignatureField({
    required this.label,
    this.currentPath,
    required this.readOnly,
    required this.onImagePicked,
  });

  @override
  State<_SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<_SignatureField> {
  Uint8List? _savedBytes;


  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    if (widget.currentPath != null && widget.currentPath!.startsWith('data:image')) {
      final base64Part = widget.currentPath!.split(',').last;
      try {
        _savedBytes = base64Decode(base64Part);
      } catch (_) {}
    }
  }

  void _openSignaturePad() async {
    final result = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _SignaturePadScreen(label: widget.label),
      ),
    );
    if (result != null && result.isNotEmpty) {
      final dataUri = 'data:image/png;base64,${base64Encode(result)}';
      setState(() => _savedBytes = result);
      widget.onImagePicked(dataUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSig = _savedBytes != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),

          if (hasSig)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Image.memory(_savedBytes!, fit: BoxFit.contain),
            ),

          if (!widget.readOnly)
            OutlinedButton.icon(
              onPressed: _openSignaturePad,
              icon: Icon(
                  hasSig ? Icons.refresh_rounded : Icons.draw_rounded,
                  size: 18),
              label: Text(hasSig ? 'Ký lại' : 'Nhấn để ký'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
        ],
      ),
    );
  }
}

// === Full-screen Signature Pad ===

class _SignaturePadScreen extends StatefulWidget {
  final String label;

  const _SignaturePadScreen({required this.label});

  @override
  State<_SignaturePadScreen> createState() => _SignaturePadScreenState();
}

class _SignaturePadScreenState extends State<_SignaturePadScreen> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get _isEmpty => _strokes.isEmpty && _currentStroke.isEmpty;

  void _clear() => setState(() {
        _strokes.clear();
        _currentStroke.clear();
      });

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
    }
  }

  Future<void> _save() async {
    if (_isEmpty) {
      Navigator.pop(context);
      return;
    }

    // Render strokes to an image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // White background
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 600, 200),
      Paint()..color = Colors.white,
    );

    // Draw all strokes scaled to 600x200
    final renderBox = context.findRenderObject() as RenderBox?;
    final widgetSize = renderBox?.size ?? const Size(300, 150);
    final scaleX = 600 / widgetSize.width;
    final scaleY = 200 / widgetSize.height;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx * scaleX, stroke.first.dy * scaleY);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx * scaleX, stroke[i].dy * scaleY);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(600, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null && mounted) {
      Navigator.pop(context, byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.label,
            style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _undo,
            child: const Text('Hoàn tác'),
          ),
          TextButton(
            onPressed: _clear,
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Lưu'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dùng ngón tay vẽ chữ ký vào khung bên dưới',
              style: GoogleFonts.nunito(
                  fontSize: 14, color: AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentStroke = [details.localPosition];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    setState(() {
                      _strokes.add(List.from(_currentStroke));
                      _currentStroke = [];
                    });
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      strokes: _strokes,
                      currentStroke: _currentStroke,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignaturePainter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw guideline
    final guideY = size.height * 0.7;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(20, guideY), Offset(size.width - 20, guideY), guidePaint);

    // Draw completed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }
    // Draw current stroke
    _drawStroke(canvas, currentStroke, paint);
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      // Smooth using quadratic bezier
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

