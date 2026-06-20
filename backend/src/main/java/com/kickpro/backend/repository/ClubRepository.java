package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Club;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ClubRepository extends JpaRepository<Club, Long> {

    List<Club> findAllByOrderByNameAsc();

    List<Club> findByCityIgnoreCaseOrderByNameAsc(String city);
}
