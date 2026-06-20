package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.service.BookmarkService;
import com.kickpro.backend.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/v1/scouts/bookmarks")
@RequiredArgsConstructor
public class BookmarkController {

    private final BookmarkService bookmarkService;

    @GetMapping
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<PlayerSearchResultResponse>>> getBookmarks() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                bookmarkService.getBookmarks(user.getUserId()),
                "Bookmarks retrieved successfully"
        ));
    }

    @GetMapping("/ids")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Set<Long>>> getBookmarkIds() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                bookmarkService.getBookmarkedProfileIds(user.getUserId()),
                "Bookmark IDs retrieved successfully"
        ));
    }

    @PostMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> bookmark(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        bookmarkService.bookmark(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(null, "Player bookmarked"));
    }

    @DeleteMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> unbookmark(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        bookmarkService.unbookmark(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(null, "Bookmark removed"));
    }
}
