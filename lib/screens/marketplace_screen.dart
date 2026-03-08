/// Marketplace Screen for CampusXchange
/// Enhanced marketplace with buying, renting, and borrowing features
/// Implements BMC: Borrow Items, On-Campus Meetups
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/listing_model.dart';
import '../providers/listing_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/bottom_navigation_bar.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ListingProvider _listingProvider = ListingProvider();
  int _currentNavIndex = 0;
  
  String _selectedCategory = 'All';
  ListingType? _filterType;
  bool _showOnlyBoosted = false;

  final List<String> _categories = [
    'All',
    'Books',
    'Electronics',
    'Furniture',
    'Clothing',
    'Sports',
    'Services',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _filterType = null; // All listings
          break;
        case 1:
          _filterType = ListingType.forSale; // Buy only
          break;
        case 2:
          _filterType = ListingType.forRent; // Rent only
          break;
      }
    });
  }

  List<Listing> get _filteredListings {
    List<Listing> listings = _listingProvider.activeListings;

    // Filter by type
    if (_filterType != null) {
      if (_filterType == ListingType.forSale) {
        listings = listings.where((l) => 
            l.listingType == ListingType.forSale || l.listingType == ListingType.both).toList();
      } else if (_filterType == ListingType.forRent) {
        listings = listings.where((l) => 
            l.listingType == ListingType.forRent || l.listingType == ListingType.both).toList();
      }
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      listings = listings.where((l) => 
          l.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      listings = listings.where((l) =>
          l.title.toLowerCase().contains(query) ||
          l.description.toLowerCase().contains(query) ||
          l.tags.any((t) => t.toLowerCase().contains(query))
      ).toList();
    }

    // Filter boosted only
    if (_showOnlyBoosted) {
      listings = listings.where((l) => l.isBoostActive || l.isFeatured).toList();
    }

    // Sort: boosted first, then by date
    listings.sort((a, b) {
      final aBoosted = a.isBoostActive || a.isFeatured;
      final bBoosted = b.isBoostActive || b.isFeatured;
      if (aBoosted && !bBoosted) return -1;
      if (!aBoosted && bBoosted) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return listings;
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
            _buildTabBar(),
            _buildCategoryChips(),
            _buildFiltersRow(),
            Expanded(
              child: _filteredListings.isEmpty
                  ? _buildEmptyState()
                  : _buildListingsGrid(),
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
        onPressed: _showCreateListingModal,
        backgroundColor: AppColors.darkWalnut,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'List Item',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warmBone,
        border: Border(
          bottom: BorderSide(
            color: AppColors.cardBorder.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkWalnut, AppColors.softOak],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marketplace',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepEspresso,
                  ),
                ),
                Text(
                  'Buy, Sell, or Rent',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.softOak,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: const ProfileAvatar(size: 36, showBorder: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.softOak.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search items to buy or rent...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.softOak.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.softOak),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.softOak),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.darkWalnut,
          borderRadius: BorderRadius.circular(14),
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
            text: 'All',
            height: 50,
          ),
          Tab(
            text: 'Buy',
            height: 50,
          ),
          Tab(
            text: 'Rent',
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'All';
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
                  color: isSelected 
                      ? AppColors.darkWalnut 
                      : AppColors.cardBorder,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredListings.length} items',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
          Row(
            children: [
              // Featured filter toggle
              FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: _showOnlyBoosted 
                          ? AppColors.accent 
                          : AppColors.softOak,
                    ),
                    const SizedBox(width: 4),
                    const Text('Featured'),
                  ],
                ),
                selected: _showOnlyBoosted,
                onSelected: (selected) {
                  setState(() {
                    _showOnlyBoosted = selected;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: AppColors.accent.withOpacity(0.15),
                labelStyle: GoogleFonts.inter(
                  fontSize: 12,
                  color: _showOnlyBoosted 
                      ? AppColors.accent 
                      : AppColors.espresso,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _showOnlyBoosted 
                        ? AppColors.accent 
                        : AppColors.cardBorder,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Clear filters
              if (_selectedCategory != 'All' || 
                  _searchController.text.isNotEmpty ||
                  _showOnlyBoosted)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _searchController.clear();
                      _showOnlyBoosted = false;
                    });
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.darkWalnut,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredListings.length,
      itemBuilder: (context, index) {
        final listing = _filteredListings[index];
        return _ListingCard(
          listing: listing,
          onTap: () => _showListingDetail(listing),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppColors.softOak.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }

  void _showListingDetail(Listing listing) {
    _listingProvider.incrementViews(listing.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ListingDetailModal(
        listing: listing,
        onRentRequest: listing.canRent 
            ? () => _showRentalRequestModal(listing) 
            : null,
        onBuy: listing.canBuy 
            ? () => _handleBuyNow(listing) 
            : null,
      ),
    );
  }

  void _showRentalRequestModal(Listing listing) {
    Navigator.pop(context); // Close detail modal
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RentalRequestModal(
        listing: listing,
        onSubmit: (startDate, endDate, message) async {
          final user = AuthContext.instance.currentUser;
          if (user == null) return;
          
          final success = await _listingProvider.createRentalRequest(
            listingId: listing.id,
            borrowerId: user.id,
            borrowerName: user.displayName,
            startDate: startDate,
            endDate: endDate,
            message: message,
          );

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success 
                      ? 'Rental request sent!' 
                      : 'Failed to send request',
                ),
                backgroundColor: success ? AppColors.success : AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleBuyNow(Listing listing) {
    Navigator.pop(context);
    // Navigate to chat with seller
    Navigator.pushNamed(
      context, 
      '/chat',
      arguments: {
        'sellerId': listing.ownerId,
        'sellerName': listing.ownerName,
        'listingId': listing.id,
        'listingTitle': listing.title,
      },
    );
  }

  void _showCreateListingModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateListingModal(
        onCreated: (listing) async {
          final success = await _listingProvider.addListing(listing);
          if (mounted && success) {
            Navigator.pop(context);
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Listing created successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Listing Card Widget
class _ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _ListingCard({
    required this.listing,
    required this.onTap,
  });

  bool get _isBoosted => listing.isBoostActive || listing.isFeatured;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isBoosted 
                ? AppColors.accent.withOpacity(0.5) 
                : AppColors.cardBorder,
            width: _isBoosted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softOak.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: listing.images.isNotEmpty && listing.images.first.isNotEmpty
                        ? Image.network(
                            listing.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Type badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeBadgeColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      listing.listingTypeText,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Boosted badge
                if (_isBoosted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Featured',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepEspresso,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.condition,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.softOak,
                      ),
                    ),
                    const Spacer(),
                    // Price display
                    _buildPriceDisplay(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.softOak.withOpacity(0.1),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.softOak,
        ),
      ),
    );
  }

  Color _getTypeBadgeColor() {
    switch (listing.listingType) {
      case ListingType.forSale:
        return AppColors.success;
      case ListingType.forRent:
        return AppColors.info;
      case ListingType.both:
        return AppColors.darkWalnut;
    }
  }

  Widget _buildPriceDisplay() {
    if (listing.listingType == ListingType.both) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            listing.formattedSalePrice,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          Text(
            listing.formattedRentalPrice,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.info,
            ),
          ),
        ],
      );
    } else if (listing.listingType == ListingType.forRent) {
      return Text(
        listing.formattedRentalPrice,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.info,
        ),
      );
    } else {
      return Text(
        listing.formattedSalePrice,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      );
    }
  }
}

/// Listing Detail Modal
class _ListingDetailModal extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onRentRequest;
  final VoidCallback? onBuy;

  const _ListingDetailModal({
    required this.listing,
    this.onRentRequest,
    this.onBuy,
  });

  bool get _isBoosted => listing.isBoostActive || listing.isFeatured;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images carousel placeholder
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.softOak.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: listing.images.isNotEmpty && listing.images.first.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              listing.images.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 64,
                                  color: AppColors.softOak,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: AppColors.softOak,
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title and badges
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          listing.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepEspresso,
                          ),
                        ),
                      ),
                      if (_isBoosted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Featured',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Category and condition
                  Row(
                    children: [
                      _buildInfoChip(listing.category, Icons.category_outlined),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        listing.condition, 
                        Icons.verified_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Price section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        if (listing.canBuy)
                          _buildPriceRow('Buy Now', listing.formattedSalePrice, AppColors.success),
                        if (listing.canBuy && listing.canRent)
                          const Divider(height: 24),
                        if (listing.canRent) ...[
                          _buildPriceRow(
                            'Rent', 
                            listing.formattedRentalPrice, 
                            AppColors.info,
                          ),
                          if (listing.securityDeposit != null && 
                              listing.securityDeposit! > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Security Deposit',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.softOak,
                                    ),
                                  ),
                                  Text(
                                    listing.formattedDeposit,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.espresso,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.espresso,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Seller info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.softOak.withOpacity(0.2),
                          child: Text(
                            listing.ownerName.isNotEmpty 
                                ? listing.ownerName[0].toUpperCase() 
                                : 'S',
                            style: GoogleFonts.inter(
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
                                listing.ownerName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepEspresso,
                                ),
                              ),
                              if (listing.ownerMajorYear != null)
                                Text(
                                  listing.ownerMajorYear!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.softOak,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (listing.isVerifiedStudent)
                          const Icon(
                            Icons.verified,
                            size: 20,
                            color: AppColors.info,
                          ),
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/chat', arguments: {
                              'sellerId': listing.ownerId,
                              'sellerName': listing.ownerName,
                            });
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.darkWalnut,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Meetup location
                  if (listing.meetupLocation != null && listing.meetupLocation!.isNotEmpty) ...[
                    Text(
                      'Meetup Location',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepEspresso,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softOak.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.softOak,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            listing.meetupLocation!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.espresso,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100), // Space for buttons
                ],
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
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
                if (onBuy != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBuy,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Buy Now',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (onBuy != null && onRentRequest != null)
                  const SizedBox(width: 12),
                if (onRentRequest != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRentRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Request Rental',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softOak.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.softOak),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.espresso,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.espresso,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Rental Request Modal
class _RentalRequestModal extends StatefulWidget {
  final Listing listing;
  final Function(DateTime startDate, DateTime endDate, String? message) onSubmit;

  const _RentalRequestModal({
    required this.listing,
    required this.onSubmit,
  });

  @override
  State<_RentalRequestModal> createState() => _RentalRequestModalState();
}

class _RentalRequestModalState extends State<_RentalRequestModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    return (widget.listing.rentalPrice ?? 0) * _rentalDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.warmBone,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softOak.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Request to Rent',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.listing.title,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.softOak,
            ),
          ),
          const SizedBox(height: 24),
          
          // Date selection
          Row(
            children: [
              Expanded(
                child: _buildDatePicker('Start Date', _startDate, (date) {
                  setState(() {
                    _startDate = date;
                    if (_endDate != null && _endDate!.isBefore(date)) {
                      _endDate = date;
                    }
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker('End Date', _endDate, (date) {
                  setState(() => _endDate = date);
                }, minDate: _startDate),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Message
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add a message to the owner (optional)',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.softOak.withOpacity(0.6),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Price summary
          if (_startDate != null && _endDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    '${widget.listing.formattedRentalPrice} × $_rentalDays days',
                    '₱${_totalPrice.toStringAsFixed(2)}',
                  ),
                  if (widget.listing.securityDeposit != null)
                    _buildSummaryRow(
                      'Security Deposit',
                      widget.listing.formattedDeposit,
                    ),
                  const Divider(),
                  _buildSummaryRow(
                    'Total',
                    '₱${(_totalPrice + (widget.listing.securityDeposit ?? 0)).toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? () => widget.onSubmit(
                        _startDate!,
                        _endDate!,
                        _messageController.text.isNotEmpty 
                            ? _messageController.text 
                            : null,
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkWalnut,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Send Request',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDatePicker(
    String label, 
    DateTime? selectedDate,
    Function(DateTime) onSelected,
    {DateTime? minDate}
  ) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? minDate ?? DateTime.now(),
          firstDate: minDate ?? DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) onSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.softOak,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.darkWalnut,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDate != null
                      ? '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}'
                      : 'Select',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.espresso,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isBold ? AppColors.deepEspresso : AppColors.espresso,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? AppColors.darkWalnut : AppColors.espresso,
            ),
          ),
        ],
      ),
    );
  }
}

/// Create Listing Modal
class _CreateListingModal extends StatefulWidget {
  final Function(Listing) onCreated;

  const _CreateListingModal({required this.onCreated});

  @override
  State<_CreateListingModal> createState() => _CreateListingModalState();
}

class _CreateListingModalState extends State<_CreateListingModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  
  ListingType _listingType = ListingType.forSale;
  final String _category = 'Electronics';
  final String _condition = 'Good';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salePriceController.dispose();
    _rentalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create Listing',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepEspresso,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing type selector
                  Text(
                    'Listing Type',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ListingType.values.map((type) {
                      final isSelected = _listingType == type;
                      return ChoiceChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _listingType = type);
                        },
                        selectedColor: AppColors.darkWalnut,
                        checkmarkColor: Colors.white,
                        labelStyle: GoogleFonts.inter(
                          color: isSelected ? Colors.white : AppColors.espresso,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  _buildTextField('Title', _titleController, 'Enter item title'),
                  const SizedBox(height: 16),
                  
                  // Description
                  _buildTextField(
                    'Description', 
                    _descriptionController, 
                    'Describe your item...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  
                  // Prices based on type
                  if (_listingType == ListingType.forSale || 
                      _listingType == ListingType.both)
                    _buildTextField(
                      'Sale Price (₱)', 
                      _salePriceController, 
                      '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  if (_listingType == ListingType.both)
                    const SizedBox(height: 16),
                  if (_listingType == ListingType.forRent || 
                      _listingType == ListingType.both)
                    _buildTextField(
                      'Rental Price Per Day (₱)', 
                      _rentalPriceController, 
                      '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Submit button
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
                onPressed: _createListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkWalnut,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create Listing',
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

  String _getTypeLabel(ListingType type) {
    switch (type) {
      case ListingType.forSale:
        return 'For Sale';
      case ListingType.forRent:
        return 'For Rent';
      case ListingType.both:
        return 'Both';
    }
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, 
    String hint,
    {int maxLines = 1, TextInputType? keyboardType}
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.deepEspresso,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak.withOpacity(0.6),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }

  void _createListing() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final user = AuthContext.instance.currentUser;
    
    final listing = Listing(
      id: 'listing_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      description: _descriptionController.text,
      category: _category,
      condition: _condition,
      images: [_getCategoryPlaceholderImage(_category)],
      listingType: _listingType,
      salePrice: _listingType != ListingType.forRent 
          ? double.tryParse(_salePriceController.text) ?? 0 
          : null,
      rentalPrice: _listingType != ListingType.forSale 
          ? double.tryParse(_rentalPriceController.text) ?? 0 
          : null,
      ownerId: user?.id ?? 'unknown',
      ownerName: user?.displayName ?? 'Unknown',
      createdAt: DateTime.now(),
    );

    widget.onCreated(listing);
  }

  String _getCategoryPlaceholderImage(String category) {
    switch (category) {
      case 'Books':
        return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400';
      case 'Electronics':
        return 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400';
      case 'Furniture':
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400';
      case 'Clothing':
        return 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=400';
      default:
        return 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400';
    }
  }
}
