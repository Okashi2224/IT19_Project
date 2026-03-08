import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String university;
  final DateTime joinedAt;
  final int itemsSold;
  final int itemsBought;
  final double rating;
  final bool isVerified;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.university,
    required this.joinedAt,
    this.itemsSold = 0,
    this.itemsBought = 0,
    this.rating = 5.0,
    this.isVerified = false,
  });

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

  User copyWith({
    String? displayName,
    String? profileImageUrl,
    int? itemsSold,
    int? itemsBought,
    double? rating,
    bool? isVerified,
  }) {
    return User(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      university: university,
      joinedAt: joinedAt,
      itemsSold: itemsSold ?? this.itemsSold,
      itemsBought: itemsBought ?? this.itemsBought,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Valid .edu domains (mock list)
  static const List<String> validEduDomains = [
    'university.edu',
    'college.edu',
    'stanford.edu',
    'mit.edu',
    'harvard.edu',
    'berkeley.edu',
    'ucla.edu',
    'nyu.edu',
    'columbia.edu',
    'yale.edu',
    'princeton.edu',
    'uchicago.edu',
    'cornell.edu',
    'upenn.edu',
    'duke.edu',
  ];

  /// Validates if email is a .edu domain
  static ValidationResult validateEduEmail(String email) {
    email = email.trim().toLowerCase();
    
    if (email.isEmpty) {
      return ValidationResult(false, 'Email is required');
    }

    // Check email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult(false, 'Invalid email format');
    }

    // Check if ends with .edu or .edu.ph (Philippine universities)
    if (!email.endsWith('.edu') && !email.endsWith('.edu.ph')) {
      return ValidationResult(false, 'Please use your university .edu email');
    }

    return ValidationResult(true, null);
  }

  /// Validates password strength
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(false, 'Password is required');
    }
    if (password.length < 8) {
      return ValidationResult(false, 'Password must be at least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(false, 'Include at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(false, 'Include at least one number');
    }
    return ValidationResult(true, null);
  }

  /// Extract university name from email
  static String extractUniversity(String email) {
    final domain = email.split('@').last;
    final name = domain.split('.').first;
    // Capitalize each word
    return name
        .split(RegExp(r'[-_]'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + (word.length > 1 ? word.substring(1) : ''))
        .join(' ');
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final emailValidation = validateEduEmail(email);
    if (!emailValidation.isValid) {
      _error = emailValidation.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock successful login
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.toLowerCase(),
      displayName: _generateNameFromEmail(email),
      university: extractUniversity(email),
      joinedAt: DateTime.now().subtract(const Duration(days: 30)),
      itemsSold: 5,
      itemsBought: 3,
      rating: 4.8,
      isVerified: true,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Validate email
    final emailValidation = validateEduEmail(email);
    if (!emailValidation.isValid) {
      _error = emailValidation.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validate password
    final passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      _error = passwordValidation.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Validate display name
    if (displayName.trim().length < 2) {
      _error = 'Display name must be at least 2 characters';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mock successful registration
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email.toLowerCase(),
      displayName: displayName.trim(),
      university: extractUniversity(email),
      joinedAt: DateTime.now(),
      isVerified: false, // Needs email verification
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Logout current user
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final validation = validateEduEmail(email);
    if (!validation.isValid) {
      _error = validation.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = _currentUser!.copyWith(
      displayName: displayName,
      profileImageUrl: profileImageUrl,
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _generateNameFromEmail(String email) {
    final localPart = email.split('@').first;
    // Remove numbers and special chars, convert to title case
    final cleaned = localPart.replaceAll(RegExp(r'[0-9_\.\-]'), ' ').trim();
    return cleaned
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1).toLowerCase() : ''))
        .join(' ');
  }
}

class ValidationResult {
  final bool isValid;
  final String? message;

  ValidationResult(this.isValid, this.message);
}

// Singleton instance for global access
class AuthContext {
  static final AuthProvider _instance = AuthProvider();
  static AuthProvider get instance => _instance;
}
