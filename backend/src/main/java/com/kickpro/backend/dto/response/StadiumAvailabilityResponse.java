package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class StadiumAvailabilityResponse {

    private Long stadiumId;
    private String date;
    private List<TimeSlot> slots;

    @Getter
    @Builder
    public static class TimeSlot {
        private String time;
        private boolean available;
    }
}
