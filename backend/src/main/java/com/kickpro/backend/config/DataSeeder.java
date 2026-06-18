package com.kickpro.backend.config;

import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final DrillRepository drillRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedAdminUser();
        seedDrills();
    }

    private void seedAdminUser() {
        String adminEmail = "admin@kickpro.dev";
        if (userRepository.existsByEmail(adminEmail)) {
            return;
        }

        User admin = User.builder()
                .email(adminEmail)
                .password(passwordEncoder.encode("admin123456"))
                .role(Role.ADMIN)
                .build();
        userRepository.save(admin);
        log.info("Seeded admin user: {} (password: admin123456)", adminEmail);
    }

    private void seedDrills() {
        if (drillRepository.count() > 0) {
            return;
        }

        Drill juggling = drillRepository.save(Drill.builder()
                .title("Juggling 20 touches")
                .description("Keep the ball in the air with feet, thighs, or head.")
                .rules("Juggle the ball at least 20 times without it touching the ground.")
                .level(DrillLevel.BEGINNER)
                .progressionOrder(1)
                .targetSkill(TargetSkill.DRIBBLING)
                .build());

        Drill coneDribbling = drillRepository.save(Drill.builder()
                .title("Cone dribbling")
                .description("Dribble through a line of cones with close control.")
                .rules("Set up 8 cones 2m apart. Dribble through without knocking any over.")
                .level(DrillLevel.BEGINNER)
                .progressionOrder(2)
                .parentDrill(juggling)
                .targetSkill(TargetSkill.DRIBBLING)
                .build());

        drillRepository.save(Drill.builder()
                .title("Basic passing wall")
                .description("Pass against a wall and control the return.")
                .rules("Complete 20 clean passes and controls against a wall.")
                .level(DrillLevel.BEGINNER)
                .progressionOrder(3)
                .parentDrill(coneDribbling)
                .targetSkill(TargetSkill.PASSING)
                .build());

        Drill shootingZones = drillRepository.save(Drill.builder()
                .title("Shooting zones")
                .description("Score from marked zones around the penalty area.")
                .rules("Score 3 out of 5 shots from different marked zones.")
                .level(DrillLevel.INTERMEDIATE)
                .progressionOrder(1)
                .targetSkill(TargetSkill.SHOOTING)
                .build());

        drillRepository.save(Drill.builder()
                .title("Speed sprint with ball")
                .description("Sprint 30m with the ball under control.")
                .rules("Complete a 30m sprint dribble in under 8 seconds.")
                .level(DrillLevel.INTERMEDIATE)
                .progressionOrder(2)
                .parentDrill(shootingZones)
                .targetSkill(TargetSkill.SPEED)
                .build());

        Drill advancedCombo = drillRepository.save(Drill.builder()
                .title("Advanced combo drill")
                .description("Combine dribbling, turn, and finish in one sequence.")
                .rules("Dribble through cones, perform a turn, then finish top corner.")
                .level(DrillLevel.ADVANCED)
                .progressionOrder(1)
                .targetSkill(TargetSkill.DRIBBLING)
                .build());

        drillRepository.save(Drill.builder()
                .title("Aerial challenge")
                .description("Heading accuracy drill from crosses.")
                .rules("Head 3 out of 5 crosses on target from 10 yards.")
                .level(DrillLevel.ADVANCED)
                .progressionOrder(2)
                .parentDrill(advancedCombo)
                .targetSkill(TargetSkill.HEADING)
                .build());

        log.info("Seeded default drill progression tree");
    }
}
