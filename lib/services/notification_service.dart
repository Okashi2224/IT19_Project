import 'package:flutter/material.dart';
import '../models/notification_model.dart';

/// Notification Service for managing app notifications
/// Supports Business Model Canvas: Notifications for Transactions and Requests

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal() {
    // Load sample notifications for demo
    _notifications = List.from(sampleNotifications);
  }

  List<AppNotification> _notifications = [];
  NotificationSettings _settings = const NotificationSettings();
  String? _currentUserId;

  // ============ GETTERS ============
  
  List<AppNotification> get notifications => 
      _notifications.where((n) => n.userId == _currentUserId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  List<AppNotification> get unreadNotifications =>
      notifications.where((n) => !n.isRead && !n.isExpired).toList();
  
  int get unreadCount => unreadNotifications.length;
  
  NotificationSettings get settings => _settings;
  
  bool get hasUnread => unreadCount > 0;

  // ============ USER MANAGEMENT ============
  
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // ============ NOTIFICATION ACTIONS ============
  
  /// Add a new notification
  void addNotification(AppNotification notification) {
    // Check if this type of notification is enabled
    if (!_shouldShowNotification(notification.type)) return;
    
    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == _currentUserId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  /// Delete a notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.removeWhere((n) => n.userId == _currentUserId);
    notifyListeners();
  }

  /// Clear expired notifications
  void clearExpired() {
    _notifications.removeWhere((n) => n.userId == _currentUserId && n.isExpired);
    notifyListeners();
  }

  // ============ NOTIFICATION SETTINGS ============
  
  void updateSettings(NotificationSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  bool _shouldShowNotification(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
        return _settings.newOffers;
      case NotificationType.offerAccepted:
      case NotificationType.offerDeclined:
        return _settings.offerUpdates;
      case NotificationType.newMessage:
        return _settings.messages;
      case NotificationType.meetupReminder:
        return _settings.meetupReminders;
      case NotificationType.tradeCompleted:
        return _settings.offerUpdates;
      case NotificationType.newReview:
        return _settings.reviews;
      case NotificationType.studyPartnerRequest:
      case NotificationType.studyGroupJoined:
      case NotificationType.studyGroupReminder:
        return _settings.bookings;
      case NotificationType.priceDropAlert:
        return _settings.priceAlerts;
      case NotificationType.newListingAlert:
        return _settings.newListings;
      case NotificationType.systemAlert:
        return true; // Always show system alerts
    }
  }

  // ============ CREATE NOTIFICATIONS ============
  
  /// Create a new offer notification
  void notifyNewOffer({
    required String sellerId,
    required String buyerName,
    required String itemTitle,
    required double offerAmount,
    String? imageUrl,
    String? tradeId,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: sellerId,
      type: NotificationType.newOffer,
      title: 'New offer received!',
      body: '$buyerName offered ₱${offerAmount.toStringAsFixed(0)} for your $itemTitle',
      imageUrl: imageUrl,
      actionUrl: '/inbox',
      payload: {'tradeId': tradeId},
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
    ));
  }

  /// Create an offer accepted notification
  void notifyOfferAccepted({
    required String buyerId,
    required String sellerName,
    required String itemTitle,
    String? tradeId,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: buyerId,
      type: NotificationType.offerAccepted,
      title: 'Offer accepted! 🎉',
      body: '$sellerName accepted your offer for $itemTitle',
      actionUrl: '/chat',
      payload: {'tradeId': tradeId},
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
    ));
  }

  /// Create a new message notification
  void notifyNewMessage({
    required String recipientId,
    required String senderName,
    required String messagePreview,
    String? tradeId,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: recipientId,
      type: NotificationType.newMessage,
      title: 'New message from $senderName',
      body: messagePreview,
      actionUrl: '/chat',
      payload: {'tradeId': tradeId},
      createdAt: DateTime.now(),
    ));
  }

  /// Create a meetup reminder
  void notifyMeetupReminder({
    required String userId,
    required String otherPartyName,
    required String location,
    required DateTime meetupTime,
    String? tradeId,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: NotificationType.meetupReminder,
      title: 'Meetup reminder',
      body: 'Exchange with $otherPartyName at $location',
      actionUrl: '/chat',
      payload: {'tradeId': tradeId},
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      expiresAt: meetupTime.add(const Duration(hours: 2)),
    ));
  }

  /// Create a study partner request notification
  void notifyStudyPartnerRequest({
    required String partnerId,
    required String requesterName,
    required String skillTitle,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: partnerId,
      type: NotificationType.studyPartnerRequest,
      title: 'New study partner request',
      body: '$requesterName wants to study $skillTitle with you',
      actionUrl: '/skills',
      createdAt: DateTime.now(),
    ));
  }

  /// Create a study group join notification
  void notifyStudyGroupJoin({
    required String creatorId,
    required String memberName,
    required String groupName,
  }) {
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: creatorId,
      type: NotificationType.studyGroupJoined,
      title: 'New group member',
      body: '$memberName joined your study group "$groupName"',
      actionUrl: '/skills',
      createdAt: DateTime.now(),
    ));
  }

  /// Create a new review notification
  void notifyNewReview({
    required String userId,
    required String reviewerName,
    required double rating,
  }) {
    final stars = '⭐' * rating.round();
    addNotification(AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: NotificationType.newReview,
      title: 'New review received',
      body: '$reviewerName left you a ${rating.toStringAsFixed(1)}-star review! $stars',
      actionUrl: '/profile',
      createdAt: DateTime.now(),
    ));
  }
}

/// Global notification service instance
final notificationService = NotificationService();
