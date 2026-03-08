/// Transaction Provider for CampusXchange
/// Manages transactions, fees, and premium subscriptions
/// Implements BMC: Revenue Stream
library;

import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = List.from(sampleTransactions);
  final Map<String, PremiumSubscription> _subscriptions = {};
  final List<CampusAd> _ads = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Singleton pattern
  static final TransactionProvider _instance = TransactionProvider._internal();
  factory TransactionProvider() => _instance;
  TransactionProvider._internal();

  /// Get transactions for user (as buyer or seller)
  List<Transaction> getTransactionsForUser(String userId) =>
      _transactions.where((t) => 
          t.buyerId == userId || t.sellerId == userId).toList();

  /// Get transactions by status
  List<Transaction> getTransactionsByStatus(TransactionStatus status) =>
      _transactions.where((t) => t.status == status).toList();

  /// Get pending transactions
  List<Transaction> get pendingTransactions =>
      _transactions.where((t) => t.status == TransactionStatus.pending).toList();

  /// Get total revenue for platform
  double get totalPlatformRevenue =>
      _transactions
          .where((t) => t.status == TransactionStatus.completed)
          .fold(0, (sum, t) => sum + t.platformFee);

  /// Get total sales amount
  double get totalSalesAmount =>
      _transactions
          .where((t) => t.status == TransactionStatus.completed && 
                       t.type == TransactionType.sale)
          .fold(0, (sum, t) => sum + t.amount);

  /// Create a new transaction
  Future<Transaction?> createTransaction({
    required TransactionType type,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    String? listingId,
    String? listingTitle,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Calculate fee based on transaction type
      final feeBreakdown = FeeCalculator.getFeeBreakdown(
        itemPrice: amount, 
        type: type,
      );

      final transaction = Transaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        buyerId: buyerId,
        buyerName: buyerName,
        sellerId: sellerId,
        sellerName: sellerName,
        listingId: listingId,
        listingTitle: listingTitle,
        amount: amount,
        platformFee: feeBreakdown['platformFee'] ?? 0,
        totalAmount: feeBreakdown['total'] ?? amount,
        paymentMethod: paymentMethod,
        status: TransactionStatus.pending,
        createdAt: DateTime.now(),
        notes: notes,
      );

      _transactions.add(transaction);
      _isLoading = false;
      notifyListeners();
      return transaction;
    } catch (e) {
      _error = 'Failed to create transaction: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update transaction status
  Future<bool> updateTransactionStatus(
    String transactionId, 
    TransactionStatus newStatus,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _transactions.indexWhere((t) => t.id == transactionId);
      
      if (index == -1) {
        _error = 'Transaction not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final old = _transactions[index];
      _transactions[index] = Transaction(
        id: old.id,
        type: old.type,
        buyerId: old.buyerId,
        buyerName: old.buyerName,
        sellerId: old.sellerId,
        sellerName: old.sellerName,
        listingId: old.listingId,
        listingTitle: old.listingTitle,
        amount: old.amount,
        platformFee: old.platformFee,
        totalAmount: old.totalAmount,
        paymentMethod: old.paymentMethod,
        status: newStatus,
        createdAt: old.createdAt,
        completedAt: newStatus == TransactionStatus.completed 
            ? DateTime.now() 
            : old.completedAt,
        notes: old.notes,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Process boost payment
  Future<Transaction?> processBoostPayment({
    required String userId,
    required String userName,
    required String listingId,
    required String listingTitle,
    required String boostTier,
    required PaymentMethod paymentMethod,
  }) async {
    final price = BoostPricing.getPrice(boostTier);
    
    return createTransaction(
      type: TransactionType.boost,
      buyerId: userId,
      buyerName: userName,
      sellerId: 'platform',
      sellerName: 'CampusXchange',
      listingId: listingId,
      listingTitle: '$listingTitle - ${boostTier.toUpperCase()} Boost',
      amount: price,
      paymentMethod: paymentMethod,
      notes: 'Boost duration: ${BoostPricing.getDuration(boostTier)} days',
    );
  }

  /// Purchase premium subscription
  Future<bool> purchasePremiumSubscription({
    required String userId,
    required String userName,
    required PremiumTier tier,
    required PaymentMethod paymentMethod,
    int months = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final monthlyPrice = PremiumPricing.getMonthlyPrice(tier);
      final totalPrice = monthlyPrice * months;

      // Create transaction for subscription
      final transaction = await createTransaction(
        type: TransactionType.premium,
        buyerId: userId,
        buyerName: userName,
        sellerId: 'platform',
        sellerName: 'CampusXchange',
        amount: totalPrice,
        paymentMethod: paymentMethod,
        notes: 'Premium ${tier.name} subscription - $months month(s)',
      );

      if (transaction == null) return false;

      // Create subscription
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: 30 * months));
      
      _subscriptions[userId] = PremiumSubscription(
        userId: userId,
        tier: tier,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to purchase subscription: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get user's subscription
  PremiumSubscription? getUserSubscription(String userId) =>
      _subscriptions[userId];

  /// Check if user has active premium
  bool hasActivePremium(String userId) {
    final subscription = _subscriptions[userId];
    return subscription?.isValid ?? false;
  }

  /// Get user's premium tier
  PremiumTier getUserPremiumTier(String userId) {
    final subscription = _subscriptions[userId];
    if (subscription?.isValid ?? false) {
      return subscription!.tier;
    }
    return PremiumTier.free;
  }

  /// Get listing limit for user based on premium tier
  int getListingLimit(String userId) {
    final tier = getUserPremiumTier(userId);
    switch (tier) {
      case PremiumTier.free:
        return 5;
      case PremiumTier.basic:
        return 20;
      case PremiumTier.pro:
        return 999; // Unlimited
    }
  }

  /// Get free boosts remaining for user
  int getFreeBoostsRemaining(String userId) {
    final tier = getUserPremiumTier(userId);
    switch (tier) {
      case PremiumTier.free:
        return 0;
      case PremiumTier.basic:
        return 1; // 1 free boost per month
      case PremiumTier.pro:
        return 3; // 3 free boosts per month
    }
  }

  // ============ Advertisement Management ============

  /// Get active ads for placement
  List<CampusAd> getAdsForPlacement(AdPlacement placement) =>
      _ads.where((ad) => 
          ad.isRunning && ad.placements.contains(placement)).toList();

  /// Record ad impression
  void recordAdImpression(String adId) {
    final index = _ads.indexWhere((a) => a.id == adId);
    if (index != -1) {
      final ad = _ads[index];
      final cpm = AdPricing.getCPM(ad.type);
      final impressionCost = cpm / 1000;

      _ads[index] = CampusAd(
        id: ad.id,
        advertiserId: ad.advertiserId,
        advertiserName: ad.advertiserName,
        type: ad.type,
        placements: ad.placements,
        imageUrl: ad.imageUrl,
        title: ad.title,
        subtitle: ad.subtitle,
        actionUrl: ad.actionUrl,
        startDate: ad.startDate,
        endDate: ad.endDate,
        impressions: ad.impressions + 1,
        clicks: ad.clicks,
        budget: ad.budget,
        spent: ad.spent + impressionCost,
        isActive: ad.isActive,
      );
      notifyListeners();
    }
  }

  /// Record ad click
  void recordAdClick(String adId) {
    final index = _ads.indexWhere((a) => a.id == adId);
    if (index != -1) {
      final ad = _ads[index];
      _ads[index] = CampusAd(
        id: ad.id,
        advertiserId: ad.advertiserId,
        advertiserName: ad.advertiserName,
        type: ad.type,
        placements: ad.placements,
        imageUrl: ad.imageUrl,
        title: ad.title,
        subtitle: ad.subtitle,
        actionUrl: ad.actionUrl,
        startDate: ad.startDate,
        endDate: ad.endDate,
        impressions: ad.impressions,
        clicks: ad.clicks + 1,
        budget: ad.budget,
        spent: ad.spent,
        isActive: ad.isActive,
      );
      notifyListeners();
    }
  }

  // ============ Analytics ============

  /// Get transaction summary for user
  Map<String, dynamic> getTransactionSummary(String userId) {
    final userTransactions = getTransactionsForUser(userId);
    final completed = userTransactions.where(
      (t) => t.status == TransactionStatus.completed);
    
    double totalSpent = 0;
    double totalEarned = 0;
    double totalFeesPaid = 0;
    int salesCount = 0;
    int purchasesCount = 0;

    for (final t in completed) {
      if (t.buyerId == userId) {
        totalSpent += t.totalAmount;
        purchasesCount++;
      }
      if (t.sellerId == userId && t.sellerId != 'platform') {
        totalEarned += t.amount - t.platformFee;
        totalFeesPaid += t.platformFee;
        salesCount++;
      }
    }

    return {
      'totalSpent': totalSpent,
      'totalEarned': totalEarned,
      'totalFeesPaid': totalFeesPaid,
      'salesCount': salesCount,
      'purchasesCount': purchasesCount,
      'transactionCount': userTransactions.length,
    };
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
