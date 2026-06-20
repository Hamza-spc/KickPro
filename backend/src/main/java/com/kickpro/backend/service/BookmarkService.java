package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.PlayerSearchResultResponse;

import java.util.List;
import java.util.Set;

public interface BookmarkService {

    void bookmark(Long scoutUserId, Long playerProfileId);

    void unbookmark(Long scoutUserId, Long playerProfileId);

    List<PlayerSearchResultResponse> getBookmarks(Long scoutUserId);

    Set<Long> getBookmarkedProfileIds(Long scoutUserId);

    boolean isBookmarked(Long scoutUserId, Long playerProfileId);
}
