package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateClubRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String city;

    @NotBlank
    private String description;

    private String logoUrl;

    private Boolean verified;
}
