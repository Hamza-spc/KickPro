package com.kickpro.backend.repository;

import com.kickpro.backend.entity.PlayerRating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PlayerRatingRepository extends JpaRepository<PlayerRating, Long> {

    boolean existsByMatchIdAndRaterIdAndRatedPlayerId(Long matchId, Long raterId, Long ratedPlayerId);

    List<PlayerRating> findByMatchId(Long matchId);

    Optional<PlayerRating> findByMatchIdAndRaterIdAndRatedPlayerId(
            Long matchId, Long raterId, Long ratedPlayerId
    );

    List<PlayerRating> findByRatedPlayerId(Long ratedPlayerId);
}
