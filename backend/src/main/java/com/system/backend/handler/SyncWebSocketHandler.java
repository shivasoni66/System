package com.system.backend.handler;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.system.backend.model.PlayerState;
import com.system.backend.repository.PlayerStateRepository;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
public class SyncWebSocketHandler extends TextWebSocketHandler {

    private final PlayerStateRepository repository;
    private final ObjectMapper objectMapper;
    private final List<WebSocketSession> sessions = new CopyOnWriteArrayList<>();

    public SyncWebSocketHandler(PlayerStateRepository repository, ObjectMapper objectMapper) {
        this.repository = repository;
        this.objectMapper = objectMapper;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessions.add(session);
        System.out.println("[SYSTEM BACKEND] Client connected: " + session.getId());

        // Send current player state to the newly connected client immediately
        Optional<PlayerState> stateOpt = repository.findById("Shiva");
        if (stateOpt.isPresent()) {
            String jsonState = objectMapper.writeValueAsString(stateOpt.get().getStateData());
            session.sendMessage(new TextMessage(jsonState));
            System.out.println("[SYSTEM BACKEND] Initial state synced to client: " + session.getId());
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        try {
            // Parse incoming state
            Map<String, Object> stateMap = objectMapper.readValue(payload, new TypeReference<Map<String, Object>>() {});
            String playerName = (String) stateMap.getOrDefault("playerName", "Shiva");

            // Save to MongoDB
            PlayerState playerState = new PlayerState(playerName, stateMap);
            repository.save(playerState);

            // Broadcast updated state to all OTHER sessions
            for (WebSocketSession s : sessions) {
                if (s.isOpen() && !s.getId().equals(session.getId())) {
                    s.sendMessage(new TextMessage(payload));
                }
            }
        } catch (Exception e) {
            System.err.println("[SYSTEM BACKEND] Error handling WebSocket message: " + e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session);
        System.out.println("[SYSTEM BACKEND] Client disconnected: " + session.getId());
    }
}
