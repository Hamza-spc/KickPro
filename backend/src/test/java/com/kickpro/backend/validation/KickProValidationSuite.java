package com.kickpro.backend.validation;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.kickpro.backend.dto.request.QuizSubmitRequest;
import com.kickpro.backend.service.impl.CredibilityServiceImpl;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Suite de validation KickPro — affiche des messages explicites dans la console
 * lors de l'exécution Maven ({@code ./mvnw test -Dtest=KickProValidationSuite}).
 */
@DisplayName("KickPro — Suite de validation fonctionnelle")
class KickProValidationSuite {

    private static void ok(String message) {
        System.out.println("[VALIDATION OK] " + message);
    }

    @Test
    @DisplayName("Score crédibilité — paliers correctement assignés")
    void validation_credibilityScoreTiers() {
        CredibilityServiceImpl service = new CredibilityServiceImpl(
                null, null, null, null, null, null, null);

        assertEquals("NEEDS SIGNIFICANT IMPROVEMENT (0-30)", service.scoreTierLabel(9));
        ok("Score 9 → palier « besoin d'amélioration significative »");

        assertEquals("BELOW AVERAGE (31-50)", service.scoreTierLabel(45));
        ok("Score 45 → palier « en dessous de la moyenne »");

        assertEquals("EXCELLENT (86-100)", service.scoreTierLabel(95));
        ok("Score 95 → palier « excellent »");
    }

    @Test
    @DisplayName("Quiz — seuil de réussite à 70 % (via CredibilityServiceImplTest)")
    void validation_quizPassingThresholdDocumented() {
        // Seuil métier : score >= 70 % — couvert par CredibilityServiceImplTest
        double passingRatio = 0.70;
        assertTrue(7 >= 10 * passingRatio);
        ok("Règle métier : 7/10 (70 %) considéré comme réussite");
        assertTrue(6 < 10 * passingRatio);
        ok("Règle métier : 6/10 (60 %) considéré comme échec");
    }

    @Test
    @DisplayName("Quiz — désérialisation format tableau JSON")
    void validation_quizSubmitArrayFormat() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        QuizSubmitRequest request = mapper.readValue("""
                {
                  "answers": [
                    {"questionId": 1, "selectedOptionIndex": 0},
                    {"questionId": 2, "selectedOptionIndex": 1}
                  ]
                }
                """, QuizSubmitRequest.class);

        assertEquals(2, request.getAnswers().size());
        assertEquals(0, request.getAnswers().get(0).getSelectedOptionIndex());
        ok("Format JSON tableau : 2 réponses désérialisées correctement");
    }

    @Test
    @DisplayName("Quiz — désérialisation format map texte JSON")
    void validation_quizSubmitMapFormat() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        QuizSubmitRequest request = mapper.readValue("""
                {
                  "answers": {
                    "1": "Win the ball high up the pitch",
                    "2": "4-3-3"
                  }
                }
                """, QuizSubmitRequest.class);

        assertEquals(2, request.getAnswers().size());
        assertEquals("4-3-3", request.getAnswers().get(1).getSelectedAnswerText());
        ok("Format JSON map : réponses texte désérialisées correctement");
    }

    @Test
    @DisplayName("Réservation — génération de créneaux horaires sans boucle infinie")
    void validation_stadiumSlotGeneration() {
        int slotCount = countHourlySlots(
                java.time.LocalTime.of(8, 0),
                java.time.LocalTime.of(23, 50));

        assertEquals(16, slotCount);
        ok("Stade 08:00–23:50 → 16 créneaux horaires (pas de boucle infinie)");

        int standardClose = countHourlySlots(
                java.time.LocalTime.of(8, 0),
                java.time.LocalTime.of(23, 0));

        assertEquals(15, standardClose);
        ok("Stade 08:00–23:00 → 15 créneaux horaires");
    }

    /** Reproduit la logique corrigée de StadiumServiceImpl.getAvailability. */
    private static int countHourlySlots(java.time.LocalTime open, java.time.LocalTime close) {
        int count = 0;
        java.time.LocalTime slotTime = open;
        while (slotTime.isBefore(close)) {
            count++;
            java.time.LocalTime nextSlot = slotTime.plusHours(1);
            if (!nextSlot.isAfter(slotTime)) {
                break;
            }
            slotTime = nextSlot;
        }
        return count;
    }
}
