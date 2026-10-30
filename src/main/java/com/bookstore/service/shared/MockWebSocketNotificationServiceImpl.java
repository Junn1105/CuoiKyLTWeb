package com.bookstore.service.shared;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MockWebSocketNotificationServiceImpl implements WebSocketNotificationService {

    private static final Logger log = LoggerFactory.getLogger(MockWebSocketNotificationServiceImpl.class);

    @Override
    public void sendToUser(Long userId, String destination, Object payload) {
        log.info("[MOCK WebSocket] Alert to User #{} on '{}': {}", userId, destination, payload);
    }

    @Override
    public void sendToBranch(Long branchId, String destination, Object payload) {
        log.info("[MOCK WebSocket] Alert to Branch #{} on '{}': {}", branchId, destination, payload);
    }

    @Override
    public void broadcastToAdmins(String destination, Object payload) {
        log.info("[MOCK WebSocket] Broadcast to Admins on '{}': {}", destination, payload);
    }
}
