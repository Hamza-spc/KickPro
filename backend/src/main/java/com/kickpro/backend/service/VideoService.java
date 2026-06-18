package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.VideoResponse;
import com.kickpro.backend.entity.TargetSkill;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface VideoService {

    VideoResponse uploadVideo(Long userId, String title, TargetSkill skillTag, MultipartFile file);

    Page<VideoResponse> getFeed(Pageable pageable);

    List<VideoResponse> getMyVideos(Long userId);
}
