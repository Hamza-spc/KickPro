package com.kickpro.backend.repository;

import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.entity.SubmissionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DrillSubmissionRepository extends JpaRepository<DrillSubmission, Long> {

    List<DrillSubmission> findByPlayerId(Long playerId);

    List<DrillSubmission> findByStatusOrderBySubmittedAtAsc(SubmissionStatus status);

    Optional<DrillSubmission> findTopByPlayerIdAndDrillIdOrderBySubmittedAtDesc(Long playerId, Long drillId);

    boolean existsByPlayerIdAndDrillIdAndStatus(Long playerId, Long drillId, SubmissionStatus status);
}
