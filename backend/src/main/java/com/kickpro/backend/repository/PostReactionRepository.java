package com.kickpro.backend.repository;

import com.kickpro.backend.entity.PostReaction;
import com.kickpro.backend.entity.ReactionType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface PostReactionRepository extends JpaRepository<PostReaction, Long> {

    Optional<PostReaction> findByPostIdAndReactorId(Long postId, Long reactorId);

    long countByPostIdAndReactionType(Long postId, ReactionType reactionType);

    @Query("SELECT COUNT(r) FROM PostReaction r WHERE r.post.id = :postId")
    long countByPostId(@Param("postId") Long postId);

    void deleteByPostIdAndReactorId(Long postId, Long reactorId);

    void deleteByPostId(Long postId);

    void deleteByReactorId(Long reactorId);
}
