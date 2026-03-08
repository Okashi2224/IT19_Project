/// Organizations Screen for CampusXchange
/// Implements BMC: Key Partnership - Student Organizations, University Offices
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/organization_model.dart';
import '../widgets/bottom_navigation_bar.dart';

class OrganizationsScreen extends StatefulWidget {
  const OrganizationsScreen({super.key});

  @override
  State<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends State<OrganizationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  OrganizationType? _selectedType;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<StudentOrganization> get _filteredOrganizations {
    List<StudentOrganization> orgs = sampleOrganizations
        .where((o) => o.verificationStatus == OrgVerificationStatus.verified)
        .toList();

    // Filter by type
    if (_selectedType != null) {
      orgs = orgs.where((o) => o.type == _selectedType).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      orgs = orgs.where((o) =>
          o.name.toLowerCase().contains(query) ||
          o.abbreviation.toLowerCase().contains(query) ||
          o.description.toLowerCase().contains(query)
      ).toList();
    }

    return orgs;
  }

  List<OrgEvent> get _upcomingEvents {
    return sampleOrgEvents
        .where((e) => e.isUpcoming && e.isActive)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmBone,
      appBar: AppBar(
        backgroundColor: AppColors.warmBone,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepEspresso),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Organizations',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.deepEspresso,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search organizations...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.softOak.withOpacity(0.6),
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.softOak),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.darkWalnut,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.softOak,
              tabs: const [
                Tab(
                  text: 'Organizations',
                  height: 50,
                ),
                Tab(
                  text: 'Events',
                  height: 50,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrganizationsTab(),
                _buildEventsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildOrganizationsTab() {
    return Column(
      children: [
        // Type filter chips
        SizedBox(
          height: 50,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            children: [
              _buildTypeChip(null, 'All'),
              _buildTypeChip(OrganizationType.academic, 'Academic'),
              _buildTypeChip(OrganizationType.cultural, 'Cultural'),
              _buildTypeChip(OrganizationType.sports, 'Sports'),
              _buildTypeChip(OrganizationType.professional, 'Professional'),
              _buildTypeChip(OrganizationType.service, 'Service'),
            ],
          ),
        ),
        
        // Organizations list
        Expanded(
          child: _filteredOrganizations.isEmpty
              ? _buildEmptyState('No organizations found')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredOrganizations.length,
                  itemBuilder: (context, index) {
                    final org = _filteredOrganizations[index];
                    return _OrganizationCard(
                      organization: org,
                      onTap: () => _showOrgDetail(org),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return _upcomingEvents.isEmpty
        ? _buildEmptyState('No upcoming events')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _upcomingEvents.length,
            itemBuilder: (context, index) {
              final event = _upcomingEvents[index];
              return _EventCard(
                event: event,
                onTap: () => _showEventDetail(event),
              );
            },
          );
  }

  Widget _buildTypeChip(OrganizationType? type, String label) {
    final isSelected = _selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.darkWalnut,
        checkmarkColor: Colors.white,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? Colors.white : AppColors.espresso,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.darkWalnut : AppColors.cardBorder,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 64,
            color: AppColors.softOak.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrgDetail(StudentOrganization org) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrgDetailModal(organization: org),
    );
  }

  void _showEventDetail(OrgEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventDetailModal(event: event),
    );
  }
}

/// Organization Card
class _OrganizationCard extends StatelessWidget {
  final StudentOrganization organization;
  final VoidCallback onTap;

  const _OrganizationCard({
    required this.organization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.softOak.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  organization.abbreviation,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkWalnut,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          organization.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepEspresso,
                          ),
                        ),
                      ),
                      if (organization.isVerified)
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.info,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${organization.typeDisplayName} • ${organization.universityName}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.softOak,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppColors.softOak,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${organization.memberCount} members',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.softOak,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.softOak,
            ),
          ],
        ),
      ),
    );
  }
}

/// Event Card
class _EventCard extends StatelessWidget {
  final OrgEvent event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: event.isMarketplaceRelated 
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.softOak.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getMonth(event.startTime),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.softOak,
                          ),
                        ),
                        Text(
                          event.startTime.day.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepEspresso,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event.isMarketplaceRelated)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Marketplace Event',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepEspresso,
                          ),
                        ),
                        Text(
                          event.orgName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.softOak,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDetail(
                        Icons.access_time_outlined, 
                        _getTimeRange(event),
                      ),
                      const SizedBox(width: 16),
                      _buildDetail(
                        Icons.location_on_outlined, 
                        event.location,
                      ),
                    ],
                  ),
                  if (event.maxParticipants != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDetail(
                          Icons.people_outline,
                          '${event.participantCount}/${event.maxParticipants} joined',
                        ),
                        if (event.isFull)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Full',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.softOak),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.softOak,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(DateTime date) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[date.month - 1];
  }

  String _getTimeRange(OrgEvent event) {
    final start = '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}';
    final end = '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

/// Organization Detail Modal
class _OrgDetailModal extends StatelessWidget {
  final StudentOrganization organization;

  const _OrgDetailModal({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.warmBone,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.softOak.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.softOak.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            organization.abbreviation,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkWalnut,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    organization.name,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.deepEspresso,
                                    ),
                                  ),
                                ),
                                if (organization.isVerified)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Icons.verified,
                                      size: 20,
                                      color: AppColors.info,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              organization.universityName,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.softOak,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats
                  Row(
                    children: [
                      _buildStatCard(
                        Icons.people_outline,
                        '${organization.memberCount}',
                        'Members',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        Icons.category_outlined,
                        organization.typeDisplayName,
                        'Type',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'About',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    organization.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.espresso,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Advisor
                  if (organization.advisorName != null) ...[
                    Text(
                      'Advisor',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepEspresso,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.softOak.withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.darkWalnut,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            organization.advisorName!,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.deepEspresso,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Contact
                  Text(
                    'Contact',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (organization.email != null)
                    _buildContactRow(Icons.email_outlined, organization.email!),
                  if (organization.website != null)
                    _buildContactRow(Icons.language, organization.website!),
                ],
              ),
            ),
          ),
          // Join button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // View listings by this org
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkWalnut,
                      side: const BorderSide(color: AppColors.darkWalnut),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View Listings',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Request to join
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkWalnut,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Join',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softOak.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.darkWalnut),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepEspresso,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.softOak,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.softOak),
          const SizedBox(width: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.espresso,
            ),
          ),
        ],
      ),
    );
  }
}

/// Event Detail Modal
class _EventDetailModal extends StatelessWidget {
  final OrgEvent event;

  const _EventDetailModal({required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.warmBone,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.softOak.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event.isMarketplaceRelated)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.storefront,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Marketplace Event',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    event.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${event.orgName}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.softOak,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date & Time card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          'Date',
                          _formatDate(event.startTime),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.access_time_outlined,
                          'Time',
                          _formatTimeRange(),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Location',
                          event.location,
                        ),
                        if (event.locationDetails != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Text(
                              event.locationDetails!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.softOak,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'About This Event',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.espresso,
                      height: 1.5,
                    ),
                  ),
                  if (event.maxParticipants != null) ...[
                    const SizedBox(height: 20),
                    // Participants
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: AppColors.darkWalnut,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${event.participantCount} / ${event.maxParticipants} participants',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.deepEspresso,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: event.participantCount / event.maxParticipants!,
                                  backgroundColor: AppColors.softOak.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation(
                                    event.isFull 
                                        ? AppColors.error 
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Join button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: event.isFull ? null : () {
                  // Join event
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Successfully joined the event!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: event.isFull 
                      ? AppColors.softOak 
                      : AppColors.darkWalnut,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  event.isFull ? 'Event Full' : 'Join Event',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.darkWalnut),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.softOak,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.deepEspresso,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTimeRange() {
    String formatTime(DateTime dt) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
    }
    return '${formatTime(event.startTime)} - ${formatTime(event.endTime)}';
  }
}
