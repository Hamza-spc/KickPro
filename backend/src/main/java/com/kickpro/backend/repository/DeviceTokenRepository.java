package com.kickpro.backend.repository;

import com.kickpro.backend.entity.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeviceTokenRepository extends JpaRepository<DeviceToken, Long> {

    List<DeviceToken> findByUser_Id(Long userId);

    Optional<DeviceToken> findByUser_IdAndToken(Long userId, String token);

    void deleteByUser_IdAndToken(Long userId, String token);

    void deleteByUser_Id(Long userId);
}
