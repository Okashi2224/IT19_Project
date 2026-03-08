/// Help Center Service for user guides and support
/// Supports Business Model Canvas: Help Center and User Guides
library;

class HelpCenterService {
  static final HelpCenterService _instance = HelpCenterService._internal();
  factory HelpCenterService() => _instance;
  HelpCenterService._internal();

  // ============================================================
  // FAQ CATEGORIES
  // ============================================================
  
  List<FAQCategory> get faqCategories => _faqCategories;

  static const List<FAQCategory> _faqCategories = [
    FAQCategory(
      id: 'getting-started',
      title: 'Getting Started',
      icon: '🚀',
      faqs: [
        FAQ(
          question: 'How do I create an account?',
          answer: 'To create an account, tap "Register" on the login screen. You\'ll need to use your .edu email address to verify you\'re a student. Follow the prompts to complete your profile setup.',
        ),
        FAQ(
          question: 'Why do I need a .edu email?',
          answer: 'CampusXchange is a student-only marketplace. Requiring a .edu email ensures that all users are verified students, making the platform safer and more trustworthy for everyone.',
        ),
        FAQ(
          question: 'How do I verify my student status?',
          answer: 'After registering with your .edu email, you\'ll receive a verification email. Click the link to verify your account. Once verified, you\'ll see a blue checkmark on your profile.',
        ),
        FAQ(
          question: 'Can I use CampusXchange on multiple devices?',
          answer: 'Yes! Simply log in with your account credentials on any device. Your listings, messages, and preferences will sync automatically.',
        ),
      ],
    ),
    FAQCategory(
      id: 'buying',
      title: 'Buying Items',
      icon: '🛒',
      faqs: [
        FAQ(
          question: 'How do I make an offer on an item?',
          answer: 'Browse items on the Discovery Feed, tap on an item you\'re interested in, and tap "Make Offer." You can enter your offer amount and an optional message to the seller. Once submitted, the seller will be notified.',
        ),
        FAQ(
          question: 'What happens after my offer is accepted?',
          answer: 'When a seller accepts your offer, you\'ll be notified and a chat will be unlocked. You can then message the seller directly to arrange a meetup time and location.',
        ),
        FAQ(
          question: 'Can I cancel an offer?',
          answer: 'Yes, you can cancel a pending offer before it\'s accepted. Go to your inbox, find the offer, and tap "Cancel." Once an offer is accepted, please communicate with the seller if you need to back out.',
        ),
        FAQ(
          question: 'How do I know if a seller is trustworthy?',
          answer: 'Check the seller\'s profile for their rating, number of reviews, and how long they\'ve been a member. Verified students have a blue checkmark. Read reviews from previous buyers for more insight.',
        ),
      ],
    ),
    FAQCategory(
      id: 'selling',
      title: 'Selling Items',
      icon: '💰',
      faqs: [
        FAQ(
          question: 'How do I post an item for sale?',
          answer: 'Tap the "Post Item" button on the main screen. Follow the 3-step wizard: 1) Add photos, 2) Enter details (title, price, description), and 3) Review and post. Our AI will suggest tags and pricing automatically!',
        ),
        FAQ(
          question: 'How does the AI Price Suggester work?',
          answer: 'Our AI analyzes your item\'s category, condition, and description to suggest a fair market price in Philippine Peso (₱). For books, it typically suggests ₱200-500. You can always adjust the price as you see fit.',
        ),
        FAQ(
          question: 'How do I accept or decline offers?',
          answer: 'Go to your Inbox and tap on the "Requests" tab. For each pending offer, you can tap "Accept" to unlock chat and proceed, or "Decline" to reject the offer.',
        ),
        FAQ(
          question: 'Can I edit my listing after posting?',
          answer: 'Yes! Go to your Profile, tap "My Listings," select the item, and tap "Edit." You can update photos, price, description, and other details.',
        ),
      ],
    ),
    FAQCategory(
      id: 'skills',
      title: 'Skill Exchange',
      icon: '📚',
      faqs: [
        FAQ(
          question: 'What is Skill Exchange?',
          answer: 'Skill Exchange is our peer-to-peer tutoring and teaching platform. Students can offer their skills (tutoring, design, programming, etc.) and book sessions with other students who need help.',
        ),
        FAQ(
          question: 'How do I offer my skills?',
          answer: 'Go to the Skills section and tap "Offer a Skill." Fill in your skill details, hourly rate (in ₱), availability, and preferred meeting location. Your listing will appear for other students to find.',
        ),
        FAQ(
          question: 'How do I book a session?',
          answer: 'Browse available skills, select one that interests you, and tap "Book Session." Choose a time slot that works for both of you, add any notes, and submit your booking request.',
        ),
        FAQ(
          question: 'How does payment work for skill sessions?',
          answer: 'Payment is handled directly between students, usually in cash during the session. Some tutors offer a free first session. Always agree on payment terms before the session.',
        ),
      ],
    ),
    FAQCategory(
      id: 'safety',
      title: 'Safety & Meetups',
      icon: '🛡️',
      faqs: [
        FAQ(
          question: 'Where should I meet for exchanges?',
          answer: 'Our app suggests safe campus meetup spots based on the time of day. Popular spots include the Student Union, Library entrance, Campus Center, and other well-lit public areas. Always meet in public!',
        ),
        FAQ(
          question: 'What safety precautions should I take?',
          answer: '1) Always meet in public places\\n2) Tell a friend where you\'re going\\n3) Meet during daylight when possible\\n4) Bring a friend for high-value items\\n5) Check the other person\'s reviews\\n6) Trust your instincts',
        ),
        FAQ(
          question: 'What if I feel unsafe during a meetup?',
          answer: 'Leave immediately if you feel unsafe. Contact campus security if needed. Report the user through the app by going to their profile and tapping the report button.',
        ),
        FAQ(
          question: 'How do I report a problem?',
          answer: 'You can report users, items, or transactions through the app. Tap the three-dot menu on any item or profile, select "Report," choose a reason, and provide details. Our team reviews all reports within 24 hours.',
        ),
      ],
    ),
    FAQCategory(
      id: 'account',
      title: 'Account & Settings',
      icon: '⚙️',
      faqs: [
        FAQ(
          question: 'How do I change my notification settings?',
          answer: 'Go to Profile > Settings > Notifications. You can customize which notifications you receive for offers, messages, reviews, and more.',
        ),
        FAQ(
          question: 'How do I update my profile?',
          answer: 'Go to your Profile and tap the edit icon. You can update your name, photo, bio, major, and listed skills.',
        ),
        FAQ(
          question: 'Can I delete my account?',
          answer: 'Yes. Go to Profile > Settings > Account > Delete Account. This action is permanent and will remove all your data, listings, and reviews.',
        ),
        FAQ(
          question: 'I forgot my password. What do I do?',
          answer: 'On the login screen, tap "Forgot Password." Enter your .edu email address and we\'ll send you a reset link.',
        ),
      ],
    ),
  ];

  // ============================================================
  // USER GUIDES
  // ============================================================
  
  List<UserGuide> get userGuides => _userGuides;

  static const List<UserGuide> _userGuides = [
    UserGuide(
      id: 'quick-start',
      title: 'Quick Start Guide',
      description: 'Get up and running in 5 minutes',
      icon: '⚡',
      steps: [
        GuideStep(
          title: 'Create Your Account',
          content: 'Sign up using your .edu email to verify you\'re a student. Complete your profile with a photo and bio to build trust.',
        ),
        GuideStep(
          title: 'Browse the Marketplace',
          content: 'Explore items on the Home tab for featured listings, or use Explore to filter by category. Tap any item to see details.',
        ),
        GuideStep(
          title: 'Make an Offer',
          content: 'Found something you want? Tap "Make Offer," enter your price, and add a friendly message. Wait for the seller to respond.',
        ),
        GuideStep(
          title: 'Chat & Meet Up',
          content: 'Once accepted, chat with the seller to arrange a meetup. Use our suggested safe campus locations.',
        ),
        GuideStep(
          title: 'Complete the Trade',
          content: 'Meet in person, inspect the item, exchange payment, and mark the trade complete. Leave a review!',
        ),
      ],
    ),
    UserGuide(
      id: 'selling-guide',
      title: 'How to Sell Successfully',
      description: 'Tips for creating great listings',
      icon: '💡',
      steps: [
        GuideStep(
          title: 'Take Great Photos',
          content: 'Use good lighting, show multiple angles, and photograph any defects. Items with clear photos sell 3x faster!',
        ),
        GuideStep(
          title: 'Write Honest Descriptions',
          content: 'Be specific about condition, dimensions, and any issues. Honesty builds trust and leads to better reviews.',
        ),
        GuideStep(
          title: 'Price Competitively',
          content: 'Use the AI Price Suggester for guidance. Check similar listings. Consider offering a small discount for quick sales.',
        ),
        GuideStep(
          title: 'Respond Quickly',
          content: 'Fast responses increase trust. Try to respond to offers within a few hours.',
        ),
        GuideStep(
          title: 'Be Flexible with Meetups',
          content: 'Offer multiple time options. Meet in convenient campus locations. Be punctual!',
        ),
      ],
    ),
    UserGuide(
      id: 'tutoring-guide',
      title: 'Becoming a Tutor',
      description: 'Share your skills and earn',
      icon: '👨‍🏫',
      steps: [
        GuideStep(
          title: 'Identify Your Skills',
          content: 'What subjects are you strong in? What can you teach others? Even basic skills can be valuable to fellow students.',
        ),
        GuideStep(
          title: 'Set Your Rate',
          content: 'Research typical tutoring rates on campus (usually ₱150-300/hr). Consider offering a free first session to build reviews.',
        ),
        GuideStep(
          title: 'Create Your Listing',
          content: 'Write a compelling description of what students will learn. Include your availability and preferred meetup spots.',
        ),
        GuideStep(
          title: 'Prepare for Sessions',
          content: 'Review material before sessions. Bring necessary supplies. Be patient and encouraging with students.',
        ),
        GuideStep(
          title: 'Build Your Reputation',
          content: 'Ask for reviews after successful sessions. Good reviews attract more students. Keep improving your teaching!',
        ),
      ],
    ),
    UserGuide(
      id: 'safety-guide',
      title: 'Safety Best Practices',
      description: 'Stay safe while trading',
      icon: '🔒',
      steps: [
        GuideStep(
          title: 'Verify Before Meeting',
          content: 'Check the other person\'s profile, reviews, and verification status. Watch for red flags like new accounts with no history.',
        ),
        GuideStep(
          title: 'Choose Safe Locations',
          content: 'Always meet in public, well-lit areas with people around. Use our AI-suggested meetup spots on campus.',
        ),
        GuideStep(
          title: 'Tell Someone',
          content: 'Let a friend know when and where you\'re meeting. Share your location if possible.',
        ),
        GuideStep(
          title: 'Inspect Before Paying',
          content: 'Always check the item thoroughly before exchanging money. Test electronics if possible.',
        ),
        GuideStep(
          title: 'Report Issues',
          content: 'If something goes wrong, report it immediately through the app. Our team is here to help resolve disputes.',
        ),
      ],
    ),
  ];

  // ============================================================
  // CONTACT SUPPORT
  // ============================================================
  
  ContactInfo get contactInfo => _contactInfo;

  static const ContactInfo _contactInfo = ContactInfo(
    email: 'support@campusxchange.ph',
    phone: '+63 2 8XXX XXXX',
    hours: 'Mon-Fri 8AM-6PM PHT',
    responseTime: 'Usually responds within 24 hours',
    socialMedia: {
      'Facebook': '@CampusXchangePH',
      'Twitter': '@CampusXchangePH',
      'Instagram': '@campusxchange.ph',
    },
  );

  // ============================================================
  // SEARCH
  // ============================================================
  
  /// Search FAQs and guides
  List<SearchResult> search(String query) {
    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();
    
    // Search FAQs
    for (final category in _faqCategories) {
      for (final faq in category.faqs) {
        if (faq.question.toLowerCase().contains(lowerQuery) ||
            faq.answer.toLowerCase().contains(lowerQuery)) {
          final previewLength = faq.answer.length > 100 ? 100 : faq.answer.length;
          results.add(SearchResult(
            type: 'FAQ',
            title: faq.question,
            preview: faq.answer.length > 100 
                ? '${faq.answer.substring(0, previewLength)}...' 
                : faq.answer,
            category: category.title,
          ));
        }
      }
    }
    
    // Search guides
    for (final guide in _userGuides) {
      if (guide.title.toLowerCase().contains(lowerQuery) ||
          guide.description.toLowerCase().contains(lowerQuery)) {
        results.add(SearchResult(
          type: 'Guide',
          title: guide.title,
          preview: guide.description,
          category: 'User Guides',
        ));
      }
    }
    
    return results;
  }
}

// ============================================================
// DATA CLASSES
// ============================================================

class FAQCategory {
  final String id;
  final String title;
  final String icon;
  final List<FAQ> faqs;

  const FAQCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  const FAQ({
    required this.question,
    required this.answer,
  });
}

class UserGuide {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<GuideStep> steps;

  const UserGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}

class GuideStep {
  final String title;
  final String content;

  const GuideStep({
    required this.title,
    required this.content,
  });
}

class ContactInfo {
  final String email;
  final String phone;
  final String hours;
  final String responseTime;
  final Map<String, String> socialMedia;

  const ContactInfo({
    required this.email,
    required this.phone,
    required this.hours,
    required this.responseTime,
    required this.socialMedia,
  });
}

class SearchResult {
  final String type;
  final String title;
  final String preview;
  final String category;

  const SearchResult({
    required this.type,
    required this.title,
    required this.preview,
    required this.category,
  });
}

/// Global help center service instance
final helpCenterService = HelpCenterService();
