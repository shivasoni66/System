package com.system.backend.controller;

import com.system.backend.model.PlayerState;
import com.system.backend.repository.PlayerStateRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/player")
@CrossOrigin(origins = "*")
public class ApiController {

    private final PlayerStateRepository repository;

    public ApiController(PlayerStateRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/state")
    public ResponseEntity<Map<String, Object>> getPlayerState() {
        Optional<PlayerState> stateOpt = repository.findById("Shiva");
        if (stateOpt.isPresent()) {
            return ResponseEntity.ok(stateOpt.get().getStateData());
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/state")
    public ResponseEntity<Void> savePlayerState(@RequestBody Map<String, Object> stateMap) {
        String playerName = (String) stateMap.getOrDefault("playerName", "Shiva");
        PlayerState playerState = new PlayerState(playerName, stateMap);
        repository.save(playerState);
        return ResponseEntity.ok().build();
    }
}
