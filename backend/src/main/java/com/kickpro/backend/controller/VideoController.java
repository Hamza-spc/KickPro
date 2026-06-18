package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.VideoResponse;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.service.VideoService;
import com.kickpro.backend.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/videos")
@RequiredArgsConstructor
public class VideoController {

    private final VideoService videoService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<VideoResponse>> uploadVideo(
            @RequestParam String title,
            @RequestParam TargetSkill skillTag,
            @RequestPart("file") MultipartFile file
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        VideoResponse response = videoService.uploadVideo(user.getUserId(), title, skillTag, file);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Video uploaded successfully"));
    }

    @GetMapping("/feed")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<VideoResponse>>> getFeed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<VideoResponse> feed = videoService.getFeed(PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(feed, "Video feed retrieved successfully"));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<VideoResponse>>> getMyVideos() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<VideoResponse> videos = videoService.getMyVideos(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(videos, "Your videos retrieved successfully"));
    }
}
