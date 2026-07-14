import 'package:flutter/material.dart';

import '../../data/mock_content.dart';
import '../../data/models.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_text.dart';
import '../reader/sloka_screen.dart';

enum SearchScope { all, bookmarks }

/// Search screen with circular reveal entrance animation (Material Design).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.center});
  final Offset center;

  /// Pushes [SearchScreen] with a fade + circular reveal transition.
  static void open(BuildContext context, {Offset? from}) {
    final overlay = Overlay.of(context);
    final box = overlay.context.findRenderObject() as RenderBox;
    final origin = from ?? box.size.topRight(Offset.zero) - const Offset(40, -28);

    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) => SearchScreen(center: origin),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (ctx, anim, _, child) {
        return _CircularReveal(
          progress: anim,
          center: origin,
          child: child,
        );
      },
    ));
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController(text: 'karma');
  final _focus = FocusNode();
  SearchScope _scope = SearchScope.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<Sloka> _results() {
    final q = _ctrl.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <Sloka>[];
    for (final c in MockContent.chapters) {
      for (final s in c.slokas) {
        if (s.transcription.toLowerCase().contains(q) ||
            s.translation.toLowerCase().contains(q)) {
          out.add(s);
          if (out.length >= 30) return out;
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final results = _results();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          style: AppText.body(),
          decoration: const InputDecoration(
            hintText: 'Search slokas…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cancel, color: AppColors.gray2),
              onPressed: () => setState(() => _ctrl.clear()),
            ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Text('Scope:',
                    style: AppText.caption().copyWith(color: AppColors.gray1)),
                const SizedBox(width: 12),
                _ScopeChip(
                  label: 'All',
                  selected: _scope == SearchScope.all,
                  onTap: () => setState(() => _scope = SearchScope.all),
                ),
                const SizedBox(width: 8),
                _ScopeChip(
                  label: 'Bookmarks',
                  selected: _scope == SearchScope.bookmarks,
                  onTap: () => setState(() => _scope = SearchScope.bookmarks),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: AppColors.black20.withValues(alpha: 0.04)),
            ),
          ),
          if (_ctrl.text.isEmpty)
            const _SearchEmpty()
          else if (results.isEmpty)
            const _NoResults()
          else
            ListView.builder(
              itemCount: results.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                    child: Text(
                      'Found ${results.length} result${results.length == 1 ? '' : 's'}',
                      style: AppText.caption(),
                    ),
                  );
                }
                final s = results[i - 1];
                return _ResultRow(sloka: s, query: _ctrl.text);
              },
            ),
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.red1 : AppColors.gray5,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.red1 : AppColors.gray3,
          ),
        ),
        child: Text(
          label,
          style: AppText.caption().copyWith(
            color: selected ? AppColors.white : AppColors.gray1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.sloka, required this.query});
  final Sloka sloka;
  final String query;

  @override
  Widget build(BuildContext context) {
    final chapter = MockContent.chapters[sloka.chapterId - 1];
    return InkWell(
      onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => SlokaScreen(slokaId: sloka.id),
      )),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray4)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(sloka.name,
                  style: AppText.label().copyWith(
                    color: AppColors.red1,
                    fontSize: 14,
                  )),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Highlighted(
                    text: sloka.translation,
                    query: query,
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 4),
                  Text('${chapter.name} · ${chapter.subtitle.split(' · ').first}',
                      style: AppText.caption()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.gray3),
          ],
        ),
      ),
    );
  }
}

class _Highlighted extends StatelessWidget {
  const _Highlighted(
      {required this.text, required this.query, required this.style});
  final String text;
  final String query;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);
    }
    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    var i = 0;
    while (i < text.length) {
      final hit = lower.indexOf(q, i);
      if (hit < 0) {
        spans.add(TextSpan(text: text.substring(i)));
        break;
      }
      if (hit > i) spans.add(TextSpan(text: text.substring(i, hit)));
      spans.add(TextSpan(
        text: text.substring(hit, hit + q.length),
        style: style.copyWith(
          color: AppColors.red1,
          fontWeight: FontWeight.w700,
          backgroundColor: AppColors.red1.withValues(alpha: 0.1),
        ),
      ));
      i = hit + q.length;
    }
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style, children: spans),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/icn_empty.png', width: 60, height: 60),
          const SizedBox(height: 14),
          Text('Search 700+ slokas',
              style: AppText.heading().copyWith(color: AppColors.gray2)),
          const SizedBox(height: 6),
          Text('Try "karma", "yoga", "duty"…',
              style: AppText.caption()),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/icn_empty.png', width: 60, height: 60),
          const SizedBox(height: 14),
          Text('No results found',
              style: AppText.heading().copyWith(color: AppColors.gray2)),
          const SizedBox(height: 6),
          Text('Try different keywords', style: AppText.caption()),
        ],
      ),
    );
  }
}

/// Circular reveal transition — masks [child] with a circle that grows from
/// [center] to cover the screen as [progress] goes from 0 → 1.
class _CircularReveal extends StatelessWidget {
  const _CircularReveal({
    required this.progress,
    required this.center,
    required this.child,
  });
  final Animation<double> progress;
  final Offset center;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        // Max radius = distance from center to farthest corner.
        final dx = (center.dx > size.width / 2 ? center.dx : size.width - center.dx);
        final dy = (center.dy > size.height / 2 ? center.dy : size.height - center.dy);
        final maxRadius = (dx * dx + dy * dy);
        final r = progress.value *
            (maxRadius == 0 ? size.longestSide : maxRadius.clamp(1.0, double.infinity));
        return ClipPath(
          clipper: _CircleClipper(center: center, radius: r),
          child: child,
        );
      },
    );
  }
}

class _CircleClipper extends CustomClipper<Path> {
  _CircleClipper({required this.center, required this.radius});
  final Offset center;
  final double radius;
  @override
  Path getClip(Size size) {
    final r = radius < 1 ? 0.0 : radius;
    final actualRadius =
        r > size.longestSide * 1.5 ? size.longestSide * 1.5 : r;
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: actualRadius));
    return path;
  }

  @override
  bool shouldReclip(covariant _CircleClipper old) =>
      old.radius != radius || old.center != center;
}
