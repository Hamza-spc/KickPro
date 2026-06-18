package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Video;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VideoRepository extends JpaRepository<Video, Long> {

    Page<Video> findAllByOrderByUploadedAtDesc(Pageable pageable);

    List<Video> findByPlayerIdOrderByUploadedAtDesc(Long playerId);
}
