package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Course;
import com.kickpro.backend.entity.DrillLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseRepository extends JpaRepository<Course, Long> {

    List<Course> findAllByOrderByTitleAsc();

    List<Course> findByLevelOrderByTitleAsc(DrillLevel level);

    boolean existsByTitle(String title);
}
