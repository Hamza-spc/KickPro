package com.kickpro.backend.config;

import com.kickpro.backend.entity.Course;
import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.Lesson;
import com.kickpro.backend.entity.Quiz;
import com.kickpro.backend.entity.QuizQuestion;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.repository.CourseRepository;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final DrillRepository drillRepository;
    private final StadiumRepository stadiumRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedAdminUser();
        seedDrills();
        seedStadiums();
        seedCourses();
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

    private void seedStadiums() {
        if (stadiumRepository.count() > 0) {
            return;
        }

        stadiumRepository.save(Stadium.builder()
                .name("Stade Mohammed V")
                .location("Casablanca, Maarif")
                .description("Full-size grass pitch with floodlights. Ideal for 11v11 and training sessions.")
                .pricePerHour(new BigDecimal("450.00"))
                .photos(List.of(
                        "https://res.cloudinary.com/demo/image/upload/sample.jpg",
                        "https://res.cloudinary.com/demo/image/upload/sample.jpg"
                ))
                .build());

        stadiumRepository.save(Stadium.builder()
                .name("Complexe Sportif Agdal")
                .location("Rabat, Agdal")
                .description("Modern futsal courts and 7v7 pitches. Changing rooms and parking available.")
                .pricePerHour(new BigDecimal("320.00"))
                .photos(List.of(
                        "https://res.cloudinary.com/demo/image/upload/sample.jpg"
                ))
                .build());

        stadiumRepository.save(Stadium.builder()
                .name("Terrain Atlas Marrakech")
                .location("Marrakech, Gueliz")
                .description("Outdoor 5v5 pitch near the city center. Great for evening kickabouts.")
                .pricePerHour(new BigDecimal("280.00"))
                .photos(List.of(
                        "https://res.cloudinary.com/demo/image/upload/sample.jpg"
                ))
                .build());

        log.info("Seeded default stadiums");
    }

    private void seedCourses() {
        if (courseRepository.count() > 0) {
            return;
        }

        Course tactics = Course.builder()
                .title("Basic Football Tactics")
                .description("Understand formations, pressing triggers, and off-the-ball movement.")
                .level(DrillLevel.BEGINNER)
                .build();

        Lesson tacticsLesson1 = Lesson.builder()
                .course(tactics)
                .title("Formations and shape")
                .content("Learn how 4-3-3 and 4-4-2 structures affect width, depth, and defensive balance.")
                .orderIndex(1)
                .build();
        tactics.getLessons().add(tacticsLesson1);

        Lesson tacticsLesson2 = Lesson.builder()
                .course(tactics)
                .title("Pressing fundamentals")
                .content("Recognize when to press as a unit and how to cut passing lanes without leaving gaps.")
                .orderIndex(2)
                .build();
        tactics.getLessons().add(tacticsLesson2);

        Quiz tacticsQuiz = Quiz.builder().lesson(tacticsLesson2).build();
        tacticsLesson2.setQuiz(tacticsQuiz);
        tacticsQuiz.getQuestions().add(QuizQuestion.builder()
                .quiz(tacticsQuiz)
                .question("What is the main goal of a coordinated press?")
                .options(List.of(
                        "Win the ball high up the pitch",
                        "Keep all players behind the ball",
                        "Man-mark every opponent",
                        "Slow the game down completely"
                ))
                .correctAnswerIndex(0)
                .build());
        tacticsQuiz.getQuestions().add(QuizQuestion.builder()
                .quiz(tacticsQuiz)
                .question("Which formation typically provides two wide forwards?")
                .options(List.of("4-3-3", "5-4-1", "3-5-2", "4-1-4-1"))
                .correctAnswerIndex(0)
                .build());

        Course discipline = Course.builder()
                .title("Discipline On and Off the Pitch")
                .description("Build professionalism, respect, and mental strength.")
                .level(DrillLevel.BEGINNER)
                .build();

        Lesson disciplineLesson = Lesson.builder()
                .course(discipline)
                .title("Professional habits")
                .content("Punctuality, body language, and respect for teammates and officials define credibility.")
                .orderIndex(1)
                .build();
        discipline.getLessons().add(disciplineLesson);

        Quiz disciplineQuiz = Quiz.builder().lesson(disciplineLesson).build();
        disciplineLesson.setQuiz(disciplineQuiz);
        disciplineQuiz.getQuestions().add(QuizQuestion.builder()
                .quiz(disciplineQuiz)
                .question("Why does punctuality matter for match day credibility?")
                .options(List.of(
                        "It shows reliability to teammates and scouts",
                        "It increases sprint speed",
                        "It replaces warm-up routines",
                        "It guarantees starting position"
                ))
                .correctAnswerIndex(0)
                .build());

        courseRepository.save(tactics);
        courseRepository.save(discipline);
        log.info("Seeded default certification courses");
    }
}
