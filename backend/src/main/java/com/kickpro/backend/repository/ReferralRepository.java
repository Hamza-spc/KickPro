package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Referral;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ReferralRepository extends JpaRepository<Referral, Long> {

    boolean existsByReferredId(Long referredUserId);

    long countByReferrerId(Long referrerUserId);

    Optional<Referral> findByReferredId(Long referredUserId);

    void deleteByReferrerId(Long referrerUserId);

    void deleteByReferredId(Long referredUserId);
}
