package com.system.backend.repository;

import com.system.backend.model.PlayerState;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PlayerStateRepository extends MongoRepository<PlayerState, String> {
}
