import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state.dart';
import '../models/item_model.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/bottom_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSidebarIndex = 0;
  int _currentNavIndex = 0;
  
  // Edit profile controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isSaving = false;

  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem(Icons.person_outline, 'Profile', 'Your account'),
    _SidebarItem(Icons.inventory_2_outlined, 'My Listings', 'Items you\'re selling'),
    _SidebarItem(Icons.favorite_outline, 'Favorites', 'Saved items'),
    _SidebarItem(Icons.history, 'History', 'Past transactions'),
    _SidebarItem(Icons.settings_outlined, 'Settings', 'Preferences'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize controllers with current user data
    final user = AuthContext.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _bioController.text = 'Student at ${user?.university ?? "University"}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: SafeArea(
        child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          child: Column(
            children: [
              _buildSidebarHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _sidebarItems.length,
                  itemBuilder: (context, index) {
                    return _buildSidebarTile(index);
                  },
                ),
              ),
              _buildLogoutButton(),
            ],
          ),
        ),
        // Main Content
        Expanded(
          child: _buildMainContent(_selectedSidebarIndex),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(
          child: _selectedSidebarIndex == 0
              ? _buildMobileContent()
              : _buildMainContent(_selectedSidebarIndex),
        ),
      ],
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.darkWalnut,
          ),
          const SizedBox(width: 8),
          Text(
            'Account',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(int index) {
    final item = _sidebarItems[index];
    final isSelected = _selectedSidebarIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppColors.beigeBadge : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            setState(() => _selectedSidebarIndex = index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppColors.darkWalnut : AppColors.softOak,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.espresso : AppColors.espresso.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.espresso.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.darkWalnut,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            AuthContext.instance.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: BorderSide(color: AppColors.error.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(int index) {
    switch (index) {
      case 0:
        return _buildProfileView();
      case 1:
        return _buildMyListingsView();
      case 2:
        return _buildFavoritesView();
      case 3:
        return _buildHistoryView();
      case 4:
        return _buildSettingsView();
      default:
        return _buildProfileView();
    }
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.darkWalnut,
          ),
          Expanded(
            child: Text(
              'Profile',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showMobileMenu(),
            icon: const Icon(Icons.more_vert),
            color: AppColors.darkWalnut,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 24),
          _buildMobileTabBar(),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemsGrid(_getMockListings()),
                _buildItemsGrid(_getFavoriteItems()),
                _buildHistoryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = AuthContext.instance.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Avatar - using shared ProfileAvatar widget
          ProfileAvatarLarge(
            user: user,
            size: 80,
          ),
          const SizedBox(height: 16),
          
          // Name & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user?.displayName ?? 'John Doe',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.espresso,
                ),
              ),
              if (user?.isVerified ?? false) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          
          // University
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school_outlined, size: 16, color: AppColors.softOak),
              const SizedBox(width: 6),
              Text(
                user?.university ?? 'University',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.espresso.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Email
          Text(
            user?.email ?? 'john.doe@university.edu',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.espresso.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final rating = user?.rating ?? 4.5;
                if (index < rating.floor()) {
                  return const Icon(Icons.star, color: AppColors.warning, size: 20);
                } else if (index < rating) {
                  return const Icon(Icons.star_half, color: AppColors.warning, size: 20);
                }
                return const Icon(Icons.star_border, color: AppColors.warning, size: 20);
              }),
              const SizedBox(width: 8),
              Text(
                (user?.rating ?? 4.5).toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.espresso,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final user = AuthContext.instance.currentUser;
    
    return Row(
      children: [
        _buildStatCard('Items Sold', '${user?.itemsSold ?? 5}', Icons.sell_outlined),
        const SizedBox(width: 12),
        _buildStatCard('Purchased', '${user?.itemsBought ?? 3}', Icons.shopping_bag_outlined),
        const SizedBox(width: 12),
        _buildStatCard('Member Since', 'Jan 2024', Icons.calendar_today_outlined),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.darkWalnut, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.espresso.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.beigeBadge,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.darkWalnut,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.espresso,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerHeight: 0,
        tabs: const [
          Tab(
            text: 'Listings',
            height: 48,
          ),
          Tab(
            text: 'Favorites',
            height: 48,
          ),
          Tab(
            text: 'History',
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account information',
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProfileCard()),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildEditProfileCard(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildEditProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildEditFieldWithController('Display Name', _nameController),
          const SizedBox(height: 16),
          _buildEditFieldWithController('Bio', _bioController),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    final success = await AuthContext.instance.updateProfile(
      displayName: _nameController.text.trim(),
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated!' : 'Failed to update profile'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Widget _buildEditFieldWithController(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.espresso,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsView() {
    final listings = _getMockListings();
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Listings',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.espresso,
                      ),
                    ),
                    Text(
                      '${listings.length} items for sale',
                      style: GoogleFonts.inter(
                        color: AppColors.espresso.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                icon: const Icon(Icons.add),
                label: const Text('New Listing'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildItemsGrid(listings)),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    final favorites = _getFavoriteItems();
    
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorites',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          Text(
            '${favorites.length} saved items',
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: favorites.isEmpty
                ? _buildEmptyState('No favorites yet', 'Items you love will appear here')
                : _buildItemsGrid(favorites),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction History',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          Text(
            'Your past exchanges',
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(child: _buildHistoryList()),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView(
      children: [
        _buildHistoryTile('Organic Chemistry Textbook', 'Sold to Sarah M.', '₱35', true),
        _buildHistoryTile('TI-84 Calculator', 'Bought from Mike J.', '₱65', false),
        _buildHistoryTile('Desk Lamp', 'Sold to Alex K.', '₱15', true),
      ],
    );
  }

  Widget _buildHistoryTile(String title, String subtitle, String price, bool isSold) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSold ? AppColors.success.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSold ? Icons.sell_outlined : Icons.shopping_bag_outlined,
              color: isSold ? AppColors.success : AppColors.info,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.espresso,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.espresso.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkWalnut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSettingsTile('Notifications', 'Manage push notifications', Icons.notifications_outlined),
          _buildSettingsTile('Privacy', 'Control your data', Icons.privacy_tip_outlined),
          _buildSettingsTile('Help & Support', 'Get help', Icons.help_outline),
          _buildSettingsTile('About', 'App version 1.0.0', Icons.info_outline),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        onTap: () => _handleSettingsTap(title),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.beigeBadge,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.darkWalnut),
        ),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.softOak),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _handleSettingsTap(String setting) {
    switch (setting) {
      case 'Notifications':
        _showNotificationSettings();
        break;
      case 'Privacy':
        _showPrivacySettings();
        break;
      case 'Help & Support':
        _showHelpDialog();
        break;
      case 'About':
        _showAboutDialog();
        break;
    }
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Notifications', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Push Notifications', style: GoogleFonts.inter()),
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.darkWalnut,
            ),
            SwitchListTile(
              title: Text('Email Notifications', style: GoogleFonts.inter()),
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppColors.darkWalnut,
            ),
            SwitchListTile(
              title: Text('New Messages', style: GoogleFonts.inter()),
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.darkWalnut,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Privacy', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Show Profile', style: GoogleFonts.inter()),
              subtitle: Text('Allow others to see your profile', style: GoogleFonts.inter(fontSize: 12)),
              value: true,
              onChanged: (v) {},
              activeThumbColor: AppColors.darkWalnut,
            ),
            SwitchListTile(
              title: Text('Show Email', style: GoogleFonts.inter()),
              value: false,
              onChanged: (v) {},
              activeThumbColor: AppColors.darkWalnut,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Help & Support', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppColors.darkWalnut),
              title: Text('Email Support', style: GoogleFonts.inter()),
              subtitle: Text('support@campusxchange.edu', style: GoogleFonts.inter(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum_outlined, color: AppColors.darkWalnut),
              title: Text('FAQ', style: GoogleFonts.inter()),
              subtitle: Text('Frequently asked questions', style: GoogleFonts.inter(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('About CampusXchange', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.darkWalnut,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.storefront_outlined, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Version 1.0.0', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'CampusXchange is a peer-to-peer marketplace for university students.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.espresso.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 CampusXchange',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.softOak),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(List<Item> items) {
    if (items.isEmpty) {
      return _buildEmptyState('No items', 'Nothing here yet');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildItemCard(item);
          },
        );
      },
    );
  }

  Widget _buildItemCard(Item item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/item-detail', arguments: item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  color: AppColors.beigeBadge,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, color: AppColors.softOak, size: 40)),
                        )
                      : const Center(child: Icon(Icons.image, color: AppColors.softOak, size: 40)),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.espresso,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      item.price == 0 ? 'Free' : '₱${item.price.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkWalnut,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.softOak),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._sidebarItems.asMap().entries.map((entry) => ListTile(
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedSidebarIndex = entry.key);
              },
              leading: Icon(entry.value.icon, color: AppColors.darkWalnut),
              title: Text(entry.value.title),
              subtitle: Text(entry.value.subtitle, style: const TextStyle(fontSize: 12)),
            )),
            const Divider(),
            ListTile(
              onTap: () {
                AuthContext.instance.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }

  List<Item> _getMockListings() {
    return initialItems.take(3).toList();
  }

  List<Item> _getFavoriteItems() {
    // Use AppStateManager for actual favorites
    return AppStateManager.instance.favoriteItems;
  }
}

class _SidebarItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _SidebarItem(this.icon, this.title, this.subtitle);
}
