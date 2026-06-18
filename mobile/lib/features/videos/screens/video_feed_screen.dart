import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/videos/data/video_repository.dart';
import 'package:kickpro/shared/models/video_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final videoFeedProvider = FutureProvider.autoDispose<List<PerformanceVideo>>((ref) {
  return ref.read(videoRepositoryProvider).getFeed();
});

class VideoFeedScreen extends ConsumerStatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> {
  final _titleController = TextEditingController();
  TargetSkill _skillTag = TargetSkill.dribbling;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _uploadVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
    if (video == null) return;

    if (_titleController.text.trim().isEmpty) {
      if (!mounted) return;
      showKickproToast(context, 'Add a title before uploading', isError: true);
      return;
    }

    setState(() => _uploading = true);
    try {
      await ref.read(videoRepositoryProvider).uploadVideo(
            title: _titleController.text.trim(),
            skillTag: _skillTag,
            filePath: video.path,
          );
      _titleController.clear();
      ref.invalidate(videoFeedProvider);
      if (mounted) showKickproToast(context, 'Video uploaded');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(videoFeedProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(videoFeedProvider),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Video Feed',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _UploadCard(
                titleController: _titleController,
                skillTag: _skillTag,
                uploading: _uploading,
                onSkillChanged: (skill) => setState(() => _skillTag = skill),
                onUpload: _uploadVideo,
              )),
              feedAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 120, width: double.infinity),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(e.toString(), style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (videos) {
                  if (videos.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No videos yet. Upload your first performance clip.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: videos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _VideoCard(video: videos[index]),
                    ),
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

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.titleController,
    required this.skillTag,
    required this.uploading,
    required this.onSkillChanged,
    required this.onUpload,
  });

  final TextEditingController titleController;
  final TargetSkill skillTag;
  final bool uploading;
  final ValueChanged<TargetSkill> onSkillChanged;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload performance video', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          KickproTextField(controller: titleController, label: 'Title', hint: 'Skills showcase'),
          const SizedBox(height: 12),
          const Text('Skill tag', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TargetSkill.values.map((skill) {
              final selected = skill == skillTag;
              return ChoiceChip(
                label: Text(skill.label),
                selected: selected,
                onSelected: (_) => onSkillChanged(skill),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary),
                backgroundColor: AppColors.background,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          KickproButton(label: 'Pick & Upload Video', isLoading: uploading, onPressed: onUpload),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.video});
  final PerformanceVideo video;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  video.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  video.skillTag.label,
                  style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(video.playerName, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: AppColors.textHint),
              const SizedBox(width: 4),
              Text('${video.viewsCount} views', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.star, size: 14, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(video.averageRating.toStringAsFixed(1), style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
