import 'vocabulary_dto.dart';
import 'json_value.dart';

class SlokaDto {
  const SlokaDto({
    required this.id,
    required this.name,
    required this.text,
    required this.transcription,
    required this.translation,
    required this.comment,
    required this.order,
    required this.audio,
    required this.audioSanskrit,
    required this.vocabularies,
  });

  final int id;
  final String? name;
  final String? text;
  final String? transcription;
  final String? translation;
  final String? comment;
  final int? order;
  final String? audio;
  final String? audioSanskrit;
  final List<VocabularyDto> vocabularies;

  factory SlokaDto.fromJson(Map<String, Object?> json) {
    final vocabJson = asObjectList(json['vocabularies']);
    return SlokaDto(
      id: asInt(json['id']) ?? 0,
      name: asString(json['name']),
      text: asString(json['text']),
      transcription: asString(json['transcription']),
      translation: asString(json['translation']),
      comment: asString(json['comment']),
      order: asInt(json['order']),
      audio: asString(json['audio']),
      audioSanskrit: asString(json['audioSanskrit']),
      vocabularies: vocabJson
          .map(VocabularyDto.fromJson)
          .toList(growable: false),
    );
  }
}
