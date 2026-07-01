package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.MatchGender;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DisplayName("CreateMatchRequest — Bean Validation")
class CreateMatchRequestValidationTest {

    private static Validator validator;

    @BeforeAll
    static void initValidator() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    @DisplayName("valid request passes validation")
    void validRequest_hasNoViolations() {
        CreateMatchRequest request = validRequest();
        assertTrue(validator.validate(request).isEmpty());
    }

    @Test
    @DisplayName("missing stadiumId fails validation")
    void missingStadiumId_fails() {
        CreateMatchRequest request = validRequest();
        request.setStadiumId(null);
        assertFalse(validator.validate(request).isEmpty());
    }

    @Test
    @DisplayName("maxPlayers below minimum fails validation")
    void maxPlayersTooLow_fails() {
        CreateMatchRequest request = validRequest();
        request.setMaxPlayers(1);
        assertFalse(validator.validate(request).isEmpty());
    }

    @Test
    @DisplayName("maxPlayers above maximum fails validation")
    void maxPlayersTooHigh_fails() {
        CreateMatchRequest request = validRequest();
        request.setMaxPlayers(30);
        assertFalse(validator.validate(request).isEmpty());
    }

    @Test
    @DisplayName("age below 13 fails validation")
    void minAgeTooLow_fails() {
        CreateMatchRequest request = validRequest();
        request.setMinAge(10);
        assertFalse(validator.validate(request).isEmpty());
    }

    @Test
    @DisplayName("missing gender fails validation")
    void missingGender_fails() {
        CreateMatchRequest request = validRequest();
        request.setGender(null);
        assertFalse(validator.validate(request).isEmpty());
    }

    private static CreateMatchRequest validRequest() {
        CreateMatchRequest request = new CreateMatchRequest();
        request.setStadiumId(1L);
        request.setDateTime(LocalDateTime.now().plusDays(1));
        request.setMaxPlayers(10);
        request.setMinAge(16);
        request.setMaxAge(30);
        request.setGender(MatchGender.MIXED);
        return request;
    }
}
