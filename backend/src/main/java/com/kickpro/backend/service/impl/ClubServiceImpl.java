package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateClubRequest;
import com.kickpro.backend.dto.response.ClubResponse;
import com.kickpro.backend.entity.Club;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.ClubMemberRepository;
import com.kickpro.backend.repository.ClubRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.ClubService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ClubServiceImpl implements ClubService {

    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ClubResponse> getClubs(String city) {
        List<Club> clubs = (city == null || city.isBlank())
                ? clubRepository.findAllByOrderByNameAsc()
                : clubRepository.findByCityIgnoreCaseOrderByNameAsc(city.trim());
        return clubs.stream().map(this::toResponse).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ClubResponse getClubById(Long clubId) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new ResourceNotFoundException("Club not found"));
        return toResponse(club);
    }

    @Override
    @Transactional
    public ClubResponse createClub(Long adminUserId, CreateClubRequest request) {
        User owner = userRepository.findById(adminUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Club club = Club.builder()
                .name(request.getName().trim())
                .city(request.getCity().trim())
                .description(request.getDescription().trim())
                .logoUrl(request.getLogoUrl())
                .verified(Boolean.TRUE.equals(request.getVerified()))
                .owner(owner)
                .build();

        return toResponse(clubRepository.save(club));
    }

    private ClubResponse toResponse(Club club) {
        return ClubResponse.builder()
                .id(club.getId())
                .name(club.getName())
                .city(club.getCity())
                .description(club.getDescription())
                .logoUrl(club.getLogoUrl())
                .verified(Boolean.TRUE.equals(club.getVerified()))
                .ownerId(club.getOwner().getId())
                .ownerName(club.getOwner().getEmail())
                .memberCount(clubMemberRepository.countByClubId(club.getId()))
                .createdAt(club.getCreatedAt())
                .build();
    }
}
