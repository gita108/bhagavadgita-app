import 'json_value.dart';

class QuoteDto {
  const QuoteDto({required this.author, required this.text});

  final String? author;
  final String? text;

  factory QuoteDto.fromJson(Map<String, Object?> json) {
    return QuoteDto(
      author: asString(json['author']),
      text: asString(json['text']),
    );
  }
}
