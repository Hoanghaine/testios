import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checklist_management/core/config/app_config.dart';
import 'package:checklist_management/core/services/api_client.dart';
import 'package:checklist_management/features/checklist/data/models/checklist_models.dart';

final checklistRepositoryProvider = Provider<ChecklistRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChecklistRepository(apiClient);
});

class ChecklistRepository {
  final ApiClient _api;

  ChecklistRepository(this._api);

  // === Template APIs ===

  Future<PagedResponse<ChecklistTemplate>> getTemplates({
    int page = 0,
    int size = 10,
    String? search,
  }) async {
    final resp = await _api.get(
      AppConfig.templatesEndpoint,
      queryParameters: {
        'page': page,
        'size': size,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: (json) =>
          PagedResponse.fromJson(json, ChecklistTemplate.fromJson),
    );
    return resp.data;
  }

  Future<TemplateDetail> getTemplateDetail(String id) async {
    final resp = await _api.get(
      '${AppConfig.templatesEndpoint}/$id',
      fromJson: (json) => TemplateDetail.fromJson(json),
    );
    return resp.data;
  }

  Future<ChecklistTemplate> createTemplate(FormData formData) async {
    final resp = await _api.postFormData(
      AppConfig.templatesEndpoint,
      formData: formData,
      fromJson: (json) => ChecklistTemplate.fromJson(json),
    );
    return resp.data;
  }

  Future<ChecklistTemplate> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await _api.put(
      '${AppConfig.templatesEndpoint}/$id',
      data: data,
      fromJson: (json) => ChecklistTemplate.fromJson(json),
    );
    return resp.data;
  }

  Future<void> deleteTemplate(String id) async {
    await _api.delete('${AppConfig.templatesEndpoint}/$id');
  }

  // === Version APIs ===

  Future<List<TemplateVersion>> getVersionHistory(String templateId) async {
    final resp = await _api.get(
      '${AppConfig.templatesEndpoint}/$templateId/versions',
      fromJson: (json) => (json as List)
          .map((e) => TemplateVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return resp.data;
  }

  Future<TemplateVersion> uploadNewVersion(
    String templateId,
    FormData formData,
  ) async {
    final resp = await _api.postFormData(
      '${AppConfig.templatesEndpoint}/$templateId/versions',
      formData: formData,
      fromJson: (json) => TemplateVersion.fromJson(json),
    );
    return resp.data;
  }

  Future<String> getOriginalFileDownloadUrl(
    String templateId,
    int version,
  ) async {
    final resp = await _api.get(
      '${AppConfig.templatesEndpoint}/$templateId/versions/$version/download',
      fromJson: (json) => json['downloadUrl'] as String,
    );
    return resp.data;
  }
}
