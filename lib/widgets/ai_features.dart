import 'dart:math';

/// AI-powered price suggestion based on category, condition, and item type
/// Returns suggested price in Philippine Pesos (₱)
class AIPriceSuggester {
  // Base price ranges by category (min, max) in Philippine Pesos
  static final Map<String, List<double>> _categoryPriceRanges = {
    'Books': [150, 2000],
    'Electronics': [500, 50000],
    'Furniture': [300, 15000],
    'Clothing': [100, 3000],
    'Sports': [200, 8000],
    'Kitchen': [150, 5000],
    'Decor': [100, 3000],
    'Other': [100, 5000],
  };

  // Condition multipliers
  static final Map<String, double> _conditionMultipliers = {
    'Like New': 0.85,
    'Good': 0.65,
    'Fair': 0.45,
    'Well Used': 0.30,
  };

  // Keywords that suggest higher value
  static final List<String> _premiumKeywords = [
    'textbook', 'calculator', 'graphing', 'macbook', 'ipad', 'airpods',
    'desk', 'chair', 'monitor', 'keyboard', 'headphones', 'laptop',
    'north face', 'lululemon', 'patagonia', 'nike', 'adidas',
    'futon', 'mattress', 'lamp', 'organizer', 'apple', 'samsung',
  ];

  // Keywords that suggest lower value
  static final List<String> _budgetKeywords = [
    'old', 'used', 'worn', 'vintage', 'basic', 'simple',
    'hangers', 'storage', 'plastic', 'small',
  ];

  /// Get AI-suggested price based on campus marketplace rules
  /// Returns price in Philippine Pesos (₱)
  static double getAiPrice(String category, String condition, {String title = ''}) {
    return suggestPrice(category: category, condition: condition, title: title);
  }

  static double suggestPrice({
    required String category,
    required String condition,
    required String title,
  }) {
    final range = _categoryPriceRanges[category] ?? [100, 2500];
    final conditionMultiplier = _conditionMultipliers[condition] ?? 0.5;
    
    // Start with base price (middle of range adjusted by condition)
    double basePrice = (range[0] + range[1]) / 2 * conditionMultiplier;
    
    // Adjust based on keywords in title
    final lowerTitle = title.toLowerCase();
    
    // Check for premium keywords
    for (final keyword in _premiumKeywords) {
      if (lowerTitle.contains(keyword)) {
        basePrice *= 1.3; // 30% boost
        break;
      }
    }
    
    // Check for budget keywords
    for (final keyword in _budgetKeywords) {
      if (lowerTitle.contains(keyword)) {
        basePrice *= 0.8; // 20% reduction
        break;
      }
    }
    
    // Special category adjustments for Philippine campus
    if (category == 'Books' && lowerTitle.contains('textbook')) {
      basePrice = max(basePrice, 250); // Textbooks minimum ₱250
    }
    if (category == 'Electronics' && (lowerTitle.contains('apple') || lowerTitle.contains('mac'))) {
      basePrice *= 1.5;
    }
    
    // Round to nearest ₱50 for cleaner prices
    return (basePrice / 50).round() * 50.0;
  }

  /// Get price range suggestion (low, suggested, high)
  static Map<String, double> getSuggestedRange({
    required String category,
    required String condition,
    required String title,
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

  /// Format price with Philippine Peso symbol
  static String formatPrice(double price) {
    if (price == 0) return 'Free';
    if (price >= 1000) {
      return '₱${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return '₱${price.toStringAsFixed(0)}';
  }
}

/// AI-powered smart tagging for items
class SmartImageTagger {
  // Category-based tag suggestions
  static final Map<String, List<String>> _categoryTags = {
    'Books': ['textbook', 'study', 'academic', 'course', 'reading', 'paperback', 'hardcover'],
    'Electronics': ['tech', 'gadget', 'charger', 'cable', 'wireless', 'portable', 'smart'],
    'Furniture': ['dorm', 'apartment', 'storage', 'compact', 'minimalist', 'modern', 'space-saver'],
    'Clothing': ['casual', 'cozy', 'athletic', 'formal', 'winter', 'summer', 'vintage'],
    'Sports': ['fitness', 'outdoor', 'exercise', 'gear', 'equipment', 'active', 'workout'],
    'Kitchen': ['cooking', 'meal-prep', 'appliance', 'utensil', 'compact', 'dorm-friendly'],
    'Decor': ['aesthetic', 'cozy', 'wall-art', 'lighting', 'plants', 'minimalist', 'bohemian'],
    'Other': ['must-have', 'essential', 'useful', 'practical', 'deal'],
  };

  // Keyword-based tag mapping
  static final Map<String, List<String>> _keywordTags = {
    'textbook': ['study-essential', 'academic', 'course-material'],
    'calculator': ['math', 'engineering', 'stem'],
    'laptop': ['tech', 'study', 'portable'],
    'desk': ['study-space', 'workspace', 'home-office'],
    'chair': ['ergonomic', 'comfort', 'seating'],
    'lamp': ['lighting', 'study', 'ambient'],
    'bike': ['transport', 'exercise', 'eco-friendly'],
    'headphones': ['audio', 'study', 'music'],
    'jacket': ['outerwear', 'layering', 'weather'],
    'sneakers': ['footwear', 'comfortable', 'casual'],
  };

  static List<String> suggestTags({
    required String title,
    required String category,
    String? description,
  }) {
    final Set<String> tags = {};
    final lowerTitle = title.toLowerCase();
    final lowerDesc = description?.toLowerCase() ?? '';
    final combinedText = '$lowerTitle $lowerDesc';

    // Add category-based tags (pick 2-3)
    final categoryTagList = _categoryTags[category] ?? _categoryTags['Other']!;
    final random = Random();
    final shuffled = List<String>.from(categoryTagList)..shuffle(random);
    tags.addAll(shuffled.take(3));

    // Add keyword-based tags
    for (final entry in _keywordTags.entries) {
      if (combinedText.contains(entry.key)) {
        tags.addAll(entry.value.take(2));
      }
    }

    // Add condition-based tags
    if (combinedText.contains('new') || combinedText.contains('unused')) {
      tags.add('like-new');
    }
    if (combinedText.contains('brand new') || combinedText.contains('sealed')) {
      tags.add('mint-condition');
    }

    // Add urgency tags
    if (combinedText.contains('moving') || combinedText.contains('graduating')) {
      tags.add('quick-sale');
    }

    // Add deal-related tags
    if (combinedText.contains('discount') || combinedText.contains('cheap') || combinedText.contains('negotiable')) {
      tags.add('great-deal');
    }

    // Limit to 6 tags max
    return tags.take(6).toList();
  }
}

/// AI-powered meetup location suggestions based on time and context
class ChatMeetupAssistant {
  // Campus locations by time of day
  static final Map<String, List<MeetupLocation>> _locationsByTime = {
    'morning': [
      MeetupLocation('Student Union Coffee Area', 'Busy with morning coffee crowd, well-lit', 4.8),
      MeetupLocation('Library Main Entrance', 'Opens at 7am, security nearby', 4.7),
      MeetupLocation('Campus Center Lobby', 'Central location, lots of foot traffic', 4.5),
      MeetupLocation('Dining Hall Entrance', 'Breakfast rush, very public', 4.3),
    ],
    'afternoon': [
      MeetupLocation('Student Union Main Lobby', 'Peak activity hours, very safe', 4.9),
      MeetupLocation('Campus Bookstore Entrance', 'High traffic, well-monitored', 4.7),
      MeetupLocation('Quad/Main Green', 'Open space, lots of people around', 4.5),
      MeetupLocation('Recreation Center Lobby', 'Busy with gym-goers', 4.4),
      MeetupLocation('Academic Building Atrium', 'Between classes, many students', 4.3),
    ],
    'evening': [
      MeetupLocation('Library Study Lounge', 'Open late, security desk nearby', 4.8),
      MeetupLocation('Student Union Info Desk', 'Staffed until closing', 4.7),
      MeetupLocation('Campus Police Station Parking', 'Safest evening option', 4.9),
      MeetupLocation('24-Hour Study Room', 'Always occupied, well-lit', 4.6),
    ],
    'weekend': [
      MeetupLocation('Campus Center Food Court', 'Open weekends, moderate traffic', 4.5),
      MeetupLocation('Library Weekend Hours Area', 'Reduced hours but safe', 4.6),
      MeetupLocation('Athletic Facility Entrance', 'Game day crowds', 4.4),
      MeetupLocation('Campus Coffee Shop', 'Popular weekend hangout', 4.7),
    ],
  };

  // Safety tips by scenario
  static final List<String> _safetyTips = [
    'Always meet in a public place with other people around',
    'Tell a friend where you\'re meeting and when',
    'Meet during daylight hours when possible',
    'Bring a friend if meeting for high-value items',
    'Don\'t share your dorm room number until you trust the buyer/seller',
    'Check the other person\'s profile and rating before meeting',
    'Trust your instincts - if something feels off, reschedule',
  ];

  static List<MeetupLocation> suggestLocations() {
    final hour = DateTime.now().hour;
    final isWeekend = DateTime.now().weekday >= 6;
    
    String timeSlot;
    if (isWeekend) {
      timeSlot = 'weekend';
    } else if (hour < 12) {
      timeSlot = 'morning';
    } else if (hour < 18) {
      timeSlot = 'afternoon';
    } else {
      timeSlot = 'evening';
    }
    
    return _locationsByTime[timeSlot] ?? _locationsByTime['afternoon']!;
  }

  static List<MeetupLocation> getTopLocations({int count = 3}) {
    final locations = suggestLocations();
    // Sort by safety rating
    locations.sort((a, b) => b.safetyRating.compareTo(a.safetyRating));
    return locations.take(count).toList();
  }

  static String getRandomSafetyTip() {
    final random = Random();
    return _safetyTips[random.nextInt(_safetyTips.length)];
  }

  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  /// Generate a suggested meetup message
  static String generateMeetupMessage(MeetupLocation location) {
    final greetings = [
      'Hey! How about we meet at',
      'Would you be available to meet at',
      'I suggest we exchange at',
      'Can we meet at',
    ];
    final random = Random();
    final greeting = greetings[random.nextInt(greetings.length)];
    
    return '$greeting ${location.name}? It\'s a safe, public spot.';
  }
}

class MeetupLocation {
  final String name;
  final String description;
  final double safetyRating; // 1-5 scale

  MeetupLocation(this.name, this.description, this.safetyRating);
}

/// AI-powered item description generator
class DescriptionAssistant {
  static String generateDescription({
    required String title,
    required String category,
    required String condition,
  }) {
    final templates = _getTemplates(category);
    final conditionPhrase = _getConditionPhrase(condition);
    
    final random = Random();
    final template = templates[random.nextInt(templates.length)];
    
    return template
        .replaceAll('{title}', title)
        .replaceAll('{condition}', conditionPhrase)
        .replaceAll('{category}', category.toLowerCase());
  }

  static List<String> _getTemplates(String category) {
    switch (category) {
      case 'Books':
        return [
          'Selling my {title}. {condition} Perfect for students taking this course. No highlighting or writing inside.',
          '{title} in {condition}. Great resource for studying. Pick up on campus.',
          '{condition} {title}. Served me well through the semester, now it\'s your turn!',
        ];
      case 'Electronics':
        return [
          '{title} in {condition}. Works perfectly, all original accessories included.',
          'Selling {title}. {condition} Upgraded so I don\'t need this anymore.',
          '{condition} {title}. No scratches, fully functional. Perfect for students.',
        ];
      case 'Furniture':
        return [
          '{title} for sale. {condition} Great for dorm rooms or apartments.',
          'Selling my {title}. {condition} Moving out and need it gone!',
          '{condition} {title}. Compact and perfect for student living.',
        ];
      default:
        return [
          '{title} in {condition}. Message me with any questions!',
          'Selling {title}. {condition} Great deal for students.',
          '{condition} {title}. Must pick up on campus.',
        ];
    }
  }

  static String _getConditionPhrase(String condition) {
    switch (condition) {
      case 'Like New':
        return 'Barely used, like new condition!';
      case 'Good':
        return 'Good condition with minor wear.';
      case 'Fair':
        return 'Shows some use but works great.';
      case 'Well Used':
        return 'Well-loved but still functional.';
      default:
        return 'Good condition.';
    }
  }
}

/// AI-powered smart search suggestions
class SearchAssistant {
  static final List<String> _popularSearches = [
    'textbooks',
    'calculator',
    'desk lamp',
    'mini fridge',
    'bike',
    'futon',
    'winter jacket',
    'headphones',
    'monitor',
    'coffee maker',
  ];

  static final Map<String, List<String>> _relatedSearches = {
    'textbook': ['course materials', 'study guides', 'workbook'],
    'calculator': ['TI-84', 'graphing calculator', 'scientific calculator'],
    'furniture': ['desk', 'chair', 'bookshelf', 'storage'],
    'electronics': ['laptop', 'tablet', 'charger', 'cables'],
    'clothing': ['jacket', 'shoes', 'formal wear', 'athletic wear'],
  };

  static List<String> getSuggestions(String query) {
    if (query.isEmpty) {
      return _popularSearches.take(5).toList();
    }

    final results = <String>[];
    final lowerQuery = query.toLowerCase();

    // Check related searches
    for (final entry in _relatedSearches.entries) {
      if (lowerQuery.contains(entry.key)) {
        results.addAll(entry.value);
      }
    }

    // Add popular searches that match
    for (final search in _popularSearches) {
      if (search.contains(lowerQuery) && !results.contains(search)) {
        results.add(search);
      }
    }

    return results.take(5).toList();
  }
}
