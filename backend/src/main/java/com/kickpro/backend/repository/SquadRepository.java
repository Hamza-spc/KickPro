package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Squad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SquadRepository extends JpaRepository<Squad, Long> {

    @Query("""
            SELECT DISTINCT s FROM Squad s
            LEFT JOIN SquadMember m ON m.squad = s
            WHERE s.captain.user.id = :userId OR m.player.user.id = :userId
            ORDER BY s.createdAt DESC
            """)
    List<Squad> findMine(@Param("userId") Long userId);

    List<Squad> findByCaptainUserIdOrderByCreatedAtDesc(Long userId);

    List<Squad> findByCityIgnoreCaseOrderByCreatedAtDesc(String city);
}
