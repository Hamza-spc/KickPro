import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/timeline_repository.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class ProfileTimelineTab extends ConsumerWidget {
  const ProfileTimelineTab({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(playerTimelineProvider(profileId));

    return timelineAsync.when(
      loading: () => const ShimmerBox(height: 160, width: double.infinity),
      error: (e, _) => Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
      data: (events) {
        if (events.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(ref.tr.noTimelineEvents, style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        return Column(
          children: events.map((event) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(event.icon, color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: const TextStyle(color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
