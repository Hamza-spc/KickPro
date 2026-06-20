package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateSquadRequest;
import com.kickpro.backend.dto.response.SquadDiscoverResponse;
import com.kickpro.backend.dto.response.SquadJoinRequestResponse;
import com.kickpro.backend.dto.response.SquadResponse;
import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Squad;
import com.kickpro.backend.entity.SquadJoinRequest;
import com.kickpro.backend.entity.SquadJoinRequestStatus;
import com.kickpro.backend.entity.SquadMember;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.SquadJoinRequestRepository;
import com.kickpro.backend.repository.SquadMemberRepository;
import com.kickpro.backend.repository.SquadRepository;
import com.kickpro.backend.service.NotificationService;
import com.kickpro.backend.service.SquadService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SquadServiceImpl implements SquadService {

    private final SquadRepository squadRepository;
    private final SquadMemberRepository squadMemberRepository;
    private final SquadJoinRequestRepository squadJoinRequestRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional
    public SquadResponse createSquad(Long userId, CreateSquadRequest request) {
        PlayerProfile captain = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before creating a squad"));

        Squad squad = Squad.builder()
                .name(request.getName().trim())
                .city(request.getCity().trim())
                .captain(captain)
                .build();

        Squad saved = squadRepository.save(squad);

        squadMemberRepository.save(SquadMember.builder()
                .squad(saved)
                .player(captain)
                .build());

        return toResponse(saved, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SquadResponse> getMySquads(Long userId) {
        return squadRepository.findMine(userId).stream()
                .map(squad -> toResponse(squad, userId))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public SquadResponse getSquadById(Long userId, Long squadId) {
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new ResourceNotFoundException("Squad not found"));
        assertMemberOrCaptain(userId, squad);
        return toResponse(squad, userId);
    }

    @Override
    @Transactional
    public SquadResponse invitePlayer(Long userId, Long squadId, Long profileId) {
        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new ResourceNotFoundException("Squad not found"));

        if (!squad.getCaptain().getUser().getId().equals(userId)) {
            throw new BadRequestException("Only the squad captain can invite players");
        }

        if (squad.getCaptain().getId().equals(profileId)) {
            throw new BadRequestException("Captain is already in the squad");
        }

        PlayerProfile invitee = playerProfileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        if (squadMemberRepository.existsBySquadIdAndPlayerId(squadId, profileId)) {
            throw new BadRequestException("Player is already in this squad");
        }

        squadMemberRepository.save(SquadMember.builder()
                .squad(squad)
                .player(invitee)
                .build());

        return toResponse(squad, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SquadDiscoverResponse> discoverSquads(Long userId, String city) {
        if (city == null || city.isBlank()) {
            throw new BadRequestException("City is required");
        }

        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before joining squads"));

        return squadRepository.findByCityIgnoreCaseOrderByCreatedAtDesc(city.trim()).stream()
                .map(squad -> {
                    int memberCount = squadMemberRepository.findBySquadIdOrderByJoinedAtAsc(squad.getId()).size();
                    String joinState = resolveJoinState(profile, squad);
                    return SquadDiscoverResponse.builder()
                            .id(squad.getId())
                            .name(squad.getName())
                            .city(squad.getCity())
                            .captainName(squad.getCaptain().getFullName())
                            .memberCount(memberCount)
                            .joinState(joinState)
                            .build();
                })
                .toList();
    }

    @Override
    @Transactional
    public SquadJoinRequestResponse requestJoin(Long userId, Long squadId) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before joining squads"));

        Squad squad = squadRepository.findById(squadId)
                .orElseThrow(() -> new ResourceNotFoundException("Squad not found"));

        if (squad.getCaptain().getId().equals(player.getId())) {
            throw new BadRequestException("You are the captain of this squad");
        }

        if (squadMemberRepository.existsBySquadIdAndPlayerId(squadId, player.getId())) {
            throw new BadRequestException("You are already in this squad");
        }

        SquadJoinRequest request = squadJoinRequestRepository.findBySquadIdAndPlayerId(squadId, player.getId())
                .orElse(null);

        if (request != null && request.getStatus() == SquadJoinRequestStatus.PENDING) {
            throw new BadRequestException("Join request already pending");
        }

        if (request == null) {
            request = SquadJoinRequest.builder()
                    .squad(squad)
                    .player(player)
                    .status(SquadJoinRequestStatus.PENDING)
                    .build();
        } else {
            request.setStatus(SquadJoinRequestStatus.PENDING);
        }

        request = squadJoinRequestRepository.save(request);

        notificationService.notifyUser(
                squad.getCaptain().getUser().getId(),
                "Squad join request",
                player.getFullName() + " wants to join " + squad.getName(),
                NotificationType.SQUAD_JOIN_REQUEST,
                "squad_join_request",
                request.getId()
        );

        return toJoinRequestResponse(request);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SquadJoinRequestResponse> getIncomingJoinRequests(Long userId) {
        return squadJoinRequestRepository
                .findByCaptainUserIdAndStatus(userId, SquadJoinRequestStatus.PENDING)
                .stream()
                .map(this::toJoinRequestResponse)
                .toList();
    }

    @Override
    @Transactional
    public SquadJoinRequestResponse approveJoinRequest(Long userId, Long requestId) {
        SquadJoinRequest request = squadJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Join request not found"));

        assertCaptain(userId, request.getSquad());

        if (request.getStatus() != SquadJoinRequestStatus.PENDING) {
            throw new BadRequestException("Join request is no longer pending");
        }

        if (squadMemberRepository.existsBySquadIdAndPlayerId(
                request.getSquad().getId(),
                request.getPlayer().getId()
        )) {
            request.setStatus(SquadJoinRequestStatus.APPROVED);
            squadJoinRequestRepository.save(request);
            throw new BadRequestException("Player is already in this squad");
        }

        squadMemberRepository.save(SquadMember.builder()
                .squad(request.getSquad())
                .player(request.getPlayer())
                .build());

        request.setStatus(SquadJoinRequestStatus.APPROVED);
        request = squadJoinRequestRepository.save(request);

        notificationService.notifyUser(
                request.getPlayer().getUser().getId(),
                "Squad request approved",
                "You were accepted into " + request.getSquad().getName(),
                NotificationType.SQUAD_JOIN_APPROVED,
                "squad",
                request.getSquad().getId()
        );

        return toJoinRequestResponse(request);
    }

    @Override
    @Transactional
    public SquadJoinRequestResponse rejectJoinRequest(Long userId, Long requestId) {
        SquadJoinRequest request = squadJoinRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Join request not found"));

        assertCaptain(userId, request.getSquad());

        if (request.getStatus() != SquadJoinRequestStatus.PENDING) {
            throw new BadRequestException("Join request is no longer pending");
        }

        request.setStatus(SquadJoinRequestStatus.REJECTED);
        request = squadJoinRequestRepository.save(request);

        notificationService.notifyUser(
                request.getPlayer().getUser().getId(),
                "Squad request declined",
                "Your request to join " + request.getSquad().getName() + " was declined",
                NotificationType.SQUAD_JOIN_REJECTED,
                "squad",
                request.getSquad().getId()
        );

        return toJoinRequestResponse(request);
    }

    private String resolveJoinState(PlayerProfile profile, Squad squad) {
        if (squad.getCaptain().getId().equals(profile.getId())) {
            return "CAPTAIN";
        }
        if (squadMemberRepository.existsBySquadIdAndPlayerId(squad.getId(), profile.getId())) {
            return "MEMBER";
        }
        if (squadJoinRequestRepository.existsBySquadIdAndPlayerIdAndStatus(
                squad.getId(),
                profile.getId(),
                SquadJoinRequestStatus.PENDING
        )) {
            return "PENDING";
        }
        return "NONE";
    }

    private void assertCaptain(Long userId, Squad squad) {
        if (!squad.getCaptain().getUser().getId().equals(userId)) {
            throw new BadRequestException("Only the squad captain can manage join requests");
        }
    }

    private void assertMemberOrCaptain(Long userId, Squad squad) {
        boolean captain = squad.getCaptain().getUser().getId().equals(userId);
        boolean member = squadMemberRepository.findBySquadIdOrderByJoinedAtAsc(squad.getId()).stream()
                .anyMatch(m -> m.getPlayer().getUser().getId().equals(userId));
        if (!captain && !member) {
            throw new BadRequestException("You are not a member of this squad");
        }
    }

    private SquadJoinRequestResponse toJoinRequestResponse(SquadJoinRequest request) {
        return SquadJoinRequestResponse.builder()
                .id(request.getId())
                .squadId(request.getSquad().getId())
                .squadName(request.getSquad().getName())
                .squadCity(request.getSquad().getCity())
                .playerProfileId(request.getPlayer().getId())
                .playerName(request.getPlayer().getFullName())
                .playerPhotoUrl(request.getPlayer().getProfilePhotoUrl())
                .status(request.getStatus())
                .createdAt(request.getCreatedAt())
                .build();
    }

    private SquadResponse toResponse(Squad squad, Long viewerUserId) {
        List<SquadMember> members = squadMemberRepository.findBySquadIdOrderByJoinedAtAsc(squad.getId());
        boolean ownSquad = squad.getCaptain().getUser().getId().equals(viewerUserId);

        return SquadResponse.builder()
                .id(squad.getId())
                .name(squad.getName())
                .city(squad.getCity())
                .captainId(squad.getCaptain().getId())
                .captainName(squad.getCaptain().getFullName())
                .captainPhotoUrl(squad.getCaptain().getProfilePhotoUrl())
                .ownSquad(ownSquad)
                .memberCount(members.size())
                .members(members.stream()
                        .map(m -> SquadResponse.MemberSummary.builder()
                                .id(m.getId())
                                .playerId(m.getPlayer().getId())
                                .playerName(m.getPlayer().getFullName())
                                .profilePhotoUrl(m.getPlayer().getProfilePhotoUrl())
                                .joinedAt(m.getJoinedAt())
                                .build())
                        .toList())
                .createdAt(squad.getCreatedAt())
                .build();
    }
}
