package com.kickpro.backend.util;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.exception.UnauthorizedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static UserPrincipal getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof UserPrincipal principal)) {
            throw new UnauthorizedException("Not authenticated");
        }
        return principal;
    }

    public static List<String> computeStrengths(Skills skills) {
        return computeSkillNames(skills, 7, 10);
    }

    public static List<String> computeWeaknesses(Skills skills) {
        return computeSkillNames(skills, 1, 4);
    }

    private static List<String> computeSkillNames(Skills skills, int min, int max) {
        Map<String, Integer> ratings = new LinkedHashMap<>();
        ratings.put("dribbling", skills.getDribbling());
        ratings.put("shooting", skills.getShooting());
        ratings.put("passing", skills.getPassing());
        ratings.put("speed", skills.getSpeed());
        ratings.put("heading", skills.getHeading());
        ratings.put("stamina", skills.getStamina());

        List<String> result = new ArrayList<>();
        ratings.forEach((name, value) -> {
            if (value >= min && value <= max) {
                result.add(name);
            }
        });
        return result;
    }
}
