import 'package:flutter/material.dart';
import '../models/skill_model.dart';
import '../services/notification_service.dart';

/// SkillProvider - State management for Study Partners & Study Groups
/// Non-transactional peer-to-peer learning community
class SkillProvider extends ChangeNotifier {
  List<Skill> _skills = [];
  List<StudyGroup> _studyGroups = [];
  String? _currentUserId;
  String _searchQuery = '';
  SkillCategory? _selectedCategory;

  SkillProvider() {
    _skills = List.from(sampleSkills);
    _studyGroups = List.from(sampleStudyGroups);
  }

  // ============ GETTERS ============

  List<Skill> get skills => _skills;
  List<StudyGroup> get studyGroups => _studyGroups;
  String get searchQuery => _searchQuery;
  SkillCategory? get selectedCategory => _selectedCategory;

  /// Get filtered skills based on search and category
  List<Skill> get filteredSkills {
    return _skills.where((skill) {
      final matchesSearch = _searchQuery.isEmpty ||
          skill.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          skill.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          skill.userName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || skill.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Get filtered study groups
  List<StudyGroup> get filteredStudyGroups {
    return _studyGroups.where((group) {
      final matchesSearch = _searchQuery.isEmpty ||
          group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          group.topic.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          group.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == null || group.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Get skills posted by current user
  List<Skill> get mySkills {
    if (_currentUserId == null) return [];
    return _skills.where((s) => s.userId == _currentUserId).toList();
  }

  /// Get study groups where current user is a member
  List<StudyGroup> get myGroups {
    if (_currentUserId == null) return [];
    return _studyGroups
        .where((g) => g.memberIds.contains(_currentUserId))
        .toList();
  }

  /// Get open study groups user can join
  List<StudyGroup> get availableGroups {
    return _studyGroups.where((g) => g.isOpen && !g.isFull).toList();
  }

  /// Get skills by category
  List<Skill> getSkillsByCategory(SkillCategory category) {
    return _skills.where((s) => s.category == category).toList();
  }

  /// Get partners who can teach (for learners to find)
  List<Skill> get teachingPartners {
    return _skills
        .where((s) =>
            s.intent == SkillIntent.canTeach || s.intent == SkillIntent.both)
        .toList();
  }

  /// Get partners who want to learn (for teachers to find)
  List<Skill> get learningPartners {
    return _skills
        .where((s) =>
            s.intent == SkillIntent.wantToLearn || s.intent == SkillIntent.both)
        .toList();
  }

  // ============ USER MANAGEMENT ============

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // ============ SEARCH/FILTER ============

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(SkillCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }

  // ============ SKILL MANAGEMENT ============

  /// Add a new skill listing (free)
  void addSkill(Skill skill) {
    _skills.insert(0, skill);
    notifyListeners();
  }

  /// Update a skill
  void updateSkill(String skillId, Skill updated) {
    final index = _skills.indexWhere((s) => s.id == skillId);
    if (index != -1) {
      _skills[index] = updated;
      notifyListeners();
    }
  }

  /// Remove a skill listing
  void removeSkill(String skillId) {
    _skills.removeWhere((s) => s.id == skillId);
    notifyListeners();
  }

  /// Get skill by ID
  Skill? getSkillById(String id) {
    try {
      return _skills.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ============ STUDY GROUP MANAGEMENT ============

  /// Create a new study group
  void createStudyGroup(StudyGroup group) {
    _studyGroups.insert(0, group);
    notifyListeners();
  }

  /// Join a study group
  bool joinStudyGroup(String groupId) {
    if (_currentUserId == null) return false;
    final index = _studyGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return false;

    final group = _studyGroups[index];
    if (group.isFull || group.memberIds.contains(_currentUserId)) return false;

    group.memberIds.add(_currentUserId!);

    // Notify group creator
    notificationService.notifyStudyGroupJoin(
      creatorId: group.creatorId,
      memberName: 'You',
      groupName: group.name,
    );

    notifyListeners();
    return true;
  }

  /// Leave a study group
  bool leaveStudyGroup(String groupId) {
    if (_currentUserId == null) return false;
    final index = _studyGroups.indexWhere((g) => g.id == groupId);
    if (index == -1) return false;

    _studyGroups[index].memberIds.remove(_currentUserId);
    notifyListeners();
    return true;
  }

  /// Get study group by ID
  StudyGroup? getStudyGroupById(String id) {
    try {
      return _studyGroups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Send a connect request to a study partner
  void connectWithPartner(Skill skill) {
    notificationService.notifyStudyPartnerRequest(
      partnerId: skill.userId,
      requesterName: 'You',
      skillTitle: skill.title,
    );
  }
}

/// Singleton instance
class SkillContext {
  static final SkillProvider _instance = SkillProvider();
  static SkillProvider get instance => _instance;
}
