package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateCommentRequest;
import com.kickpro.backend.dto.request.ReactToPostRequest;
import com.kickpro.backend.dto.request.UpdatePostRequest;
import com.kickpro.backend.dto.response.CommentResponse;
import com.kickpro.backend.dto.response.PostResponse;
import com.kickpro.backend.entity.PlayerFollow;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.PostComment;
import com.kickpro.backend.entity.PostReaction;
import com.kickpro.backend.entity.PostType;
import com.kickpro.backend.entity.ReactionType;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.event.KafkaEventPublisher;
import com.kickpro.backend.event.VideoUploadedEvent;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerFollowRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PostCommentRepository;
import com.kickpro.backend.repository.PostReactionRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.PostService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final VideoRepository videoRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final PostCommentRepository postCommentRepository;
    private final PostReactionRepository postReactionRepository;
    private final UserRepository userRepository;
    private final PlayerFollowRepository playerFollowRepository;
    private final CloudinaryService cloudinaryService;
    private final KafkaEventPublisher kafkaEventPublisher;

    @Override
    @Transactional
    public PostResponse createPost(Long userId, String title, PostType postType, TargetSkill skillTag, MultipartFile file) {
        if (title == null || title.isBlank()) {
            throw new BadRequestException("Caption is required");
        }
        if (postType == null) {
            throw new BadRequestException("Post type is required");
        }

        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before posting"));

        String mediaUrl = null;
        if (postType == PostType.TEXT) {
            if (file != null && !file.isEmpty()) {
                throw new BadRequestException("Text posts cannot include media");
            }
        } else {
            if (file == null || file.isEmpty()) {
                throw new BadRequestException("Media file is required for video and image posts");
            }
            try {
                String publicId = "player-" + player.getId() + "-" + System.currentTimeMillis();
                mediaUrl = postType == PostType.VIDEO
                        ? cloudinaryService.uploadVideo(file, "kickpro/videos", publicId)
                        : cloudinaryService.uploadImage(file, "kickpro/posts", publicId);
            } catch (IOException ex) {
                throw new BadRequestException("Failed to upload media");
            }
        }

        Video post = Video.builder()
                .player(player)
                .title(title.trim())
                .cloudinaryUrl(mediaUrl)
                .skillTag(skillTag)
                .postType(postType)
                .build();

        Video saved = videoRepository.save(post);

        if (postType == PostType.VIDEO && mediaUrl != null) {
            kafkaEventPublisher.publishVideoUploaded(VideoUploadedEvent.builder()
                    .videoId(saved.getId())
                    .playerId(player.getId())
                    .title(saved.getTitle())
                    .videoUrl(saved.getCloudinaryUrl())
                    .skillTag(saved.getSkillTag())
                    .uploadedAt(saved.getUploadedAt())
                    .build());
        }

        return toResponse(saved, userId, player, true, false);
    }

    @Override
    @Transactional
    public PostResponse updatePost(Long userId, Long postId, UpdatePostRequest request) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        Video post = videoRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));

        if (!post.getPlayer().getId().equals(player.getId())) {
            throw new BadRequestException("You can only edit your own posts");
        }

        post.setTitle(request.getTitle().trim());
        if (post.getPostType() != PostType.TEXT) {
            post.setSkillTag(request.getSkillTag());
        }

        Video saved = videoRepository.save(post);
        boolean following = isFollowing(player.getId(), post.getPlayer().getId());
        return toResponse(saved, userId, player, true, following);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getFeed(Long viewerUserId, Pageable pageable) {
        PlayerProfile viewer = viewerUserId == null ? null : playerProfileRepository.findByUserId(viewerUserId).orElse(null);

        return videoRepository.findAllByHiddenFalseOrderByUploadedAtDesc(pageable)
                .map(post -> {
                    boolean own = viewer != null && post.getPlayer().getId().equals(viewer.getId());
                    boolean following = viewerUserId != null
                            && isFollowing(viewerUserId, post.getPlayer().getId());
                    return toResponse(post, viewerUserId, viewer, own, following);
                });
    }

    @Override
    @Transactional(readOnly = true)
    public List<CommentResponse> getComments(Long postId) {
        ensurePostExists(postId);
        return postCommentRepository.findByPostIdOrderByCreatedAtAsc(postId).stream()
                .map(comment -> CommentResponse.builder()
                        .id(comment.getId())
                        .authorId(comment.getAuthor().getId())
                        .authorProfileId(resolveAuthorProfileId(comment.getAuthor()))
                        .authorName(resolveDisplayName(comment.getAuthor()))
                        .text(comment.getText())
                        .createdAt(comment.getCreatedAt())
                        .build())
                .toList();
    }

    @Override
    @Transactional
    public CommentResponse addComment(Long userId, Long postId, CreateCommentRequest request) {
        User author = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Video post = videoRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));

        PostComment comment = PostComment.builder()
                .post(post)
                .author(author)
                .text(request.getText().trim())
                .build();

        PostComment saved = postCommentRepository.save(comment);
        return CommentResponse.builder()
                .id(saved.getId())
                .authorId(author.getId())
                .authorProfileId(resolveAuthorProfileId(author))
                .authorName(resolveDisplayName(author))
                .text(saved.getText())
                .createdAt(saved.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public PostResponse react(Long userId, Long postId, ReactToPostRequest request) {
        User reactor = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Video post = videoRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));

        var existing = postReactionRepository.findByPostIdAndReactorId(postId, reactor.getId());
        if (existing.isPresent()) {
            PostReaction reaction = existing.get();
            if (reaction.getReactionType() == request.getReactionType()) {
                postReactionRepository.delete(reaction);
            } else {
                reaction.setReactionType(request.getReactionType());
                postReactionRepository.save(reaction);
            }
        } else {
            postReactionRepository.save(PostReaction.builder()
                    .post(post)
                    .reactor(reactor)
                    .reactionType(request.getReactionType())
                    .build());
        }

        PlayerProfile reactorProfile = playerProfileRepository.findByUserId(userId).orElse(null);
        boolean own = reactorProfile != null && post.getPlayer().getId().equals(reactorProfile.getId());
        boolean following = isFollowing(userId, post.getPlayer().getId());
        return toResponse(post, userId, reactorProfile, own, following);
    }

    @Override
    @Transactional
    public void follow(Long userId, Long targetProfileId) {
        User follower = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        PlayerProfile following = playerProfileRepository.findById(targetProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player not found"));

        if (following.getUser().getId().equals(userId)) {
            throw new BadRequestException("You cannot follow yourself");
        }

        if (playerFollowRepository.existsByFollowerIdAndFollowingId(userId, following.getId())) {
            return;
        }

        playerFollowRepository.save(PlayerFollow.builder()
                .follower(follower)
                .following(following)
                .build());
    }

    @Override
    @Transactional
    public void unfollow(Long userId, Long targetProfileId) {
        userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        playerFollowRepository.deleteByFollowerIdAndFollowingId(userId, targetProfileId);
    }

    private void ensurePostExists(Long postId) {
        if (!videoRepository.existsById(postId)) {
            throw new ResourceNotFoundException("Post not found");
        }
    }

    private boolean isFollowing(Long followerUserId, Long followingProfileId) {
        return playerFollowRepository.existsByFollowerIdAndFollowingId(followerUserId, followingProfileId);
    }

    private Long resolveAuthorProfileId(User user) {
        return playerProfileRepository.findByUserId(user.getId())
                .map(PlayerProfile::getId)
                .orElse(null);
    }

    private String resolveDisplayName(User user) {
        return playerProfileRepository.findByUserId(user.getId())
                .map(PlayerProfile::getFullName)
                .orElse(user.getEmail().split("@")[0]);
    }

    private PostResponse toResponse(
            Video post,
            Long viewerUserId,
            PlayerProfile viewerProfile,
            boolean ownPost,
            boolean followingAuthor
    ) {
        ReactionType myReaction = null;
        if (viewerUserId != null) {
            myReaction = postReactionRepository.findByPostIdAndReactorId(post.getId(), viewerUserId)
                    .map(PostReaction::getReactionType)
                    .orElse(null);
        }

        Map<ReactionType, Long> reactionCounts = new EnumMap<>(ReactionType.class);
        for (ReactionType type : ReactionType.values()) {
            reactionCounts.put(type, postReactionRepository.countByPostIdAndReactionType(post.getId(), type));
        }

        return PostResponse.builder()
                .id(post.getId())
                .playerId(post.getPlayer().getId())
                .playerName(post.getPlayer().getFullName())
                .playerPhotoUrl(post.getPlayer().getProfilePhotoUrl())
                .title(post.getTitle())
                .cloudinaryUrl(post.getCloudinaryUrl())
                .postType(post.getPostType())
                .skillTag(post.getSkillTag())
                .viewsCount(post.getViewsCount())
                .averageRating(post.getAverageRating())
                .uploadedAt(post.getUploadedAt())
                .updatedAt(post.getUpdatedAt())
                .ownPost(ownPost)
                .followingAuthor(followingAuthor)
                .commentCount(postCommentRepository.countByPostId(post.getId()))
                .reactionCounts(reactionCounts)
                .myReaction(myReaction)
                .build();
    }
}
