import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/screens/scout_assist_sheet.dart';
import 'package:kickpro/features/search/data/search_repository.dart';
import 'package:kickpro/features/search/screens/player_preview_sheet.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/shared/widgets/credibility_ring.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Find Players',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => showScoutAssistSheet(context, ref),
                    icon: const Icon(Icons.auto_awesome, color: AppColors.accent),
                    tooltip: 'AI Scout Assistant',
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
                  hint: 'Search by player name...',
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
                  decoration: _inputDecoration(hint: 'All cities', prefixIcon: Icons.location_city),
                  items: const [
                    DropdownMenuItem<String?>(value: null, child: Text('All cities')),
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
                  decoration: _inputDecoration(hint: 'All cities', prefixIcon: Icons.location_city),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All cities', style: TextStyle(color: AppColors.textSecondary)),
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
                        label: position.label,
                        selected: _position == position,
                        onTap: () {
                          setState(() => _position = _position == position ? null : position);
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                  _FilterChip(
                    label: 'Certified',
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
                      label: 'Search',
                      onPressed: _applyFilters,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: KickproButton(
                      label: 'Reset',
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
                    if (page.content.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No players match your filters',
                              style: TextStyle(color: AppColors.textHint),
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
                          child: _PlayerSearchCard(
                            player: player,
                            onTap: () => showPlayerPreviewSheet(context, ref, player.profileId),
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

class _PlayerSearchCard extends StatelessWidget {
  const _PlayerSearchCard({required this.player, required this.onTap});

  final PlayerSearchResult player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                backgroundImage: player.profilePhotoUrl != null
                    ? NetworkImage(player.profilePhotoUrl!)
                    : null,
                child: player.profilePhotoUrl == null
                    ? Text(
                        player.fullName.isNotEmpty ? player.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${player.position.label} · ${player.city} · ${player.age} yrs',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (player.skills != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Top: Speed ${player.skills!.speed}/10 · Shooting ${player.skills!.shooting}/10',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              CredibilityRing(score: player.credibilityScore, size: 56),
            ],
          ),
        ),
      ),
    );
  }
}
