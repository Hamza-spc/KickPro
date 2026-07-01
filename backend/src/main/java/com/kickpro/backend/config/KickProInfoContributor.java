package com.kickpro.backend.config;

import org.springframework.boot.actuate.info.Info;
import org.springframework.boot.actuate.info.InfoContributor;
import org.springframework.stereotype.Component;

@Component
public class KickProInfoContributor implements InfoContributor {

    @Override
    public void contribute(Info.Builder builder) {
        builder.withDetail("app", "KickPro API");
        builder.withDetail("description", "KickPro football talent platform — Spring Boot backend");
    }
}
