package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.ScoutNoteResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.ScoutNote;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.ScoutNoteRepository;
import com.kickpro.backend.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/players/notes")
@RequiredArgsConstructor
public class PlayerNotesController {

    private final PlayerProfileRepository playerProfileRepository;
    private final ScoutNoteRepository scoutNoteRepository;

    @GetMapping("/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<ScoutNoteResponse>>> myNotes() {
        UserPrincipal user = SecurityUtils.getCurrentUser();

        PlayerProfile profile = playerProfileRepository.findByUserId(user.getUserId())
                .orElseThrow(() -> new BadRequestException("Create your profile before viewing notes"));

        List<ScoutNote> notes = scoutNoteRepository.findByPlayerProfile_IdOrderByUpdatedAtDesc(profile.getId());
        List<ScoutNoteResponse> responses = notes.stream()
                .map(note -> ScoutNoteResponse.builder()
                        .id(note.getId())
                        .playerProfileId(note.getPlayerProfile().getId())
                        .scoutUserId(note.getScout().getId())
                        .scoutName(note.getScout().getEmail())
                        .scoutEmail(note.getScout().getEmail())
                        .technicalAbility(note.getTechnicalAbility())
                        .potential(note.getPotential())
                        .note(note.getNote())
                        .createdAt(note.getCreatedAt())
                        .updatedAt(note.getUpdatedAt())
                        .build())
                .toList();

        return ResponseEntity.ok(ApiResponse.success(responses, "Notes retrieved successfully"));
    }
}

