import 'json_value.dart';

class VocabularyDto {
  const VocabularyDto({
    required this.id,
    required this.text,
    required this.translation,
  });

  final int id;
  final String? text;
  final String? translation;

  factory VocabularyDto.fromJson(Map<String, Object?> json) {
    return VocabularyDto(
      id: asInt(json['id']) ?? 0,
      text: asString(json['text']),
      translation: asString(json['translation']),
    );
  }
}
