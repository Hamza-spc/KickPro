package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.GrassType;
import com.kickpro.backend.entity.PitchType;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

@Getter
@Builder
public class StadiumResponse {

    private Long id;
    private String name;
    private String location;
    private String phoneNumber;
    private String description;
    private BigDecimal pricePerHour;
    private Integer pitchCount;
    private List<PitchType> pitchTypes;
    private LocalTime openTime;
    private LocalTime closeTime;
    private GrassType grassType;
    private Double latitude;
    private Double longitude;
    private List<String> photos;
}
