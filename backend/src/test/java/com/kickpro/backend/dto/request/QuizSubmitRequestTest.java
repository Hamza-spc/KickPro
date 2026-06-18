package com.kickpro.backend.dto.request;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class QuizSubmitRequestTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void deserializesArrayFormat() throws Exception {
        QuizSubmitRequest request = objectMapper.readValue("""
                {
                  "answers": [
                    {"questionId": 1, "selectedOptionIndex": 0},
                    {"questionId": 2, "selectedOptionIndex": 1}
                  ]
                }
                """, QuizSubmitRequest.class);

        assertEquals(2, request.getAnswers().size());
        assertEquals(0, request.getAnswers().get(0).getSelectedOptionIndex());
        assertNull(request.getAnswers().get(0).getSelectedAnswerText());
    }

    @Test
    void deserializesMapTextFormat() throws Exception {
        QuizSubmitRequest request = objectMapper.readValue("""
                {
                  "answers": {
                    "1": "Win the ball high up the pitch",
                    "2": "4-3-3"
                  }
                }
                """, QuizSubmitRequest.class);

        assertEquals(2, request.getAnswers().size());
        assertEquals("Win the ball high up the pitch", request.getAnswers().get(0).getSelectedAnswerText());
        assertEquals("4-3-3", request.getAnswers().get(1).getSelectedAnswerText());
    }
}
