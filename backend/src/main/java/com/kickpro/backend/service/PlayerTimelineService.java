package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.TimelineEventResponse;

import java.util.List;

public interface PlayerTimelineService {

    List<TimelineEventResponse> getTimeline(Long profileId);
}
