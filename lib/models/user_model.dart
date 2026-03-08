/// User model for student authentication and profiles
/// Supports .edu email verification for campus-only marketplace
enum VerificationStatus {
  unverified,
  pending,
  verified,
}

class StudentUser {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String university;
  final String? major;
  final String? yearLevel;
  final DateTime joinedAt;
  final int itemsSold;
  final int itemsBought;
  final int skillsSessions;
  final double rating;
  final int reviewCount;
  final VerificationStatus verificationStatus;
  final bool isStudent;
  final List<String>? skills;
  final String? bio;

  const StudentUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.university,
    this.major,
    this.yearLevel,
    required this.joinedAt,
    this.itemsSold = 0,
    this.itemsBought = 0,
    this.skillsSessions = 0,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.verificationStatus = VerificationStatus.unverified,
    this.isStudent = true,
    this.skills,
    this.bio,
  });

  /// Get user initials for avatar
  String get initials {
    if (displayName.isEmpty) return '?';
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.length >= 2 
        ? displayName.substring(0, 2).toUpperCase()
        : displayName[0].toUpperCase();
  }

  /// Check if email is verified .edu domain
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Format member since date
  String get memberSince {
    final months = DateTime.now().difference(joinedAt).inDays ~/ 30;
    if (months < 1) return 'New member';
    if (months == 1) return 'Member for 1 month';
    if (months < 12) return 'Member for $months months';
    final years = months ~/ 12;
    return years == 1 ? 'Member for 1 year' : 'Member for $years years';
  }

  /// Get rating display with stars
  String get ratingDisplay {
    return '${rating.toStringAsFixed(1)} ($reviewCount reviews)';
  }

  StudentUser copyWith({
    String? displayName,
    String? profileImageUrl,
    String? major,
    String? yearLevel,
    int? itemsSold,
    int? itemsBought,
    int? skillsSessions,
    double? rating,
    int? reviewCount,
    VerificationStatus? verificationStatus,
    List<String>? skills,
    String? bio,
  }) {
    return StudentUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      university: university,
      major: major ?? this.major,
      yearLevel: yearLevel ?? this.yearLevel,
      joinedAt: joinedAt,
      itemsSold: itemsSold ?? this.itemsSold,
      itemsBought: itemsBought ?? this.itemsBought,
      skillsSessions: skillsSessions ?? this.skillsSessions,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isStudent: isStudent,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'profileImageUrl': profileImageUrl,
    'university': university,
    'major': major,
    'yearLevel': yearLevel,
    'joinedAt': joinedAt.toIso8601String(),
    'itemsSold': itemsSold,
    'itemsBought': itemsBought,
    'skillsSessions': skillsSessions,
    'rating': rating,
    'reviewCount': reviewCount,
    'verificationStatus': verificationStatus.name,
    'isStudent': isStudent,
    'skills': skills,
    'bio': bio,
  };

  factory StudentUser.fromJson(Map<String, dynamic> json) => StudentUser(
    id: json['id'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    profileImageUrl: json['profileImageUrl'] as String?,
    university: json['university'] as String,
    major: json['major'] as String?,
    yearLevel: json['yearLevel'] as String?,
    joinedAt: DateTime.parse(json['joinedAt'] as String),
    itemsSold: json['itemsSold'] as int? ?? 0,
    itemsBought: json['itemsBought'] as int? ?? 0,
    skillsSessions: json['skillsSessions'] as int? ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    verificationStatus: VerificationStatus.values.firstWhere(
      (e) => e.name == json['verificationStatus'],
      orElse: () => VerificationStatus.unverified,
    ),
    isStudent: json['isStudent'] as bool? ?? true,
    skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
    bio: json['bio'] as String?,
  );
}

/// Sample users for the marketplace
final List<StudentUser> sampleUsers = [
  StudentUser(
    id: 'user_1',
    email: 'sarah.miller@university.edu.ph',
    displayName: 'Sarah Miller',
    university: 'University of the Philippines',
    major: 'Mathematics',
    yearLevel: 'Year 3',
    joinedAt: DateTime(2024, 3, 15),
    itemsSold: 12,
    rating: 4.8,
    reviewCount: 15,
    verificationStatus: VerificationStatus.verified,
    skills: ['Calculus Tutoring', 'Statistics Help'],
    bio: 'Math major passionate about helping others succeed!',
  ),
  StudentUser(
    id: 'user_2',
    email: 'james.wilson@ateneo.edu',
    displayName: 'James Wilson',
    university: 'Ateneo de Manila University',
    major: 'Computer Science',
    yearLevel: 'Year 4',
    joinedAt: DateTime(2023, 9, 1),
    itemsSold: 8,
    itemsBought: 5,
    skillsSessions: 20,
    rating: 4.9,
    reviewCount: 23,
    verificationStatus: VerificationStatus.verified,
    skills: ['Programming', 'Web Development', 'Data Structures'],
    bio: 'CS senior, happy to help with coding assignments!',
  ),
  StudentUser(
    id: 'user_3',
    email: 'emily.chen@dlsu.edu.ph',
    displayName: 'Emily Chen',
    university: 'De La Salle University',
    major: 'Design',
    yearLevel: 'Year 2',
    joinedAt: DateTime(2025, 1, 10),
    itemsSold: 3,
    rating: 5.0,
    reviewCount: 4,
    verificationStatus: VerificationStatus.verified,
    skills: ['Graphic Design', 'UI/UX'],
    bio: 'Design student selling dorm essentials!',
  ),
];
