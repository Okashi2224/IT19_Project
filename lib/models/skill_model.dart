/// Skill model for peer-to-peer study partner matching
/// Supports the Business Model Canvas: Community Learning & Study Groups
/// Non-transactional - no fees, purely peer-to-peer knowledge sharing

enum SkillCategory {
  academic,
  technology,
  creative,
  language,
  music,
  sports,
  lifestyle,
  other,
}

/// What the user wants to do with this skill
enum SkillIntent {
  canTeach,    // I can help others learn this
  wantToLearn, // I'm looking for a study partner
  both,        // I can teach AND want to improve
}

/// Level of proficiency
enum SkillLevel {
  beginner,
  intermediate,
  advanced,
}

class Skill {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String title;
  final String description;
  final SkillCategory category;
  final SkillIntent intent;
  final SkillLevel level;
  final List<String> availableDays;
  final String? preferredLocation;
  final List<String> tags;
  final DateTime createdAt;

  const Skill({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.title,
    required this.description,
    required this.category,
    this.intent = SkillIntent.both,
    this.level = SkillLevel.intermediate,
    this.availableDays = const ['Mon', 'Wed', 'Fri'],
    this.preferredLocation,
    this.tags = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  /// Get category display name
  String get categoryName {
    switch (category) {
      case SkillCategory.academic:
        return 'Academic';
      case SkillCategory.technology:
        return 'Technology';
      case SkillCategory.creative:
        return 'Creative';
      case SkillCategory.language:
        return 'Language';
      case SkillCategory.music:
        return 'Music';
      case SkillCategory.sports:
        return 'Sports';
      case SkillCategory.lifestyle:
        return 'Lifestyle';
      case SkillCategory.other:
        return 'Other';
    }
  }

  /// Get intent display text
  String get intentLabel {
    switch (intent) {
      case SkillIntent.canTeach:
        return 'Can Help';
      case SkillIntent.wantToLearn:
        return 'Looking for Partner';
      case SkillIntent.both:
        return 'Teach & Learn';
    }
  }

  /// Get level display text
  String get levelLabel {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }

  Skill copyWith({
    String? title,
    String? description,
    SkillCategory? category,
    SkillIntent? intent,
    SkillLevel? level,
    List<String>? availableDays,
    String? preferredLocation,
    List<String>? tags,
  }) {
    return Skill(
      id: id,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      intent: intent ?? this.intent,
      level: level ?? this.level,
      availableDays: availableDays ?? this.availableDays,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      tags: tags ?? this.tags,
      createdAt: createdAt,
    );
  }
}

/// Study Group Model - Community Learning
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final SkillCategory category;
  final String topic;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final int maxMembers;
  final String? meetupLocation;
  final DateTime? nextMeetup;
  final bool isOpen;
  final DateTime createdAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.topic,
    required this.creatorId,
    required this.creatorName,
    required this.memberIds,
    this.maxMembers = 8,
    this.meetupLocation,
    this.nextMeetup,
    this.isOpen = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  bool get isFull => memberIds.length >= maxMembers;
  int get openSlots => maxMembers - memberIds.length;
  int get memberCount => memberIds.length;
}

/// Helper class for default DateTime
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();

  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// Sample skills for the study partner board
final List<Skill> sampleSkills = [
  const Skill(
    id: 'skill_1',
    userId: 'user_1',
    userName: 'Sarah Miller',
    title: 'Calculus Study Group',
    description:
        'Looking for study partners for Calculus I, II, or III. I am strong in derivatives and integrals - happy to help others while we review together!',
    category: SkillCategory.academic,
    intent: SkillIntent.canTeach,
    level: SkillLevel.advanced,
    availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
    preferredLocation: 'University Library',
    tags: ['math', 'calculus', 'stem', 'exam-prep'],
  ),
  const Skill(
    id: 'skill_2',
    userId: 'user_2',
    userName: 'James Wilson',
    title: 'Python Programming Partner',
    description:
        'Want to practice Python together! I know OOP and data structures - looking for someone to build projects with and prep for coding interviews.',
    category: SkillCategory.technology,
    intent: SkillIntent.both,
    level: SkillLevel.intermediate,
    availableDays: ['Tue', 'Thu', 'Sun'],
    preferredLocation: 'CS Building Lab',
    tags: ['programming', 'python', 'coding', 'cs'],
  ),
  const Skill(
    id: 'skill_3',
    userId: 'user_3',
    userName: 'Emily Chen',
    title: 'Learn Graphic Design Together',
    description:
        'Let us learn Photoshop, Illustrator, and Canva together! Perfect for making presentations and posters. I can share what I know.',
    category: SkillCategory.creative,
    intent: SkillIntent.both,
    level: SkillLevel.intermediate,
    availableDays: ['Mon', 'Wed', 'Sat'],
    preferredLocation: 'Design Studio',
    tags: ['design', 'photoshop', 'creative', 'canva'],
  ),
  const Skill(
    id: 'skill_4',
    userId: 'user_4',
    userName: 'Maria Santos',
    title: 'Filipino/Tagalog Conversation Partner',
    description:
        'Native speaker looking for language exchange partners! I will help you practice Tagalog, and you can help me with English or other languages.',
    category: SkillCategory.language,
    intent: SkillIntent.both,
    level: SkillLevel.advanced,
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    preferredLocation: 'Student Center',
    tags: ['language', 'filipino', 'tagalog', 'culture'],
  ),
  const Skill(
    id: 'skill_5',
    userId: 'user_5',
    userName: 'Alex Rivera',
    title: 'Guitar Jam Sessions',
    description:
        'Looking for fellow guitar players to jam with on weekends! Beginners welcome - let us learn chords, fingerpicking, and play songs together.',
    category: SkillCategory.music,
    intent: SkillIntent.canTeach,
    level: SkillLevel.intermediate,
    availableDays: ['Sat', 'Sun'],
    preferredLocation: 'Music Room',
    tags: ['music', 'guitar', 'acoustic', 'jam'],
  ),
];

/// Sample study groups
final List<StudyGroup> sampleStudyGroups = [
  StudyGroup(
    id: 'group_1',
    name: 'CS101 Study Squad',
    description:
        'Computer Science 101 - preparing for midterms together. We meet twice a week to review lectures and solve problem sets.',
    category: SkillCategory.technology,
    topic: 'Computer Science 101',
    creatorId: 'user_2',
    creatorName: 'James Wilson',
    memberIds: ['user_2', 'user_1', 'user_3', 'user_5'],
    maxMembers: 8,
    meetupLocation: 'Library Floor 2',
    nextMeetup: DateTime.now().add(const Duration(days: 2)),
    isOpen: true,
  ),
  StudyGroup(
    id: 'group_2',
    name: 'Calculus III Review',
    description:
        'Weekly group review for Calc III. We share notes, practice problems, and help each other before quizzes.',
    category: SkillCategory.academic,
    topic: 'Calculus III',
    creatorId: 'user_1',
    creatorName: 'Sarah Miller',
    memberIds: ['user_1', 'user_4'],
    maxMembers: 6,
    meetupLocation: 'Math Building Room 203',
    nextMeetup: DateTime.now().add(const Duration(days: 3)),
    isOpen: true,
  ),
  StudyGroup(
    id: 'group_3',
    name: 'Spanish Conversacion',
    description:
        'Practice conversational Spanish together. All levels welcome! We do casual meetups to practice speaking.',
    category: SkillCategory.language,
    topic: 'Spanish Language',
    creatorId: 'user_4',
    creatorName: 'Maria Santos',
    memberIds: ['user_4', 'user_3', 'user_5', 'user_1', 'user_2'],
    maxMembers: 6,
    meetupLocation: 'Student Center Lounge',
    nextMeetup: DateTime.now().add(const Duration(days: 1)),
    isOpen: true,
  ),
  StudyGroup(
    id: 'group_4',
    name: 'Design Portfolio Builders',
    description:
        'Let us build our design portfolios together! We share feedback, learn tools, and motivate each other.',
    category: SkillCategory.creative,
    topic: 'Graphic Design & Portfolio',
    creatorId: 'user_3',
    creatorName: 'Emily Chen',
    memberIds: ['user_3'],
    maxMembers: 5,
    meetupLocation: 'Design Studio',
    nextMeetup: DateTime.now().add(const Duration(days: 5)),
    isOpen: true,
  ),
];
