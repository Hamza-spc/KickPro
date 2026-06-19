import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/features/admin/widgets/admin_stadium_map_picker.dart';
import 'package:kickpro/features/matches/screens/match_booking_screen.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

const _allowedFormatOptions = ['5v5', '6v6', '7v7', '11v11'];

Future<void> showAdminVenueForm(BuildContext context, WidgetRef ref, {AdminStadium? venue}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _AdminVenueFormSheet(venue: venue),
  );
}

class _AdminVenueFormSheet extends ConsumerStatefulWidget {
  const _AdminVenueFormSheet({this.venue});

  final AdminStadium? venue;

  @override
  ConsumerState<_AdminVenueFormSheet> createState() => _AdminVenueFormSheetState();
}

class _AdminVenueFormSheetState extends ConsumerState<_AdminVenueFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _pitchCountCtrl;
  late final TextEditingController _openCtrl;
  late final TextEditingController _closeCtrl;

  String? _city;
  String _grass = 'ARTIFICIAL';
  double? _latitude;
  double? _longitude;
  final _selectedPitchTypes = <String>{};
  final _selectedFormats = <String>{};
  final _newPhotoPaths = <String>[];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final venue = widget.venue;
    _nameCtrl = TextEditingController(text: venue?.name ?? '');
    _locationCtrl = TextEditingController(text: venue?.location ?? '');
    _phoneCtrl = TextEditingController(text: venue?.phoneNumber ?? '');
    _descCtrl = TextEditingController(text: venue?.description ?? '');
    _priceCtrl = TextEditingController(text: venue?.pricePerHour.toString() ?? '');
    _pitchCountCtrl = TextEditingController(text: '${venue?.pitchCount ?? 1}');
    _openCtrl = TextEditingController(text: venue?.openTime?.substring(0, 5) ?? '08:00');
    _closeCtrl = TextEditingController(text: venue?.closeTime?.substring(0, 5) ?? '23:00');
    _city = kMatchCities.contains(venue?.city) ? venue!.city : kMatchCities.first;
    _grass = venue?.grassType ?? 'ARTIFICIAL';
    _latitude = venue?.latitude ?? 33.5731;
    _longitude = venue?.longitude ?? -7.5898;
    _selectedPitchTypes.addAll(venue?.pitchTypes ?? ['FIVE_V_FIVE']);
    _selectedFormats.addAll(
      venue?.allowedFormats.isNotEmpty == true ? venue!.allowedFormats : ['5v5'],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _pitchCountCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final images = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    setState(() => _newPhotoPaths.addAll(images.map((e) => e.path)));
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      showKickproToast(context, 'Name and address are required', isError: true);
      return;
    }
    if (_selectedFormats.isEmpty) {
      showKickproToast(context, 'Select at least one format', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final body = {
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'city': _city,
        if (_phoneCtrl.text.trim().isNotEmpty) 'phoneNumber': _phoneCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'pricePerHour': double.tryParse(_priceCtrl.text.trim()) ?? 0,
        'pitchCount': int.tryParse(_pitchCountCtrl.text.trim()) ?? 1,
        'pitchTypes': _selectedPitchTypes.toList(),
        'allowedFormats': _selectedFormats.toList(),
        'openTime': '${_openCtrl.text.trim()}:00',
        'closeTime': '${_closeCtrl.text.trim()}:00',
        'grassType': _grass,
        'latitude': _latitude,
        'longitude': _longitude,
      };

      final repo = ref.read(adminRepositoryProvider);
      AdminStadium saved;
      if (widget.venue == null) {
        saved = await repo.createStadium(body);
      } else {
        saved = await repo.updateStadium(widget.venue!.id, body);
      }

      if (_newPhotoPaths.isNotEmpty) {
        await repo.uploadStadiumPhotos(saved.id, _newPhotoPaths);
      }

      ref.invalidate(adminStadiumsProvider);
      if (mounted) {
        showKickproToast(context, widget.venue == null ? 'Venue created' : 'Venue updated');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingPhotos = widget.venue?.photos ?? const [];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.venue == null ? 'Create venue' : 'Edit venue',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 12),
            KickproTextField(controller: _nameCtrl, label: 'Name'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _city,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: 'City'),
              items: kMatchCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _city = v),
            ),
            const SizedBox(height: 12),
            KickproTextField(controller: _locationCtrl, label: 'Address'),
            KickproTextField(controller: _phoneCtrl, label: 'Phone number', keyboardType: TextInputType.phone),
            KickproTextField(controller: _descCtrl, label: 'Description', maxLines: 2),
            KickproTextField(controller: _priceCtrl, label: 'Price per hour (MAD)', keyboardType: TextInputType.number),
            KickproTextField(controller: _pitchCountCtrl, label: 'Number of pitches', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            AdminStadiumMapPicker(
              latitude: _latitude,
              longitude: _longitude,
              onLocationPicked: (lat, lng) => setState(() {
                _latitude = lat;
                _longitude = lng;
              }),
            ),
            const SizedBox(height: 12),
            KickproTextField(controller: _openCtrl, label: 'Open time (HH:mm)'),
            KickproTextField(controller: _closeCtrl, label: 'Close time (HH:mm)'),
            DropdownButtonFormField<String>(
              initialValue: _grass,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: 'Grass type'),
              items: const [
                DropdownMenuItem(value: 'NATURAL', child: Text('Natural')),
                DropdownMenuItem(value: 'ARTIFICIAL', child: Text('Artificial')),
                DropdownMenuItem(value: 'HYBRID', child: Text('Hybrid')),
              ],
              onChanged: (v) => setState(() => _grass = v ?? _grass),
            ),
            const SizedBox(height: 8),
            const Text('Allowed formats', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            Wrap(
              spacing: 8,
              children: _allowedFormatOptions.map((format) {
                final selected = _selectedFormats.contains(format);
                return FilterChip(
                  label: Text(format),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedFormats.add(format);
                    } else {
                      _selectedFormats.remove(format);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            const Text('Pitch types', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Wrap(
              spacing: 8,
              children: ['FIVE_V_FIVE', 'SEVEN_V_SEVEN', 'ELEVEN_V_ELEVEN'].map((type) {
                final selected = _selectedPitchTypes.contains(type);
                return FilterChip(
                  label: Text(type.replaceAll('_', ' ')),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedPitchTypes.add(type);
                    } else {
                      _selectedPitchTypes.remove(type);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Photos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: existingPhotos.length + _newPhotoPaths.length + 1,
              itemBuilder: (_, index) {
                if (index == existingPhotos.length + _newPhotoPaths.length) {
                  return InkWell(
                    onTap: _pickPhotos,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textHint),
                    ),
                  );
                }
                if (index < existingPhotos.length) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(existingPhotos[index], fit: BoxFit.cover),
                  );
                }
                final path = _newPhotoPaths[index - existingPhotos.length];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _newPhotoPaths.remove(path)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.error,
                          child: Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            KickproButton(
              label: widget.venue == null ? 'Create venue' : 'Save changes',
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
