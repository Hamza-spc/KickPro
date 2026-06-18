package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.StadiumResponse;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.service.StadiumService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class StadiumServiceImpl implements StadiumService {

    private final StadiumRepository stadiumRepository;

    @Override
    @Transactional(readOnly = true)
    public List<StadiumResponse> getAllStadiums() {
        return stadiumRepository.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public StadiumResponse getStadiumById(Long stadiumId) {
        Stadium stadium = stadiumRepository.findById(stadiumId)
                .orElseThrow(() -> new ResourceNotFoundException("Stadium not found"));
        return toResponse(stadium);
    }

    private StadiumResponse toResponse(Stadium stadium) {
        return StadiumResponse.builder()
                .id(stadium.getId())
                .name(stadium.getName())
                .location(stadium.getLocation())
                .description(stadium.getDescription())
                .pricePerHour(stadium.getPricePerHour())
                .photos(stadium.getPhotos())
                .build();
    }
}
