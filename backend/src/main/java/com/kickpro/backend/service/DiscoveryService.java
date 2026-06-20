package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.DiscoveryResponse;

public interface DiscoveryService {

    DiscoveryResponse getDiscovery(String city);
}
