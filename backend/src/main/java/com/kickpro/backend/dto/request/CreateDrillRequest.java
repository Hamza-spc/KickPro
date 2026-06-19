package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.TargetSkill;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateDrillRequest {

    @NotBlank
    @Size(max = 200)
    private String title;

    @NotBlank
    @Size(max = 2000)
    private String description;

    @NotBlank
    @Size(max = 2000)
    private String rules;

    @NotNull
    private DrillLevel level;

    @NotNull
    private Integer progressionOrder;

    private Long parentDrillId;

    @NotNull
    private TargetSkill targetSkill;
}
