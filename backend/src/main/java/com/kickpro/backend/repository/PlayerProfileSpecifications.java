package com.kickpro.backend.repository;

import com.kickpro.backend.entity.Certification;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.DrillSubmission;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public final class PlayerProfileSpecifications {

    private PlayerProfileSpecifications() {
    }

    public static Specification<PlayerProfile> withFilters(
            Position position,
            String city,
            PreferredFoot preferredFoot,
            Integer minAge,
            Integer maxAge,
            Double minCredibility,
            Double maxCredibility,
            Integer minDribbling,
            Integer minShooting,
            Integer minPassing,
            Integer minSpeed,
            Integer minHeading,
            Integer minStamina,
            Integer minDrillScore,
            Boolean hasCertification
    ) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (position != null) {
                predicates.add(cb.equal(root.get("position"), position));
            }
            if (city != null && !city.isBlank()) {
                predicates.add(cb.like(cb.lower(root.get("city")), "%" + city.trim().toLowerCase() + "%"));
            }
            if (preferredFoot != null) {
                predicates.add(cb.equal(root.get("preferredFoot"), preferredFoot));
            }
            if (minCredibility != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("credibilityScore"), minCredibility));
            }
            if (maxCredibility != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("credibilityScore"), maxCredibility));
            }

            LocalDate today = LocalDate.now();
            if (minAge != null) {
                LocalDate maxBirthDate = today.minusYears(minAge);
                predicates.add(cb.lessThanOrEqualTo(root.get("dateOfBirth"), maxBirthDate));
            }
            if (maxAge != null) {
                LocalDate minBirthDate = today.minusYears(maxAge + 1L).plusDays(1);
                predicates.add(cb.greaterThanOrEqualTo(root.get("dateOfBirth"), minBirthDate));
            }

            if (minDribbling != null) {
                predicates.add(hasMinSkill(root, query, cb, "dribbling", minDribbling));
            }
            if (minShooting != null) {
                predicates.add(hasMinSkill(root, query, cb, "shooting", minShooting));
            }
            if (minPassing != null) {
                predicates.add(hasMinSkill(root, query, cb, "passing", minPassing));
            }
            if (minSpeed != null) {
                predicates.add(hasMinSkill(root, query, cb, "speed", minSpeed));
            }
            if (minHeading != null) {
                predicates.add(hasMinSkill(root, query, cb, "heading", minHeading));
            }
            if (minStamina != null) {
                predicates.add(hasMinSkill(root, query, cb, "stamina", minStamina));
            }

            if (minDrillScore != null) {
                predicates.add(hasMinAverageDrillScore(root, query, cb, minDrillScore));
            }

            if (hasCertification != null) {
                predicates.add(hasCertification(root, query, cb, hasCertification));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }

    private static Predicate hasMinSkill(
            Root<PlayerProfile> root,
            jakarta.persistence.criteria.CriteriaQuery<?> query,
            jakarta.persistence.criteria.CriteriaBuilder cb,
            String skillField,
            int minValue
    ) {
        Subquery<Long> subquery = query.subquery(Long.class);
        Root<Skills> skillsRoot = subquery.from(Skills.class);
        subquery.select(cb.literal(1L));
        subquery.where(
                cb.equal(skillsRoot.get("playerProfile").get("id"), root.get("id")),
                cb.greaterThanOrEqualTo(skillsRoot.get(skillField), minValue)
        );
        return cb.exists(subquery);
    }

    private static Predicate hasMinAverageDrillScore(
            Root<PlayerProfile> root,
            jakarta.persistence.criteria.CriteriaQuery<?> query,
            jakarta.persistence.criteria.CriteriaBuilder cb,
            int minDrillScore
    ) {
        Subquery<Double> subquery = query.subquery(Double.class);
        Root<DrillSubmission> submissionRoot = subquery.from(DrillSubmission.class);
        subquery.select(cb.avg(submissionRoot.get("score")));
        subquery.where(
                cb.equal(submissionRoot.get("player").get("id"), root.get("id")),
                cb.equal(submissionRoot.get("status"), SubmissionStatus.APPROVED)
        );
        return cb.greaterThanOrEqualTo(subquery, (double) minDrillScore);
    }

    private static Predicate hasCertification(
            Root<PlayerProfile> root,
            jakarta.persistence.criteria.CriteriaQuery<?> query,
            jakarta.persistence.criteria.CriteriaBuilder cb,
            boolean required
    ) {
        Subquery<Long> subquery = query.subquery(Long.class);
        Root<Certification> certificationRoot = subquery.from(Certification.class);
        subquery.select(cb.literal(1L));
        subquery.where(cb.equal(certificationRoot.get("player").get("id"), root.get("id")));
        return required ? cb.exists(subquery) : cb.not(cb.exists(subquery));
    }
}
