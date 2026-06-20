package com.kickpro.backend.repository;

import com.kickpro.backend.entity.SquadMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SquadMemberRepository extends JpaRepository<SquadMember, Long> {

    List<SquadMember> findBySquadIdOrderByJoinedAtAsc(Long squadId);

    boolean existsBySquadIdAndPlayerId(Long squadId, Long playerId);

    Optional<SquadMember> findBySquadIdAndPlayerId(Long squadId, Long playerId);
}
