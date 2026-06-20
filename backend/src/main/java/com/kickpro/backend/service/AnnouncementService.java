package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateAnnouncementRequest;
import com.kickpro.backend.dto.response.AnnouncementResponse;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface AnnouncementService {

    List<AnnouncementResponse> getAnnouncements(Long viewerUserId, String city);

    AnnouncementResponse create(Long authorUserId, CreateAnnouncementRequest request);

    AnnouncementResponse uploadImage(Long userId, Long announcementId, MultipartFile file);

    void delete(Long userId, Long announcementId);
}
