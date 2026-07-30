import 'package:flutter/material.dart';

import '../../data/local/user_data_repository.dart';
import '../../l10n/l10n.dart';
import '../../ui/theme/app_colors.dart';
import '../../ui/theme/app_spacing.dart';
import '../../ui/theme/app_text.dart';

/// Full-screen note/comment editor for a single verse. Reuses the same
/// [UserDataRepository.watchNote]/[saveNote] API the reader screen already
/// used inline — this screen just gives it a dedicated place, matching
/// legacy's separate Note screen (reached via the comment icon).
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key, required this.userData, required this.slokaId});

  final UserDataRepository userData;
  final int slokaId;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loaded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _seedFromExisting(String? note) {
    if (_loaded) return;
    _loaded = true;
    _controller.text = note ?? '';
    _controller.selection = const TextSelection.collapsed(offset: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _save() async {
    await widget.userData.saveNote(widget.slokaId, _controller.text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.noteTitle, style: AppText.navTitle()),
        actions: [
          TextButton(
            onPressed: _save,
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            child: Text(l10n.save),
          ),
        ],
      ),
      body: StreamBuilder<String?>(
        stream: widget.userData.watchNote(widget.slokaId),
        builder: (context, snap) {
          _seedFromExisting(snap.data);
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.space5,
              AppSpacing.gutter,
              AppSpacing.gutter,
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppText.body(),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
