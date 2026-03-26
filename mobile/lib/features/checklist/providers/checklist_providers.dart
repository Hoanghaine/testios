import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checklist_management/features/checklist/data/models/checklist_models.dart';
import 'package:checklist_management/features/checklist/data/models/record_models.dart';
import 'package:checklist_management/features/checklist/data/repositories/checklist_repository.dart';
import 'package:checklist_management/features/checklist/data/repositories/record_repository.dart';
import 'package:checklist_management/core/services/api_client.dart';

// === Template Providers ===

final templateListProvider = FutureProvider.family<
    PagedResponse<ChecklistTemplate>,
    ({int page, int size, String? search})>((ref, params) async {
  final repo = ref.watch(checklistRepositoryProvider);
  return repo.getTemplates(
    page: params.page,
    size: params.size,
    search: params.search,
  );
});

final templateDetailProvider =
    FutureProvider.family<TemplateDetail, String>((ref, id) async {
  final repo = ref.watch(checklistRepositoryProvider);
  return repo.getTemplateDetail(id);
});

final versionHistoryProvider =
    FutureProvider.family<List<TemplateVersion>, String>((ref, templateId) async {
  final repo = ref.watch(checklistRepositoryProvider);
  return repo.getVersionHistory(templateId);
});

// === Record Providers ===

final recordListProvider = FutureProvider.family<
    PagedResponse<ChecklistRecord>,
    ({int page, int size, String? templateId, String? schoolId})>(
    (ref, params) async {
  final repo = ref.watch(recordRepositoryProvider);
  return repo.getRecords(
    page: params.page,
    size: params.size,
    templateId: params.templateId,
    schoolId: params.schoolId,
  );
});

final recordDetailProvider =
    FutureProvider.family<ChecklistRecord, String>((ref, id) async {
  final repo = ref.watch(recordRepositoryProvider);
  return repo.getRecordDetail(id);
});

// === School Providers ===

final schoolListProvider = FutureProvider<List<School>>((ref) async {
  final repo = ref.watch(schoolRepositoryProvider);
  return repo.getSchools();
});

// === State Notifier for Template List Actions ===

class TemplateListNotifier extends StateNotifier<AsyncValue<void>> {
  final ChecklistRepository _repo;
  final Ref _ref;

  TemplateListNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<bool> createTemplate(FormData formData) async {
    state = const AsyncLoading();
    try {
      await _repo.createTemplate(formData);
      _ref.invalidate(templateListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateTemplate(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repo.updateTemplate(id, data);
      _ref.invalidate(templateListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteTemplate(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.deleteTemplate(id);
      _ref.invalidate(templateListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> uploadNewVersion(String templateId, FormData formData) async {
    state = const AsyncLoading();
    try {
      await _repo.uploadNewVersion(templateId, formData);
      _ref.invalidate(versionHistoryProvider(templateId));
      _ref.invalidate(templateListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final templateActionsProvider =
    StateNotifierProvider<TemplateListNotifier, AsyncValue<void>>((ref) {
  return TemplateListNotifier(
    ref.watch(checklistRepositoryProvider),
    ref,
  );
});

// === State Notifier for Record Actions ===

class RecordActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final RecordRepository _repo;
  final Ref _ref;

  RecordActionsNotifier(this._repo, this._ref) : super(const AsyncData(null));

  Future<bool> createRecord(RecordCreateReq req) async {
    state = const AsyncLoading();
    try {
      await _repo.createRecord(req);
      _ref.invalidate(recordListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> updateRecord(String id, RecordUpdateReq req) async {
    state = const AsyncLoading();
    try {
      await _repo.updateRecord(id, req);
      _ref.invalidate(recordListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.deleteRecord(id);
      _ref.invalidate(recordListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> exportRecord(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.exportRecord(id);
      _ref.invalidate(recordListProvider);
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final recordActionsProvider =
    StateNotifierProvider<RecordActionsNotifier, AsyncValue<void>>((ref) {
  return RecordActionsNotifier(
    ref.watch(recordRepositoryProvider),
    ref,
  );
});
