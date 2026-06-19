package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.TargetSkill;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdatePostRequest {

    @NotBlank
    @Size(max = 500)
    private String title;

    private TargetSkill skillTag;
}
