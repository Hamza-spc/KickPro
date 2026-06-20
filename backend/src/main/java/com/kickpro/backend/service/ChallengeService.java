package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateWeeklyChallengeRequest;
import com.kickpro.backend.dto.request.SubmitChallengeRequest;
import com.kickpro.backend.dto.response.ChallengeSubmissionResponse;
import com.kickpro.backend.dto.response.WeeklyChallengeResponse;

import java.util.List;

public interface ChallengeService {

    WeeklyChallengeResponse getActiveChallenge();

    List<ChallengeSubmissionResponse> getSubmissions(Long userId);

    ChallengeSubmissionResponse submit(Long userId, SubmitChallengeRequest request);

    ChallengeSubmissionResponse vote(Long userId, Long submissionId);

    WeeklyChallengeResponse createChallenge(CreateWeeklyChallengeRequest request);
}
