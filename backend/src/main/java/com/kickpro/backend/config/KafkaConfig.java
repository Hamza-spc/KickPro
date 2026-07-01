package com.kickpro.backend.config;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
@EnableKafka
@Profile("!test")
public class KafkaConfig {

    @Bean
    public NewTopic drillSubmittedTopic() {
        return TopicBuilder.name("drill.submitted").partitions(1).replicas(1).build();
    }

    @Bean
    public NewTopic videoUploadedTopic() {
        return TopicBuilder.name("video.uploaded").partitions(1).replicas(1).build();
    }

    @Bean
    public NewTopic matchBookedTopic() {
        return TopicBuilder.name("match.booked").partitions(1).replicas(1).build();
    }

    @Bean
    public NewTopic matchCompletedTopic() {
        return TopicBuilder.name("match.completed").partitions(1).replicas(1).build();
    }
}
