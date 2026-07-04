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

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
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
        
        // Parse Player Name query param from URI: ?name=PLAYER_NAME
        String playerName = "Shiva"; // Default fallback
        URI uri = session.getUri();
        if (uri != null && uri.getQuery() != null) {
            String query = uri.getQuery();
            for (String param : query.split("&")) {
                String[] pair = param.split("=");
                if (pair.length > 1 && "name".equals(pair[0])) {
                    try {
                        playerName = URLDecoder.decode(pair[1], StandardCharsets.UTF_8.toString());
                    } catch (Exception e) {
                        playerName = pair[1];
                    }
                }
            }
        }
        
        // Cache player name inside session attributes
        session.getAttributes().put("playerName", playerName);
        System.out.println("[SYSTEM BACKEND] Client connected: " + session.getId() + " under name: " + playerName);

        // Fetch this player's specific state from MongoDB
        Optional<PlayerState> stateOpt = repository.findById(playerName);
        if (stateOpt.isPresent()) {
            String jsonState = objectMapper.writeValueAsString(stateOpt.get().getStateData());
            session.sendMessage(new TextMessage(jsonState));
            System.out.println("[SYSTEM BACKEND] Synced MongoDB profile state for: " + playerName);
        } else {
            System.out.println("[SYSTEM BACKEND] No previous MongoDB records found for: " + playerName);
        }
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        try {
            // Parse incoming state
            Map<String, Object> stateMap = objectMapper.readValue(payload, new TypeReference<Map<String, Object>>() {});
            String playerName = (String) stateMap.getOrDefault("playerName", "Shiva");
            String sessionPlayerName = (String) session.getAttributes().getOrDefault("playerName", "Shiva");

            // Save to MongoDB using player name as key
            PlayerState playerState = new PlayerState(playerName, stateMap);
            repository.save(playerState);

            // Broadcast only to OTHER sessions registered under the SAME player name (multi-device sync)
            for (WebSocketSession s : sessions) {
                if (s.isOpen() && !s.getId().equals(session.getId())) {
                    String otherPlayerName = (String) s.getAttributes().getOrDefault("playerName", "Shiva");
                    if (sessionPlayerName.equals(otherPlayerName)) {
                        s.sendMessage(new TextMessage(payload));
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[SYSTEM BACKEND] Error handling message: " + e.getMessage());
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        sessions.remove(session);
        String playerName = (String) session.getAttributes().getOrDefault("playerName", "unknown");
        System.out.println("[SYSTEM BACKEND] Client disconnected: " + session.getId() + " (" + playerName + ")");
    }
}
