package com.kickpro.backend.repository;

import com.kickpro.backend.entity.PlayerProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface PlayerProfileRepository extends JpaRepository<PlayerProfile, Long>, JpaSpecificationExecutor<PlayerProfile> {

    Optional<PlayerProfile> findByUserId(Long userId);

    @Query("SELECT DISTINCT p.city FROM PlayerProfile p ORDER BY p.city ASC")
    List<String> findDistinctCitiesAsc();
}
