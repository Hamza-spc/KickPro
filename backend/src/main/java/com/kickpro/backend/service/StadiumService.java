package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.StadiumResponse;

import java.util.List;

public interface StadiumService {

    List<StadiumResponse> getAllStadiums();

    StadiumResponse getStadiumById(Long stadiumId);
}
