package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateMatchRequest;
import com.kickpro.backend.dto.request.ParticipantReviewRequest;
import com.kickpro.backend.dto.request.PlayerRatingRequest;
import com.kickpro.backend.dto.response.MatchResponse;
import com.kickpro.backend.dto.response.PlayerRatingResponse;

import java.util.List;

public interface MatchService {

    MatchResponse createMatch(Long userId, CreateMatchRequest request);

    List<MatchResponse> getOpenMatches(String city);

    List<MatchResponse> getMyMatches(Long userId);

    MatchResponse getMatchById(Long matchId);

    MatchResponse requestToJoin(Long userId, Long matchId);

    MatchResponse reviewParticipant(Long organizerUserId, Long matchId, Long participantId,
                                    ParticipantReviewRequest request);

    MatchResponse completeMatch(Long organizerUserId, Long matchId);

    MatchResponse cancelMatch(Long organizerUserId, Long matchId);

    PlayerRatingResponse submitRating(Long userId, Long matchId, PlayerRatingRequest request);

    List<PlayerRatingResponse> getMatchRatings(Long matchId);
}
