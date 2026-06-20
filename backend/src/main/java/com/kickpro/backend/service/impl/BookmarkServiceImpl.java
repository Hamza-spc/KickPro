package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.ScoutBookmark;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.ScoutBookmarkRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.BookmarkService;
import com.kickpro.backend.service.PlayerSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class BookmarkServiceImpl implements BookmarkService {

    private final ScoutBookmarkRepository scoutBookmarkRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final PlayerSearchService playerSearchService;

    @Override
    @Transactional
    public void bookmark(Long scoutUserId, Long playerProfileId) {
        User scout = userRepository.findById(scoutUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        PlayerProfile profile = playerProfileRepository.findById(playerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        if (scoutBookmarkRepository.existsByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId)) {
            return;
        }

        scoutBookmarkRepository.save(ScoutBookmark.builder()
                .scout(scout)
                .playerProfile(profile)
                .build());
    }

    @Override
    @Transactional
    public void unbookmark(Long scoutUserId, Long playerProfileId) {
        scoutBookmarkRepository.deleteByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PlayerSearchResultResponse> getBookmarks(Long scoutUserId) {
        List<ScoutBookmark> bookmarks = scoutBookmarkRepository.findByScout_IdOrderByCreatedAtDesc(scoutUserId);
        List<PlayerProfile> profiles = bookmarks.stream()
                .map(ScoutBookmark::getPlayerProfile)
                .toList();
        return playerSearchService.toSearchResults(profiles);
    }

    @Override
    @Transactional(readOnly = true)
    public Set<Long> getBookmarkedProfileIds(Long scoutUserId) {
        return new HashSet<>(scoutBookmarkRepository.findPlayerProfileIdByScoutId(scoutUserId));
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isBookmarked(Long scoutUserId, Long playerProfileId) {
        return scoutBookmarkRepository.existsByScout_IdAndPlayerProfile_Id(scoutUserId, playerProfileId);
    }
}
