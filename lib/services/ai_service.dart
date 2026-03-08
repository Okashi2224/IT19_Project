import 'dart:math';

/// AI Service for campus marketplace intelligence
/// Implements mock AI logic for price suggestions, tagging, and meetup recommendations

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final Random _random = Random();

  // ============================================================
  // AI PRICE SUGGESTER (₱ Philippine Peso)
  // ============================================================
  
  /// Price ranges by category in Philippine Peso
  static const Map<String, List<double>> _categoryPriceRanges = {
    'Books': [150, 2000],           // ₱150-2000 for textbooks
    'Electronics': [500, 50000],    // Wide range for tech
    'Furniture': [300, 15000],      // Dorm furniture
    'Clothing': [100, 3000],        // Student apparel
    'Sports': [200, 8000],          // Sports equipment
    'Kitchen': [150, 5000],         // Kitchen items
    'Decor': [100, 3000],           // Room decor
    'Transport': [500, 10000],      // Bikes, skateboards
    'Tech': [500, 50000],           // Alias for electronics
    'Free': [0, 0],                 // Giveaways
    'Other': [100, 5000],           // Misc items
  };

  /// Condition multipliers for pricing
  static const Map<String, double> _conditionMultipliers = {
    'Like New': 0.85,
    'Good': 0.65,
    'Fair': 0.45,
    'Well Used': 0.30,
  };

  /// Premium keywords that increase price
  static const List<String> _premiumKeywords = [
    'textbook', 'calculator', 'graphing', 'macbook', 'ipad', 'airpods',
    'desk', 'chair', 'monitor', 'keyboard', 'headphones', 'laptop',
    'north face', 'lululemon', 'patagonia', 'nike', 'adidas', 'apple',
    'samsung', 'sony', 'bose', 'kindle', 'iphone',
  ];

  /// Budget keywords that decrease price
  static const List<String> _budgetKeywords = [
    'old', 'used', 'worn', 'vintage', 'basic', 'simple',
    'hangers', 'storage', 'plastic', 'small', 'damaged',
  ];

  /// Get AI-suggested price for an item
  /// Returns price in Philippine Peso (₱)
  double suggestPrice({
    required String category,
    required String condition,
    String title = '',
    String? description,
  }) {
    final range = _categoryPriceRanges[category] ?? [100, 2500];
    final conditionMultiplier = _conditionMultipliers[condition] ?? 0.5;
    
    // Start with base price (middle of range adjusted by condition)
    double basePrice = (range[0] + range[1]) / 2 * conditionMultiplier;
    
    // Analyze title and description for keywords
    final lowerText = '${title.toLowerCase()} ${(description ?? '').toLowerCase()}';
    
    // Check for premium keywords
    for (final keyword in _premiumKeywords) {
      if (lowerText.contains(keyword)) {
        basePrice *= 1.3; // 30% boost
        break;
      }
    }
    
    // Check for budget keywords
    for (final keyword in _budgetKeywords) {
      if (lowerText.contains(keyword)) {
        basePrice *= 0.8; // 20% reduction
        break;
      }
    }
    
    // Category-specific adjustments
    if (category == 'Books') {
      if (lowerText.contains('textbook')) {
        basePrice = basePrice.clamp(250, 2000);
      }
      // Suggested price range: ₱200-500 for books as specified
      basePrice = basePrice.clamp(200, 500);
    }
    
    // Round to nearest ₱50 for cleaner prices
    return (basePrice / 50).round() * 50.0;
  }

  /// Get price range (low, suggested, high)
  Map<String, double> getSuggestedPriceRange({
    required String category,
    required String condition,
    String title = '',
  }) {
    final suggested = suggestPrice(
      category: category,
      condition: condition,
      title: title,
    );
    
    return {
      'low': (suggested * 0.8).roundToDouble(),
      'suggested': suggested,
      'high': (suggested * 1.2).roundToDouble(),
    };
  }

  // ============================================================
  // AI AUTO-TAGGING
  // ============================================================
  
  /// Category-based tags
  static const Map<String, List<String>> _categoryTags = {
    'Books': ['textbook', 'study', 'academic', 'course', 'reading', 'paperback'],
    'Electronics': ['tech', 'gadget', 'charger', 'wireless', 'portable'],
    'Furniture': ['dorm', 'apartment', 'storage', 'compact', 'minimalist'],
    'Clothing': ['casual', 'athletic', 'formal', 'winter', 'summer', 'vintage'],
    'Sports': ['fitness', 'outdoor', 'exercise', 'gear', 'equipment'],
    'Kitchen': ['cooking', 'meal-prep', 'appliance', 'dorm-friendly'],
    'Decor': ['aesthetic', 'cozy', 'wall-art', 'lighting', 'minimalist'],
    'Transport': ['bike', 'commute', 'eco-friendly', 'campus'],
    'Tech': ['tech', 'gadget', 'smart', 'wireless', 'portable'],
    'Other': ['must-have', 'essential', 'useful', 'practical'],
  };

  /// Generate AI tags for an item
  List<String> generateTags({
    required String title,
    required String category,
    String? description,
  }) {
    final Set<String> tags = {};
    final lowerText = '${title.toLowerCase()} ${(description ?? '').toLowerCase()}';
    
    // Add category tags (pick 2-3)
    final categoryTagList = _categoryTags[category] ?? _categoryTags['Other']!;
    final shuffled = List<String>.from(categoryTagList)..shuffle(_random);
    tags.addAll(shuffled.take(3));
    
    // Add keyword-based tags
    if (lowerText.contains('new') || lowerText.contains('unused')) {
      tags.add('like-new');
    }
    if (lowerText.contains('brand new') || lowerText.contains('sealed')) {
      tags.add('mint-condition');
    }
    if (lowerText.contains('moving') || lowerText.contains('graduating')) {
      tags.add('quick-sale');
    }
    if (lowerText.contains('negotiable') || lowerText.contains('obo')) {
      tags.add('great-deal');
    }
    if (lowerText.contains('free')) {
      tags.add('giveaway');
    }
    
    return tags.take(6).toList();
  }

  // ============================================================
  // AI MEETUP SPOT SUGGESTIONS
  // ============================================================
  
  /// Get campus meetup spot based on current time
  /// Returns recommended safe, public locations on campus
  MeetupSpot getCampusMeetupSpot() {
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday >= 6;
    
    if (isWeekend) {
      return _weekendLocations[_random.nextInt(_weekendLocations.length)];
    } else if (hour >= 7 && hour < 12) {
      return _morningLocations[_random.nextInt(_morningLocations.length)];
    } else if (hour >= 12 && hour < 18) {
      return _afternoonLocations[_random.nextInt(_afternoonLocations.length)];
    } else {
      return _eveningLocations[_random.nextInt(_eveningLocations.length)];
    }
  }

  /// Get multiple meetup suggestions
  List<MeetupSpot> getMeetupSuggestions({int count = 3}) {
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday >= 6;
    
    List<MeetupSpot> locations;
    if (isWeekend) {
      locations = List.from(_weekendLocations);
    } else if (hour >= 7 && hour < 12) {
      locations = List.from(_morningLocations);
    } else if (hour >= 12 && hour < 18) {
      locations = List.from(_afternoonLocations);
    } else {
      locations = List.from(_eveningLocations);
    }
    
    locations.shuffle(_random);
    return locations.take(count).toList();
  }

  /// Morning meetup locations (7 AM - 12 PM)
  static const List<MeetupSpot> _morningLocations = [
    MeetupSpot(
      name: 'Student Union Coffee Area',
      description: 'Busy with morning coffee crowd, well-lit',
      safetyRating: 4.8,
      bestTime: 'Morning',
    ),
    MeetupSpot(
      name: 'University Library Main Entrance',
      description: 'Opens at 7am, security nearby',
      safetyRating: 4.9,
      bestTime: 'Morning',
    ),
    MeetupSpot(
      name: 'Campus Center Lobby',
      description: 'Central location, lots of foot traffic',
      safetyRating: 4.7,
      bestTime: 'Morning',
    ),
    MeetupSpot(
      name: 'Dining Hall Entrance',
      description: 'Breakfast rush, very public area',
      safetyRating: 4.5,
      bestTime: 'Morning',
    ),
  ];

  /// Afternoon meetup locations (12 PM - 6 PM)
  static const List<MeetupSpot> _afternoonLocations = [
    MeetupSpot(
      name: 'Student Center Main Lobby',
      description: 'Peak activity hours, very safe',
      safetyRating: 4.9,
      bestTime: 'Afternoon',
    ),
    MeetupSpot(
      name: 'Campus Bookstore Entrance',
      description: 'High traffic, monitored area',
      safetyRating: 4.8,
      bestTime: 'Afternoon',
    ),
    MeetupSpot(
      name: 'University Quad / Main Green',
      description: 'Open space, lots of people around',
      safetyRating: 4.6,
      bestTime: 'Afternoon',
    ),
    MeetupSpot(
      name: 'Recreation Center Lobby',
      description: 'Busy with gym-goers',
      safetyRating: 4.5,
      bestTime: 'Afternoon',
    ),
    MeetupSpot(
      name: 'Academic Building Atrium',
      description: 'Between classes, many students',
      safetyRating: 4.4,
      bestTime: 'Afternoon',
    ),
  ];

  /// Evening meetup locations (6 PM onwards)
  static const List<MeetupSpot> _eveningLocations = [
    MeetupSpot(
      name: 'University Library Study Lounge',
      description: 'Open late, security desk nearby',
      safetyRating: 4.8,
      bestTime: 'Evening',
    ),
    MeetupSpot(
      name: 'Student Union Info Desk',
      description: 'Staffed until closing',
      safetyRating: 4.7,
      bestTime: 'Evening',
    ),
    MeetupSpot(
      name: 'Campus Security Station Area',
      description: 'Safest evening option',
      safetyRating: 5.0,
      bestTime: 'Evening',
    ),
    MeetupSpot(
      name: '24-Hour Study Room',
      description: 'Always occupied, well-lit',
      safetyRating: 4.6,
      bestTime: 'Evening',
    ),
  ];

  /// Weekend meetup locations
  static const List<MeetupSpot> _weekendLocations = [
    MeetupSpot(
      name: 'Campus Center Food Court',
      description: 'Open weekends, moderate traffic',
      safetyRating: 4.5,
      bestTime: 'Weekend',
    ),
    MeetupSpot(
      name: 'University Library (Weekend Hours)',
      description: 'Reduced hours but safe',
      safetyRating: 4.7,
      bestTime: 'Weekend',
    ),
    MeetupSpot(
      name: 'Athletic Facility Entrance',
      description: 'Game day crowds, busy',
      safetyRating: 4.4,
      bestTime: 'Weekend',
    ),
    MeetupSpot(
      name: 'Campus Coffee Shop',
      description: 'Popular weekend hangout',
      safetyRating: 4.8,
      bestTime: 'Weekend',
    ),
  ];

  // ============================================================
  // SAFETY TIPS
  // ============================================================
  
  /// Get safety tips for meetups
  List<String> getSafetyTips() {
    return const [
      'Always meet in a public place with other people around',
      'Tell a friend where you\'re meeting and when',
      'Meet during daylight hours when possible',
      'Bring a friend if meeting for high-value items',
      'Don\'t share your dorm room number until you trust the buyer/seller',
      'Check the other person\'s profile and rating before meeting',
      'Trust your instincts - if something feels off, reschedule',
      'Keep your phone charged and accessible',
      'Consider using campus security escort after dark',
    ];
  }
}

/// Meetup location data class
class MeetupSpot {
  final String name;
  final String description;
  final double safetyRating;
  final String bestTime;

  const MeetupSpot({
    required this.name,
    required this.description,
    required this.safetyRating,
    required this.bestTime,
  });

  /// Format safety rating as stars
  String get safetyDisplay => '${safetyRating.toStringAsFixed(1)} ★';
}

/// Global AI service instance
final aiService = AIService();
