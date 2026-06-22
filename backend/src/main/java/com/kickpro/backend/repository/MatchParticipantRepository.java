package com.kickpro.backend.repository;

import com.kickpro.backend.entity.MatchParticipant;
import com.kickpro.backend.entity.ParticipantStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MatchParticipantRepository extends JpaRepository<MatchParticipant, Long> {

    List<MatchParticipant> findByMatchIdOrderByJoinedAtAsc(Long matchId);

    long countByMatchIdAndStatus(Long matchId, ParticipantStatus status);

    boolean existsByMatchIdAndPlayerId(Long matchId, Long playerId);

    Optional<MatchParticipant> findByMatchIdAndPlayerId(Long matchId, Long playerId);

    long countByPlayerIdAndStatus(Long playerId, ParticipantStatus status);

    List<MatchParticipant> findByPlayerIdOrderByJoinedAtDesc(Long playerId);

    void deleteByPlayerId(Long playerId);

    void deleteByMatchId(Long matchId);
}
