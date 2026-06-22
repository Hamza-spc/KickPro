import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/messages/data/message_repository.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';
import 'package:kickpro/shared/widgets/kickpro_empty_state.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class MessagesTab extends ConsumerStatefulWidget {
  const MessagesTab({
    super.key,
    this.initialUserId,
    this.initialUserLabel,
  });

  final int? initialUserId;
  final String? initialUserLabel;

  @override
  ConsumerState<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends ConsumerState<MessagesTab> {
  int? _selectedUserId;
  String? _selectedUserLabel;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialUserId;
    _selectedUserLabel = widget.initialUserLabel;
  }

  @override
  void didUpdateWidget(covariant MessagesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUserId != null && widget.initialUserId != _selectedUserId) {
      _selectedUserId = widget.initialUserId;
      _selectedUserLabel = widget.initialUserLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedUserId != null) {
      return _ChatView(
        otherUserId: _selectedUserId!,
        otherUserLabel: _selectedUserLabel,
        onBack: () => setState(() {
          _selectedUserId = null;
          _selectedUserLabel = null;
        }),
      );
    }

    final conversationsAsync = ref.watch(conversationsProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(conversationsProvider),
        child: conversationsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: const [
              ShimmerBox(height: 80, width: double.infinity),
            ],
          ),
          error: (e, _) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
            ],
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  KickproEmptyState(
                    icon: Icons.mail_outline,
                    message: ref.tr.noConversationsYet,
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final title = conversation.otherUserName.isNotEmpty
                  ? conversation.otherUserName
                  : conversation.otherUserEmail;
              return ListTile(
                onTap: () => setState(() {
                  _selectedUserId = conversation.otherUserId;
                  _selectedUserLabel = title;
                }),
                leading: KickproAvatar(
                  photoUrl: conversation.otherUserPhotoUrl,
                  name: title,
                ),
                title: Text(
                  title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  conversation.lastMessageOwn ? '${ref.tr.you}: ${conversation.lastMessage}' : conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            },
          );
          },
        ),
      ),
    );
  }
}

class MessagesChatScreen extends ConsumerWidget {
  const MessagesChatScreen({
    super.key,
    required this.otherUserId,
    this.otherUserLabel,
  });

  final int otherUserId;
  final String? otherUserLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _ChatView(
          otherUserId: otherUserId,
          otherUserLabel: otherUserLabel,
          onBack: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

class _ChatView extends ConsumerStatefulWidget {
  const _ChatView({
    required this.otherUserId,
    required this.onBack,
    this.otherUserLabel,
  });

  final int otherUserId;
  final String? otherUserLabel;
  final VoidCallback onBack;

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(messageRepositoryProvider).sendMessage(
            receiverId: widget.otherUserId,
            content: text,
          );
      _controller.clear();
      ref.invalidate(messagesWithUserProvider(widget.otherUserId));
      ref.invalidate(conversationsProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesWithUserProvider(widget.otherUserId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              Expanded(
                child: Text(
                  widget.otherUserLabel ?? ref.tr.navMessages,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: ShimmerBox(height: 120, width: double.infinity)),
            error: (e, _) => Center(
              child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
            ),
            data: (messages) {
              if (messages.isEmpty) {
                return Center(
                  child: KickproEmptyState(
                    icon: Icons.chat_bubble_outline,
                    message: ref.tr.noMessagesYet,
                  ),
                );
              }
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message.ownMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: message.ownMessage
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(message.content, style: const TextStyle(color: AppColors.textPrimary)),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: ref.tr.typeMessage),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sending ? null : _send(),
                  ),
                ),
                IconButton(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send, color: AppColors.accent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
