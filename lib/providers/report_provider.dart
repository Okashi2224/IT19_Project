import 'package:flutter/material.dart';
import '../models/report_model.dart';

/// ReportProvider - State management for Reports and Disputes
/// Supports Business Model Canvas: Reporting and Dispute Resolution
class ReportProvider extends ChangeNotifier {
  final List<Report> _reports = [];
  final List<Dispute> _disputes = [];
  String? _currentUserId;
  
  // ============ GETTERS ============
  
  List<Report> get reports => _reports;
  List<Dispute> get disputes => _disputes;
  
  /// Get reports submitted by current user
  List<Report> get myReports {
    if (_currentUserId == null) return [];
    return _reports.where((r) => r.reporterId == _currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get disputes involving current user
  List<Dispute> get myDisputes {
    if (_currentUserId == null) return [];
    return _disputes.where((d) =>
        d.initiatorId == _currentUserId || d.respondentId == _currentUserId
    ).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Get active disputes (not resolved)
  List<Dispute> get activeDisputes {
    return myDisputes.where((d) =>
        d.status != ReportStatus.resolved && d.status != ReportStatus.dismissed
    ).toList();
  }
  
  // ============ USER MANAGEMENT ============
  
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
  
  // ============ REPORT ACTIONS ============
  
  /// Submit a new report
  Future<Report> submitReport({
    required String reportedId,
    required String reportedType,
    required ReportType type,
    required String description,
    List<String>? evidenceUrls,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final report = Report(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: _currentUserId ?? 'unknown',
      reporterName: 'You',
      reportedId: reportedId,
      reportedType: reportedType,
      type: type,
      description: description,
      evidenceUrls: evidenceUrls,
      status: ReportStatus.submitted,
      createdAt: DateTime.now(),
    );
    
    _reports.add(report);
    notifyListeners();
    return report;
  }
  
  /// Get report by ID
  Report? getReportById(String id) {
    try {
      return _reports.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // ============ DISPUTE ACTIONS ============
  
  /// Open a new dispute
  Future<Dispute> openDispute({
    required String transactionId,
    required String respondentId,
    required String respondentName,
    required DisputeType type,
    required String description,
    double? amountInDispute,
    List<String>? evidenceUrls,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final dispute = Dispute(
      id: 'dispute_${DateTime.now().millisecondsSinceEpoch}',
      transactionId: transactionId,
      initiatorId: _currentUserId ?? 'unknown',
      initiatorName: 'You',
      respondentId: respondentId,
      respondentName: respondentName,
      type: type,
      description: description,
      amountInDispute: amountInDispute,
      evidenceUrls: evidenceUrls,
      status: ReportStatus.submitted,
      createdAt: DateTime.now(),
    );
    
    _disputes.add(dispute);
    notifyListeners();
    return dispute;
  }
  
  /// Add a message to a dispute
  Future<bool> addDisputeMessage(String disputeId, String content) async {
    final index = _disputes.indexWhere((d) => d.id == disputeId);
    if (index == -1) return false;
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    final message = DisputeMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      disputeId: disputeId,
      senderId: _currentUserId ?? 'unknown',
      senderName: 'You',
      content: content,
      sentAt: DateTime.now(),
    );
    
    final dispute = _disputes[index];
    final updatedMessages = [...dispute.messages, message];
    
    _disputes[index] = Dispute(
      id: dispute.id,
      transactionId: dispute.transactionId,
      initiatorId: dispute.initiatorId,
      initiatorName: dispute.initiatorName,
      respondentId: dispute.respondentId,
      respondentName: dispute.respondentName,
      type: dispute.type,
      description: dispute.description,
      amountInDispute: dispute.amountInDispute,
      evidenceUrls: dispute.evidenceUrls,
      status: dispute.status,
      createdAt: dispute.createdAt,
      resolvedAt: dispute.resolvedAt,
      resolution: dispute.resolution,
      messages: updatedMessages,
    );
    
    notifyListeners();
    return true;
  }
  
  /// Get dispute by ID
  Dispute? getDisputeById(String id) {
    try {
      return _disputes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // ============ COUNTS ============
  
  int get pendingReportsCount {
    return _reports.where((r) =>
        r.status == ReportStatus.submitted || r.status == ReportStatus.underReview
    ).length;
  }
  
  int get activeDisputesCount {
    return activeDisputes.length;
  }
}

/// Singleton instance
class ReportContext {
  static final ReportProvider _instance = ReportProvider();
  static ReportProvider get instance => _instance;
}
