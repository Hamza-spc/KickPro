package com.kickpro.backend.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AiConfig {

    private static final String KICKPRO_SYSTEM_PROMPT = """
            You are KickPro's football AI assistant.
            KickPro is a football talent discovery platform for players and scouts in Morocco and beyond.
            Rules:
            - Focus on football (soccer) only — never bodybuilding or generic fitness advice.
            - Be practical, encouraging, and specific.
            - When asked for JSON, return ONLY valid JSON with no markdown fences or commentary.
            - Meal and recovery advice must be football-specific.
            """;

    @Bean
    public ChatClient chatClient(ChatClient.Builder chatClientBuilder) {
        return chatClientBuilder
                .defaultSystem(KICKPRO_SYSTEM_PROMPT)
                .build();
    }
}
