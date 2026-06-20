package com.kickpro.backend.repository;

import com.kickpro.backend.entity.ScoutNote;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ScoutNoteRepository extends JpaRepository<ScoutNote, Long> {

    Optional<ScoutNote> findByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);

    List<ScoutNote> findByPlayerProfile_IdOrderByUpdatedAtDesc(Long playerProfileId);

    void deleteByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);

    boolean existsByScout_IdAndPlayerProfile_Id(Long scoutId, Long playerProfileId);
}
