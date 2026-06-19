package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LessonRepository extends JpaRepository<Lesson, Long> {

    @Query("""
            SELECT l FROM Lesson l
            LEFT JOIN FETCH l.quiz q
            LEFT JOIN FETCH q.questions
            WHERE l.course.id = :courseId
            ORDER BY l.orderIndex ASC
            """)
    List<Lesson> findByCourseIdWithQuizOrderByOrderIndexAsc(@Param("courseId") Long courseId);

    List<Lesson> findByCourseIdOrderByOrderIndexAsc(Long courseId);

    long countByCourseId(Long courseId);

    Optional<Lesson> findTopByCourseIdOrderByOrderIndexDesc(Long courseId);
}
