package com.kickpro.backend.repository;

import com.kickpro.backend.entity.WeeklyChallenge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface WeeklyChallengeRepository extends JpaRepository<WeeklyChallenge, Long> {

    Optional<WeeklyChallenge> findFirstByActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByStartDateDesc(
            LocalDate today,
            LocalDate todayAgain
    );
}
