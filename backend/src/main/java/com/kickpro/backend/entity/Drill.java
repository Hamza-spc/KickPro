package com.kickpro.backend.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "drills")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Drill {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, length = 2000)
    private String description;

    @Column(nullable = false, length = 2000)
    private String rules;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private DrillLevel level;

    @Column(nullable = false)
    private Integer progressionOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_drill_id")
    private Drill parentDrill;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TargetSkill targetSkill;
}
