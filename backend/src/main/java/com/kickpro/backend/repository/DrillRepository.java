package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DrillRepository extends JpaRepository<Drill, Long> {

    List<Drill> findByLevelOrderByProgressionOrderAsc(DrillLevel level);

    long count();
}
