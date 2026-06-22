package com.kickpro.backend.repository;

import com.kickpro.backend.entity.DirectMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DirectMessageRepository extends JpaRepository<DirectMessage, Long> {

    @Query("""
            SELECT m FROM DirectMessage m
            WHERE (m.sender.id = :userId AND m.receiver.id = :otherUserId)
               OR (m.sender.id = :otherUserId AND m.receiver.id = :userId)
            ORDER BY m.createdAt ASC
            """)
    List<DirectMessage> findConversation(@Param("userId") Long userId, @Param("otherUserId") Long otherUserId);

    @Query("""
            SELECT m FROM DirectMessage m
            WHERE m.sender.id = :userId OR m.receiver.id = :userId
            ORDER BY m.createdAt DESC
            """)
    List<DirectMessage> findByUserInvolvedOrderByCreatedAtDesc(@Param("userId") Long userId);

    @Modifying
    @Query("DELETE FROM DirectMessage m WHERE m.sender.id = :userId OR m.receiver.id = :userId")
    void deleteByUserInvolved(@Param("userId") Long userId);
}
