package com.bookstore.service.shared;

public interface WebSocketNotificationService {
    /**
     * Send real-time notification to a specific user.
     */
    void sendToUser(Long userId, String destination, Object payload);

    /**
     * Send real-time notification to all staff of a specific branch.
     */
    void sendToBranch(Long branchId, String destination, Object payload);

    /**
     * Broadcast to all admin/managers.
     */
    void broadcastToAdmins(String destination, Object payload);

    /**
     * Broadcast a stock or transfer update event to a branch.
     */
    default void broadcastStockUpdate(Long branchId, String message) {
        sendToBranch(branchId, "/topic/stock-updates", message);
    }
}
