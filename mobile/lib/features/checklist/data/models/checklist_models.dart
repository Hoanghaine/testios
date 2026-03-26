/// Parse date from backend: can be array [y,m,d,h,m,s] or ISO string
String? parseDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is List) {
    try {
      final dt = DateTime(
        value[0] as int,
        value[1] as int,
        value[2] as int,
        value.length > 3 ? value[3] as int : 0,
        value.length > 4 ? value[4] as int : 0,
        value.length > 5 ? value[5] as int : 0,
      );
      return dt.toIso8601String();
    } catch (_) {
      return value.toString();
    }
  }
  return value.toString();
}

class ChecklistTemplate {
  final String id;
  final String name;
  final String? description;
  final int currentVersion;
  final String status;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;

  ChecklistTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.currentVersion,
    required this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currentVersion: json['currentVersion'] as int? ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: parseDate(json['createdAt']),
      createdBy: json['createdBy'] as String?,
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'currentVersion': currentVersion,
        'status': status,
      };
}

class TemplateVersion {
  final String id;
  final String templateId;
  final int version;
  final ChecklistSchema? schemaData;
  final String? originalFileName;
  final String? changeNote;
  final String? createdAt;
  final String? createdBy;

  TemplateVersion({
    required this.id,
    required this.templateId,
    required this.version,
    this.schemaData,
    this.originalFileName,
    this.changeNote,
    this.createdAt,
    this.createdBy,
  });

  factory TemplateVersion.fromJson(Map<String, dynamic> json) {
    return TemplateVersion(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      version: json['version'] as int,
      schemaData: json['schemaData'] != null
          ? ChecklistSchema.fromJson(json['schemaData'] as Map<String, dynamic>)
          : null,
      originalFileName: json['originalFileName'] as String?,
      changeNote: json['changeNote'] as String?,
      createdAt: parseDate(json['createdAt']),
      createdBy: json['createdBy'] as String?,
    );
  }
}

class TemplateDetail {
  final String id;
  final String name;
  final String? description;
  final int currentVersion;
  final String status;
  final TemplateVersion? latestVersion;
  final List<TemplateVersion> versions;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;

  TemplateDetail({
    required this.id,
    required this.name,
    this.description,
    required this.currentVersion,
    required this.status,
    this.latestVersion,
    this.versions = const [],
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory TemplateDetail.fromJson(Map<String, dynamic> json) {
    return TemplateDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      currentVersion: json['currentVersion'] as int? ?? 1,
      status: json['status'] as String? ?? 'ACTIVE',
      latestVersion: json['latestVersion'] != null
          ? TemplateVersion.fromJson(
              json['latestVersion'] as Map<String, dynamic>)
          : null,
      versions: (json['versions'] as List?)
              ?.map(
                  (e) => TemplateVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: parseDate(json['createdAt']),
      createdBy: json['createdBy'] as String?,
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

// === Checklist Schema Models ===

class ChecklistSchema {
  final List<SchemaField> rootFields;
  final List<SchemaObject> objects;
  final List<SchemaTable> tables;
  final List<SchemaSummary> summaries;
  final List<GroupedFieldGroup> groupedFields;
  final List<CellMapping> cellMappings;

  ChecklistSchema({
    this.rootFields = const [],
    this.objects = const [],
    this.tables = const [],
    this.summaries = const [],
    this.groupedFields = const [],
    this.cellMappings = const [],
  });

  factory ChecklistSchema.fromJson(Map<String, dynamic> json) {
    return ChecklistSchema(
      rootFields: (json['rootFields'] as List?)
              ?.map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      objects: (json['objects'] as List?)
              ?.map((e) => SchemaObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tables: (json['tables'] as List?)
              ?.map((e) => SchemaTable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summaries: (json['summaries'] as List?)
              ?.map((e) => SchemaSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groupedFields: (json['groupedFields'] as List?)
              ?.map((e) =>
                  GroupedFieldGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cellMappings: (json['cellMappings'] as List?)
              ?.map((e) => CellMapping.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SchemaField {
  final String key;
  final String? label;
  final String type; // text, radio, checkbox, select, number, datetime, image, signature
  final List<String>? options;
  final FieldCondition? condition;
  final bool? suffixLabel;
  final int? row;
  final int? col;

  SchemaField({
    required this.key,
    this.label,
    required this.type,
    this.options,
    this.condition,
    this.suffixLabel,
    this.row,
    this.col,
  });

  factory SchemaField.fromJson(Map<String, dynamic> json) {
    return SchemaField(
      key: json['key'] as String,
      label: json['label'] as String?,
      type: json['type'] as String,
      options:
          (json['options'] as List?)?.map((e) => e as String).toList(),
      condition: json['condition'] != null
          ? FieldCondition.fromJson(json['condition'] as Map<String, dynamic>)
          : null,
      suffixLabel: json['suffixLabel'] as bool?,
      row: json['row'] as int?,
      col: json['col'] as int?,
    );
  }
}

class GroupedFieldGroup {
  final String groupKey;
  final List<SchemaField> fields;

  GroupedFieldGroup({required this.groupKey, this.fields = const []});

  factory GroupedFieldGroup.fromJson(Map<String, dynamic> json) {
    return GroupedFieldGroup(
      groupKey: json['groupKey'] as String,
      fields: (json['fields'] as List?)
              ?.map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SchemaObject {
  final String key;
  final String? label;
  final String type;
  final List<SchemaItem> items;
  final int? row;
  final int? col;

  SchemaObject({
    required this.key,
    this.label,
    this.type = 'object',
    this.items = const [],
    this.row,
    this.col,
  });

  factory SchemaObject.fromJson(Map<String, dynamic> json) {
    return SchemaObject(
      key: json['key'] as String,
      label: json['label'] as String?,
      type: json['type'] as String? ?? 'object',
      items: (json['items'] as List?)
              ?.map((e) => SchemaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      row: json['row'] as int?,
      col: json['col'] as int?,
    );
  }
}

class SchemaItem {
  final String key;
  final String? label;
  final List<SchemaField> fields;
  final int? row;
  final int? col;

  SchemaItem({
    required this.key,
    this.label,
    this.fields = const [],
    this.row,
    this.col,
  });

  factory SchemaItem.fromJson(Map<String, dynamic> json) {
    return SchemaItem(
      key: json['key'] as String,
      label: json['label'] as String?,
      fields: (json['fields'] as List?)
              ?.map((e) => SchemaField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      row: json['row'] as int?,
      col: json['col'] as int?,
    );
  }
}

class SchemaTable {
  final String key;
  final String? label;
  final String type;
  final List<TableColumn> columns;
  final int? row;
  final int? col;

  SchemaTable({
    required this.key,
    this.label,
    this.type = 'table',
    this.columns = const [],
    this.row,
    this.col,
  });

  factory SchemaTable.fromJson(Map<String, dynamic> json) {
    return SchemaTable(
      key: json['key'] as String,
      label: json['label'] as String?,
      type: json['type'] as String? ?? 'table',
      columns: (json['columns'] as List?)
              ?.map((e) => TableColumn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      row: json['row'] as int?,
      col: json['col'] as int?,
    );
  }
}

class TableColumn {
  final String key;
  final String? label;
  final String type; // text, number, formula, datetime, date
  final String? formula;
  final int? row;
  final int? col;

  TableColumn({
    required this.key,
    this.label,
    required this.type,
    this.formula,
    this.row,
    this.col,
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      key: json['key'] as String,
      label: json['label'] as String?,
      type: json['type'] as String,
      formula: json['formula'] as String?,
      row: json['row'] as int?,
      col: json['col'] as int?,
    );
  }
}

class SchemaSummary {
  final String key;
  final String? label;
  final String type;
  final String formula;

  SchemaSummary({
    required this.key,
    this.label,
    this.type = 'formula',
    required this.formula,
  });

  factory SchemaSummary.fromJson(Map<String, dynamic> json) {
    return SchemaSummary(
      key: json['key'] as String,
      label: json['label'] as String?,
      type: json['type'] as String? ?? 'formula',
      formula: json['formula'] as String,
    );
  }
}

class FieldCondition {
  final String type; // and, or
  final List<String> values;

  FieldCondition({required this.type, this.values = const []});

  factory FieldCondition.fromJson(Map<String, dynamic> json) {
    return FieldCondition(
      type: json['type'] as String,
      values:
          (json['values'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class CellMapping {
  final String type;
  final String? key;
  final String? objectKey;
  final String? itemKey;
  final String? groupKey;
  final int row;
  final int col;

  CellMapping({
    required this.type,
    this.key,
    this.objectKey,
    this.itemKey,
    this.groupKey,
    required this.row,
    required this.col,
  });

  factory CellMapping.fromJson(Map<String, dynamic> json) {
    return CellMapping(
      type: json['type'] as String? ?? '',
      key: json['key'] as String?,
      objectKey: json['objectKey'] as String?,
      itemKey: json['itemKey'] as String?,
      groupKey: json['groupKey'] as String?,
      row: json['row'] as int? ?? 0,
      col: json['col'] as int? ?? 0,
    );
  }
}
