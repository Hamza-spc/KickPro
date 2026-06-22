package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Certification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CertificationRepository extends JpaRepository<Certification, Long> {

    List<Certification> findByPlayerIdOrderByEarnedAtDesc(Long playerId);

    long countByPlayerId(Long playerId);

    boolean existsByPlayerIdAndCourseId(Long playerId, Long courseId);

    Optional<Certification> findByPlayerIdAndCourseId(Long playerId, Long courseId);

    void deleteByPlayerId(Long playerId);
}
