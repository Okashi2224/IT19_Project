/// Transaction and Fee Model for CampusXchange
/// Implements Business Model Canvas: Revenue Stream
/// - Small Transaction Fee Per Sale
/// - Premium Seller Features
/// - Featured Listing Boosts
/// - Campus-Based Advertisements
library;

/// Transaction type
enum TransactionType {
  sale,
  rental,
  boost,
  premium,
  advertisement,
  deposit,
  refund,
}

/// Transaction status
enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  disputed,
}

/// Payment method
enum PaymentMethod {
  inApp,          // In-app wallet
  gcash,          // GCash
  maya,           // Maya/PayMaya
  bankTransfer,   // Bank transfer
  cash,           // Cash on meetup
}

class Transaction {
  final String id;
  final TransactionType type;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String? listingId;
  final String? listingTitle;
  final double amount;          // Item price
  final double platformFee;     // CampusXchange fee
  final double totalAmount;     // amount + platformFee
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  const Transaction({
    required this.id,
    required this.type,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    this.listingId,
    this.listingTitle,
    required this.amount,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
    this.status = TransactionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  /// Format amount with peso
  String get formattedAmount => '₱${amount.toStringAsFixed(2)}';
  String get formattedFee => '₱${platformFee.toStringAsFixed(2)}';
  String get formattedTotal => '₱${totalAmount.toStringAsFixed(2)}';

  /// Get transaction type display name
  String get typeDisplayName {
    switch (type) {
      case TransactionType.sale:
        return 'Item Sale';
      case TransactionType.rental:
        return 'Item Rental';
      case TransactionType.boost:
        return 'Listing Boost';
      case TransactionType.premium:
        return 'Premium Subscription';
      case TransactionType.advertisement:
        return 'Advertisement';
      case TransactionType.deposit:
        return 'Security Deposit';
      case TransactionType.refund:
        return 'Refund';
    }
  }
}

/// Fee Calculator Service
/// Implements BMC Revenue Stream: Small Transaction Fee Per Sale
class FeeCalculator {
  // Platform fee percentages (configurable)
  static const double saleFeePct = 0.05;        // 5% on sales
  static const double rentalFeePct = 0.08;      // 8% on rentals
  
  // Minimum fees in ₱
  static const double minSaleFee = 10.0;
  static const double minRentalFee = 15.0;
  
  // Maximum fee cap
  static const double maxFeeCap = 500.0;

  /// Calculate platform fee for a sale
  static double calculateSaleFee(double salePrice) {
    if (salePrice == 0) return 0;
    final fee = salePrice * saleFeePct;
    return fee.clamp(minSaleFee, maxFeeCap);
  }

  /// Calculate platform fee for a rental
  static double calculateRentalFee(double rentalPrice) {
    if (rentalPrice == 0) return 0;
    final fee = rentalPrice * rentalFeePct;
    return fee.clamp(minRentalFee, maxFeeCap);
  }

  /// Get fee breakdown for display
  static Map<String, double> getFeeBreakdown({
    required double itemPrice,
    required TransactionType type,
  }) {
    double fee;
    switch (type) {
      case TransactionType.sale:
        fee = calculateSaleFee(itemPrice);
        break;
      case TransactionType.rental:
        fee = calculateRentalFee(itemPrice);
        break;
      default:
        fee = 0;
    }

    return {
      'itemPrice': itemPrice,
      'platformFee': fee,
      'total': itemPrice + fee,
      'sellerReceives': itemPrice - fee, // Seller gets item price minus fee
    };
  }
}

/// Boost Pricing
/// Implements BMC Revenue Stream: Featured Listing Boosts
class BoostPricing {
  static const Map<String, double> prices = {
    'basic': 29.0,      // 24 hours - ₱29
    'standard': 79.0,   // 3 days - ₱79
    'premium': 149.0,   // 7 days - ₱149
  };

  static const Map<String, int> durations = {
    'basic': 1,         // 1 day
    'standard': 3,      // 3 days
    'premium': 7,       // 7 days
  };

  static const Map<String, String> benefits = {
    'basic': 'Featured for 24 hours',
    'standard': 'Featured 3 days + Priority in search',
    'premium': 'Featured 7 days + Top placement + Premium badge',
  };

  static double getPrice(String tier) => prices[tier] ?? 0;
  static int getDuration(String tier) => durations[tier] ?? 0;
  static String getBenefits(String tier) => benefits[tier] ?? '';
}

/// Premium Seller Subscription
/// Implements BMC Revenue Stream: Premium Seller Features
enum PremiumTier {
  free,
  basic,
  pro,
}

class PremiumSubscription {
  final String userId;
  final PremiumTier tier;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const PremiumSubscription({
    required this.userId,
    this.tier = PremiumTier.free,
    this.startDate,
    this.endDate,
    this.isActive = false,
  });

  /// Check if subscription is valid
  bool get isValid => 
      isActive && 
      endDate != null && 
      endDate!.isAfter(DateTime.now());
}

class PremiumPricing {
  // Monthly prices in ₱
  static const Map<PremiumTier, double> monthlyPrices = {
    PremiumTier.free: 0,
    PremiumTier.basic: 99.0,    // ₱99/month
    PremiumTier.pro: 199.0,     // ₱199/month
  };

  // Features per tier
  static const Map<PremiumTier, List<String>> features = {
    PremiumTier.free: [
      'Up to 5 active listings',
      'Basic messaging',
      'Standard support',
    ],
    PremiumTier.basic: [
      'Up to 20 active listings',
      'Priority messaging',
      'Seller analytics',
      'Verified seller badge',
      '1 free boost/month',
      'Priority support',
    ],
    PremiumTier.pro: [
      'Unlimited listings',
      'Priority messaging',
      'Advanced analytics',
      'Pro seller badge',
      '3 free boosts/month',
      'Featured seller profile',
      'Early access to features',
      'Premium support',
    ],
  };

  static double getMonthlyPrice(PremiumTier tier) => monthlyPrices[tier] ?? 0;
  static List<String> getFeatures(PremiumTier tier) => features[tier] ?? [];
}

/// Campus Advertisement Model
/// Implements BMC Revenue Stream: Campus-Based Advertisements
enum AdType {
  banner,         // Top/bottom banner
  sponsored,      // Sponsored listing
  popup,          // Popup ad (limited)
  carousel,       // Carousel in feed
}

enum AdPlacement {
  feedTop,
  feedBottom,
  searchResults,
  itemDetail,
  inbox,
}

class CampusAd {
  final String id;
  final String advertiserId;
  final String advertiserName;
  final AdType type;
  final List<AdPlacement> placements;
  final String imageUrl;
  final String title;
  final String? subtitle;
  final String? actionUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int impressions;
  final int clicks;
  final double budget;
  final double spent;
  final bool isActive;

  const CampusAd({
    required this.id,
    required this.advertiserId,
    required this.advertiserName,
    required this.type,
    required this.placements,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.actionUrl,
    required this.startDate,
    required this.endDate,
    this.impressions = 0,
    this.clicks = 0,
    required this.budget,
    this.spent = 0,
    this.isActive = true,
  });

  /// Check if ad is currently running
  bool get isRunning => 
      isActive &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate) &&
      spent < budget;

  /// Calculate click-through rate
  double get ctr => impressions > 0 ? (clicks / impressions) * 100 : 0;

  /// Get remaining budget
  double get remainingBudget => budget - spent;
}

class AdPricing {
  // Cost per 1000 impressions (CPM) in ₱
  static const Map<AdType, double> cpmRates = {
    AdType.banner: 50.0,       // ₱50 per 1000 views
    AdType.sponsored: 100.0,   // ₱100 per 1000 views
    AdType.popup: 200.0,       // ₱200 per 1000 views
    AdType.carousel: 75.0,     // ₱75 per 1000 views
  };

  // Minimum spend in ₱
  static const double minimumSpend = 500.0;

  // Maximum daily budget
  static const double maxDailyBudget = 10000.0;

  static double getCPM(AdType type) => cpmRates[type] ?? 50.0;
}

/// Sample transactions
final List<Transaction> sampleTransactions = [
  Transaction(
    id: 'txn_1',
    type: TransactionType.sale,
    buyerId: 'user_buyer_1',
    buyerName: 'Alex Kim',
    sellerId: 'user_seller_1',
    sellerName: 'Sarah Miller',
    listingId: 'listing_1',
    listingTitle: 'Calculus Textbook',
    amount: 450,
    platformFee: 22.50,
    totalAmount: 472.50,
    paymentMethod: PaymentMethod.gcash,
    status: TransactionStatus.completed,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    completedAt: DateTime.now().subtract(const Duration(hours: 20)),
  ),
  Transaction(
    id: 'txn_2',
    type: TransactionType.rental,
    buyerId: 'user_borrower_1',
    buyerName: 'Mike Torres',
    sellerId: 'user_lender_1',
    sellerName: 'James Wilson',
    listingId: 'listing_2',
    listingTitle: 'MacBook Pro 2022',
    amount: 1500,
    platformFee: 120,
    totalAmount: 1620,
    paymentMethod: PaymentMethod.maya,
    status: TransactionStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  Transaction(
    id: 'txn_3',
    type: TransactionType.boost,
    buyerId: 'user_seller_2',
    buyerName: 'Emily Chen',
    sellerId: 'platform',
    sellerName: 'CampusXchange',
    listingId: 'listing_4',
    listingTitle: 'Study Desk - Boost',
    amount: 79,
    platformFee: 0,
    totalAmount: 79,
    paymentMethod: PaymentMethod.gcash,
    status: TransactionStatus.completed,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    completedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];
