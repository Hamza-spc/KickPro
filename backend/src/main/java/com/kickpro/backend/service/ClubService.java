package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateClubRequest;
import com.kickpro.backend.dto.response.ClubResponse;

import java.util.List;

public interface ClubService {

    List<ClubResponse> getClubs(String city);

    ClubResponse getClubById(Long clubId);

    ClubResponse createClub(Long adminUserId, CreateClubRequest request);
}
