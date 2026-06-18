package com.kickpro.backend.event;

import com.kickpro.backend.entity.TargetSkill;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VideoUploadedEvent {

    private Long videoId;
    private Long playerId;
    private String title;
    private String videoUrl;
    private TargetSkill skillTag;
    private LocalDateTime uploadedAt;
}
