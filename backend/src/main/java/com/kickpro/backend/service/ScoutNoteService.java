package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.ScoutNoteRequest;
import com.kickpro.backend.dto.response.ScoutNoteResponse;

public interface ScoutNoteService {

    ScoutNoteResponse getNote(Long scoutUserId, Long playerProfileId);

    ScoutNoteResponse createNote(Long scoutUserId, Long playerProfileId, ScoutNoteRequest request);

    ScoutNoteResponse updateNote(Long scoutUserId, Long playerProfileId, ScoutNoteRequest request);

    void deleteNote(Long scoutUserId, Long playerProfileId);
}
