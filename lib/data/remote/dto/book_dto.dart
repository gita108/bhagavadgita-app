import 'json_value.dart';

class BookDto {
  const BookDto({
    required this.id,
    required this.languageId,
    required this.name,
    required this.initials,
    required this.chaptersCount,
  });

  final int id;
  final int languageId;
  final String? name;
  final String? initials;
  final int? chaptersCount;

  factory BookDto.fromJson(Map<String, Object?> json) {
    return BookDto(
      id: asInt(json['id']) ?? 0,
      languageId: asInt(json['languageId']) ?? 0,
      name: asString(json['name']),
      initials: asString(json['initials']),
      chaptersCount: asInt(json['chaptersCount']),
    );
  }
}
