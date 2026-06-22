package com.kickpro.backend.service.impl;

import com.kickpro.backend.entity.Club;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.Squad;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.AnnouncementRepository;
import com.kickpro.backend.repository.AppNotificationRepository;
import com.kickpro.backend.repository.BadgeRepository;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.ChallengeSubmissionRepository;
import com.kickpro.backend.repository.ChatMessageRepository;
import com.kickpro.backend.repository.ChatRoomRepository;
import com.kickpro.backend.repository.ClubMemberRepository;
import com.kickpro.backend.repository.ClubRepository;
import com.kickpro.backend.repository.DeviceTokenRepository;
import com.kickpro.backend.repository.DirectMessageRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerFollowRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.PostCommentRepository;
import com.kickpro.backend.repository.PostReactionRepository;
import com.kickpro.backend.repository.ReferralRepository;
import com.kickpro.backend.repository.ScoutBookmarkRepository;
import com.kickpro.backend.repository.ScoutNoteRepository;
import com.kickpro.backend.repository.SkillsRepository;
import com.kickpro.backend.repository.SquadJoinRequestRepository;
import com.kickpro.backend.repository.SquadMemberRepository;
import com.kickpro.backend.repository.SquadRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.AdminUserDeletionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminUserDeletionServiceImpl implements AdminUserDeletionService {

    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final DirectMessageRepository directMessageRepository;
    private final AppNotificationRepository appNotificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final PostCommentRepository postCommentRepository;
    private final PostReactionRepository postReactionRepository;
    private final PlayerFollowRepository playerFollowRepository;
    private final ReferralRepository referralRepository;
    private final AnnouncementRepository announcementRepository;
    private final ScoutBookmarkRepository scoutBookmarkRepository;
    private final ScoutNoteRepository scoutNoteRepository;
    private final MatchRepository matchRepository;
    private final MatchParticipantRepository matchParticipantRepository;
    private final PlayerRatingRepository playerRatingRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final VideoRepository videoRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final CertificationRepository certificationRepository;
    private final BadgeRepository badgeRepository;
    private final ChallengeSubmissionRepository challengeSubmissionRepository;
    private final SkillsRepository skillsRepository;
    private final SquadRepository squadRepository;
    private final SquadMemberRepository squadMemberRepository;
    private final SquadJoinRequestRepository squadJoinRequestRepository;

    @Override
    @Transactional
    public void deleteUser(Long adminUserId, Long targetUserId) {
        if (adminUserId.equals(targetUserId)) {
            throw new BadRequestException("You cannot delete your own account");
        }

        User user = userRepository.findById(targetUserId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (user.getRole() == Role.ADMIN) {
            throw new BadRequestException("Admin accounts cannot be deleted");
        }

        deleteUserScopedData(user);
        playerProfileRepository.findByUserId(targetUserId).ifPresent(this::deletePlayerProfile);
        userRepository.delete(user);
    }

    private void deleteUserScopedData(User user) {
        Long userId = user.getId();

        directMessageRepository.deleteByUserInvolved(userId);
        appNotificationRepository.deleteByUser_Id(userId);
        deviceTokenRepository.deleteByUser_Id(userId);
        postCommentRepository.deleteByAuthor_Id(userId);
        postReactionRepository.deleteByReactorId(userId);
        playerFollowRepository.deleteByFollowerId(userId);
        referralRepository.deleteByReferrerId(userId);
        referralRepository.deleteByReferredId(userId);
        announcementRepository.deleteByAuthor_Id(userId);
        scoutBookmarkRepository.deleteByScout_Id(userId);
        scoutNoteRepository.deleteByScout_Id(userId);

        for (Match match : new ArrayList<>(matchRepository.findByOrganizerIdOrderByDateTimeDesc(userId))) {
            deleteMatch(match);
        }

        for (Club club : new ArrayList<>(clubRepository.findByOwner_Id(userId))) {
            clubMemberRepository.deleteByClubId(club.getId());
            clubRepository.delete(club);
        }
    }

    private void deletePlayerProfile(PlayerProfile profile) {
        Long profileId = profile.getId();
        Long userId = profile.getUser().getId();

        for (Squad squad : new ArrayList<>(squadRepository.findByCaptainUserIdOrderByCreatedAtDesc(userId))) {
            deleteSquad(squad);
        }

        scoutNoteRepository.deleteByPlayerProfile_Id(profileId);
        scoutBookmarkRepository.deleteByPlayerProfile_Id(profileId);
        playerFollowRepository.deleteByFollowingId(profileId);
        clubMemberRepository.deleteByPlayerId(profileId);

        for (Video video : new ArrayList<>(videoRepository.findByPlayerIdOrderByUploadedAtDesc(profileId))) {
            postCommentRepository.deleteByPostId(video.getId());
            postReactionRepository.deleteByPostId(video.getId());
            videoRepository.delete(video);
        }

        drillSubmissionRepository.deleteByPlayerId(profileId);
        certificationRepository.deleteByPlayerId(profileId);
        badgeRepository.deleteByPlayerId(profileId);
        challengeSubmissionRepository.deleteByPlayerId(profileId);
        matchParticipantRepository.deleteByPlayerId(profileId);
        playerRatingRepository.deleteByRatedPlayerId(profileId);
        playerRatingRepository.deleteByRaterId(profileId);
        squadMemberRepository.deleteByPlayerId(profileId);
        squadJoinRequestRepository.deleteByPlayerId(profileId);
        skillsRepository.deleteByPlayerProfileId(profileId);

        playerProfileRepository.delete(profile);
    }

    private void deleteSquad(Squad squad) {
        squadJoinRequestRepository.deleteBySquadId(squad.getId());
        squadMemberRepository.deleteBySquadId(squad.getId());
        squadRepository.delete(squad);
    }

    private void deleteMatch(Match match) {
        playerRatingRepository.deleteByMatchId(match.getId());
        matchParticipantRepository.deleteByMatchId(match.getId());
        chatRoomRepository.findByMatchId(match.getId()).ifPresent(room -> {
            chatMessageRepository.deleteByRoomId(room.getId());
            chatRoomRepository.delete(room);
        });
        matchRepository.delete(match);
    }
}
