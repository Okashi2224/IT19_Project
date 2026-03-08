import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/notification_service.dart';

/// ReviewProvider - State management for Ratings and Reviews
/// Handles product reviews, skill reviews, and user reviews
class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [];
  String? _currentUserId;
  
  ReviewProvider() {
    _reviews.addAll(sampleReviews);
  }
  
  // ============ GETTERS ============
  
  List<Review> get reviews => _reviews;
  
  /// Get reviews for a specific target (product, skill, or user)
  List<Review> getReviewsFor(String targetId) {
    return _reviews.where((r) => r.targetId == targetId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get reviews by current user
  List<Review> get myReviews {
    if (_currentUserId == null) return [];
    return _reviews.where((r) => r.reviewerId == _currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get reviews for current user
  List<Review> get reviewsAboutMe {
    if (_currentUserId == null) return [];
    return _reviews.where((r) => 
        r.targetId == _currentUserId && r.type == ReviewType.user
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get rating summary for a target
  RatingSummary getRatingSummary(String targetId) {
    final targetReviews = getReviewsFor(targetId);
    return RatingSummary.fromReviews(targetId, targetReviews);
  }
  
  /// Get average rating for a target
  double getAverageRating(String targetId) {
    final reviews = getReviewsFor(targetId);
    if (reviews.isEmpty) return 0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }
  
  /// Get review count for a target
  int getReviewCount(String targetId) {
    return getReviewsFor(targetId).length;
  }
  
  // ============ USER MANAGEMENT ============
  
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
  
  // ============ REVIEW ACTIONS ============
  
  /// Add a new review
  Future<Review> addReview({
    required String targetId,
    required ReviewType type,
    required double rating,
    String? comment,
    String? transactionId,
    List<String>? images,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final review = Review(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      reviewerId: _currentUserId ?? 'unknown',
      reviewerName: 'You',
      targetId: targetId,
      type: type,
      rating: rating,
      comment: comment,
      transactionId: transactionId,
      createdAt: DateTime.now(),
      isVerifiedPurchase: transactionId != null,
      images: images,
    );
    
    _reviews.insert(0, review);
    
    // Notify the target about the new review
    _notifyNewReview(targetId, rating);
    
    notifyListeners();
    return review;
  }
  
  /// Mark a review as helpful
  void markHelpful(String reviewId) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(
        helpfulCount: _reviews[index].helpfulCount + 1,
      );
      notifyListeners();
    }
  }
  
  /// Add seller response to a review
  Future<bool> addSellerResponse(String reviewId, String response) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _reviews[index] = _reviews[index].copyWith(
      sellerResponse: response,
      respondedAt: DateTime.now(),
    );
    
    notifyListeners();
    return true;
  }
  
  /// Delete a review (only own reviews)
  Future<bool> deleteReview(String reviewId) async {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index == -1) return false;
    
    final review = _reviews[index];
    if (review.reviewerId != _currentUserId) return false;
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    _reviews.removeAt(index);
    notifyListeners();
    return true;
  }
  
  /// Check if user can review target (no duplicate reviews)
  bool canReview(String targetId, {String? transactionId}) {
    return !_reviews.any((r) =>
        r.reviewerId == _currentUserId &&
        r.targetId == targetId &&
        (transactionId == null || r.transactionId == transactionId)
    );
  }
  
  void _notifyNewReview(String targetId, double rating) {
    notificationService.notifyNewReview(
      userId: targetId,
      reviewerName: 'A user',
      rating: rating,
    );
  }
  
  // ============ STATISTICS ============
  
  /// Get overall stats for a seller/tutor
  Map<String, dynamic> getSellerStats(String userId) {
    final userReviews = _reviews.where((r) => r.targetId == userId).toList();
    
    if (userReviews.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'positivePercent': 0,
        'responseRate': 0,
      };
    }
    
    final total = userReviews.length;
    final avgRating = userReviews.map((r) => r.rating).reduce((a, b) => a + b) / total;
    final positive = userReviews.where((r) => r.rating >= 4).length;
    final responses = userReviews.where((r) => r.sellerResponse != null).length;
    
    return {
      'averageRating': avgRating,
      'totalReviews': total,
      'positivePercent': (positive / total * 100).round(),
      'responseRate': (responses / total * 100).round(),
    };
  }
}

/// Singleton instance
class ReviewContext {
  static final ReviewProvider _instance = ReviewProvider();
  static ReviewProvider get instance => _instance;
}
