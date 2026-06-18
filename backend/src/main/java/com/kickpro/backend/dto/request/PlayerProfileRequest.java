package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class PlayerProfileRequest {

    @NotBlank
    @Size(max = 100)
    private String fullName;

    @NotNull
    @Past
    private LocalDate dateOfBirth;

    @NotBlank
    @Size(max = 100)
    private String city;

    @NotNull
    private Position position;

    @NotNull
    private PreferredFoot preferredFoot;

    @Size(max = 1000)
    private String bio;

    @NotNull
    @Min(100)
    @Max(250)
    private Integer height;

    @NotNull
    @Min(30)
    @Max(200)
    private Integer weight;
}
