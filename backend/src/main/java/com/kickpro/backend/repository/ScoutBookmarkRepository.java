package com.kickpro.backend.repository;

import com.kickpro.backend.entity.ScoutBookmark;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ScoutBookmarkRepository extends JpaRepository<ScoutBookmark, Long> {

    List<ScoutBookmark> findByScout_IdOrderByCreatedAtDesc(Long scoutId);

    Optional<ScoutBookmark> findByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);

    boolean existsByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);

    void deleteByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);

    void deleteByScout_Id(Long scoutId);

    void deleteByPlayerProfile_Id(Long playerProfileId);

    @Query("SELECT b.playerProfile.id FROM ScoutBookmark b WHERE b.scout.id = :scoutId")
    List<Long> findPlayerProfileIdByScoutId(@Param("scoutId") Long scoutId);
}
