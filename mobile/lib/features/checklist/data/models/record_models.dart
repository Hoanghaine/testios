import 'package:checklist_management/features/checklist/data/models/checklist_models.dart';

class ChecklistRecord {
  final String id;
  final String templateId;
  final String? templateName;
  final String? templateVersionId;
  final int? templateVersion;
  final String? schoolId;
  final String? schoolName;
  final Map<String, dynamic> data;
  final ChecklistSchema? schemaData;
  final String? exportedFileS3Key;
  final String status; // DRAFT, COMPLETED, EXPORTED
  final String? note;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;

  ChecklistRecord({
    required this.id,
    required this.templateId,
    this.templateName,
    this.templateVersionId,
    this.templateVersion,
    this.schoolId,
    this.schoolName,
    required this.data,
    this.schemaData,
    this.exportedFileS3Key,
    required this.status,
    this.note,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
  });

  factory ChecklistRecord.fromJson(Map<String, dynamic> json) {
    return ChecklistRecord(
      id: json['id'] as String,
      templateId: json['templateId'] as String,
      templateName: json['templateName'] as String?,
      templateVersionId: json['templateVersionId'] as String?,
      templateVersion: json['templateVersion'] as int?,
      schoolId: json['schoolId'] as String?,
      schoolName: json['schoolName'] as String?,
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      schemaData: json['schemaData'] != null
          ? ChecklistSchema.fromJson(json['schemaData'] as Map<String, dynamic>)
          : null,
      exportedFileS3Key: json['exportedFileS3Key'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      note: json['note'] as String?,
      createdAt: parseDate(json['createdAt']),
      createdBy: json['createdBy'] as String?,
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

class RecordCreateReq {
  final String templateId;
  final String? templateVersionId;
  final String? schoolId;
  final Map<String, dynamic> data;
  final String? note;

  RecordCreateReq({
    required this.templateId,
    this.templateVersionId,
    this.schoolId,
    required this.data,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        if (templateVersionId != null) 'templateVersionId': templateVersionId,
        if (schoolId != null) 'schoolId': schoolId,
        'data': data,
        if (note != null) 'note': note,
      };
}

class RecordUpdateReq {
  final String? schoolId;
  final Map<String, dynamic>? data;
  final String? note;
  final String? status;

  RecordUpdateReq({this.schoolId, this.data, this.note, this.status});

  Map<String, dynamic> toJson() => {
        if (schoolId != null) 'schoolId': schoolId,
        if (data != null) 'data': data,
        if (note != null) 'note': note,
        if (status != null) 'status': status,
      };
}

class School {
  final String id;
  final String? code;
  final String name;
  final String? address;
  final String? keyImage;
  final String? createdAt;

  School({
    required this.id,
    this.code,
    required this.name,
    this.address,
    this.keyImage,
    this.createdAt,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      code: json['code'] as String?,
      name: json['name'] as String,
      address: json['address'] as String?,
      keyImage: json['keyImage'] as String?,
      createdAt: parseDate(json['createdAt']),
    );
  }
}

