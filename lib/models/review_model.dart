/// Review model for ratings and review system
/// Supports Business Model Canvas: User Ratings and Reviews
enum ReviewType {
  product,
  skill,
  user,
}

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImageUrl;
  final String targetId; // Product, Skill, or User ID
  final ReviewType type;
  final double rating; // 1.0 to 5.0
  final String? comment;
  final String? transactionId; // Related trade/booking
  final DateTime createdAt;
  final bool isVerifiedPurchase;
  final List<String>? images;
  final int helpfulCount;
  final String? sellerResponse;
  final DateTime? respondedAt;

  const Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImageUrl,
    required this.targetId,
    required this.type,
    required this.rating,
    this.comment,
    this.transactionId,
    required this.createdAt,
    this.isVerifiedPurchase = true,
    this.images,
    this.helpfulCount = 0,
    this.sellerResponse,
    this.respondedAt,
  });

  /// Get rating as stars display
  String get starsDisplay {
    return '★' * rating.round() + '☆' * (5 - rating.round());
  }

  /// Get type display name
  String get typeDisplay {
    switch (type) {
      case ReviewType.product:
        return 'Product Review';
      case ReviewType.skill:
        return 'Study Partner Review';
      case ReviewType.user:
        return 'User Review';
    }
  }

  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365}y ago';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  Review copyWith({
    String? comment,
    double? rating,
    int? helpfulCount,
    String? sellerResponse,
    DateTime? respondedAt,
  }) {
    return Review(
      id: id,
      reviewerId: reviewerId,
      reviewerName: reviewerName,
      reviewerImageUrl: reviewerImageUrl,
      targetId: targetId,
      type: type,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      transactionId: transactionId,
      createdAt: createdAt,
      isVerifiedPurchase: isVerifiedPurchase,
      images: images,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      sellerResponse: sellerResponse ?? this.sellerResponse,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

/// Rating summary for products/users/skills
class RatingSummary {
  final String targetId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // 5 -> 20 means 20 five-star reviews

  const RatingSummary({
    required this.targetId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  /// Get percentage for a star rating
  double getPercentage(int stars) {
    if (totalReviews == 0) return 0;
    return (ratingDistribution[stars] ?? 0) / totalReviews * 100;
  }

  factory RatingSummary.empty(String targetId) => RatingSummary(
    targetId: targetId,
    averageRating: 0,
    totalReviews: 0,
    ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
  );

  factory RatingSummary.fromReviews(String targetId, List<Review> reviews) {
    if (reviews.isEmpty) return RatingSummary.empty(targetId);
    
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    double total = 0;
    
    for (final review in reviews) {
      final stars = review.rating.round().clamp(1, 5);
      distribution[stars] = (distribution[stars] ?? 0) + 1;
      total += review.rating;
    }
    
    return RatingSummary(
      targetId: targetId,
      averageRating: total / reviews.length,
      totalReviews: reviews.length,
      ratingDistribution: distribution,
    );
  }
}

/// Sample reviews
final List<Review> sampleReviews = [
  Review(
    id: 'review_1',
    reviewerId: 'user_2',
    reviewerName: 'James Wilson',
    targetId: '1',
    type: ReviewType.product,
    rating: 5.0,
    comment: 'Great textbook! Exactly as described, minimal highlighting. Fast meetup at the library. Highly recommend this seller!',
    transactionId: 'trade_1',
    createdAt: DateTime(2026, 2, 15),
    isVerifiedPurchase: true,
    helpfulCount: 3,
  ),
  Review(
    id: 'review_2',
    reviewerId: 'user_3',
    reviewerName: 'Emily Chen',
    targetId: 'skill_1',
    type: ReviewType.skill,
    rating: 4.8,
    comment: 'Sarah is an amazing study partner! She helped me understand calculus concepts I\'ve struggled with all semester. Very patient and explains things clearly.',
    createdAt: DateTime(2026, 2, 20),
    helpfulCount: 7,
  ),
  Review(
    id: 'review_3',
    reviewerId: 'user_4',
    reviewerName: 'Maria Santos',
    targetId: 'user_1',
    type: ReviewType.user,
    rating: 5.0,
    comment: 'Excellent seller! Items are always as described, responds quickly, and very friendly during meetups. Would definitely buy from again!',
    createdAt: DateTime(2026, 2, 22),
    helpfulCount: 5,
  ),
  Review(
    id: 'review_4',
    reviewerId: 'user_1',
    reviewerName: 'Sarah Miller',
    targetId: 'skill_2',
    type: ReviewType.skill,
    rating: 5.0,
    comment: 'James is a fantastic study partner! He helped me debug my project and taught me best practices. The session flew by. Highly recommend!',
    createdAt: DateTime(2026, 2, 25),
    helpfulCount: 4,
  ),
];
