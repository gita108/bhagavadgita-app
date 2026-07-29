import 'sloka_dto.dart';
import 'json_value.dart';

class ChapterDto {
  const ChapterDto({
    required this.id,
    required this.name,
    required this.order,
    required this.slokas,
  });

  final int id;
  final String? name;
  final int? order;
  final List<SlokaDto> slokas;

  factory ChapterDto.fromJson(Map<String, Object?> json) {
    final slokaJson = asObjectList(json['shlokas']);
    return ChapterDto(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']),
      order: asInt(json['order']),
      slokas: slokaJson.map(SlokaDto.fromJson).toList(growable: false),
    );
  }
}
