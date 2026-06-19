import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/features/matches/screens/match_booking_screen.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final stadiumsByCityProvider = FutureProvider.autoDispose
    .family<List<Stadium>, String>((ref, city) {
  return ref.read(matchRepositoryProvider).getStadiums(city: city);
});

class BookMatchFlowScreen extends ConsumerStatefulWidget {
  const BookMatchFlowScreen({super.key, required this.onBooked});

  final VoidCallback onBooked;

  @override
  ConsumerState<BookMatchFlowScreen> createState() => _BookMatchFlowScreenState();
}

class _BookMatchFlowScreenState extends ConsumerState<BookMatchFlowScreen> {
  int _step = 0;
  String? _city;
  Stadium? _stadium;
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedFormat;
  RangeValues _ageRange = const RangeValues(18, 35);
  MatchGender _gender = MatchGender.mixed;
  bool _submitting = false;
  bool _cityInitialized = false;

  StadiumAvailability? _availability;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCity());
  }

  Future<void> _initCity() async {
    if (_cityInitialized) return;
    try {
      final profile = await ref.read(profileRepositoryProvider).getMyProfile();
      if (!mounted) return;
      setState(() {
        _city = kMatchCities.contains(profile.city) ? profile.city : null;
        _cityInitialized = true;
      });
    } catch (_) {
      if (mounted) setState(() => _cityInitialized = true);
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    if (_stadium == null) return;
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
      _loadingSlots = true;
      _availability = null;
    });
    try {
      final availability = await ref.read(matchRepositoryProvider).getStadiumAvailability(
            stadiumId: _stadium!.id,
            date: date,
          );
      if (mounted) setState(() => _availability = availability);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (picked != null) await _loadSlots(picked);
  }

  Future<void> _submit() async {
    if (_stadium == null || _selectedDate == null || _selectedTime == null || _selectedFormat == null) {
      showKickproToast(context, 'Complete all booking steps', isError: true);
      return;
    }

    final parts = _selectedTime!.split(':');
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    setState(() => _submitting = true);
    try {
      await ref.read(matchRepositoryProvider).createMatch(
            stadiumId: _stadium!.id,
            dateTime: dateTime,
            maxPlayers: maxPlayersForFormat(_selectedFormat!),
            minAge: _ageRange.start.round(),
            maxAge: _ageRange.end.round(),
            gender: _gender,
          );
      if (mounted) {
        showKickproToast(context, 'Match booked!');
        widget.onBooked();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _nextStep() {
    if (_step == 0 && _city == null) {
      showKickproToast(context, 'Select a city', isError: true);
      return;
    }
    if (_step == 1 && _stadium == null) {
      showKickproToast(context, 'Select a stadium', isError: true);
      return;
    }
    if (_step == 2 && (_selectedTime == null || _selectedTime!.isEmpty)) {
      showKickproToast(context, 'Select an available time slot', isError: true);
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      _stepTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('${_step + 1}/4', style: const TextStyle(color: AppColors.textHint)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LinearProgressIndicator(
                value: (_step + 1) / 4,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(child: _buildStep()),
            if (_step < 3)
              Padding(
                padding: const EdgeInsets.all(24),
                child: KickproButton(label: 'Continue', onPressed: _nextStep),
              )
            else
              Padding(
                padding: const EdgeInsets.all(24),
                child: KickproButton(
                  label: 'Confirm Booking',
                  isLoading: _submitting,
                  onPressed: _submit,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _stepTitle => switch (_step) {
        0 => 'Choose city',
        1 => 'Choose stadium',
        2 => 'Pick date & time',
        _ => 'Match details',
      };

  Widget _buildStep() {
    return switch (_step) {
      0 => _CityStep(
          selected: _city,
          onSelected: (city) => setState(() {
            _city = city;
            _stadium = null;
          }),
        ),
      1 => _StadiumStep(
          city: _city!,
          selected: _stadium,
          onSelected: (stadium) => setState(() {
            _stadium = stadium;
            _selectedDate = null;
            _selectedTime = null;
            _availability = null;
            _selectedFormat = null;
          }),
          onInfo: _showStadiumDetails,
        ),
      2 => _SlotStep(
          stadium: _stadium!,
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          availability: _availability,
          loading: _loadingSlots,
          onPickDate: _pickDate,
          onTimeSelected: (time) => setState(() => _selectedTime = time),
        ),
      _ => _FormatStep(
          stadium: _stadium!,
          selectedFormat: _selectedFormat,
          ageRange: _ageRange,
          gender: _gender,
          onFormatSelected: (f) => setState(() => _selectedFormat = f),
          onAgeChanged: (v) => setState(() => _ageRange = v),
          onGenderSelected: (g) => setState(() => _gender = g),
        ),
    };
  }

  void _showStadiumDetails(Stadium stadium) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StadiumDetailSheet(stadium: stadium),
    );
  }
}

class _CityStep extends StatelessWidget {
  const _CityStep({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Where do you want to play?',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: kMatchCities.map((city) {
            final isSelected = selected == city;
            return GestureDetector(
              onTap: () => onSelected(city),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StadiumStep extends ConsumerWidget {
  const _StadiumStep({
    required this.city,
    required this.selected,
    required this.onSelected,
    required this.onInfo,
  });

  final String city;
  final Stadium? selected;
  final ValueChanged<Stadium> onSelected;
  final ValueChanged<Stadium> onInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stadiumsAsync = ref.watch(stadiumsByCityProvider(city));

    return stadiumsAsync.when(
      loading: () => const Center(child: ShimmerBox(height: 120, width: double.infinity)),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
        ),
      ),
      data: (stadiums) {
        if (stadiums.isEmpty) {
          return Center(
            child: Text(
              'No stadiums in $city yet.\nTry another city.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: stadiums.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final stadium = stadiums[index];
            final isSelected = selected?.id == stadium.id;
            return _StadiumCard(
              stadium: stadium,
              selected: isSelected,
              onTap: () => onSelected(stadium),
              onInfo: () => onInfo(stadium),
            );
          },
        );
      },
    );
  }
}

class _StadiumCard extends StatelessWidget {
  const _StadiumCard({
    required this.stadium,
    required this.selected,
    required this.onTap,
    required this.onInfo,
  });

  final Stadium stadium;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: stadium.coverPhoto != null
                      ? Image.network(stadium.coverPhoto!, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _photoPlaceholder())
                      : _photoPlaceholder(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stadium.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(stadium.location,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                            '${stadium.pricePerHour.toStringAsFixed(0)} MAD/hr',
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onInfo,
                      icon: const Icon(Icons.info_outline, color: AppColors.textHint),
                    ),
                    if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, Color(0xFF1D4ED8)]),
      ),
      child: const Center(child: Icon(Icons.stadium_outlined, color: Colors.white, size: 48)),
    );
  }
}

class _StadiumDetailSheet extends StatelessWidget {
  const _StadiumDetailSheet({required this.stadium});

  final Stadium stadium;

  @override
  Widget build(BuildContext context) {
    final formats = stadium.allowedFormats.isNotEmpty
        ? stadium.allowedFormats
        : stadium.pitchTypes.map((p) => p.replaceAll('_', ' ')).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(stadium.name,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(stadium.location, style: const TextStyle(color: AppColors.textSecondary)),
          if (stadium.phoneNumber != null && stadium.phoneNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                Text(stadium.phoneNumber!, style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          if (stadium.description != null && stadium.description!.isNotEmpty)
            Text(stadium.description!, style: const TextStyle(color: AppColors.textPrimary, height: 1.5)),
          const SizedBox(height: 16),
          const Text('Allowed formats', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: formats
                .map((f) => Chip(label: Text(f), backgroundColor: AppColors.background))
                .toList(),
          ),
          if (stadium.photos.length > 1) ...[
            const SizedBox(height: 16),
            const Text('Photos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stadium.photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(stadium.photos[i], width: 120, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlotStep extends StatelessWidget {
  const _SlotStep({
    required this.stadium,
    required this.selectedDate,
    required this.selectedTime,
    required this.availability,
    required this.loading,
    required this.onPickDate,
    required this.onTimeSelected,
  });

  final Stadium stadium;
  final DateTime? selectedDate;
  final String? selectedTime;
  final StadiumAvailability? availability;
  final bool loading;
  final VoidCallback onPickDate;
  final ValueChanged<String> onTimeSelected;

  @override
  Widget build(BuildContext context) {
    final dateLabel = selectedDate == null
        ? 'Select a date'
        : DateFormat('EEE, d MMM yyyy').format(selectedDate!);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(stadium.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onPickDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.accent, size: 20),
                const SizedBox(width: 12),
                Text(dateLabel, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.textHint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Available slots', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        if (selectedDate == null)
          const Text('Pick a date to see time slots', style: TextStyle(color: AppColors.textHint))
        else if (loading)
          const ShimmerBox(height: 80, width: double.infinity)
        else if (availability == null || availability!.slots.isEmpty)
          const Text('No slots for this date', style: TextStyle(color: AppColors.textHint))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availability!.slots.map((slot) {
              final selected = selectedTime == slot.time;
              final disabled = !slot.available;
              return GestureDetector(
                onTap: disabled ? null : () => onTimeSelected(slot.time),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: disabled
                        ? AppColors.background.withValues(alpha: 0.5)
                        : selected
                            ? AppColors.primary
                            : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: disabled
                          ? AppColors.border
                          : selected
                              ? AppColors.primary
                              : AppColors.border,
                    ),
                  ),
                  child: Text(
                    slot.time,
                    style: TextStyle(
                      color: disabled
                          ? AppColors.textHint
                          : selected
                              ? Colors.white
                              : AppColors.textPrimary,
                      decoration: disabled ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _FormatStep extends StatelessWidget {
  const _FormatStep({
    required this.stadium,
    required this.selectedFormat,
    required this.ageRange,
    required this.gender,
    required this.onFormatSelected,
    required this.onAgeChanged,
    required this.onGenderSelected,
  });

  final Stadium stadium;
  final String? selectedFormat;
  final RangeValues ageRange;
  final MatchGender gender;
  final ValueChanged<String> onFormatSelected;
  final ValueChanged<RangeValues> onAgeChanged;
  final ValueChanged<MatchGender> onGenderSelected;

  @override
  Widget build(BuildContext context) {
    final formats = stadium.allowedFormats.isNotEmpty ? stadium.allowedFormats : ['5v5'];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Match format', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: formats.map((format) {
            final selected = selectedFormat == format;
            return FilterChip(
              label: Text(format),
              selected: selected,
              onSelected: (_) => onFormatSelected(format),
            );
          }).toList(),
        ),
        if (selectedFormat != null) ...[
          const SizedBox(height: 8),
          Text(
            '${maxPlayersForFormat(selectedFormat!)} players max',
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
        const SizedBox(height: 20),
        const Text('Age range', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Row(
          children: [
            Expanded(
              child: RangeSlider(
                values: ageRange,
                min: 13,
                max: 60,
                divisions: 47,
                activeColor: AppColors.primary,
                labels: RangeLabels(
                  ageRange.start.round().toString(),
                  ageRange.end.round().toString(),
                ),
                onChanged: onAgeChanged,
              ),
            ),
            Text(
              '${ageRange.start.round()}–${ageRange.end.round()}',
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Text('Gender', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: MatchGender.values.map((g) {
            return FilterChip(
              label: Text(g.label),
              selected: gender == g,
              onSelected: (_) => onGenderSelected(g),
            );
          }).toList(),
        ),
      ],
    );
  }
}
