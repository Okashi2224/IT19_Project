import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/auth_provider.dart';

/// A reusable profile avatar widget that displays the user's profile picture
/// or falls back to initials if no image is available.
/// 
/// This widget ensures consistent profile display across:
/// - Navbar (discovery feed)
/// - Profile page
/// - Bottom navigation
/// - Any other location needing a profile avatar
class ProfileAvatar extends StatelessWidget {
  /// Size of the avatar (diameter)
  final double size;
  
  /// Whether to show the border
  final bool showBorder;
  
  /// Border width (if showBorder is true)
  final double borderWidth;
  
  /// Callback when avatar is tapped
  final VoidCallback? onTap;
  
  /// Optional custom user (defaults to AuthContext.instance.currentUser)
  final User? user;

  const ProfileAvatar({
    super.key,
    this.size = 40,
    this.showBorder = true,
    this.borderWidth = 2,
    this.onTap,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? AuthContext.instance.currentUser;
    final hasImage = currentUser?.profileImageUrl != null && 
                     currentUser!.profileImageUrl!.isNotEmpty;
    
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasImage ? null : AppColors.darkWalnut,
        border: showBorder 
            ? Border.all(color: AppColors.darkWalnut, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkWalnut.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(currentUser.profileImageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasImage
          ? null
          : Center(
              child: Text(
                currentUser?.initials ?? 'U',
                style: GoogleFonts.playfairDisplay(
                  fontSize: size * 0.35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }
    
    return avatar;
  }
}

/// A smaller profile avatar for use in lists, comments, etc.
class ProfileAvatarSmall extends StatelessWidget {
  final User? user;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarSmall({
    super.key,
    this.user,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      user: user,
      size: size,
      showBorder: false,
      onTap: onTap,
    );
  }
}

/// A large profile avatar for profile pages and headers
class ProfileAvatarLarge extends StatelessWidget {
  final User? user;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarLarge({
    super.key,
    this.user,
    this.size = 80,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      user: user,
      size: size,
      showBorder: true,
      borderWidth: 3,
      onTap: onTap,
    );
  }
}
