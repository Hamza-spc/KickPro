package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Announcement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AnnouncementRepository extends JpaRepository<Announcement, Long> {

    List<Announcement> findAllByOrderByCreatedAtDesc();

    List<Announcement> findByCityIgnoreCaseOrderByCreatedAtDesc(String city);
}
