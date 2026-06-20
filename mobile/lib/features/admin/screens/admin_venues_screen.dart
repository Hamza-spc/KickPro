import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/widgets/admin_venue_form.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AdminVenuesScreen extends ConsumerWidget {
  const AdminVenuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(adminStadiumsProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(ref.tr.venues, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => showAdminVenueForm(context, ref),
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(adminStadiumsProvider),
              child: venuesAsync.when(
                loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
                error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
                data: (venues) => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: venues.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final venue = venues[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 72,
                              height: 72,
                              child: venue.coverPhoto != null
                                  ? Image.network(venue.coverPhoto!, fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => _photoPlaceholder())
                                  : _photoPlaceholder(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(venue.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                Text('${venue.city} · ${venue.location}',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                if (venue.phoneNumber != null && venue.phoneNumber!.isNotEmpty)
                                  Text(venue.phoneNumber!, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                                const SizedBox(height: 6),
                                Text('${venue.pitchCount} pitches · ${venue.pricePerHour.toStringAsFixed(0)} MAD/hr',
                                    style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                                if (venue.allowedFormats.isNotEmpty)
                                  Text(venue.allowedFormats.join(', '),
                                      style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () => showAdminVenueForm(context, ref, venue: venue),
                                      child: Text(ref.tr.edit),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await ref.read(adminRepositoryProvider).deleteStadium(venue.id);
                                          ref.invalidate(adminStadiumsProvider);
                                        } catch (e) {
                                          if (context.mounted) {
                                            showKickproToast(context, apiErrorMessage(e), isError: true);
                                          }
                                        }
                                      },
                                      child: Text(ref.tr.delete, style: const TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.stadium_outlined, color: AppColors.textHint),
    );
  }
}
