package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.ScoutNoteRequest;
import com.kickpro.backend.dto.response.ScoutNoteResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.ScoutNote;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.ScoutNoteRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.ScoutNoteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ScoutNoteServiceImpl implements ScoutNoteService {

    private final ScoutNoteRepository scoutNoteRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;

    @Override
    @Transactional(readOnly = true)
    public ScoutNoteResponse getNote(Long scoutUserId, Long playerProfileId) {
        ScoutNote note = scoutNoteRepository.findByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Scout note not found"));
        return toResponse(note);
    }

    @Override
    @Transactional
    public ScoutNoteResponse createNote(Long scoutUserId, Long playerProfileId, ScoutNoteRequest request) {
        if (scoutNoteRepository.existsByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId)) {
            throw new BadRequestException("A note already exists for this player. Use PUT to update it.");
        }

        User scout = userRepository.findById(scoutUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        PlayerProfile profile = playerProfileRepository.findById(playerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        ScoutNote note = ScoutNote.builder()
                .scout(scout)
                .playerProfile(profile)
                .technicalAbility(request.getTechnicalAbility())
                .potential(request.getPotential())
                .note(request.getNote().trim())
                .build();

        return toResponse(scoutNoteRepository.save(note));
    }

    @Override
    @Transactional
    public ScoutNoteResponse updateNote(Long scoutUserId, Long playerProfileId, ScoutNoteRequest request) {
        ScoutNote note = scoutNoteRepository.findByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Scout note not found"));

        note.setTechnicalAbility(request.getTechnicalAbility());
        note.setPotential(request.getPotential());
        note.setNote(request.getNote().trim());

        return toResponse(scoutNoteRepository.save(note));
    }

    @Override
    @Transactional
    public void deleteNote(Long scoutUserId, Long playerProfileId) {
        if (!scoutNoteRepository.existsByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId)) {
            throw new ResourceNotFoundException("Scout note not found");
        }
        scoutNoteRepository.deleteByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId);
    }

    private ScoutNoteResponse toResponse(ScoutNote note) {
        return ScoutNoteResponse.builder()
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
                .build();
    }
}
