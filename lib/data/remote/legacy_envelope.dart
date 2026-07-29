class LegacyEnvelope<T> {
  const LegacyEnvelope({
    required this.code,
    required this.data,
    required this.message,
  });

  final int code;
  final T data;
  final String? message;

  static LegacyEnvelope<T> fromJson<T>(
    Map<String, Object?> json, {
    required T Function(Object? dataJson) parseData,
  }) {
    return LegacyEnvelope<T>(
      code: (json['code'] as num?)?.toInt() ?? -1,
      data: parseData(json['data']),
      message: _asMessage(json['message']),
    );
  }

  bool get isOk => code == 0;
}

String? _asMessage(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}
