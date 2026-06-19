package com.kickpro.backend.config;

import com.kickpro.backend.entity.Course;
import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.GrassType;
import com.kickpro.backend.entity.Lesson;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchGender;
import com.kickpro.backend.entity.MatchParticipant;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.PitchType;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.PlayerRating;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import com.kickpro.backend.entity.Quiz;
import com.kickpro.backend.entity.QuizQuestion;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.entity.TargetSkill;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.repository.CourseRepository;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.SkillsRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private static final String DEMO_PHOTO =
            "https://res.cloudinary.com/demo/image/upload/w_400,h_400,c_fill,g_face/sample.jpg";

    private final DrillRepository drillRepository;
    private final StadiumRepository stadiumRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final SkillsRepository skillsRepository;
    private final MatchRepository matchRepository;
    private final MatchParticipantRepository matchParticipantRepository;
    private final PlayerRatingRepository playerRatingRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        if (playerProfileRepository.count() > 0) {
            log.info("Database already contains player data — skipping mock seed");
            return;
        }

        seedAdminUser();
        seedScoutsAndAgent();
        List<PlayerProfile> players = seedPlayers();
        List<Stadium> stadiums = seedStadiums();
        seedDrills();
        seedCourses();
        seedMatches(players, stadiums);

        log.info("Fresh mock data seeded successfully");
    }

    private void seedAdminUser() {
        if (userRepository.existsByEmail("admin@kickpro.dev")) {
            return;
        }
        userRepository.save(User.builder()
                .email("admin@kickpro.dev")
                .password(passwordEncoder.encode("admin123456"))
                .role(Role.ADMIN)
                .build());
        log.info("Seeded admin user admin@kickpro.dev / admin123456");
    }

    private void seedScoutsAndAgent() {
        if (!userRepository.existsByEmail("scout1@kickpro.dev")) {
            userRepository.save(User.builder()
                    .email("scout1@kickpro.dev")
                    .password(passwordEncoder.encode("scout123456"))
                    .role(Role.SCOUT)
                    .build());
        }
        if (!userRepository.existsByEmail("scout2@kickpro.dev")) {
            userRepository.save(User.builder()
                    .email("scout2@kickpro.dev")
                    .password(passwordEncoder.encode("scout123456"))
                    .role(Role.SCOUT)
                    .build());
        }
        if (!userRepository.existsByEmail("agent@kickpro.ma")) {
            userRepository.save(User.builder()
                    .email("agent@kickpro.ma")
                    .password(passwordEncoder.encode("agent123456"))
                    .role(Role.AGENT)
                    .agentVerified(true)
                    .build());
        }
    }

    private List<PlayerProfile> seedPlayers() {
        return List.of(
                seedPlayer("youssef@kickpro.dev", "Youssef Benali", "Casablanca", Position.STRIKER, 22,
                        new int[]{8, 9, 6, 8, 5, 7}, 72.0),
                seedPlayer("amina@kickpro.dev", "Amina El Fassi", "Rabat", Position.MIDFIELDER, 24,
                        new int[]{7, 6, 9, 7, 4, 8}, 68.0),
                seedPlayer("karim@kickpro.dev", "Karim Idrissi", "Marrakech", Position.DEFENDER, 26,
                        new int[]{5, 4, 7, 6, 8, 7}, 61.0),
                seedPlayer("sara@kickpro.dev", "Sara Mouline", "Fes", Position.GOALKEEPER, 20,
                        new int[]{4, 3, 6, 5, 7, 6}, 55.0),
                seedPlayer("omar@kickpro.dev", "Omar Tazi", "Tanger", Position.STRIKER, 19,
                        new int[]{6, 7, 5, 9, 4, 6}, 9.0)
        );
    }

    private PlayerProfile seedPlayer(
            String email,
            String fullName,
            String city,
            Position position,
            int age,
            int[] skillRatings,
            double credibility
    ) {
        User user = userRepository.save(User.builder()
                .email(email)
                .password(passwordEncoder.encode("player123456"))
                .role(Role.PLAYER)
                .build());

        PlayerProfile profile = playerProfileRepository.save(PlayerProfile.builder()
                .user(user)
                .fullName(fullName)
                .dateOfBirth(LocalDate.now().minusYears(age))
                .city(city)
                .position(position)
                .preferredFoot(PreferredFoot.RIGHT)
                .bio("KickPro player from " + city + ". Looking for competitive matches.")
                .height(175 + (age % 10))
                .weight(68 + (age % 8))
                .profilePhotoUrl(DEMO_PHOTO)
                .credibilityScore(credibility)
                .build());

        skillsRepository.save(Skills.builder()
                .playerProfile(profile)
                .dribbling(skillRatings[0])
                .shooting(skillRatings[1])
                .passing(skillRatings[2])
                .speed(skillRatings[3])
                .heading(skillRatings[4])
                .stamina(skillRatings[5])
                .build());

        return profile;
    }

    private List<Stadium> seedStadiums() {
        if (stadiumRepository.count() > 0) {
            return stadiumRepository.findAll();
        }

        Stadium casa = stadiumRepository.save(Stadium.builder()
                .name("Arena Maarif")
                .city("Casablanca")
                .location("Boulevard Zerktouni, Maarif")
                .phoneNumber("+212 522 123 456")
                .description("Premium 5v5 and 7v7 pitches with LED lighting.")
                .pricePerHour(new BigDecimal("350.00"))
                .pitchCount(3)
                .pitchTypes(List.of(PitchType.FIVE_V_FIVE, PitchType.SEVEN_V_SEVEN))
                .allowedFormats(new ArrayList<>(List.of("5v5", "7v7")))
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(23, 0))
                .grassType(GrassType.ARTIFICIAL)
                .latitude(33.5892)
                .longitude(-7.6261)
                .photos(List.of(DEMO_PHOTO))
                .build());

        Stadium rabat = stadiumRepository.save(Stadium.builder()
                .name("Complexe Agdal Sport")
                .city("Rabat")
                .location("Avenue Annakhil, Agdal")
                .phoneNumber("+212 537 654 321")
                .description("Indoor and outdoor courts. Ideal for evening sessions.")
                .pricePerHour(new BigDecimal("300.00"))
                .pitchCount(2)
                .pitchTypes(List.of(PitchType.FIVE_V_FIVE))
                .allowedFormats(new ArrayList<>(List.of("5v5")))
                .openTime(LocalTime.of(9, 0))
                .closeTime(LocalTime.of(22, 0))
                .grassType(GrassType.ARTIFICIAL)
                .latitude(33.9911)
                .longitude(-6.8405)
                .photos(List.of(DEMO_PHOTO))
                .build());

        Stadium marrakech = stadiumRepository.save(Stadium.builder()
                .name("Gueliz Football Hub")
                .city("Marrakech")
                .location("Rue de la Liberté, Gueliz")
                .phoneNumber("+212 524 111 222")
                .description("Mixed format venue with 5v5, 6v6, and 7v7 options.")
                .pricePerHour(new BigDecimal("280.00"))
                .pitchCount(4)
                .pitchTypes(List.of(PitchType.FIVE_V_FIVE, PitchType.SEVEN_V_SEVEN))
                .allowedFormats(new ArrayList<>(List.of("5v5", "6v6", "7v7")))
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(23, 30))
                .grassType(GrassType.HYBRID)
                .latitude(31.6345)
                .longitude(-8.0083)
                .photos(List.of(DEMO_PHOTO))
                .build());

        Stadium fes = stadiumRepository.save(Stadium.builder()
                .name("Fès Medina Arena")
                .city("Fes")
                .location("Route de Sefrou, Ville Nouvelle")
                .phoneNumber("+212 535 888 999")
                .description("Community pitch with natural grass 5v5 and 7v7.")
                .pricePerHour(new BigDecimal("220.00"))
                .pitchCount(2)
                .pitchTypes(List.of(PitchType.FIVE_V_FIVE, PitchType.SEVEN_V_SEVEN))
                .allowedFormats(new ArrayList<>(List.of("5v5", "7v7")))
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(21, 0))
                .grassType(GrassType.NATURAL)
                .latitude(34.0181)
                .longitude(-5.0078)
                .photos(List.of(DEMO_PHOTO))
                .build());

        return List.of(casa, rabat, marrakech, fes);
    }

    private void seedDrills() {
        if (drillRepository.count() > 0) {
            return;
        }

        Drill dribbling = drillRepository.save(Drill.builder()
                .title("Cone weave control")
                .description("Close control through cones.")
                .rules("Complete 8 cones without touching.")
                .level(DrillLevel.BEGINNER)
                .progressionOrder(1)
                .targetSkill(TargetSkill.DRIBBLING)
                .build());

        Drill passing = drillRepository.save(Drill.builder()
                .title("Wall passing accuracy")
                .description("One-touch passing against a wall.")
                .rules("20 consecutive clean passes.")
                .level(DrillLevel.BEGINNER)
                .progressionOrder(2)
                .parentDrill(dribbling)
                .targetSkill(TargetSkill.PASSING)
                .build());

        Drill shooting = drillRepository.save(Drill.builder()
                .title("Zone finishing")
                .description("Finish from marked zones.")
                .rules("Score 3/5 from different zones.")
                .level(DrillLevel.INTERMEDIATE)
                .progressionOrder(1)
                .targetSkill(TargetSkill.SHOOTING)
                .build());

        Drill speed = drillRepository.save(Drill.builder()
                .title("30m sprint dribble")
                .description("Speed with ball over 30 meters.")
                .rules("Finish under 8 seconds.")
                .level(DrillLevel.INTERMEDIATE)
                .progressionOrder(2)
                .parentDrill(shooting)
                .targetSkill(TargetSkill.SPEED)
                .build());

        Drill heading = drillRepository.save(Drill.builder()
                .title("Cross heading drill")
                .description("Heading accuracy from crosses.")
                .rules("3/5 headers on target.")
                .level(DrillLevel.ADVANCED)
                .progressionOrder(1)
                .targetSkill(TargetSkill.HEADING)
                .build());

        drillRepository.save(Drill.builder()
                .title("Box-to-box stamina run")
                .description("Repeated sprints with recovery jogs.")
                .rules("Complete 6 x 40m runs under 90 seconds total.")
                .level(DrillLevel.ADVANCED)
                .progressionOrder(2)
                .parentDrill(heading)
                .targetSkill(TargetSkill.STAMINA)
                .build());
    }

    private void seedCourses() {
        if (courseRepository.count() > 0) {
            return;
        }

        seedTacticsCourse();
        seedDisciplineCourse();
    }

    private void seedTacticsCourse() {
        Course course = Course.builder()
                .title("Modern Football Tactics")
                .description("Formations, pressing, and transitions for competitive players.")
                .level(DrillLevel.INTERMEDIATE)
                .build();

        Lesson lesson1 = Lesson.builder()
                .course(course)
                .title("Reading formations")
                .content("Understand how 4-3-3 and 4-2-3-1 create width and central overloads.")
                .orderIndex(1)
                .build();
        course.getLessons().add(lesson1);

        Lesson lesson2 = Lesson.builder()
                .course(course)
                .title("Pressing triggers")
                .content("Learn when to press, cover, and drop as a unit.")
                .orderIndex(2)
                .build();
        course.getLessons().add(lesson2);

        Quiz quiz = Quiz.builder().lesson(lesson2).build();
        lesson2.setQuiz(quiz);
        quiz.getQuestions().addAll(List.of(
                QuizQuestion.builder().quiz(quiz)
                        .question("What is the main goal of a high press?")
                        .options(List.of("Win the ball early", "Keep everyone behind the ball", "Slow the game", "Man-mark everyone"))
                        .correctAnswerIndex(0).build(),
                QuizQuestion.builder().quiz(quiz)
                        .question("Which formation gives two wide forwards?")
                        .options(List.of("4-3-3", "5-4-1", "4-4-2 flat", "3-4-3"))
                        .correctAnswerIndex(0).build(),
                QuizQuestion.builder().quiz(quiz)
                        .question("A pressing trigger is often...")
                        .options(List.of("A backwards pass", "A goal kick", "Half-time", "A throw-in in own box"))
                        .correctAnswerIndex(0).build()
        ));

        courseRepository.save(course);
    }

    private void seedDisciplineCourse() {
        Course course = Course.builder()
                .title("Pro Mindset & Discipline")
                .description("Professional habits that boost credibility on and off the pitch.")
                .level(DrillLevel.BEGINNER)
                .build();

        Lesson lesson1 = Lesson.builder()
                .course(course)
                .title("Match day routines")
                .content("Punctuality, warm-up discipline, and communication standards.")
                .orderIndex(1)
                .build();
        course.getLessons().add(lesson1);

        Lesson lesson2 = Lesson.builder()
                .course(course)
                .title("Resilience after mistakes")
                .content("Reset quickly after errors and maintain team energy.")
                .orderIndex(2)
                .build();
        course.getLessons().add(lesson2);

        Quiz quiz = Quiz.builder().lesson(lesson2).build();
        lesson2.setQuiz(quiz);
        quiz.getQuestions().addAll(List.of(
                QuizQuestion.builder().quiz(quiz)
                        .question("Why does punctuality matter?")
                        .options(List.of("Shows reliability", "Increases sprint speed", "Replaces warm-up", "Guarantees starting spot"))
                        .correctAnswerIndex(0).build(),
                QuizQuestion.builder().quiz(quiz)
                        .question("After conceding a goal, the best response is...")
                        .options(List.of("Refocus on the next action", "Blame teammates", "Stop communicating", "Ignore the coach"))
                        .correctAnswerIndex(0).build(),
                QuizQuestion.builder().quiz(quiz)
                        .question("Body language should be...")
                        .options(List.of("Positive and engaged", "Always neutral", "Aggressive to opponents only", "Hidden from coaches"))
                        .correctAnswerIndex(0).build(),
                QuizQuestion.builder().quiz(quiz)
                        .question("Credibility grows when you...")
                        .options(List.of("Follow through on commitments", "Only play when fit", "Avoid feedback", "Skip recovery"))
                        .correctAnswerIndex(0).build()
        ));

        courseRepository.save(course);
    }

    private void seedMatches(List<PlayerProfile> players, List<Stadium> stadiums) {
        if (matchRepository.count() > 0) {
            return;
        }

        Stadium casa = stadiums.get(0);
        Stadium rabat = stadiums.get(1);
        Stadium marrakech = stadiums.get(2);

        PlayerProfile organizer1 = players.get(0);
        PlayerProfile organizer2 = players.get(1);
        PlayerProfile organizer3 = players.get(2);

        Match openMatch = matchRepository.save(Match.builder()
                .stadium(casa)
                .organizer(organizer1.getUser())
                .dateTime(LocalDateTime.now().plusDays(2).withHour(18).withMinute(0))
                .maxPlayers(10)
                .city("Casablanca")
                .minAge(18)
                .maxAge(30)
                .gender(MatchGender.MIXED)
                .status(MatchStatus.OPEN)
                .build());
        addParticipant(openMatch, organizer1, ParticipantStatus.APPROVED);

        Match fullMatch = matchRepository.save(Match.builder()
                .stadium(rabat)
                .organizer(organizer2.getUser())
                .dateTime(LocalDateTime.now().plusDays(3).withHour(20).withMinute(0))
                .maxPlayers(10)
                .city("Rabat")
                .minAge(20)
                .maxAge(35)
                .gender(MatchGender.MIXED)
                .status(MatchStatus.FULL)
                .build());
        for (PlayerProfile p : players.subList(0, 4)) {
            addParticipant(fullMatch, p, ParticipantStatus.APPROVED);
        }

        Match completedMatch = matchRepository.save(Match.builder()
                .stadium(marrakech)
                .organizer(organizer3.getUser())
                .dateTime(LocalDateTime.now().minusDays(3).withHour(19).withMinute(0))
                .maxPlayers(10)
                .city("Marrakech")
                .minAge(18)
                .maxAge(28)
                .gender(MatchGender.MIXED)
                .status(MatchStatus.COMPLETED)
                .build());
        addParticipant(completedMatch, organizer3, ParticipantStatus.APPROVED);
        addParticipant(completedMatch, players.get(3), ParticipantStatus.APPROVED);
        addParticipant(completedMatch, players.get(4), ParticipantStatus.APPROVED);

        playerRatingRepository.save(PlayerRating.builder()
                .match(completedMatch)
                .rater(organizer3)
                .ratedPlayer(players.get(3))
                .performanceScore(4)
                .punctualityScore(5)
                .teamworkScore(4)
                .behaviorScore(5)
                .build());
        playerRatingRepository.save(PlayerRating.builder()
                .match(completedMatch)
                .rater(players.get(3))
                .ratedPlayer(organizer3)
                .performanceScore(5)
                .punctualityScore(4)
                .teamworkScore(5)
                .behaviorScore(4)
                .build());
    }

    private void addParticipant(Match match, PlayerProfile player, ParticipantStatus status) {
        matchParticipantRepository.save(MatchParticipant.builder()
                .match(match)
                .player(player)
                .status(status)
                .build());
    }
}
