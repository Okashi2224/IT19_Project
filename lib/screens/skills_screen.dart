import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/skill_model.dart';
import '../providers/skill_provider.dart';
import '../services/ai_service.dart';
import '../widgets/bottom_navigation_bar.dart';

/// Study Partners Screen - Free peer-to-peer learning community
/// Supports Business Model Canvas: Community Learning & Study Groups
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  SkillCategory? _selectedCategory;
  int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SkillContext.instance.setCurrentUser('current_user');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            _buildTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFindPartnersTab(),
                  _buildStudyGroupsTab(),
                  _buildMyPostsTab(),
                ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostModal,
        backgroundColor: AppColors.darkWalnut,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Share Skill',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.darkWalnut,
          ),
          Expanded(
            child: Text(
              'Study Partners',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.aiGlow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, size: 16, color: AppColors.aiPurple),
                const SizedBox(width: 4),
                Text(
                  'FREE',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.aiPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            SkillContext.instance.setSearchQuery(value);
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search study partners, groups, subjects...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.softOak,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.softOak),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildCategoryChip(null, 'All'),
          ...SkillCategory.values.map(
              (cat) => _buildCategoryChip(cat, _getCategoryName(cat))),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(SkillCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppColors.espresso,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.darkWalnut,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.darkWalnut : AppColors.cardBorder,
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
            SkillContext.instance.setSelectedCategory(_selectedCategory);
          });
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            text: 'Find Partners',
            height: 48,
          ),
          Tab(
            text: 'Study Groups',
            height: 48,
          ),
          Tab(
            text: 'My Posts',
            height: 48,
          ),
        ],
      ),
    );
  }

  // ============ TAB 1: FIND PARTNERS ============

  Widget _buildFindPartnersTab() {
    return ListenableBuilder(
      listenable: SkillContext.instance,
      builder: (context, _) {
        final skills = SkillContext.instance.filteredSkills;

        if (skills.isEmpty) {
          return _buildEmptyState(
            'No study partners found',
            'Try adjusting your filters or be the first to share!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: skills.length,
          itemBuilder: (context, index) => _buildPartnerCard(skills[index]),
        );
      },
    );
  }

  Widget _buildPartnerCard(Skill skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Intent badge
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.beigeBadge,
                  child: Text(
                    skill.userName.isNotEmpty ? skill.userName[0] : '?',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkWalnut,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.userName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.espresso,
                        ),
                      ),
                      Text(
                        '${skill.levelLabel} ${skill.categoryName}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.softOak,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildIntentBadge(skill.intent),
              ],
            ),
            const SizedBox(height: 12),

            // Skill title
            Text(
              skill.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              skill.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.espresso.withOpacity(0.7),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTagChip(
                    skill.intentLabel,
                    skill.intent == SkillIntent.canTeach
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.aiGlow,
                    skill.intent == SkillIntent.canTeach
                        ? AppColors.success
                        : AppColors.aiPurple),
                ...skill.tags.take(3).map((tag) => _buildTagChip(
                      tag,
                      AppColors.beigeBadge,
                      AppColors.softOak,
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom: availability + connect button
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.softOak),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    skill.availableDays.join(', '),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.softOak),
                  ),
                ),
                if (skill.preferredLocation != null) ...[
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.softOak),
                  const SizedBox(width: 4),
                  Text(
                    skill.preferredLocation!,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.softOak),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showConnectDialog(skill),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Connect'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntentBadge(SkillIntent intent) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (intent) {
      case SkillIntent.canTeach:
        bgColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.school;
        break;
      case SkillIntent.wantToLearn:
        bgColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        icon = Icons.menu_book;
        break;
      case SkillIntent.both:
        bgColor = AppColors.aiGlow;
        textColor = AppColors.aiPurple;
        icon = Icons.swap_horiz;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: textColor),
    );
  }

  // ============ TAB 2: STUDY GROUPS ============

  Widget _buildStudyGroupsTab() {
    return ListenableBuilder(
      listenable: SkillContext.instance,
      builder: (context, _) {
        final groups = SkillContext.instance.filteredStudyGroups;

        if (groups.isEmpty) {
          return _buildEmptyState(
            'No study groups found',
            'Create a group and invite classmates!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: groups.length,
          itemBuilder: (context, index) => _buildGroupCard(groups[index]),
        );
      },
    );
  }

  Widget _buildGroupCard(StudyGroup group) {
    final isMember = group.memberIds.contains('current_user');
    final isFull = group.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name + category
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.aiGlow,
                  child: Icon(Icons.groups, color: AppColors.aiPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.espresso,
                        ),
                      ),
                      Text(
                        group.topic,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.softOak,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMember)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Joined',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              group.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.espresso.withOpacity(0.7),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Info row: members, location, next meetup
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: AppColors.softOak),
                const SizedBox(width: 4),
                Text(
                  '${group.memberCount}/${group.maxMembers}',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.espresso),
                ),
                const SizedBox(width: 16),
                if (group.meetupLocation != null) ...[
                  const Icon(Icons.location_on,
                      size: 16, color: AppColors.softOak),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      group.meetupLocation!,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.espresso),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            if (group.nextMeetup != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppColors.softOak),
                  const SizedBox(width: 4),
                  Text(
                    'Next meetup: ${_formatDateTime(group.nextMeetup!)}',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: AppColors.info),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Join / Leave button
            SizedBox(
              width: double.infinity,
              child: isMember
                  ? OutlinedButton(
                      onPressed: () {
                        SkillContext.instance.leaveStudyGroup(group.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Left ${group.name}')),
                        );
                      },
                      child: const Text('Leave Group'),
                    )
                  : ElevatedButton.icon(
                      onPressed: isFull
                          ? null
                          : () {
                              SkillContext.instance.joinStudyGroup(group.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Joined ${group.name}!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            },
                      icon: Icon(isFull ? Icons.lock : Icons.group_add,
                          size: 18),
                      label: Text(isFull
                          ? 'Group Full'
                          : 'Join Group (${group.openSlots} spots left)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ TAB 3: MY POSTS ============

  Widget _buildMyPostsTab() {
    return ListenableBuilder(
      listenable: SkillContext.instance,
      builder: (context, _) {
        final mySkills = SkillContext.instance.mySkills;
        final myGroups = SkillContext.instance.myGroups;

        if (mySkills.isEmpty && myGroups.isEmpty) {
          return _buildEmptyState(
            'No posts yet',
            'Share your skills or create a study group!',
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            if (mySkills.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 8),
                child: Text(
                  'My Study Partner Posts',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.espresso,
                  ),
                ),
              ),
              ...mySkills
                  .map((skill) => _buildPartnerCard(skill)),
            ],
            if (myGroups.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12, top: 16),
                child: Text(
                  'My Study Groups',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.espresso,
                  ),
                ),
              ),
              ...myGroups
                  .map((group) => _buildGroupCard(group)),
            ],
          ],
        );
      },
    );
  }

  // ============ SHARED WIDGETS ============

  Widget _buildTagChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined,
              size: 64, color: AppColors.softOak.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(SkillCategory category) {
    switch (category) {
      case SkillCategory.academic:
        return 'Academic';
      case SkillCategory.technology:
        return 'Tech';
      case SkillCategory.creative:
        return 'Creative';
      case SkillCategory.language:
        return 'Language';
      case SkillCategory.music:
        return 'Music';
      case SkillCategory.sports:
        return 'Sports';
      case SkillCategory.lifestyle:
        return 'Lifestyle';
      case SkillCategory.other:
        return 'Other';
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${months[dt.month - 1]} ${dt.day} at $hour:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }

  // ============ DIALOGS & MODALS ============

  void _showConnectDialog(Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Connect with ${skill.userName}',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a study partner request for:',
              style: GoogleFonts.inter(color: AppColors.softOak),
            ),
            const SizedBox(height: 8),
            Text(
              skill.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.espresso,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.aiGlow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: AppColors.aiPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Suggested Meetup',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.aiPurple,
                          ),
                        ),
                        Text(
                          aiService.getCampusMeetupSpot().name,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.espresso),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              SkillContext.instance.connectWithPartner(skill);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Connect request sent to ${skill.userName}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What would you like to create?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.success.withOpacity(0.1),
                child: const Icon(Icons.person_add, color: AppColors.success),
              ),
              title: Text(
                'Find Study Partner',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Post that you can teach or want to learn'),
              onTap: () {
                Navigator.pop(context);
                _showShareSkillModal();
              },
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.aiGlow,
                child: Icon(Icons.groups, color: AppColors.aiPurple),
              ),
              title: Text(
                'Create Study Group',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Start a group for your class or topic'),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupModal();
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showShareSkillModal() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    SkillCategory selectedCategory = SkillCategory.academic;
    SkillIntent selectedIntent = SkillIntent.both;
    SkillLevel selectedLevel = SkillLevel.intermediate;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final screenHeight = MediaQuery.of(context).size.height;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Share Your Skill',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g., Calculus Study Partner',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SkillCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: SkillCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name[0].toUpperCase() +
                              cat.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('What are you looking for?',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SkillIntent.values.map((intent) {
                        final isSelected = selectedIntent == intent;
                        String label;
                        switch (intent) {
                          case SkillIntent.canTeach:
                            label = 'I can help others';
                            break;
                          case SkillIntent.wantToLearn:
                            label = 'I want to learn';
                            break;
                          case SkillIntent.both:
                            label = 'Both';
                            break;
                        }
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(label),
                          selectedColor: AppColors.darkWalnut,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.espresso,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedIntent = intent);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Your level',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SkillLevel.values.map((level) {
                        final isSelected = selectedLevel == level;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text(level.name[0].toUpperCase() +
                              level.name.substring(1)),
                          selectedColor: AppColors.darkWalnut,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.espresso,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedLevel = level);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'What topics do you want to study together?',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (titleController.text.isEmpty ||
                                    descriptionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please fill in all fields')),
                                  );
                                  return;
                                }
                                setModalState(() => isLoading = true);
                                final skill = Skill(
                                  id: 'skill_${DateTime.now().millisecondsSinceEpoch}',
                                  userId: 'current_user',
                                  userName: 'You',
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  category: selectedCategory,
                                  intent: selectedIntent,
                                  level: selectedLevel,
                                );
                                SkillContext.instance.addSkill(skill);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Skill shared successfully!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Share Skill (Free)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateGroupModal() {
    final nameController = TextEditingController();
    final topicController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    SkillCategory selectedCategory = SkillCategory.academic;
    int maxMembers = 6;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final screenHeight = MediaQuery.of(context).size.height;
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Create Study Group',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g., CS101 Study Squad',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: topicController,
                      decoration: InputDecoration(
                        labelText: 'Topic / Subject',
                        hintText: 'e.g., Computer Science 101',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SkillCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: SkillCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name[0].toUpperCase() +
                              cat.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() => selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'What will the group study?',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Meetup Location (optional)',
                        hintText: 'e.g., Library Floor 2',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Max Members',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [4, 6, 8, 10, 12].map((count) {
                        final isSelected = maxMembers == count;
                        return ChoiceChip(
                          selected: isSelected,
                          label: Text('$count'),
                          selectedColor: AppColors.darkWalnut,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.espresso,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => maxMembers = count);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (nameController.text.isEmpty ||
                                    topicController.text.isEmpty ||
                                    descriptionController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Please fill in all fields')),
                                  );
                                  return;
                                }
                                setModalState(() => isLoading = true);
                                final group = StudyGroup(
                                  id: 'group_${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  category: selectedCategory,
                                  topic: topicController.text,
                                  creatorId: 'current_user',
                                  creatorName: 'You',
                                  memberIds: ['current_user'],
                                  maxMembers: maxMembers,
                                  meetupLocation:
                                      locationController.text.isNotEmpty
                                          ? locationController.text
                                          : null,
                                  isOpen: true,
                                );
                                SkillContext.instance.createStudyGroup(group);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Study group created!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Create Group (Free)'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
