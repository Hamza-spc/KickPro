package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.StadiumAvailabilityResponse;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.StadiumRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@DisplayName("StadiumService — disponibilité des créneaux")
class StadiumServiceImplTest {

    @Mock
    private StadiumRepository stadiumRepository;

    @Mock
    private MatchRepository matchRepository;

    @InjectMocks
    private StadiumServiceImpl stadiumService;

    @Test
    @DisplayName("Retourne 16 créneaux pour un stade fermant à 23:50")
    void getAvailability_lateClosingTime_returnsSixteenSlots() {
        Stadium stadium = Stadium.builder()
                .id(14L)
                .name("complexe foot agdal")
                .location("agdal")
                .city("Rabat")
                .pricePerHour(BigDecimal.valueOf(350))
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(23, 50))
                .build();

        LocalDate date = LocalDate.of(2026, 6, 25);

        when(stadiumRepository.findById(14L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findByStadiumIdAndDate(eq(14L), any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(List.of());

        StadiumAvailabilityResponse availability = stadiumService.getAvailability(14L, date);

        assertEquals(16, availability.getSlots().size());
        assertEquals("08:00", availability.getSlots().getFirst().getTime());
        assertEquals("23:00", availability.getSlots().getLast().getTime());
        System.out.println("[VALIDATION OK] API disponibilité : 16 créneaux pour stade 08:00–23:50");
    }

    @Test
    @DisplayName("Marque indisponible un créneau en conflit avec un match existant")
    void getAvailability_marksBookedSlotUnavailable() {
        Stadium stadium = Stadium.builder()
                .id(1L)
                .name("test stadium")
                .location("test")
                .city("Rabat")
                .pricePerHour(BigDecimal.valueOf(200))
                .openTime(LocalTime.of(10, 0))
                .closeTime(LocalTime.of(22, 0))
                .build();

        LocalDate date = LocalDate.now().plusDays(3);
        LocalDateTime matchStart = date.atTime(14, 0);

        when(stadiumRepository.findById(1L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findByStadiumIdAndDate(eq(1L), any(LocalDateTime.class), any(LocalDateTime.class)))
                .thenReturn(List.of(
                        com.kickpro.backend.entity.Match.builder()
                                .dateTime(matchStart)
                                .build()
                ));

        StadiumAvailabilityResponse availability = stadiumService.getAvailability(1L, date);

        var slot14 = availability.getSlots().stream()
                .filter(s -> "14:00".equals(s.getTime()))
                .findFirst()
                .orElseThrow();

        assertFalse(slot14.isAvailable());
        System.out.println("[VALIDATION OK] Créneau 14:00 marqué indisponible (match existant)");
    }
}
