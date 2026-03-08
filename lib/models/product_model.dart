/// Product status enum for tracking item availability
enum ProductStatus {
  available,
  pending,
  sold,
}

/// Product model with comprehensive fields for campus marketplace
class Product {
  final String id;
  final String title;
  final double price;
  final String category;
  final String imagePath;
  final ProductStatus status;
  final String? description;
  final String? condition;
  final String sellerId;
  final String sellerName;
  final String? sellerMajorYear;
  final bool isVerifiedStudent;
  final DateTime createdAt;
  final List<String>? tags;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.imagePath,
    this.status = ProductStatus.available,
    this.description,
    this.condition,
    required this.sellerId,
    required this.sellerName,
    this.sellerMajorYear,
    this.isVerifiedStudent = true,
    DateTime? createdAt,
    this.tags,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  /// Copy with new values
  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? category,
    String? imagePath,
    ProductStatus? status,
    String? description,
    String? condition,
    String? sellerId,
    String? sellerName,
    String? sellerMajorYear,
    bool? isVerifiedStudent,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerMajorYear: sellerMajorYear ?? this.sellerMajorYear,
      isVerifiedStudent: isVerifiedStudent ?? this.isVerifiedStudent,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case ProductStatus.available:
        return 'Available';
      case ProductStatus.pending:
        return 'Pending';
      case ProductStatus.sold:
        return 'Sold';
    }
  }

  /// Check if product is still purchasable
  bool get isAvailable => status == ProductStatus.available;

  /// Format price with Philippine Peso symbol
  String get formattedPrice {
    if (price == 0) return 'Free';
    return '₱${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
  }
}

/// Helper class for default DateTime
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// Sample products for the marketplace
final List<Product> sampleProducts = [
  const Product(
    id: '1',
    title: 'Calculus Textbook 4th Edition',
    price: 450.00,
    imagePath: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400',
    category: 'Books',
    condition: 'Good',
    sellerId: 'seller1',
    sellerName: 'Sarah Miller',
    sellerMajorYear: 'Mathematics / Year 3',
    description: 'Excellent condition, minimal highlighting. Perfect for MATH 201.',
  ),
  const Product(
    id: '2',
    title: 'MacBook Pro 2022 M2',
    price: 45000.00,
    imagePath: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
    category: 'Tech',
    condition: 'Like New',
    sellerId: 'seller2',
    sellerName: 'James Wilson',
    sellerMajorYear: 'Computer Science / Year 4',
    description: '256GB, Space Gray. Includes charger and case.',
  ),
  const Product(
    id: '3',
    title: 'IKEA Study Desk',
    price: 3750.00,
    imagePath: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400',
    category: 'Furniture',
    condition: 'Good',
    sellerId: 'seller3',
    sellerName: 'Emily Chen',
    sellerMajorYear: 'Design / Year 2',
    description: 'White oak finish, 120x60cm. Minor scratches on surface.',
  ),
  const Product(
    id: '4',
    title: 'Vintage Campus Bicycle',
    price: 6000.00,
    imagePath: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400',
    category: 'Transport',
    condition: 'Fair',
    sellerId: 'seller4',
    sellerName: 'Michael Brown',
    sellerMajorYear: 'Engineering / Year 3',
    description: 'Classic road bike, recently serviced. Great for campus commute.',
  ),
  const Product(
    id: '5',
    title: 'Psychology 101 Bundle',
    price: 1750.00,
    imagePath: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
    category: 'Books',
    condition: 'Good',
    sellerId: 'seller5',
    sellerName: 'Lisa Park',
    sellerMajorYear: 'Psychology / Year 2',
    description: '3 textbooks included. All in good condition.',
  ),
  const Product(
    id: '6',
    title: 'iPad Air 5th Gen',
    price: 22500.00,
    imagePath: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
    category: 'Tech',
    condition: 'Like New',
    sellerId: 'seller6',
    sellerName: 'David Kim',
    sellerMajorYear: 'Business / Year 4',
    description: '64GB WiFi, Blue. Includes Apple Pencil 2nd gen.',
  ),
  const Product(
    id: '7',
    title: 'Ergonomic Office Chair',
    price: 4750.00,
    imagePath: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400',
    category: 'Furniture',
    condition: 'Good',
    sellerId: 'seller7',
    sellerName: 'Anna Martinez',
    sellerMajorYear: 'Architecture / Year 3',
    description: 'Mesh back, adjustable height. Very comfortable for long study sessions.',
  ),
  const Product(
    id: '8',
    title: 'Desk Lamp & Organizer Set',
    price: 0.00,
    imagePath: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400',
    category: 'Free',
    condition: 'Well Used',
    sellerId: 'seller8',
    sellerName: 'Tom Anderson',
    sellerMajorYear: 'Liberal Arts / Year 4',
    description: 'Moving out! Free to good home. Pick up only.',
  ),
];

/// Category model for filtering
class CategoryItem {
  final String id;
  final String name;
  final dynamic icon;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
  });
}
