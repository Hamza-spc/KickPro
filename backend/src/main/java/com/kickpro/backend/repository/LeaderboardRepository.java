package com.kickpro.backend.repository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import com.kickpro.backend.entity.PlayerProfile;

import java.util.List;

public interface LeaderboardRepository extends Repository<PlayerProfile, Long> {

    @Query(value = """
            SELECT pp.id, pp.full_name, pp.profile_photo_url, pp.city, COUNT(mp.id) AS metric
            FROM match_participants mp
            JOIN player_profiles pp ON mp.player_id = pp.id
            WHERE mp.status = 'APPROVED'
            GROUP BY pp.id, pp.full_name, pp.profile_photo_url, pp.city
            ORDER BY metric DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<Object[]> findTopByMatchCount(@Param("limit") int limit);

    @Query(value = """
            SELECT pp.id, pp.full_name, pp.profile_photo_url, pp.city, COUNT(b.id) AS metric
            FROM badges b
            JOIN player_profiles pp ON b.player_id = pp.id
            GROUP BY pp.id, pp.full_name, pp.profile_photo_url, pp.city
            ORDER BY metric DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<Object[]> findTopByBadgeCount(@Param("limit") int limit);

    @Query(value = """
            SELECT pp.id, pp.full_name, pp.profile_photo_url, pp.city,
                   AVG((pr.performance_score + pr.punctuality_score + pr.teamwork_score + pr.behavior_score) / 4.0) AS metric
            FROM player_ratings pr
            JOIN player_profiles pp ON pr.rated_player_id = pp.id
            GROUP BY pp.id, pp.full_name, pp.profile_photo_url, pp.city
            HAVING COUNT(pr.id) >= 1
            ORDER BY metric DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<Object[]> findTopByAverageRating(@Param("limit") int limit);
}
