import 'json_value.dart';

class LanguageDto {
  const LanguageDto({required this.id, required this.name, required this.code});

  final int id;
  final String? name;
  final String? code;

  factory LanguageDto.fromJson(Map<String, Object?> json) {
    return LanguageDto(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']),
      code: asString(json['code']),
    );
  }
}
