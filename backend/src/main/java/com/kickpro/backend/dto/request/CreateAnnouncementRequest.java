package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.AnnouncementType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateAnnouncementRequest {

    @NotBlank
    private String title;

    @NotBlank
    private String content;

    @NotNull
    private AnnouncementType type;

    private String city;
}
