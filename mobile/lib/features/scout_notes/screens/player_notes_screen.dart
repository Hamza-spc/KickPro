import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/scout_notes/data/player_notes_repository.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_empty_state.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class PlayerNotesScreen extends ConsumerWidget {
  const PlayerNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(myPlayerNotesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myPlayerNotesProvider),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          ref.tr.privateNotes,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              notesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 120, width: double.infinity),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                    ),
                  ),
                ),
                data: (notes) {
                  if (notes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: KickproEmptyState(
                        icon: Icons.note_alt_outlined,
                        message: ref.tr.noNotesYet,
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final n = notes[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, color: AppColors.accent, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      n.scoutName.isNotEmpty ? n.scoutName : n.scoutEmail,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${n.updatedAt.day}/${n.updatedAt.month}/${n.updatedAt.year}',
                                    style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _Chip(label: '${ref.tr.technicalAbility}: ${n.technicalAbility}/5'),
                                  const SizedBox(width: 8),
                                  _Chip(label: '${ref.tr.potential}: ${n.potential}/5'),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(n.note, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: KickproButton(
                                  label: ref.tr.sendMessage,
                                  onPressed: () => context.push(
                                    '/messages/chat/${n.scoutUserId}?label=${Uri.encodeComponent(n.scoutName.isNotEmpty ? n.scoutName : n.scoutEmail)}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

