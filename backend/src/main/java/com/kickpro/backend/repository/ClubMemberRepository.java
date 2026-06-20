package com.kickpro.backend.repository;

import com.kickpro.backend.entity.ClubMember;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClubMemberRepository extends JpaRepository<ClubMember, Long> {

    long countByClubId(Long clubId);
}
