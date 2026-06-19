package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateCommentRequest;
import com.kickpro.backend.dto.request.ReactToPostRequest;
import com.kickpro.backend.dto.request.UpdatePostRequest;
import com.kickpro.backend.dto.response.CommentResponse;
import com.kickpro.backend.dto.response.PostResponse;
import com.kickpro.backend.entity.PostType;
import com.kickpro.backend.entity.TargetSkill;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PostService {

    PostResponse createPost(Long userId, String title, PostType postType, TargetSkill skillTag, MultipartFile file);

    PostResponse updatePost(Long userId, Long postId, UpdatePostRequest request);

    Page<PostResponse> getFeed(Long viewerUserId, Pageable pageable);

    List<CommentResponse> getComments(Long postId);

    CommentResponse addComment(Long userId, Long postId, CreateCommentRequest request);

    PostResponse react(Long userId, Long postId, ReactToPostRequest request);

    void follow(Long userId, Long targetProfileId);

    void unfollow(Long userId, Long targetProfileId);
}
