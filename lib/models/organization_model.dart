/// Student Organization Model for CampusXchange
/// Implements Business Model Canvas: Key Partnership & Customer Segments
/// - University Offices
/// - Student Organizations
/// - Campus Community
library;

/// Organization type
enum OrganizationType {
  academic,         // Academic clubs, honor societies
  cultural,         // Cultural organizations
  sports,           // Sports clubs, intramurals
  religious,        // Religious organizations
  service,          // Community service groups
  professional,     // Professional/career organizations
  media,            // Publications, broadcasting
  governance,       // Student government
  other,
}

/// Organization verification status
enum OrgVerificationStatus {
  pending,
  verified,
  rejected,
  suspended,
}

/// Role within organization
enum OrgRole {
  president,
  vicePresident,
  secretary,
  treasurer,
  officer,
  member,
}

class StudentOrganization {
  final String id;
  final String name;
  final String abbreviation;       // e.g., "UPLB", "CSC"
  final String description;
  final OrganizationType type;
  final String logoUrl;
  final String? bannerUrl;
  final String universityId;
  final String universityName;
  final OrgVerificationStatus verificationStatus;
  final DateTime createdAt;
  final String? website;
  final String? email;
  final Map<String, String>? socialLinks;  // facebook, instagram, etc.
  final List<String> memberIds;
  final List<String> officerIds;
  final String advisorId;
  final String? advisorName;
  final bool isActive;

  const StudentOrganization({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.description,
    required this.type,
    required this.logoUrl,
    this.bannerUrl,
    required this.universityId,
    required this.universityName,
    this.verificationStatus = OrgVerificationStatus.pending,
    required this.createdAt,
    this.website,
    this.email,
    this.socialLinks,
    this.memberIds = const [],
    this.officerIds = const [],
    required this.advisorId,
    this.advisorName,
    this.isActive = true,
  });

  /// Get member count
  int get memberCount => memberIds.length;

  /// Check if verified
  bool get isVerified => verificationStatus == OrgVerificationStatus.verified;

  /// Get type display name
  String get typeDisplayName {
    switch (type) {
      case OrganizationType.academic:
        return 'Academic';
      case OrganizationType.cultural:
        return 'Cultural';
      case OrganizationType.sports:
        return 'Sports';
      case OrganizationType.religious:
        return 'Religious';
      case OrganizationType.service:
        return 'Community Service';
      case OrganizationType.professional:
        return 'Professional';
      case OrganizationType.media:
        return 'Media';
      case OrganizationType.governance:
        return 'Student Government';
      case OrganizationType.other:
        return 'Other';
    }
  }
}

/// Organization member
class OrgMember {
  final String id;
  final String orgId;
  final String userId;
  final String userName;
  final String userEmail;
  final OrgRole role;
  final DateTime joinedAt;
  final bool isActive;
  final String? position;   // Custom position title

  const OrgMember({
    required this.id,
    required this.orgId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.role,
    required this.joinedAt,
    this.isActive = true,
    this.position,
  });

  /// Get role display name
  String get roleDisplayName {
    if (position != null && position!.isNotEmpty) return position!;
    switch (role) {
      case OrgRole.president:
        return 'President';
      case OrgRole.vicePresident:
        return 'Vice President';
      case OrgRole.secretary:
        return 'Secretary';
      case OrgRole.treasurer:
        return 'Treasurer';
      case OrgRole.officer:
        return 'Officer';
      case OrgRole.member:
        return 'Member';
    }
  }
}

/// Organization listing (marketplace items listed by org)
class OrgListing {
  final String id;
  final String orgId;
  final String orgName;
  final String listingId;
  final String title;
  final String description;
  final double price;
  final bool isFundraiser;     // Is this a fundraiser?
  final double? fundraiserGoal;
  final double? fundraiserRaised;
  final DateTime createdAt;
  final bool isActive;

  const OrgListing({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.listingId,
    required this.title,
    required this.description,
    required this.price,
    this.isFundraiser = false,
    this.fundraiserGoal,
    this.fundraiserRaised,
    required this.createdAt,
    this.isActive = true,
  });

  /// Calculate fundraiser progress percentage
  double get fundraiserProgress {
    if (!isFundraiser || fundraiserGoal == null || fundraiserGoal == 0) return 0;
    return ((fundraiserRaised ?? 0) / fundraiserGoal!) * 100;
  }
}

/// Organization event for meetups
class OrgEvent {
  final String id;
  final String orgId;
  final String orgName;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String? locationDetails;
  final int? maxParticipants;
  final List<String> participantIds;
  final bool isMarketplaceRelated;   // Related to buying/selling
  final String? linkedListingId;
  final DateTime createdAt;
  final bool isActive;

  const OrgEvent({
    required this.id,
    required this.orgId,
    required this.orgName,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.locationDetails,
    this.maxParticipants,
    this.participantIds = const [],
    this.isMarketplaceRelated = false,
    this.linkedListingId,
    required this.createdAt,
    this.isActive = true,
  });

  /// Get participant count
  int get participantCount => participantIds.length;

  /// Check if event is full
  bool get isFull => maxParticipants != null && participantCount >= maxParticipants!;

  /// Check if event is upcoming
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing => 
      DateTime.now().isAfter(startTime) && 
      DateTime.now().isBefore(endTime);
}

/// University model (for organization verification)
class University {
  final String id;
  final String name;
  final String abbreviation;
  final String city;
  final String province;
  final String? logoUrl;
  final String domain;           // Email domain for verification
  final bool isPartner;          // Official partner university
  final bool allowsStudentOrgs;
  final int studentCount;

  const University({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.city,
    required this.province,
    this.logoUrl,
    required this.domain,
    this.isPartner = false,
    this.allowsStudentOrgs = true,
    this.studentCount = 0,
  });
}

/// Sample universities
final List<University> sampleUniversities = [
  const University(
    id: 'uni_1',
    name: 'University of the Philippines Los Baños',
    abbreviation: 'UPLB',
    city: 'Los Baños',
    province: 'Laguna',
    domain: 'up.edu.ph',
    isPartner: true,
    studentCount: 15000,
  ),
  const University(
    id: 'uni_2',
    name: 'De La Salle University',
    abbreviation: 'DLSU',
    city: 'Manila',
    province: 'Metro Manila',
    domain: 'dlsu.edu.ph',
    isPartner: true,
    studentCount: 18000,
  ),
  const University(
    id: 'uni_3',
    name: 'Ateneo de Manila University',
    abbreviation: 'ADMU',
    city: 'Quezon City',
    province: 'Metro Manila',
    domain: 'ateneo.edu',
    isPartner: true,
    studentCount: 16000,
  ),
  const University(
    id: 'uni_4',
    name: 'University of Santo Tomas',
    abbreviation: 'UST',
    city: 'Manila',
    province: 'Metro Manila',
    domain: 'ust.edu.ph',
    studentCount: 45000,
  ),
];

/// Sample organizations
final List<StudentOrganization> sampleOrganizations = [
  StudentOrganization(
    id: 'org_1',
    name: 'Computer Science Society',
    abbreviation: 'CSS',
    description: 'The official organization for Computer Science students. We host hackathons, tech talks, and career workshops.',
    type: OrganizationType.academic,
    logoUrl: 'assets/images/org_css.png',
    universityId: 'uni_1',
    universityName: 'UPLB',
    verificationStatus: OrgVerificationStatus.verified,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    email: 'css@up.edu.ph',
    socialLinks: {
      'facebook': 'https://facebook.com/CSSUPLB',
      'instagram': '@cssuplb',
    },
    memberIds: ['user_1', 'user_2', 'user_3', 'user_4', 'user_5'],
    officerIds: ['user_1', 'user_2'],
    advisorId: 'faculty_1',
    advisorName: 'Dr. Juan dela Cruz',
  ),
  StudentOrganization(
    id: 'org_2',
    name: 'Green Campus Initiative',
    abbreviation: 'GCI',
    description: 'Promoting sustainability and eco-friendly practices on campus through awareness campaigns and recycling drives.',
    type: OrganizationType.service,
    logoUrl: 'assets/images/org_gci.png',
    universityId: 'uni_1',
    universityName: 'UPLB',
    verificationStatus: OrgVerificationStatus.verified,
    createdAt: DateTime.now().subtract(const Duration(days: 200)),
    memberIds: ['user_6', 'user_7', 'user_8'],
    officerIds: ['user_6'],
    advisorId: 'faculty_2',
  ),
  StudentOrganization(
    id: 'org_3',
    name: 'Entrepreneur\'s Club',
    abbreviation: 'EC',
    description: 'Supporting student entrepreneurs with mentorship, networking events, and startup resources.',
    type: OrganizationType.professional,
    logoUrl: 'assets/images/org_ec.png',
    universityId: 'uni_2',
    universityName: 'DLSU',
    verificationStatus: OrgVerificationStatus.verified,
    createdAt: DateTime.now().subtract(const Duration(days: 400)),
    website: 'https://dlsu-ec.org',
    memberIds: ['user_9', 'user_10', 'user_11', 'user_12'],
    officerIds: ['user_9', 'user_10'],
    advisorId: 'faculty_3',
    advisorName: 'Prof. Maria Santos',
  ),
];

/// Sample org events
final List<OrgEvent> sampleOrgEvents = [
  OrgEvent(
    id: 'event_1',
    orgId: 'org_1',
    orgName: 'Computer Science Society',
    title: 'Tech Garage Sale',
    description: 'Buy and sell tech items, gadgets, and accessories. Great deals for students!',
    startTime: DateTime.now().add(const Duration(days: 7)),
    endTime: DateTime.now().add(const Duration(days: 7, hours: 4)),
    location: 'UPLB Student Union Building',
    locationDetails: 'Ground Floor, Main Hall',
    maxParticipants: 100,
    isMarketplaceRelated: true,
    createdAt: DateTime.now(),
  ),
  OrgEvent(
    id: 'event_2',
    orgId: 'org_2',
    orgName: 'Green Campus Initiative',
    title: 'Secondhand Bazaar for a Cause',
    description: 'Donate or sell your pre-loved items. Proceeds go to tree planting.',
    startTime: DateTime.now().add(const Duration(days: 14)),
    endTime: DateTime.now().add(const Duration(days: 14, hours: 6)),
    location: 'UPLB Freedom Park',
    maxParticipants: 50,
    isMarketplaceRelated: true,
    createdAt: DateTime.now(),
  ),
];
