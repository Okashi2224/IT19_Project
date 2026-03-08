/// Comprehensive Listing Model for CampusXchange
/// Supports: Selling, Borrowing/Lending, Premium Features, Boosts
/// Implements Business Model Canvas: Item Listing and Borrowing Management
library;

/// Type of listing - supports both selling and lending
enum ListingType {
  forSale,      // Traditional sale
  forRent,      // Rental/Borrowing
  both,         // Available for both
}

/// Listing status
enum ListingStatus {
  active,
  pending,
  sold,
  rented,
  expired,
  suspended,
}

/// Boost/Promotion type for Featured Listing
enum BoostType {
  none,
  basic,        // 24 hours featured
  standard,     // 3 days featured + priority
  premium,      // 7 days featured + top placement + badge
}

/// Rental duration options
enum RentalDuration {
  hourly,
  daily,
  weekly,
  monthly,
  semester,
}

class Listing {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> images;
  final String condition;
  
  // Seller/Lender info
  final String ownerId;
  final String ownerName;
  final String? ownerMajorYear;
  final bool isVerifiedStudent;
  final String? organizationId; // For student org listings
  
  // Pricing - Sale
  final ListingType listingType;
  final double? salePrice;        // Price in ₱ for sale
  final bool isNegotiable;
  
  // Pricing - Rental/Borrowing
  final double? rentalPrice;      // Price in ₱ per rental period
  final RentalDuration? rentalDuration;
  final double? securityDeposit;  // Required deposit for rentals
  final int? maxRentalDays;       // Maximum rental period
  
  // Status and metadata
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final int favoriteCount;
  final int inquiryCount;
  
  // Boost/Promotion (Revenue Stream: Featured Listing Boosts)
  final BoostType boostType;
  final DateTime? boostExpiresAt;
  final bool isFeatured;
  
  // Tags and search
  final List<String> tags;
  final String? meetupLocation;   // Suggested campus meetup spot
  
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.images,
    required this.condition,
    required this.ownerId,
    required this.ownerName,
    this.ownerMajorYear,
    this.isVerifiedStudent = true,
    this.organizationId,
    required this.listingType,
    this.salePrice,
    this.isNegotiable = true,
    this.rentalPrice,
    this.rentalDuration,
    this.securityDeposit,
    this.maxRentalDays,
    this.status = ListingStatus.active,
    required this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.inquiryCount = 0,
    this.boostType = BoostType.none,
    this.boostExpiresAt,
    this.isFeatured = false,
    this.tags = const [],
    this.meetupLocation,
  });

  /// Check if listing can be purchased
  bool get canBuy => 
      (listingType == ListingType.forSale || listingType == ListingType.both) &&
      status == ListingStatus.active;

  /// Check if listing can be rented
  bool get canRent =>
      (listingType == ListingType.forRent || listingType == ListingType.both) &&
      status == ListingStatus.active;

  /// Check if boost is active
  bool get isBoostActive =>
      boostType != BoostType.none &&
      boostExpiresAt != null &&
      boostExpiresAt!.isAfter(DateTime.now());

  /// Get formatted sale price
  String get formattedSalePrice {
    if (salePrice == null) return 'N/A';
    if (salePrice == 0) return 'Free';
    return '₱${salePrice!.toStringAsFixed(salePrice!.truncateToDouble() == salePrice ? 0 : 2)}';
  }

  /// Get formatted rental price
  String get formattedRentalPrice {
    if (rentalPrice == null) return 'N/A';
    if (rentalPrice == 0) return 'Free';
    final period = rentalDuration?.name ?? 'day';
    return '₱${rentalPrice!.toStringAsFixed(0)}/$period';
  }

  /// Get formatted security deposit
  String get formattedDeposit {
    if (securityDeposit == null) return 'N/A';
    if (securityDeposit == 0) return 'Free';
    return '₱${securityDeposit!.toStringAsFixed(securityDeposit!.truncateToDouble() == securityDeposit ? 0 : 2)}';
  }

  /// Get listing type display text
  String get listingTypeText {
    switch (listingType) {
      case ListingType.forSale:
        return 'For Sale';
      case ListingType.forRent:
        return 'For Rent';
      case ListingType.both:
        return 'Sale or Rent';
    }
  }

  /// Get primary image
  String get primaryImage => images.isNotEmpty ? images.first : '';

  /// Copy with new values
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    List<String>? images,
    String? condition,
    String? ownerId,
    String? ownerName,
    String? ownerMajorYear,
    bool? isVerifiedStudent,
    String? organizationId,
    ListingType? listingType,
    double? salePrice,
    bool? isNegotiable,
    double? rentalPrice,
    RentalDuration? rentalDuration,
    double? securityDeposit,
    int? maxRentalDays,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? favoriteCount,
    int? inquiryCount,
    BoostType? boostType,
    DateTime? boostExpiresAt,
    bool? isFeatured,
    List<String>? tags,
    String? meetupLocation,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerMajorYear: ownerMajorYear ?? this.ownerMajorYear,
      isVerifiedStudent: isVerifiedStudent ?? this.isVerifiedStudent,
      organizationId: organizationId ?? this.organizationId,
      listingType: listingType ?? this.listingType,
      salePrice: salePrice ?? this.salePrice,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      rentalDuration: rentalDuration ?? this.rentalDuration,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      maxRentalDays: maxRentalDays ?? this.maxRentalDays,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      inquiryCount: inquiryCount ?? this.inquiryCount,
      boostType: boostType ?? this.boostType,
      boostExpiresAt: boostExpiresAt ?? this.boostExpiresAt,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      meetupLocation: meetupLocation ?? this.meetupLocation,
    );
  }
}

/// Rental/Borrowing request model
class RentalRequest {
  final String id;
  final String listingId;
  final String listingTitle;
  final String borrowerId;
  final String borrowerName;
  final String lenderId;
  final String lenderName;
  final DateTime requestedAt;
  final DateTime startDate;
  final DateTime endDate;
  final double rentalPrice;
  final double securityDeposit;
  final RentalRequestStatus status;
  final String? message;
  final String? meetupLocation;

  const RentalRequest({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.borrowerId,
    required this.borrowerName,
    required this.lenderId,
    required this.lenderName,
    required this.requestedAt,
    required this.startDate,
    required this.endDate,
    required this.rentalPrice,
    required this.securityDeposit,
    this.status = RentalRequestStatus.pending,
    this.message,
    this.meetupLocation,
  });

  /// Calculate total rental cost
  double get totalCost => rentalPrice + securityDeposit;

  /// Get rental duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Format rental period
  String get formattedPeriod {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[startDate.month - 1]} ${startDate.day} - ${months[endDate.month - 1]} ${endDate.day}';
  }
}

enum RentalRequestStatus {
  pending,
  approved,
  rejected,
  active,      // Currently rented
  returned,    // Item returned
  overdue,     // Past return date
  disputed,    // Issue with return
}

/// Sample listings with borrowing support
final List<Listing> sampleListings = [
  Listing(
    id: 'listing_1',
    title: 'Calculus Textbook (Rent or Buy)',
    description: 'Stewart Calculus 8th Edition. Perfect for MATH 201. Minor highlighting.',
    category: 'Books',
    images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400'],
    condition: 'Good',
    ownerId: 'user_1',
    ownerName: 'Sarah Miller',
    ownerMajorYear: 'Mathematics / Year 3',
    listingType: ListingType.both,
    salePrice: 450,
    rentalPrice: 50,
    rentalDuration: RentalDuration.weekly,
    securityDeposit: 200,
    maxRentalDays: 30,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    tags: ['textbook', 'math', 'calculus', 'stem'],
    meetupLocation: 'University Library',
  ),
  Listing(
    id: 'listing_2',
    title: 'MacBook Pro 2022 - For Rent',
    description: 'Need a laptop for a project? Rent my MacBook Pro M2. Includes charger.',
    category: 'Tech',
    images: ['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'],
    condition: 'Like New',
    ownerId: 'user_2',
    ownerName: 'James Wilson',
    ownerMajorYear: 'Computer Science / Year 4',
    listingType: ListingType.forRent,
    rentalPrice: 500,
    rentalDuration: RentalDuration.daily,
    securityDeposit: 5000,
    maxRentalDays: 14,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    boostType: BoostType.standard,
    boostExpiresAt: DateTime.now().add(const Duration(days: 2)),
    isFeatured: true,
    tags: ['laptop', 'macbook', 'tech', 'rental'],
  ),
  Listing(
    id: 'listing_3',
    title: 'DSLR Camera for Events',
    description: 'Canon EOS 90D with 18-135mm lens. Perfect for campus events!',
    category: 'Tech',
    images: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400'],
    condition: 'Good',
    ownerId: 'org_photo_club',
    ownerName: 'Campus Photo Club',
    organizationId: 'org_photo_club',
    listingType: ListingType.forRent,
    rentalPrice: 300,
    rentalDuration: RentalDuration.daily,
    securityDeposit: 2000,
    maxRentalDays: 7,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    tags: ['camera', 'photography', 'events', 'dslr'],
  ),
  Listing(
    id: 'listing_4',
    title: 'Study Desk - Moving Sale',
    description: 'IKEA MALM desk, white. Must sell before semester ends!',
    category: 'Furniture',
    images: ['https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400'],
    condition: 'Good',
    ownerId: 'user_3',
    ownerName: 'Emily Chen',
    ownerMajorYear: 'Design / Year 4',
    listingType: ListingType.forSale,
    salePrice: 1500,
    isNegotiable: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    tags: ['desk', 'furniture', 'ikea', 'study'],
  ),
];
