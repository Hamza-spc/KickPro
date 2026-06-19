package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateCommentRequest;
import com.kickpro.backend.dto.request.ReactToPostRequest;
import com.kickpro.backend.dto.request.UpdatePostRequest;
import com.kickpro.backend.dto.response.CommentResponse;
import com.kickpro.backend.dto.response.PostResponse;
import com.kickpro.backend.entity.PostType;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.service.PostService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PostResponse>> createPost(
            @RequestParam String title,
            @RequestParam PostType postType,
            @RequestParam(required = false) TargetSkill skillTag,
            @RequestPart(value = "file", required = false) MultipartFile file
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PostResponse response = postService.createPost(user.getUserId(), title, postType, skillTag, file);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Post created successfully"));
    }

    @GetMapping("/feed")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getFeed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        Page<PostResponse> feed = postService.getFeed(user.getUserId(), PageRequest.of(page, size));
        return ResponseEntity.ok(ApiResponse.success(feed, "Feed retrieved successfully"));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PostResponse>> updatePost(
            @PathVariable Long id,
            @Valid @RequestBody UpdatePostRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PostResponse response = postService.updatePost(user.getUserId(), id, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Post updated successfully"));
    }

    @GetMapping("/{id}/comments")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<CommentResponse>>> getComments(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(postService.getComments(id), "Comments retrieved"));
    }

    @PostMapping("/{id}/comments")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<CommentResponse>> addComment(
            @PathVariable Long id,
            @Valid @RequestBody CreateCommentRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        CommentResponse response = postService.addComment(user.getUserId(), id, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Comment added"));
    }

    @PostMapping("/{id}/reactions")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<PostResponse>> react(
            @PathVariable Long id,
            @Valid @RequestBody ReactToPostRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PostResponse response = postService.react(user.getUserId(), id, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Reaction updated"));
    }
}
