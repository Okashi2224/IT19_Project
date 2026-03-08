import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/item_model.dart';
import '../models/product_model.dart';
import '../providers/app_state.dart';
import '../widgets/item_card.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/post_item_modal_v2.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../providers/auth_provider.dart';

class DiscoveryFeedScreen extends StatefulWidget {
  const DiscoveryFeedScreen({super.key});

  @override
  State<DiscoveryFeedScreen> createState() => _DiscoveryFeedScreenState();
}

class _DiscoveryFeedScreenState extends State<DiscoveryFeedScreen> 
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AppState _appState;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _appState = AppStateManager.instance;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    _appState.setSearchQuery(_searchController.text);
    setState(() {});
  }
  
  void _onCategorySelected(String category) {
    _appState.setSelectedCategory(category);
    setState(() {});
  }

  void _showPostItemModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostItemModal(
        onItemPosted: (item) {
          _appState.addItem(item);
          setState(() {});
          Navigator.pop(context);
          _showSuccessSnackbar('Item posted successfully!');
        },
      ),
    );
  }
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _appState.filteredItems;
    final filteredProducts = _appState.filteredProducts;
    
    // Get featured products for sponsor section
    final featuredProducts = _appState.products.take(3).toList();
    
    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: SafeArea(
        child: Column(
          children: [
            // Frosted Glass Navbar
            _buildNavbar(),
            
            // Search Bar
            _buildSearchBar(),
            
            // Main scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sponsored/Featured Items Section at the top
                    _buildSponsoredSection(featuredProducts),
                    
                    // Category Cards Section
                    _buildCategoryCards(),
                    
                    // Results count header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${filteredItems.length} items found',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.softOak,
                            ),
                          ),
                          if (_appState.searchQuery.isNotEmpty || 
                              _appState.selectedCategory != 'All')
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _appState.setSelectedCategory('All');
                                setState(() {});
                              },
                              child: Text(
                                'Clear filters',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.darkWalnut,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Products/Items Grid - Using ProductCard for better UI
                    filteredProducts.isEmpty && filteredItems.isEmpty
                        ? _buildEmptyState()
                        : filteredProducts.isNotEmpty
                            ? _buildProductsGridNonScrollable(filteredProducts)
                            : _buildItemsGridNonScrollable(filteredItems),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() => _currentIndex = index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPostItemModal,
        backgroundColor: AppColors.darkWalnut,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Post Item',
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

  Widget _buildNavbar() {
    // Navbar with profile icon in upper right
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warmBone.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.softOak.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkWalnut.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CampusXchange',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepEspresso,
                  ),
                ),
                Text(
                  'Student Marketplace',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.softOak,
                  ),
                ),
              ],
            ),
          ),
          // Profile with name - navigates to profile page
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Row(
              children: [
                Text(
                  AuthContext.instance.currentUser?.displayName ?? 'Guest',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.espresso,
                  ),
                ),
                const SizedBox(width: 10),
                const ProfileAvatar(
                  size: 36,
                  showBorder: true,
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
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.cardBorder, width: 1),
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
          decoration: InputDecoration(
            hintText: 'Search for books, electronics, furniture...',
            hintStyle: GoogleFonts.inter(
              color: AppColors.softOak.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.softOak,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.softOak),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  /// Build Sponsored/Featured Items section at the top
  Widget _buildSponsoredSection(List<Product> featuredProducts) {
    if (featuredProducts.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with "Sponsored" badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.darkWalnut],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Featured & Sponsored',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepEspresso,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AD',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable featured items
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return _buildFeaturedCard(product);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Build a featured product card for the sponsored section
  Widget _buildFeaturedCard(Product product) {
    return GestureDetector(
      onTap: () {
        final item = Item(
          id: product.id,
          title: product.title,
          price: product.price,
          imageUrl: product.imagePath,
          category: product.category,
          sellerId: product.sellerId,
          sellerName: product.sellerName,
          sellerMajorYear: product.sellerMajorYear,
          isVerifiedStudent: product.isVerifiedStudent,
          description: product.description,
        );
        Navigator.pushNamed(context, '/item-detail', arguments: item);
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accent.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Featured badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.beigeBadge,
                    child: product.imagePath.startsWith('http')
                        ? Image.network(
                            product.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: AppColors.softOak,
                            ),
                          )
                        : const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.softOak,
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.darkWalnut],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Featured',
                          style: GoogleFonts.inter(
                            fontSize: 10,
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
            // Product info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkWalnut,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 12,
                        color: product.isVerifiedStudent 
                            ? AppColors.success 
                            : AppColors.softOak,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.sellerName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.softOak,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Category Cards section
  Widget _buildCategoryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkWalnut.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.category_outlined,
                  color: AppColors.darkWalnut,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Browse Categories',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepEspresso,
                ),
              ),
            ],
          ),
        ),
        // Category chips in horizontal scroll
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _appState.selectedCategory.toLowerCase() == 
                  category.name.toLowerCase();
              return CategoryChip(
                icon: category.icon,
                label: category.name,
                isSelected: isSelected,
                onTap: () => _onCategorySelected(category.name),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Non-scrollable items grid for use inside SingleChildScrollView
  Widget _buildItemsGridNonScrollable(List<Item> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.72;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.70;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.68;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ItemCard(
                item: item,
                isFavorite: _appState.isFavorite(item.id),
                onFavoriteToggle: () {
                  _appState.toggleFavorite(item.id);
                  setState(() {});
                },
                onTap: () {
                  Navigator.pushNamed(context, '/item-detail', arguments: item);
                },
              );
            },
          ),
        );
      },
    );
  }

  /// Non-scrollable products grid for use inside SingleChildScrollView
  Widget _buildProductsGridNonScrollable(List<Product> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 4;
          childAspectRatio = 0.72;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 4;
          childAspectRatio = 0.70;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
          childAspectRatio = 0.68;
        } else {
          crossAxisCount = 2;
          childAspectRatio = 0.68;
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                isFavorite: _appState.isFavorite(product.id),
                onFavoriteToggle: () {
                  _appState.toggleFavorite(product.id);
                  setState(() {});
                },
                onTap: () {
                  final item = Item(
                    id: product.id,
                    title: product.title,
                    price: product.price,
                    imageUrl: product.imagePath,
                    category: product.category,
                    sellerId: product.sellerId,
                    sellerName: product.sellerName,
                    sellerMajorYear: product.sellerMajorYear,
                    isVerifiedStudent: product.isVerifiedStudent,
                    description: product.description,
                  );
                  Navigator.pushNamed(context, '/item-detail', arguments: item);
                },
              );
            },
          ),
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
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }
}
