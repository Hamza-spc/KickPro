package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Stadium;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StadiumRepository extends JpaRepository<Stadium, Long> {

    List<Stadium> findByCityIgnoreCaseOrderByNameAsc(String city);

    List<Stadium> findByNameContainingIgnoreCaseOrderByNameAsc(String name);

    List<Stadium> findByCityIgnoreCaseAndNameContainingIgnoreCaseOrderByNameAsc(String city, String name);
}
