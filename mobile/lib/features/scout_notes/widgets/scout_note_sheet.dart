import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/scout_notes/data/scout_note_repository.dart';
import 'package:kickpro/features/scout_notes/models/scout_note_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

Future<void> showScoutNoteSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int profileId,
  required String playerName,
}) async {
  final existing = await ref.read(scoutNoteRepositoryProvider).getNote(profileId);
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _ScoutNoteSheet(
      ref: ref,
      profileId: profileId,
      playerName: playerName,
      existing: existing,
    ),
  );
}

class _ScoutNoteSheet extends ConsumerStatefulWidget {
  const _ScoutNoteSheet({
    required this.ref,
    required this.profileId,
    required this.playerName,
    required this.existing,
  });

  final WidgetRef ref;
  final int profileId;
  final String playerName;
  final ScoutNote? existing;

  @override
  ConsumerState<_ScoutNoteSheet> createState() => _ScoutNoteSheetState();
}

class _ScoutNoteSheetState extends ConsumerState<_ScoutNoteSheet> {
  late final TextEditingController _technicalCtrl;
  late final TextEditingController _potentialCtrl;
  late final TextEditingController _noteCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _technicalCtrl = TextEditingController(text: '${widget.existing?.technicalAbility ?? 3}');
    _potentialCtrl = TextEditingController(text: '${widget.existing?.potential ?? 3}');
    _noteCtrl = TextEditingController(text: widget.existing?.note ?? '');
  }

  @override
  void dispose() {
    _technicalCtrl.dispose();
    _potentialCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final technical = int.tryParse(_technicalCtrl.text.trim());
    final potential = int.tryParse(_potentialCtrl.text.trim());
    final note = _noteCtrl.text.trim();
    if (technical == null ||
        technical < 1 ||
        technical > 5 ||
        potential == null ||
        potential < 1 ||
        potential > 5 ||
        note.isEmpty) {
      showKickproToast(context, ref.tr.scoutNoteInvalid, isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(scoutNoteRepositoryProvider).saveNote(
            profileId: widget.profileId,
            technicalAbility: technical,
            potential: potential,
            note: note,
            exists: widget.existing != null,
          );
      ref.invalidate(scoutNoteProvider(widget.profileId));
      if (mounted) {
        Navigator.pop(context);
        showKickproToast(context, ref.tr.scoutNoteSaved);
      }
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (widget.existing == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(scoutNoteRepositoryProvider).deleteNote(widget.profileId);
      ref.invalidate(scoutNoteProvider(widget.profileId));
      if (mounted) {
        Navigator.pop(context);
        showKickproToast(context, ref.tr.scoutNoteDeleted);
      }
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.tr.scoutNotesTitle(widget.playerName),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _RatingField(label: ref.tr.technicalAbility, controller: _technicalCtrl),
            const SizedBox(height: 12),
            _RatingField(label: ref.tr.potential, controller: _potentialCtrl),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: ref.tr.scoutNoteLabel,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            KickproButton(label: ref.tr.saveNote, isLoading: _saving, onPressed: _save),
            if (widget.existing != null) ...[
              const SizedBox(height: 8),
              KickproButton(
                label: ref.tr.deleteNote,
                variant: KickproButtonVariant.ghost,
                isLoading: _saving,
                onPressed: _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingField extends StatelessWidget {
  const _RatingField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: '1-5',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
