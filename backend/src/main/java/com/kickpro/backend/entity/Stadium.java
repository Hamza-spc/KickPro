package com.kickpro.backend.entity;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "stadiums")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Stadium {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String location;

    @Column(length = 30)
    private String phoneNumber;

    @Column(length = 2000)
    private String description;

    @Column(nullable = false)
    private BigDecimal pricePerHour;

    @Builder.Default
    @Column(nullable = false)
    private Integer pitchCount = 1;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "stadium_pitch_types", joinColumns = @JoinColumn(name = "stadium_id"))
    @Enumerated(EnumType.STRING)
    @Column(name = "pitch_type")
    @Builder.Default
    private List<PitchType> pitchTypes = new ArrayList<>();

    @Column
    private LocalTime openTime;

    @Column
    private LocalTime closeTime;

    @Enumerated(EnumType.STRING)
    @Column
    private GrassType grassType;

    @Column
    private Double latitude;

    @Column
    private Double longitude;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "stadium_photos", joinColumns = @JoinColumn(name = "stadium_id"))
    @Column(name = "photo_url")
    @Builder.Default
    private List<String> photos = new ArrayList<>();

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
