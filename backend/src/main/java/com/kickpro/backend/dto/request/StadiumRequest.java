package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.GrassType;
import com.kickpro.backend.entity.PitchType;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

@Getter
@Setter
public class StadiumRequest {

    @NotBlank
    @Size(max = 200)
    private String name;

    @NotBlank
    @Size(max = 500)
    private String location;

    @NotBlank
    @Size(max = 100)
    private String city;

    @Size(max = 30)
    private String phoneNumber;

    @Size(max = 2000)
    private String description;

    @NotNull
    @DecimalMin("0.0")
    private BigDecimal pricePerHour;

    @NotNull
    private Integer pitchCount;

    private List<PitchType> pitchTypes;

    private List<String> allowedFormats;

    private LocalTime openTime;

    private LocalTime closeTime;

    private GrassType grassType;

    private Double latitude;

    private Double longitude;
}
