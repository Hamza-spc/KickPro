package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Skills;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface SkillsRepository extends JpaRepository<Skills, Long> {

    Optional<Skills> findByPlayerProfileId(Long playerProfileId);

    List<Skills> findByPlayerProfileIdIn(Collection<Long> playerProfileIds);

    void deleteByPlayerProfileId(Long playerProfileId);
}
