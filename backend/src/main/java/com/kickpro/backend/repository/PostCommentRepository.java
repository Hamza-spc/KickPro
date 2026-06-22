package com.kickpro.backend.repository;

import com.kickpro.backend.entity.PostComment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostCommentRepository extends JpaRepository<PostComment, Long> {

    List<PostComment> findByPostIdOrderByCreatedAtAsc(Long postId);

    long countByPostId(Long postId);

    void deleteByPostId(Long postId);

    void deleteByAuthor_Id(Long authorId);
}
