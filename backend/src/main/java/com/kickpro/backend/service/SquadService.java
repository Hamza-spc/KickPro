package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateSquadRequest;
import com.kickpro.backend.dto.response.SquadDiscoverResponse;
import com.kickpro.backend.dto.response.SquadJoinRequestResponse;
import com.kickpro.backend.dto.response.SquadResponse;

import java.util.List;

public interface SquadService {

    SquadResponse createSquad(Long userId, CreateSquadRequest request);

    List<SquadResponse> getMySquads(Long userId);

    SquadResponse getSquadById(Long userId, Long squadId);

    SquadResponse invitePlayer(Long userId, Long squadId, Long profileId);

    List<SquadDiscoverResponse> discoverSquads(Long userId, String city);

    SquadJoinRequestResponse requestJoin(Long userId, Long squadId);

    List<SquadJoinRequestResponse> getIncomingJoinRequests(Long userId);

    SquadJoinRequestResponse approveJoinRequest(Long userId, Long requestId);

    SquadJoinRequestResponse rejectJoinRequest(Long userId, Long requestId);
}
