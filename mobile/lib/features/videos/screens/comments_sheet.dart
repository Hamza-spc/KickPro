import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/videos/data/post_repository.dart';
import 'package:kickpro/shared/models/post_models.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

Future<void> showCommentsSheet(BuildContext context, WidgetRef ref, FeedPost post) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CommentsSheet(postId: post.id),
  );
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.postId});

  final int postId;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _textController = TextEditingController();
  bool _loading = false;
  late Future<List<PostComment>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(postRepositoryProvider).getComments(widget.postId);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(postRepositoryProvider).addComment(postId: widget.postId, text: text);
      _textController.clear();
      setState(_load);
      ref.invalidate(postFeedProvider);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr.comments, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<PostComment>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }
                if (snapshot.hasError) {
                  return Text(apiErrorMessage(snapshot.error!), style: const TextStyle(color: AppColors.error));
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return Text(context.tr.noCommentsYet, style: const TextStyle(color: AppColors.textSecondary));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const Divider(color: AppColors.border),
                  itemBuilder: (_, index) {
                    final c = comments[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: c.authorProfileId == null
                          ? null
                          : () {
                              Navigator.pop(context);
                              openPlayerProfile(context, c.authorProfileId!);
                            },
                      title: Text(c.authorName, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                      subtitle: Text(c.text, style: const TextStyle(color: AppColors.textPrimary)),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: KickproTextField(
                  controller: _textController,
                  label: context.tr.commentLabel,
                  hint: context.tr.addCommentHint,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
