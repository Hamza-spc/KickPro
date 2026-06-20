package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.StadiumAvailabilityResponse;
import com.kickpro.backend.dto.response.StadiumResponse;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.service.StadiumService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StadiumServiceImpl implements StadiumService {

    private static final LocalTime DEFAULT_OPEN = LocalTime.of(8, 0);
    private static final LocalTime DEFAULT_CLOSE = LocalTime.of(23, 0);

    private final StadiumRepository stadiumRepository;
    private final MatchRepository matchRepository;

    @Override
    @Transactional(readOnly = true)
    public List<StadiumResponse> getAllStadiums(String city, String name) {
        String cityFilter = city != null && !city.isBlank() ? city.trim() : null;
        String nameFilter = name != null && !name.isBlank() ? name.trim() : null;

        List<Stadium> stadiums;
        if (cityFilter != null && nameFilter != null) {
            stadiums = stadiumRepository.findByCityIgnoreCaseAndNameContainingIgnoreCaseOrderByNameAsc(
                    cityFilter, nameFilter);
        } else if (cityFilter != null) {
            stadiums = stadiumRepository.findByCityIgnoreCaseOrderByNameAsc(cityFilter);
        } else if (nameFilter != null) {
            stadiums = stadiumRepository.findByNameContainingIgnoreCaseOrderByNameAsc(nameFilter);
        } else {
            stadiums = stadiumRepository.findAll();
        }

        return stadiums.stream()
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

    @Override
    @Transactional(readOnly = true)
    public StadiumAvailabilityResponse getAvailability(Long stadiumId, LocalDate date) {
        Stadium stadium = stadiumRepository.findById(stadiumId)
                .orElseThrow(() -> new ResourceNotFoundException("Stadium not found"));

        LocalTime open = stadium.getOpenTime() != null ? stadium.getOpenTime() : DEFAULT_OPEN;
        LocalTime close = stadium.getCloseTime() != null ? stadium.getCloseTime() : DEFAULT_CLOSE;

        LocalDateTime dayStart = date.atStartOfDay();
        LocalDateTime dayEnd = date.plusDays(1).atStartOfDay();
        List<Match> dayMatches = matchRepository.findByStadiumIdAndDate(stadiumId, dayStart, dayEnd);

        List<StadiumAvailabilityResponse.TimeSlot> slots = new ArrayList<>();
        LocalTime slotTime = open;
        LocalDateTime now = LocalDateTime.now();

        while (slotTime.isBefore(close)) {
            LocalDateTime slotDateTime = date.atTime(slotTime);
            boolean available = !slotDateTime.isBefore(now.plusMinutes(15))
                    && dayMatches.stream().noneMatch(match -> conflictsWithSlot(match.getDateTime(), slotDateTime));

            slots.add(StadiumAvailabilityResponse.TimeSlot.builder()
                    .time(slotTime.toString().substring(0, 5))
                    .available(available)
                    .build());

            slotTime = slotTime.plusHours(1);
        }

        return StadiumAvailabilityResponse.builder()
                .stadiumId(stadiumId)
                .date(date.toString())
                .slots(slots)
                .build();
    }

    private boolean conflictsWithSlot(LocalDateTime matchStart, LocalDateTime slotStart) {
        LocalDateTime windowStart = slotStart.minusMinutes(Match.DEFAULT_DURATION_MINUTES);
        LocalDateTime windowEnd = slotStart.plusMinutes(Match.DEFAULT_DURATION_MINUTES);
        return !matchStart.isBefore(windowStart) && matchStart.isBefore(windowEnd);
    }

    private StadiumResponse toResponse(Stadium stadium) {
        return StadiumResponse.builder()
                .id(stadium.getId())
                .name(stadium.getName())
                .location(stadium.getLocation())
                .city(stadium.getCity())
                .phoneNumber(stadium.getPhoneNumber())
                .description(stadium.getDescription())
                .pricePerHour(stadium.getPricePerHour())
                .pitchCount(stadium.getPitchCount())
                .pitchTypes(stadium.getPitchTypes())
                .allowedFormats(stadium.getAllowedFormats())
                .openTime(stadium.getOpenTime())
                .closeTime(stadium.getCloseTime())
                .grassType(stadium.getGrassType())
                .latitude(stadium.getLatitude())
                .longitude(stadium.getLongitude())
                .photos(stadium.getPhotos())
                .build();
    }
}
