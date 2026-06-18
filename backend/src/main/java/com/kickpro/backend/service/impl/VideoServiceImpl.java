package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.VideoResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.event.KafkaEventPublisher;
import com.kickpro.backend.event.VideoUploadedEvent;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.VideoService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class VideoServiceImpl implements VideoService {

    private final VideoRepository videoRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final CloudinaryService cloudinaryService;
    private final KafkaEventPublisher kafkaEventPublisher;

    @Override
    @Transactional
    public VideoResponse uploadVideo(Long userId, String title, TargetSkill skillTag, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Video file is required");
        }
        if (title == null || title.isBlank()) {
            throw new BadRequestException("Title is required");
        }
        if (skillTag == null) {
            throw new BadRequestException("Skill tag is required");
        }

        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before uploading videos"));

        try {
            String publicId = "player-" + player.getId() + "-" + System.currentTimeMillis();
            String videoUrl = cloudinaryService.uploadVideo(file, "kickpro/videos", publicId);

            Video video = Video.builder()
                    .player(player)
                    .title(title.trim())
                    .cloudinaryUrl(videoUrl)
                    .skillTag(skillTag)
                    .build();

            Video saved = videoRepository.save(video);

            kafkaEventPublisher.publishVideoUploaded(VideoUploadedEvent.builder()
                    .videoId(saved.getId())
                    .playerId(player.getId())
                    .title(saved.getTitle())
                    .videoUrl(saved.getCloudinaryUrl())
                    .skillTag(saved.getSkillTag())
                    .uploadedAt(saved.getUploadedAt())
                    .build());

            return toResponse(saved);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload video");
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Page<VideoResponse> getFeed(Pageable pageable) {
        return videoRepository.findAllByOrderByUploadedAtDesc(pageable).map(this::toResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public List<VideoResponse> getMyVideos(Long userId) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return videoRepository.findByPlayerIdOrderByUploadedAtDesc(player.getId())
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private VideoResponse toResponse(Video video) {
        return VideoResponse.builder()
                .id(video.getId())
                .playerId(video.getPlayer().getId())
                .playerName(video.getPlayer().getFullName())
                .title(video.getTitle())
                .cloudinaryUrl(video.getCloudinaryUrl())
                .skillTag(video.getSkillTag())
                .viewsCount(video.getViewsCount())
                .averageRating(video.getAverageRating())
                .uploadedAt(video.getUploadedAt())
                .build();
    }
}
