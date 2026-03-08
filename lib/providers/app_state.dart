import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/product_model.dart';

/// AppState - Central state management using ChangeNotifier
/// Handles products, favorites, filtering, and search
class AppState extends ChangeNotifier {
  // Products state (new Product model)
  List<Product> _products = [];
  
  // Legacy items state for backward compatibility
  List<Item> _items = [];
  
  // Favorites state - stores product/item IDs
  final Set<String> _favoriteIds = {};
  
  // Search query for real-time filtering
  String _searchQuery = '';
  
  // Selected category for Explore tab filtering
  String _selectedCategory = 'All';
  
  AppState() {
    _products = List.from(sampleProducts);
    _items = List.from(initialItems);
  }
  
  // ============ GETTERS ============
  
  List<Product> get products => _products;
  List<Item> get items => _items;
  Set<String> get favoriteIds => _favoriteIds;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  
  /// Get filtered products based on search query and category
  /// Implements dynamic filtering for Explore tab
  List<Product> get filteredProducts {
    return _products.where((product) {
      // Search filter - matches title, category, or description
      final matchesSearch = _searchQuery.isEmpty ||
          product.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      // Category filter for Explore tab
      final matchesCategory = _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      
      return matchesSearch && matchesCategory;
    }).toList();
  }
  
  /// Get filtered items (legacy) based on search and category
  List<Item> get filteredItems {
    return _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' ||
          item.category.toLowerCase() == _selectedCategory.toLowerCase();
      
      return matchesSearch && matchesCategory;
    }).toList();
  }
  
  /// Get favorite products
  List<Product> get favoriteProducts {
    return _products.where((p) => _favoriteIds.contains(p.id)).toList();
  }
  
  /// Get favorite items (legacy)
  List<Item> get favoriteItems {
    return _items.where((item) => _favoriteIds.contains(item.id)).toList();
  }
  
  /// Get available products only
  List<Product> get availableProducts {
    return filteredProducts.where((p) => p.isAvailable).toList();
  }
  
  // ============ FAVORITE METHODS ============
  
  /// Check if product/item is favorite
  bool isFavorite(String id) => _favoriteIds.contains(id);
  
  /// Toggle favorite status - updates heart icon across app
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
  
  // ============ SEARCH/FILTER METHODS ============
  
  /// Update search query - triggers real-time filtering
  /// Used by TextField controller for live search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  /// Update selected category - filters Explore tab dynamically
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }
  
  // ============ PRODUCT MANAGEMENT ============
  
  /// Add new product to the list
  void addProduct(Product product) {
    _products.insert(0, product);
    notifyListeners();
  }
  
  /// Update product status (Available -> Pending -> Sold)
  void updateProductStatus(String productId, ProductStatus status) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index] = _products[index].copyWith(status: status);
      notifyListeners();
    }
  }
  
  /// Remove product
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _favoriteIds.remove(productId);
    notifyListeners();
  }
  
  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // ============ LEGACY ITEM METHODS ============
  
  /// Add new item (legacy)
  void addItem(Item item) {
    _items.insert(0, item);
    notifyListeners();
  }
  
  /// Remove item (legacy)
  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _favoriteIds.remove(itemId);
    notifyListeners();
  }
}

// Initial mock data with robust item array
final List<Item> initialItems = [
  Item(
    id: '1',
    title: 'Calculus Textbook 4th Edition',
    price: 45.00,
    imageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    category: 'Books',
    sellerId: 'seller1',
    sellerName: 'Sarah Miller',
    sellerMajorYear: 'Mathematics / Year 3',
    isVerifiedStudent: true,
    description: 'Excellent condition, minimal highlighting. Perfect for MATH 201.',
  ),
  Item(
    id: '2',
    title: 'MacBook Pro 2022 M2',
    price: 899.00,
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
    category: 'Tech',
    sellerId: 'seller2',
    sellerName: 'James Wilson',
    sellerMajorYear: 'Computer Science / Year 4',
    isVerifiedStudent: true,
    description: '256GB, Space Gray. Includes charger and case.',
  ),
  Item(
    id: '3',
    title: 'IKEA Study Desk',
    price: 75.00,
    imageUrl: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400',
    category: 'Furniture',
    sellerId: 'seller3',
    sellerName: 'Emily Chen',
    sellerMajorYear: 'Design / Year 2',
    isVerifiedStudent: true,
    description: 'White oak finish, 120x60cm. Minor scratches on surface.',
  ),
  Item(
    id: '4',
    title: 'Vintage Campus Bicycle',
    price: 120.00,
    imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400',
    category: 'Transport',
    sellerId: 'seller4',
    sellerName: 'Michael Brown',
    sellerMajorYear: 'Engineering / Year 3',
    isVerifiedStudent: true,
    description: 'Classic road bike, recently serviced. Great for campus commute.',
  ),
  Item(
    id: '5',
    title: 'Psychology 101 Bundle',
    price: 35.00,
    imageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    category: 'Books',
    sellerId: 'seller5',
    sellerName: 'Lisa Park',
    sellerMajorYear: 'Psychology / Year 2',
    isVerifiedStudent: true,
    description: '3 textbooks included. All in good condition.',
  ),
  Item(
    id: '6',
    title: 'iPad Air 5th Gen',
    price: 450.00,
    imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
    category: 'Tech',
    sellerId: 'seller6',
    sellerName: 'David Kim',
    sellerMajorYear: 'Business / Year 4',
    isVerifiedStudent: true,
    description: '64GB WiFi, Blue. Includes Apple Pencil 2nd gen.',
  ),
  Item(
    id: '7',
    title: 'Ergonomic Office Chair',
    price: 95.00,
    imageUrl: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400',
    category: 'Furniture',
    sellerId: 'seller7',
    sellerName: 'Anna Martinez',
    sellerMajorYear: 'Architecture / Year 3',
    isVerifiedStudent: true,
    description: 'Mesh back, adjustable height. Very comfortable for long study sessions.',
  ),
  Item(
    id: '8',
    title: 'Desk Lamp & Organizer Set',
    price: 0.00,
    imageUrl: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400',
    category: 'Free',
    sellerId: 'seller8',
    sellerName: 'Tom Anderson',
    sellerMajorYear: 'Liberal Arts / Year 4',
    isVerifiedStudent: true,
    description: 'Moving out! Free to good home. Pick up only.',
  ),
];

// Categories
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}

const List<CategoryItem> categories = [
  CategoryItem(id: 'all', name: 'All', icon: Icons.apps),
  CategoryItem(id: 'books', name: 'Books', icon: Icons.menu_book_outlined),
  CategoryItem(id: 'tech', name: 'Tech', icon: Icons.devices_outlined),
  CategoryItem(id: 'furniture', name: 'Furniture', icon: Icons.chair_outlined),
  CategoryItem(id: 'transport', name: 'Transport', icon: Icons.directions_bike_outlined),
  CategoryItem(id: 'free', name: 'Free', icon: Icons.card_giftcard_outlined),
];
