package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface MatchRepository extends JpaRepository<Match, Long> {

    List<Match> findByStatusOrderByDateTimeAsc(MatchStatus status);

    List<Match> findByOrganizerIdOrderByDateTimeDesc(Long organizerId);

    @Query("""
            SELECT m FROM Match m
            WHERE m.stadium.id = :stadiumId
            AND m.status <> com.kickpro.backend.entity.MatchStatus.CANCELLED
            AND m.dateTime < :slotEnd
            AND m.dateTime >= :slotStart
            """)
    List<Match> findOverlappingMatches(
            @Param("stadiumId") Long stadiumId,
            @Param("slotStart") LocalDateTime slotStart,
            @Param("slotEnd") LocalDateTime slotEnd
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT s FROM Stadium s WHERE s.id = :stadiumId")
    com.kickpro.backend.entity.Stadium lockStadiumForBooking(@Param("stadiumId") Long stadiumId);

    @Query("""
            SELECT DISTINCT m FROM Match m
            JOIN MatchParticipant p ON p.match = m
            WHERE p.player.user.id = :userId
            ORDER BY m.dateTime DESC
            """)
    List<Match> findMatchesForPlayer(@Param("userId") Long userId);
}
