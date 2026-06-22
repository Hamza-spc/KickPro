package com.kickpro.backend.repository;

import com.kickpro.backend.entity.ChallengeSubmission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChallengeSubmissionRepository extends JpaRepository<ChallengeSubmission, Long> {

    List<ChallengeSubmission> findByChallengeIdOrderByVotesDescSubmittedAtAsc(Long challengeId);

    Optional<ChallengeSubmission> findByChallengeIdAndPlayerId(Long challengeId, Long playerId);

    void deleteByPlayerId(Long playerId);
}
