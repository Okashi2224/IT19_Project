/// Report model for reporting and dispute resolution system
/// Supports Business Model Canvas: Reporting and Dispute Resolution
enum ReportType {
  inappropriateContent,
  scam,
  harassment,
  fakeProduct,
  noShow,
  wrongItem,
  paymentIssue,
  safetyHazard,
  other,
}

enum ReportStatus {
  submitted,
  underReview,
  actionTaken,
  resolved,
  dismissed,
}

enum DisputeType {
  itemNotAsDescribed,
  paymentNotReceived,
  itemNotReceived,
  qualityIssue,
  meetupIssue,
  communicationIssue,
  other,
}

class Report {
  final String id;
  final String reporterId;
  final String reporterName;
  final String reportedId; // User, Product, or Skill ID
  final String reportedType; // 'user', 'product', 'skill'
  final ReportType type;
  final String description;
  final List<String>? evidenceUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final String? resolution;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.reportedId,
    required this.reportedType,
    required this.type,
    required this.description,
    this.evidenceUrls,
    this.status = ReportStatus.submitted,
    required this.createdAt,
    this.reviewedAt,
    this.adminNotes,
    this.resolution,
  });

  /// Get report type display name
  String get typeDisplay {
    switch (type) {
      case ReportType.inappropriateContent:
        return 'Inappropriate Content';
      case ReportType.scam:
        return 'Potential Scam';
      case ReportType.harassment:
        return 'Harassment';
      case ReportType.fakeProduct:
        return 'Fake/Counterfeit Product';
      case ReportType.noShow:
        return 'No Show at Meetup';
      case ReportType.wrongItem:
        return 'Wrong Item Received';
      case ReportType.paymentIssue:
        return 'Payment Issue';
      case ReportType.safetyHazard:
        return 'Safety Concern';
      case ReportType.other:
        return 'Other';
    }
  }

  /// Get status display
  String get statusDisplay {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.actionTaken:
        return 'Action Taken';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  Report copyWith({
    ReportStatus? status,
    DateTime? reviewedAt,
    String? adminNotes,
    String? resolution,
  }) {
    return Report(
      id: id,
      reporterId: reporterId,
      reporterName: reporterName,
      reportedId: reportedId,
      reportedType: reportedType,
      type: type,
      description: description,
      evidenceUrls: evidenceUrls,
      status: status ?? this.status,
      createdAt: createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      resolution: resolution ?? this.resolution,
    );
  }
}

class Dispute {
  final String id;
  final String transactionId;
  final String initiatorId;
  final String initiatorName;
  final String respondentId;
  final String respondentName;
  final DisputeType type;
  final String description;
  final double? amountInDispute;
  final List<String>? evidenceUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? resolution;
  final List<DisputeMessage> messages;

  const Dispute({
    required this.id,
    required this.transactionId,
    required this.initiatorId,
    required this.initiatorName,
    required this.respondentId,
    required this.respondentName,
    required this.type,
    required this.description,
    this.amountInDispute,
    this.evidenceUrls,
    this.status = ReportStatus.submitted,
    required this.createdAt,
    this.resolvedAt,
    this.resolution,
    this.messages = const [],
  });

  /// Get dispute type display name
  String get typeDisplay {
    switch (type) {
      case DisputeType.itemNotAsDescribed:
        return 'Item Not as Described';
      case DisputeType.paymentNotReceived:
        return 'Payment Not Received';
      case DisputeType.itemNotReceived:
        return 'Item Not Received';
      case DisputeType.qualityIssue:
        return 'Quality Issue';
      case DisputeType.meetupIssue:
        return 'Meetup Issue';
      case DisputeType.communicationIssue:
        return 'Communication Issue';
      case DisputeType.other:
        return 'Other';
    }
  }

  /// Format amount with Philippine Peso
  String get formattedAmount {
    if (amountInDispute == null) return 'N/A';
    return '₱${amountInDispute!.toStringAsFixed(0)}';
  }
}

class DisputeMessage {
  final String id;
  final String disputeId;
  final String senderId;
  final String senderName;
  final String content;
  final bool isAdmin;
  final DateTime sentAt;

  const DisputeMessage({
    required this.id,
    required this.disputeId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.isAdmin = false,
    required this.sentAt,
  });
}

/// Report reason options for UI
class ReportReasons {
  static const List<Map<String, dynamic>> productReasons = [
    {'type': ReportType.fakeProduct, 'label': 'Fake or counterfeit item'},
    {'type': ReportType.inappropriateContent, 'label': 'Inappropriate content'},
    {'type': ReportType.scam, 'label': 'Potential scam'},
    {'type': ReportType.safetyHazard, 'label': 'Safety concern'},
    {'type': ReportType.other, 'label': 'Other reason'},
  ];

  static const List<Map<String, dynamic>> userReasons = [
    {'type': ReportType.harassment, 'label': 'Harassment or bullying'},
    {'type': ReportType.scam, 'label': 'Scam or fraud'},
    {'type': ReportType.noShow, 'label': 'Didn\'t show up to meetup'},
    {'type': ReportType.inappropriateContent, 'label': 'Inappropriate behavior'},
    {'type': ReportType.other, 'label': 'Other reason'},
  ];

  static const List<Map<String, dynamic>> transactionReasons = [
    {'type': DisputeType.itemNotAsDescribed, 'label': 'Item not as described'},
    {'type': DisputeType.itemNotReceived, 'label': 'Did not receive item'},
    {'type': DisputeType.paymentNotReceived, 'label': 'Did not receive payment'},
    {'type': DisputeType.qualityIssue, 'label': 'Quality issue'},
    {'type': DisputeType.meetupIssue, 'label': 'Problem with meetup'},
    {'type': DisputeType.other, 'label': 'Other issue'},
  ];
}
