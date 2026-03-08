import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widgets/bottom_navigation_bar.dart';

/// Notifications Screen - View and manage all notifications
/// Supports Business Model Canvas: Notifications for Transactions and Requests
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _currentNavIndex = 3;
  @override
  void initState() {
    super.initState();
    notificationService.setCurrentUser('current_user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: notificationService,
                builder: (context, _) {
                  final notifications = notificationService.notifications;
                  
                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return _buildNotificationList(notifications);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.darkWalnut,
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: notificationService,
            builder: (context, _) {
              final unread = notificationService.unreadCount;
              return Row(
                children: [
                  if (unread > 0)
                    TextButton(
                      onPressed: () => notificationService.markAllAsRead(),
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.darkWalnut,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _showSettings,
                    icon: const Icon(Icons.settings_outlined),
                    color: AppColors.darkWalnut,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    // Group by date
    final today = DateTime.now();
    final todayNotifications = <AppNotification>[];
    final earlierNotifications = <AppNotification>[];
    
    for (final n in notifications) {
      if (n.createdAt.day == today.day &&
          n.createdAt.month == today.month &&
          n.createdAt.year == today.year) {
        todayNotifications.add(n);
      } else {
        earlierNotifications.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (todayNotifications.isNotEmpty) ...[
          _buildSectionHeader('Today'),
          ...todayNotifications.map((n) => _buildNotificationCard(n)),
        ],
        if (earlierNotifications.isNotEmpty) ...[
          _buildSectionHeader('Earlier'),
          ...earlierNotifications.map((n) => _buildNotificationCard(n)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.espresso,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => notificationService.deleteNotification(notification.id),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.aiGlow.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead 
                  ? AppColors.cardBorder 
                  : AppColors.aiPurple.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon/Image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: notification.imageUrl?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            notification.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                notification.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            notification.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                                color: AppColors.espresso,
                              ),
                            ),
                          ),
                          Text(
                            notification.timeAgo,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.softOak,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.softOak,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notification.priority == NotificationPriority.high ||
                          notification.priority == NotificationPriority.urgent) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.priority == NotificationPriority.urgent
                                ? AppColors.error.withOpacity(0.1)
                                : AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.priority == NotificationPriority.urgent
                                ? 'URGENT'
                                : 'IMPORTANT',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: notification.priority == NotificationPriority.urgent
                                  ? AppColors.error
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Unread indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.aiPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.softOak.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newOffer:
      case NotificationType.offerAccepted:
        return AppColors.success;
      case NotificationType.offerDeclined:
        return AppColors.error;
      case NotificationType.newMessage:
        return AppColors.info;
      case NotificationType.meetupReminder:
      case NotificationType.studyGroupReminder:
        return AppColors.warning;
      case NotificationType.newReview:
        return Colors.amber;
      case NotificationType.studyPartnerRequest:
      case NotificationType.studyGroupJoined:
        return AppColors.aiPurple;
      default:
        return AppColors.softOak;
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    notificationService.markAsRead(notification.id);
    
    // Navigate to relevant screen
    if (notification.actionUrl != null) {
      Navigator.pushNamed(
        context,
        notification.actionUrl!,
        arguments: notification.payload,
      );
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _NotificationSettingsSheet(),
    );
  }
}

class _NotificationSettingsSheet extends StatefulWidget {
  @override
  State<_NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = notificationService.settings;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingToggle(
            'New Offers',
            'When someone makes an offer on your items',
            _settings.newOffers,
            (value) => setState(() => _settings = _settings.copyWith(newOffers: value)),
          ),
          _buildSettingToggle(
            'Messages',
            'New messages from buyers/sellers',
            _settings.messages,
            (value) => setState(() => _settings = _settings.copyWith(messages: value)),
          ),
          _buildSettingToggle(
            'Meetup Reminders',
            'Reminders for scheduled meetups',
            _settings.meetupReminders,
            (value) => setState(() => _settings = _settings.copyWith(meetupReminders: value)),
          ),
          _buildSettingToggle(
            'Reviews',
            'When you receive a new review',
            _settings.reviews,
            (value) => setState(() => _settings = _settings.copyWith(reviews: value)),
          ),
          _buildSettingToggle(
            'Study Groups',
            'Study partner requests and group updates',
            _settings.bookings,
            (value) => setState(() => _settings = _settings.copyWith(bookings: value)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                notificationService.updateSettings(_settings);
                Navigator.pop(context);
              },
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 12, color: AppColors.softOak),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.darkWalnut,
      ),
    );
  }
}
