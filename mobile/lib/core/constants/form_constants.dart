class FormConstants {
  FormConstants._();

  /// Fields auto-filled on submit, hidden from form UI
  static const hiddenAutoFillFields = {'ten_bep', 'thoi_gian'};

  /// Key for school/kitchen name — auto-filled from school selector
  static const fieldKeySchoolName = 'ten_bep';

  /// Key for datetime — auto-filled with DateTime.now() on submit
  static const fieldKeyDateTime = 'thoi_gian';

  /// Label overrides for generic field keys
  static const labelOverrides = {
    'note': 'Ghi chú',
    'evidence': 'Hình ảnh minh chứng',
  };
}
