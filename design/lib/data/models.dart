// In-memory mock model layer.
//
// This mirrors the Drift schema in shape but stays in-memory so the layout
// preview can run without the seed/database stack. Real wiring should
// replace these with the existing Drift-backed repositories.

class Chapter {
  Chapter({
    required this.id,
    required this.position,
    required this.name,
    required this.subtitle,
    required this.slokas,
  });

  final int id;
  final int position;
  final String name;
  final String subtitle;
  final List<Sloka> slokas;
}

class Sloka {
  Sloka({
    required this.id,
    required this.chapterId,
    required this.position,
    required this.name,
    required this.sanskrit,
    required this.transcription,
    required this.translation,
    required this.vocabulary,
    required this.commentaries,
  });

  final int id;
  final int chapterId;
  final int position;
  final String name;
  final String sanskrit;
  final String transcription;
  final String translation;
  final List<VocabEntry> vocabulary;
  final List<Commentary> commentaries;
}

class VocabEntry {
  VocabEntry(this.token, this.meaning);
  final String token;
  final String meaning;
}

class Commentary {
  Commentary({
    required this.initials,
    required this.author,
    required this.text,
  });

  final String initials;
  final String author;
  final String text;
}

class AppLanguage {
  const AppLanguage(this.code, this.name, this.native);
  final String code;
  final String name;
  final String native;
}
