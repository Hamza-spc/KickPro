package com.kickpro.backend.repository;

import com.kickpro.backend.entity.PlayerFollow;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PlayerFollowRepository extends JpaRepository<PlayerFollow, Long> {

    boolean existsByFollowerIdAndFollowingId(Long followerId, Long followingId);

    Optional<PlayerFollow> findByFollowerIdAndFollowingId(Long followerId, Long followingId);

    long countByFollowingId(Long followingId);

    long countByFollowerId(Long followerId);

    void deleteByFollowerIdAndFollowingId(Long followerId, Long followingId);

    void deleteByFollowerId(Long followerId);

    void deleteByFollowingId(Long followingId);
}
