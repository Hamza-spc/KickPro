package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.ReactionType;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReactToPostRequest {

    @NotNull
    private ReactionType reactionType;
}
