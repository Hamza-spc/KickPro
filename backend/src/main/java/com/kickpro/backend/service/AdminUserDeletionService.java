package com.kickpro.backend.service;

public interface AdminUserDeletionService {

    void deleteUser(Long adminUserId, Long targetUserId);
}
