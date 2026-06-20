package com.kickpro.backend.repository;

import com.kickpro.backend.entity.SquadJoinRequest;
import com.kickpro.backend.entity.SquadJoinRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SquadJoinRequestRepository extends JpaRepository<SquadJoinRequest, Long> {

    Optional<SquadJoinRequest> findBySquadIdAndPlayerId(Long squadId, Long playerId);

    boolean existsBySquadIdAndPlayerIdAndStatus(Long squadId, Long playerId, SquadJoinRequestStatus status);

    @Query("""
            SELECT r FROM SquadJoinRequest r
            WHERE r.squad.captain.user.id = :userId
              AND r.status = :status
            ORDER BY r.createdAt DESC
            """)
    List<SquadJoinRequest> findByCaptainUserIdAndStatus(
            @Param("userId") Long userId,
            @Param("status") SquadJoinRequestStatus status
    );
}
