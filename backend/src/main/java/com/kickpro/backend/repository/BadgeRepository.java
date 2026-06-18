package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Badge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BadgeRepository extends JpaRepository<Badge, Long> {

    List<Badge> findByPlayerIdOrderByEarnedAtDesc(Long playerId);

    Optional<Badge> findByPlayerIdAndDrillId(Long playerId, Long drillId);
}
