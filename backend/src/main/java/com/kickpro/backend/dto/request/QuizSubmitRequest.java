package com.kickpro.backend.dto.request;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@JsonDeserialize(using = QuizSubmitRequest.QuizSubmitRequestDeserializer.class)
public class QuizSubmitRequest {

    private List<AnswerSubmission> answers;

    public List<AnswerSubmission> getAnswers() {
        return answers;
    }

    public static class AnswerSubmission {

        private Long questionId;
        private Integer selectedOptionIndex;
        private String selectedAnswerText;

        public Long getQuestionId() {
            return questionId;
        }

        public Integer getSelectedOptionIndex() {
            return selectedOptionIndex;
        }

        public String getSelectedAnswerText() {
            return selectedAnswerText;
        }

        void setQuestionId(Long questionId) {
            this.questionId = questionId;
        }

        void setSelectedOptionIndex(Integer selectedOptionIndex) {
            this.selectedOptionIndex = selectedOptionIndex;
        }

        void setSelectedAnswerText(String selectedAnswerText) {
            this.selectedAnswerText = selectedAnswerText;
        }
    }

    static class QuizSubmitRequestDeserializer extends JsonDeserializer<QuizSubmitRequest> {

        @Override
        public QuizSubmitRequest deserialize(JsonParser parser, DeserializationContext context) throws IOException {
            JsonNode root = parser.getCodec().readTree(parser);
            JsonNode answersNode = root.get("answers");

            if (answersNode == null || answersNode.isNull()) {
                throw new IllegalArgumentException(
                        "answers is required. Use [{\"questionId\":1,\"selectedOptionIndex\":0}] "
                                + "or {\"1\":\"option text\",\"2\":\"option text\"}"
                );
            }

            QuizSubmitRequest request = new QuizSubmitRequest();
            request.answers = parseAnswers(answersNode);
            return request;
        }

        private List<AnswerSubmission> parseAnswers(JsonNode answersNode) {
            if (answersNode.isArray()) {
                return parseArrayAnswers(answersNode);
            }
            if (answersNode.isObject()) {
                return parseMapAnswers(answersNode);
            }
            throw new IllegalArgumentException(
                    "answers must be an array or an object map of questionId to answer"
            );
        }

        private List<AnswerSubmission> parseArrayAnswers(JsonNode answersNode) {
            List<AnswerSubmission> submissions = new ArrayList<>();
            for (JsonNode item : answersNode) {
                AnswerSubmission submission = new AnswerSubmission();
                JsonNode questionIdNode = item.get("questionId");
                if (questionIdNode == null || !questionIdNode.canConvertToLong()) {
                    throw new IllegalArgumentException("Each answer must include questionId");
                }
                submission.setQuestionId(questionIdNode.longValue());

                JsonNode indexNode = item.get("selectedOptionIndex");
                JsonNode textNode = item.get("selectedAnswerText");
                if (indexNode != null && !indexNode.isNull()) {
                    submission.setSelectedOptionIndex(indexNode.intValue());
                } else if (textNode != null && textNode.isTextual()) {
                    submission.setSelectedAnswerText(textNode.asText().trim());
                } else {
                    throw new IllegalArgumentException(
                            "Each answer must include selectedOptionIndex or selectedAnswerText"
                    );
                }
                submissions.add(submission);
            }
            return submissions;
        }

        private List<AnswerSubmission> parseMapAnswers(JsonNode answersNode) {
            List<AnswerSubmission> submissions = new ArrayList<>();
            Iterator<Map.Entry<String, JsonNode>> fields = answersNode.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> entry = fields.next();
                AnswerSubmission submission = new AnswerSubmission();
                try {
                    submission.setQuestionId(Long.parseLong(entry.getKey()));
                } catch (NumberFormatException ex) {
                    throw new IllegalArgumentException("Question id keys must be numeric: " + entry.getKey());
                }

                JsonNode value = entry.getValue();
                if (value.isNumber()) {
                    submission.setSelectedOptionIndex(value.intValue());
                } else if (value.isTextual()) {
                    submission.setSelectedAnswerText(value.asText().trim());
                } else {
                    throw new IllegalArgumentException(
                            "Answer for question " + entry.getKey() + " must be option text or index"
                    );
                }
                submissions.add(submission);
            }
            return submissions;
        }
    }
}
