package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Builder
public class StadiumResponse {

    private Long id;
    private String name;
    private String location;
    private String description;
    private BigDecimal pricePerHour;
    private List<String> photos;
}
