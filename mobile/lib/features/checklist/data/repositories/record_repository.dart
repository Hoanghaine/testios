import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checklist_management/core/config/app_config.dart';
import 'package:checklist_management/core/services/api_client.dart';
import 'package:checklist_management/features/checklist/data/models/record_models.dart';

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecordRepository(apiClient);
});

class RecordRepository {
  final ApiClient _api;

  RecordRepository(this._api);

  Future<PagedResponse<ChecklistRecord>> getRecords({
    int page = 0,
    int size = 10,
    String? templateId,
    String? schoolId,
  }) async {
    final resp = await _api.get(
      AppConfig.recordsEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
        if (templateId != null) 'templateId': templateId,
        if (schoolId != null) 'schoolId': schoolId,
      },
      fromJson: (json) =>
          PagedResponse.fromJson(json, ChecklistRecord.fromJson),
    );
    return resp.data;
  }

  Future<ChecklistRecord> getRecordDetail(String id) async {
    final resp = await _api.get(
      '${AppConfig.recordsEndpoint}/$id',
      fromJson: (json) => ChecklistRecord.fromJson(json),
    );
    return resp.data;
  }

  Future<ChecklistRecord> createRecord(RecordCreateReq req) async {
    final resp = await _api.post(
      AppConfig.recordsEndpoint,
      data: req.toJson(),
      fromJson: (json) => ChecklistRecord.fromJson(json),
    );
    return resp.data;
  }

  Future<ChecklistRecord> updateRecord(String id, RecordUpdateReq req) async {
    final resp = await _api.put(
      '${AppConfig.recordsEndpoint}/$id',
      data: req.toJson(),
      fromJson: (json) => ChecklistRecord.fromJson(json),
    );
    return resp.data;
  }

  Future<void> deleteRecord(String id) async {
    await _api.delete('${AppConfig.recordsEndpoint}/$id');
  }

  Future<ChecklistRecord> exportRecord(String id) async {
    final resp = await _api.post(
      '${AppConfig.recordsEndpoint}/$id/export',
      fromJson: (json) => ChecklistRecord.fromJson(json),
    );
    return resp.data;
  }

  Future<String> getRecordDownloadUrl(String id) async {
    final resp = await _api.get(
      '${AppConfig.recordsEndpoint}/$id/download',
      fromJson: (json) => json['downloadUrl'] as String,
    );
    return resp.data;
  }
}

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SchoolRepository(apiClient);
});

class SchoolRepository {
  final ApiClient _api;

  SchoolRepository(this._api);

  Future<List<School>> getSchools() async {
    final resp = await _api.get(
      AppConfig.schoolsEndpoint,
      fromJson: (json) => (json as List)
          .map((e) => School.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return resp.data;
  }
}
