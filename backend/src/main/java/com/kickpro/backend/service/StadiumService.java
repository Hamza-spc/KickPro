package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.StadiumAvailabilityResponse;
import com.kickpro.backend.dto.response.StadiumResponse;

import java.time.LocalDate;
import java.util.List;

public interface StadiumService {

    List<StadiumResponse> getAllStadiums(String city);

    StadiumResponse getStadiumById(Long stadiumId);

    StadiumAvailabilityResponse getAvailability(Long stadiumId, LocalDate date);
}
