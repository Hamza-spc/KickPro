package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateSquadRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String city;
}
