import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/screens/scout_assist_sheet.dart';
import 'package:kickpro/features/search/data/bookmark_repository.dart';
import 'package:kickpro/features/search/data/search_repository.dart';
import 'package:kickpro/features/search/screens/player_preview_sheet.dart';
import 'package:kickpro/features/search/widgets/scout_player_card.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final scoutSearchProvider = FutureProvider.autoDispose
    .family<PagedPlayers, PlayerSearchFilters>((ref, filters) {
  return ref.read(searchRepositoryProvider).searchPlayers(
        filters: filters,
        page: 0,
        size: 30,
      );
});

final scoutCitiesProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.read(searchRepositoryProvider).getCities();
});

class ScoutSearchScreen extends ConsumerStatefulWidget {
  const ScoutSearchScreen({super.key});

  @override
  ConsumerState<ScoutSearchScreen> createState() => _ScoutSearchScreenState();
}

class _ScoutSearchScreenState extends ConsumerState<ScoutSearchScreen> {
  final _nameController = TextEditingController();
  PlayerSearchFilters _filters = const PlayerSearchFilters();

  String? _selectedCity;
  PlayerPosition? _position;
  bool _certifiedOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyFilters());
  }

  void _applyFilters() {
    setState(() {
      _filters = PlayerSearchFilters(
        name: _nameController.text,
        city: _selectedCity,
        position: _position,
        hasCertification: _certifiedOnly ? true : null,
      );
    });
  }

  void _resetFilters() {
    _nameController.clear();
    setState(() {
      _selectedCity = null;
      _position = null;
      _certifiedOnly = false;
      _filters = const PlayerSearchFilters();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(scoutSearchProvider(_filters));
    final citiesAsync = ref.watch(scoutCitiesProvider);
    final bookmarkIdsAsync = ref.watch(scoutBookmarkIdsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr.findPlayersTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showScoutAssistSheet(context, ref),
                    icon: const KickproChatbotLogo(size: 24),
                    tooltip: ref.tr.scoutAssistTooltip,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration(
                  hint: ref.tr.searchByPlayer,
                  prefixIcon: Icons.person_search,
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: citiesAsync.when(
                loading: () => const ShimmerBox(height: 48, width: double.infinity),
                error: (_, _) => DropdownButtonFormField<String?>(
                  key: ValueKey(_selectedCity),
                  initialValue: _selectedCity,
                  dropdownColor: AppColors.surface,
                  decoration: _inputDecoration(hint: ref.tr.allCities, prefixIcon: Icons.location_city),
                  items: [
                    DropdownMenuItem<String?>(value: null, child: Text(ref.tr.allCities)),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                    _applyFilters();
                  },
                ),
                data: (cities) => DropdownButtonFormField<String?>(
                  key: ValueKey(_selectedCity),
                  initialValue: _selectedCity,
                  dropdownColor: AppColors.surface,
                  decoration: _inputDecoration(hint: ref.tr.allCities, prefixIcon: Icons.location_city),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(ref.tr.allCities, style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                    ...cities.map(
                      (city) => DropdownMenuItem<String?>(
                        value: city,
                        child: Text(city, style: const TextStyle(color: AppColors.textPrimary)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                    _applyFilters();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ...PlayerPosition.values.map(
                    (position) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: ref.tr.positionLabel(position),
                        selected: _position == position,
                        onTap: () {
                          setState(() => _position = _position == position ? null : position);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                  _FilterChip(
                    label: ref.tr.certified,
                    selected: _certifiedOnly,
                    onTap: () {
                      setState(() => _certifiedOnly = !_certifiedOnly);
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: KickproButton(
                      label: ref.tr.searchBtn,
                      onPressed: _applyFilters,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KickproButton(
                      label: ref.tr.resetBtn,
                      variant: KickproButtonVariant.ghost,
                      onPressed: _resetFilters,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(scoutSearchProvider);
                  ref.invalidate(scoutCitiesProvider);
                  ref.invalidate(scoutBookmarkIdsProvider);
                },
                child: searchAsync.when(
                  loading: () => ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: ShimmerBox(height: 100, width: double.infinity),
                      ),
                    ],
                  ),
                  error: (error, _) => ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          apiErrorMessage(error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  data: (page) {
                    final bookmarkIds = bookmarkIdsAsync.maybeWhen(
                      data: (ids) => ids,
                      orElse: () => <int>{},
                    );

                    if (page.content.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              ref.tr.noPlayersMatch,
                              style: const TextStyle(color: AppColors.textHint),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: page.content.length,
                      itemBuilder: (context, index) {
                        final player = page.content[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ScoutPlayerCard(
                            player: player,
                            isBookmarked: bookmarkIds.contains(player.profileId),
                            onTap: () => showPlayerPreviewSheet(context, ref, player.profileId),
                            onBookmarkToggle: () async {
                              final repo = ref.read(bookmarkRepositoryProvider);
                              if (bookmarkIds.contains(player.profileId)) {
                                await repo.unbookmark(player.profileId);
                              } else {
                                await repo.bookmark(player.profileId);
                              }
                              ref.invalidate(scoutBookmarkIdsProvider);
                              ref.invalidate(scoutBookmarksProvider);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surface,
      prefixIcon: Icon(prefixIcon, color: AppColors.textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
