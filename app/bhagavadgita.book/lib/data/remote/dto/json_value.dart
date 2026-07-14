int? asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? asString(Object? value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

List<Map<String, Object?>> asObjectList(Object? value) {
  if (value is! List) return const <Map<String, Object?>>[];
  final items = <Map<String, Object?>>[];
  for (final entry in value) {
    if (entry is Map) {
      items.add(entry.cast<String, Object?>());
    }
  }
  return items;
}
