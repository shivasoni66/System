package com.system.backend.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.Map;

@Document(collection = "player_state")
public class PlayerState {
    @Id
    private String playerName; // Identifies the player document (e.g. "Shiva")
    private Map<String, Object> stateData; // Dynamic player game data

    public PlayerState() {}

    public PlayerState(String playerName, Map<String, Object> stateData) {
        this.playerName = playerName;
        this.stateData = stateData;
    }

    public String getPlayerName() {
        return playerName;
    }

    public void setPlayerName(String playerName) {
        this.playerName = playerName;
    }

    public Map<String, Object> getStateData() {
        return stateData;
    }

    public void setStateData(Map<String, Object> stateData) {
        this.stateData = stateData;
    }
}
