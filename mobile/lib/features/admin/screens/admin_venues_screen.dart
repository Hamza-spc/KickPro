import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
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
                const Expanded(
                  child: Text('Venues', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => _openVenueForm(context, ref),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(venue.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                          Text(venue.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('${venue.pitchCount} pitches · ${venue.pricePerHour.toStringAsFixed(0)} MAD/hr',
                              style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                          if (venue.pitchTypes.isNotEmpty)
                            Text(venue.pitchTypes.join(', '), style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              TextButton(onPressed: () => _openVenueForm(context, ref, venue: venue), child: const Text('Edit')),
                              TextButton(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final images = await picker.pickMultiImage(imageQuality: 85);
                                  if (images.isEmpty) return;
                                  try {
                                    await ref.read(adminRepositoryProvider).uploadStadiumPhotos(
                                          venue.id,
                                          images.map((e) => e.path).toList(),
                                        );
                                    ref.invalidate(adminStadiumsProvider);
                                    if (context.mounted) showKickproToast(context, 'Photos uploaded');
                                  } catch (e) {
                                    if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                                  }
                                },
                                child: const Text('Photos'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await ref.read(adminRepositoryProvider).deleteStadium(venue.id);
                                    ref.invalidate(adminStadiumsProvider);
                                  } catch (e) {
                                    if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                                  }
                                },
                                child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
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

  Future<void> _openVenueForm(BuildContext context, WidgetRef ref, {AdminStadium? venue}) async {
    final nameCtrl = TextEditingController(text: venue?.name ?? '');
    final locationCtrl = TextEditingController(text: venue?.location ?? '');
    final descCtrl = TextEditingController(text: venue?.description ?? '');
    final priceCtrl = TextEditingController(text: venue?.pricePerHour.toString() ?? '');
    final pitchCountCtrl = TextEditingController(text: '${venue?.pitchCount ?? 1}');
    final latCtrl = TextEditingController(text: venue?.latitude?.toString() ?? '');
    final lngCtrl = TextEditingController(text: venue?.longitude?.toString() ?? '');
    final openCtrl = TextEditingController(text: venue?.openTime?.substring(0, 5) ?? '08:00');
    final closeCtrl = TextEditingController(text: venue?.closeTime?.substring(0, 5) ?? '23:00');
    var grass = venue?.grassType ?? 'ARTIFICIAL';
    final selectedTypes = {...(venue?.pitchTypes ?? ['FIVE_V_FIVE'])};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(venue == null ? 'Create venue' : 'Edit venue',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
              const SizedBox(height: 12),
              KickproTextField(controller: nameCtrl, label: 'Name'),
              KickproTextField(controller: locationCtrl, label: 'Location / address'),
              KickproTextField(controller: descCtrl, label: 'Description', maxLines: 2),
              KickproTextField(controller: priceCtrl, label: 'Price per hour (MAD)', keyboardType: TextInputType.number),
              KickproTextField(controller: pitchCountCtrl, label: 'Number of pitches', keyboardType: TextInputType.number),
              KickproTextField(controller: latCtrl, label: 'Latitude (map pin)', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              KickproTextField(controller: lngCtrl, label: 'Longitude (map pin)', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              KickproTextField(controller: openCtrl, label: 'Open time (HH:mm)'),
              KickproTextField(controller: closeCtrl, label: 'Close time (HH:mm)'),
              DropdownButtonFormField<String>(
                value: grass,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(labelText: 'Grass type'),
                items: const [
                  DropdownMenuItem(value: 'NATURAL', child: Text('Natural')),
                  DropdownMenuItem(value: 'ARTIFICIAL', child: Text('Artificial')),
                  DropdownMenuItem(value: 'HYBRID', child: Text('Hybrid')),
                ],
                onChanged: (v) => setModalState(() => grass = v ?? grass),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['FIVE_V_FIVE', 'SEVEN_V_SEVEN', 'ELEVEN_V_ELEVEN'].map((type) {
                  final selected = selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(type.replaceAll('_', ' ')),
                    selected: selected,
                    onSelected: (v) {
                      setModalState(() {
                        if (v) {
                          selectedTypes.add(type);
                        } else {
                          selectedTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              KickproButton(
                label: venue == null ? 'Create venue' : 'Save changes',
                onPressed: () async {
                  final body = {
                    'name': nameCtrl.text.trim(),
                    'location': locationCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'pricePerHour': double.tryParse(priceCtrl.text.trim()) ?? 0,
                    'pitchCount': int.tryParse(pitchCountCtrl.text.trim()) ?? 1,
                    'pitchTypes': selectedTypes.toList(),
                    'openTime': '${openCtrl.text.trim()}:00',
                    'closeTime': '${closeCtrl.text.trim()}:00',
                    'grassType': grass,
                    if (latCtrl.text.isNotEmpty) 'latitude': double.tryParse(latCtrl.text.trim()),
                    if (lngCtrl.text.isNotEmpty) 'longitude': double.tryParse(lngCtrl.text.trim()),
                  };
                  try {
                    if (venue == null) {
                      await ref.read(adminRepositoryProvider).createStadium(body);
                    } else {
                      await ref.read(adminRepositoryProvider).updateStadium(venue.id, body);
                    }
                    ref.invalidate(adminStadiumsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) showKickproToast(ctx, apiErrorMessage(e), isError: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
