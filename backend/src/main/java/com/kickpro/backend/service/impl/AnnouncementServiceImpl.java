package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateAnnouncementRequest;
import com.kickpro.backend.dto.response.AnnouncementResponse;
import com.kickpro.backend.entity.Announcement;
import com.kickpro.backend.entity.AnnouncementType;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.exception.UnauthorizedException;
import com.kickpro.backend.repository.AnnouncementRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.AnnouncementService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnnouncementServiceImpl implements AnnouncementService {

    private final AnnouncementRepository announcementRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    @Transactional(readOnly = true)
    public List<AnnouncementResponse> getAnnouncements(Long viewerUserId, String city) {
        List<Announcement> announcements = city != null && !city.isBlank()
                ? announcementRepository.findByCityIgnoreCaseOrderByCreatedAtDesc(city.trim())
                : announcementRepository.findAllByOrderByCreatedAtDesc();
        return announcements.stream()
                .map(announcement -> toResponse(announcement, viewerUserId))
                .toList();
    }

    @Override
    @Transactional
    public AnnouncementResponse create(Long authorUserId, CreateAnnouncementRequest request) {
        User author = userRepository.findById(authorUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (author.getRole() == Role.AGENT && !Boolean.TRUE.equals(author.getAgentVerified())) {
            throw new UnauthorizedException("Agent must be verified to post announcements");
        }

        AnnouncementType type = request.getType();
        if (author.getRole() == Role.AGENT && type != AnnouncementType.OFFICIAL_TRIAL && type != AnnouncementType.TRIAL) {
            type = AnnouncementType.OFFICIAL_TRIAL;
        }

        Announcement announcement = Announcement.builder()
                .author(author)
                .title(request.getTitle().trim())
                .content(request.getContent().trim())
                .type(type)
                .city(request.getCity() != null && !request.getCity().isBlank() ? request.getCity().trim() : null)
                .build();

        return toResponse(announcementRepository.save(announcement), authorUserId);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long announcementId) {
        Announcement announcement = announcementRepository.findById(announcementId)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!announcement.getAuthor().getId().equals(userId) && user.getRole() != Role.ADMIN) {
            throw new UnauthorizedException("Not allowed to delete this announcement");
        }

        announcementRepository.delete(announcement);
    }

    @Override
    @Transactional
    public AnnouncementResponse uploadImage(Long userId, Long announcementId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Image file is required");
        }

        Announcement announcement = announcementRepository.findById(announcementId)
                .orElseThrow(() -> new ResourceNotFoundException("Announcement not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!announcement.getAuthor().getId().equals(userId) && user.getRole() != Role.ADMIN) {
            throw new UnauthorizedException("Not allowed to update this announcement");
        }

        try {
            String publicId = "announcement-" + announcementId;
            String url = cloudinaryService.uploadImage(file, "kickpro/announcements", publicId);
            announcement.setImageUrl(url);
            return toResponse(announcementRepository.save(announcement), userId);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload announcement image");
        }
    }

    private AnnouncementResponse toResponse(Announcement announcement, Long viewerUserId) {
        User author = announcement.getAuthor();
        String authorName = author.getEmail().split("@")[0];

        boolean official = announcement.getType() == AnnouncementType.OFFICIAL_TRIAL
                || (author.getRole() == Role.AGENT && Boolean.TRUE.equals(author.getAgentVerified()));

        boolean ownAnnouncement = viewerUserId != null && author.getId().equals(viewerUserId);

        return AnnouncementResponse.builder()
                .id(announcement.getId())
                .title(announcement.getTitle())
                .content(announcement.getContent())
                .type(announcement.getType())
                .city(announcement.getCity())
                .imageUrl(announcement.getImageUrl())
                .authorName(authorName)
                .authorRole(author.getRole().name())
                .official(official)
                .ownAnnouncement(ownAnnouncement)
                .createdAt(announcement.getCreatedAt())
                .build();
    }
}
