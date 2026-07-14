import 'models.dart';

/// Sample content for layout work. Real content lives in the Drift snapshot.
class MockContent {
  MockContent._();

  static final List<AppLanguage> languages = const [
    AppLanguage('en', 'English', 'English'),
    AppLanguage('ru', 'Russian', 'Русский'),
    AppLanguage('hi', 'Hindi', 'हिंदी'),
    AppLanguage('es', 'Spanish', 'Español'),
    AppLanguage('de', 'German', 'Deutsch'),
    AppLanguage('fr', 'French', 'Français'),
  ];

  static const quoteOfTheDay =
      'You have a right to perform your prescribed duties, '
      'but you are not entitled to the fruits of your actions.';
  static const quoteAuthor = 'Bhagavad Gita 2.47';

  static final List<Chapter> chapters = _buildChapters();

  static List<Chapter> _buildChapters() {
    final names = const <List<String>>[
      ['Arjuna Vishada Yoga', "Arjuna's Despair"],
      ['Sankhya Yoga', 'The Yoga of Knowledge'],
      ['Karma Yoga', 'The Yoga of Action'],
      ['Jnana Karma Sanyasa Yoga', 'Knowledge & Renunciation'],
      ['Karma Sanyasa Yoga', 'Renunciation of Action'],
      ['Dhyana Yoga', 'The Yoga of Meditation'],
      ['Jnana Vijnana Yoga', 'Knowledge & Wisdom'],
      ['Akshara Brahma Yoga', 'The Imperishable Brahman'],
      ['Raja Vidya Yoga', 'Royal Knowledge'],
      ['Vibhuti Yoga', 'Divine Manifestations'],
      ['Vishvarupa Darshana Yoga', 'The Universal Form'],
      ['Bhakti Yoga', 'The Path of Devotion'],
      ['Kshetra Kshetrajna Yoga', 'Field & Knower'],
      ['Gunatraya Vibhaga Yoga', 'The Three Modes'],
      ['Purushottama Yoga', 'The Supreme Person'],
      ['Daivasura Sampad Yoga', 'Divine & Demonic'],
      ['Shraddhatraya Vibhaga Yoga', 'Threefold Faith'],
      ['Moksha Sanyasa Yoga', 'Liberation & Renunciation'],
    ];

    final slokaCounts = const [
      47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78,
    ];

    final chapters = <Chapter>[];
    var idCounter = 1;

    for (var i = 0; i < names.length; i++) {
      final position = i + 1;
      final slokas = <Sloka>[];
      for (var j = 1; j <= slokaCounts[i]; j++) {
        slokas.add(Sloka(
          id: idCounter++,
          chapterId: position,
          position: j,
          name: '$position.$j',
          sanskrit: position == 2 && j == 47
              ? 'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।\n'
                  'मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥'
              : 'श्रीभगवानुवाच।\nयोगस्थः कुरु कर्माणि सङ्गं त्यक्त्वा धनञ्जय।',
          transcription: position == 2 && j == 47
              ? 'karmaṇyevādhikāraste mā phaleṣu kadācana \n'
                  'mā karma-phala-hetur bhūr mā te saṅgo \'stv akarmaṇi'
              : 'yoga-sthaḥ kuru karmāṇi saṅgaṁ tyaktvā dhanañjaya',
          translation: position == 2 && j == 47
              ? 'You have a right to perform your prescribed duties, but you are '
                  'not entitled to the fruits of your actions. Never consider '
                  'yourself to be the cause of the results, nor be attached to inaction.'
              : 'Perform action, O Dhananjaya, established in yoga, having '
                  'abandoned attachment, balanced in success and failure.',
          vocabulary: position == 2 && j == 47
              ? const [
                  VocabEntry('karmaṇi', 'in prescribed duty'),
                  VocabEntry('eva', 'certainly'),
                  VocabEntry('adhikāraḥ', 'right'),
                  VocabEntry('te', 'your'),
                  VocabEntry('mā', 'never'),
                  VocabEntry('phaleṣu', 'in the fruits'),
                  VocabEntry('kadācana', 'at any time'),
                ]
              : const [
                  VocabEntry('yoga-sthaḥ', 'steady in yoga'),
                  VocabEntry('kuru', 'perform'),
                  VocabEntry('karmāṇi', 'duties'),
                  VocabEntry('saṅgam', 'attachment'),
                  VocabEntry('tyaktvā', 'having given up'),
                ],
          commentaries: position == 2 && j == 47
              ? const [
                  Commentary(
                    initials: 'SP',
                    author: 'Srila Prabhupada',
                    text:
                        'This verse establishes the principle of niṣkāma karma — '
                        'action without attachment to its fruit. One who works '
                        'without selfish motive while remaining absorbed in '
                        'devotion attains the supreme goal.',
                  ),
                  Commentary(
                    initials: 'BG',
                    author: 'Bhaktivedanta',
                    text:
                        'The essence of karma yoga is that the doer should '
                        'perform their duty as worship, surrendering all results '
                        'to the Supreme without expectation.',
                  ),
                ]
              : const [
                  Commentary(
                    initials: 'SP',
                    author: 'Srila Prabhupada',
                    text:
                        'Equanimity in success and failure is the mark of a '
                        'soul established in yoga.',
                  ),
                ],
        ));
      }
      chapters.add(Chapter(
        id: position,
        position: position,
        name: 'Chapter $position',
        subtitle: '${names[i][0]} · ${names[i][1]}',
        slokas: slokas,
      ));
    }
    return chapters;
  }

  static Sloka? findSloka(int chapterId, int position) {
    final chapter = chapters.firstWhere(
      (c) => c.id == chapterId,
      orElse: () => chapters.first,
    );
    if (position < 1 || position > chapter.slokas.length) return null;
    return chapter.slokas[position - 1];
  }
}
