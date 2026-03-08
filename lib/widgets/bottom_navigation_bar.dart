import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/trade_provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class CampusXchangeBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;

  const CampusXchangeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  State<CampusXchangeBottomNav> createState() => _CampusXchangeBottomNavState();
}

class _CampusXchangeBottomNavState extends State<CampusXchangeBottomNav> {
  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softOak.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'More Options',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepEspresso,
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuTile(context, Icons.person_outline, 'My Profile', '/profile'),
            _buildMenuTile(context, Icons.favorite_border, 'Favorites', null, onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            }),
            _buildMenuTile(context, Icons.help_outline, 'Help Center', '/help'),
            _buildMenuTile(context, Icons.settings_outlined, 'Settings', null, onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            }),
            _buildMenuTile(context, Icons.logout, 'Sign Out', null, onTap: () {
              Navigator.pop(context);
              AuthContext.instance.logout();
              Navigator.pushReplacementNamed(context, '/login');
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String? route,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warmBone,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.darkWalnut, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.deepEspresso,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.softOak),
      onTap: () {
        if (route != null) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        } else if (onTap != null) {
          onTap();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationCount = NotificationService.instance.unreadCount;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.softOak.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Home', 0),
              _buildNavItem(context, Icons.school_outlined, 'Skills', 1),
              _buildNavItem(
                context,
                Icons.chat_bubble_outline,
                'Messages',
                2,
                badge: TradeContext.instance.unreadCount > 0
                    ? TradeContext.instance.unreadCount.toString()
                    : null,
              ),
              _buildNavItem(
                context,
                Icons.notifications_outlined,
                'Alerts',
                3,
                badge: notificationCount > 0 ? notificationCount.toString() : null,
              ),
              _buildNavItem(context, Icons.menu, 'More', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index,
      {String? badge}) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () {
        widget.onIndexChanged(index);

        // Home tab - navigate to home
        if (index == 0) {
          Navigator.of(context).pushReplacementNamed('/');
        }
        // Skills tab - navigate to skills exchange
        else if (index == 1) {
          Navigator.of(context).pushReplacementNamed('/skills');
        }
        // Messages
        else if (index == 2) {
          Navigator.of(context).pushReplacementNamed('/inbox');
        }
        // Notifications
        else if (index == 3) {
          Navigator.of(context).pushReplacementNamed('/notifications');
        }
        // More menu
        else if (index == 4) {
          _showMoreMenu(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkWalnut.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.darkWalnut : AppColors.softOak,
                  size: 24,
                ),
                if (badge != null)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.darkWalnut : AppColors.softOak,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
