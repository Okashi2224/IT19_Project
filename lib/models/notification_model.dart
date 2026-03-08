/// Notification model for transaction and request notifications
/// Supports Business Model Canvas: Notifications for Transactions and Requests
enum NotificationType {
  newOffer,
  offerAccepted,
  offerDeclined,
  newMessage,
  meetupReminder,
  tradeCompleted,
  newReview,
  studyPartnerRequest,
  studyGroupJoined,
  studyGroupReminder,
  priceDropAlert,
  newListingAlert,
  systemAlert,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl; // Deep link route
  final Map<String, dynamic>? payload;
  final NotificationPriority priority;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    this.payload,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    required this.createdAt,
    this.expiresAt,
  });

  /// Get icon for notification type
  String get icon {
    switch (type) {
      case NotificationType.newOffer:
        return '💰';
      case NotificationType.offerAccepted:
        return '🎉';
      case NotificationType.offerDeclined:
        return '❌';
      case NotificationType.newMessage:
        return '💬';
      case NotificationType.meetupReminder:
        return '📍';
      case NotificationType.tradeCompleted:
        return '✅';
      case NotificationType.newReview:
        return '⭐';
      case NotificationType.studyPartnerRequest:
        return '📚';
      case NotificationType.studyGroupJoined:
        return '👥';
      case NotificationType.studyGroupReminder:
        return '⏰';
      case NotificationType.priceDropAlert:
        return '📉';
      case NotificationType.newListingAlert:
        return '🆕';
      case NotificationType.systemAlert:
        return 'ℹ️';
    }
  }

  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      payload: payload,
      priority: priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }
}

/// Notification settings for user preferences
class NotificationSettings {
  final bool newOffers;
  final bool offerUpdates;
  final bool messages;
  final bool meetupReminders;
  final bool reviews;
  final bool bookings;
  final bool priceAlerts;
  final bool newListings;
  final bool emailNotifications;
  final bool pushNotifications;

  const NotificationSettings({
    this.newOffers = true,
    this.offerUpdates = true,
    this.messages = true,
    this.meetupReminders = true,
    this.reviews = true,
    this.bookings = true,
    this.priceAlerts = false,
    this.newListings = false,
    this.emailNotifications = true,
    this.pushNotifications = true,
  });

  NotificationSettings copyWith({
    bool? newOffers,
    bool? offerUpdates,
    bool? messages,
    bool? meetupReminders,
    bool? reviews,
    bool? bookings,
    bool? priceAlerts,
    bool? newListings,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationSettings(
      newOffers: newOffers ?? this.newOffers,
      offerUpdates: offerUpdates ?? this.offerUpdates,
      messages: messages ?? this.messages,
      meetupReminders: meetupReminders ?? this.meetupReminders,
      reviews: reviews ?? this.reviews,
      bookings: bookings ?? this.bookings,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      newListings: newListings ?? this.newListings,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}

/// Sample notifications
final List<AppNotification> sampleNotifications = [
  AppNotification(
    id: 'notif_1',
    userId: 'current_user',
    type: NotificationType.newOffer,
    title: 'New offer received!',
    body: 'Sarah M. offered ₱350 for your Calculus Textbook',
    imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=100',
    actionUrl: '/inbox',
    payload: {'tradeId': 'trade_mock_1'},
    priority: NotificationPriority.high,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  AppNotification(
    id: 'notif_2',
    userId: 'current_user',
    type: NotificationType.offerAccepted,
    title: 'Offer accepted! 🎉',
    body: 'Mike J. accepted your offer for TI-84 Calculator',
    actionUrl: '/chat',
    payload: {'tradeId': 'trade_mock_2'},
    createdAt: DateTime.now().subtract(const Duration(hours: 20)),
  ),
  AppNotification(
    id: 'notif_3',
    userId: 'current_user',
    type: NotificationType.meetupReminder,
    title: 'Meetup reminder',
    body: 'Don\'t forget: Exchange with Mike J. at University Library tomorrow at 2PM',
    actionUrl: '/chat',
    payload: {'tradeId': 'trade_mock_2'},
    priority: NotificationPriority.high,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  AppNotification(
    id: 'notif_4',
    userId: 'current_user',
    type: NotificationType.studyPartnerRequest,
    title: 'New study partner request',
    body: 'Emily C. wants to study Calculus with you',
    actionUrl: '/skills',
    payload: {},
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AppNotification(
    id: 'notif_5',
    userId: 'current_user',
    type: NotificationType.newReview,
    title: 'New review received',
    body: 'James W. left you a 5-star review! ⭐⭐⭐⭐⭐',
    actionUrl: '/profile',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
];
