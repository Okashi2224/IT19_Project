/// Listing Provider for CampusXchange
/// Manages listings state with borrowing/lending and boost features
/// Implements BMC: Key Activities - Borrowing Management
library;

import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';

class ListingProvider extends ChangeNotifier {
  final List<Listing> _listings = List.from(sampleListings);
  final List<RentalRequest> _rentalRequests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Listing> get listings => _listings;
  List<RentalRequest> get rentalRequests => _rentalRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Singleton pattern
  static final ListingProvider _instance = ListingProvider._internal();
  factory ListingProvider() => _instance;
  ListingProvider._internal();

  /// Get all active listings
  List<Listing> get activeListings => 
      _listings.where((l) => l.status == ListingStatus.active).toList();

  /// Get listings for sale
  List<Listing> get forSaleListings =>
      activeListings.where((l) => 
          l.listingType == ListingType.forSale || l.listingType == ListingType.both).toList();

  /// Get listings for rent
  List<Listing> get forRentListings =>
      activeListings.where((l) => 
          l.listingType == ListingType.forRent || l.listingType == ListingType.both).toList();

  /// Get boosted listings first, then by date
  List<Listing> get sortedListings {
    final sorted = List<Listing>.from(activeListings);
    sorted.sort((a, b) {
      // Boosted items first
      final aBoosted = a.isBoostActive || a.isFeatured;
      final bBoosted = b.isBoostActive || b.isFeatured;
      if (aBoosted && !bBoosted) return -1;
      if (!aBoosted && bBoosted) return 1;
      // Then by boost tier
      if (aBoosted && bBoosted) {
        return b.boostType.index.compareTo(a.boostType.index);
      }
      // Then by date
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  /// Get featured/boosted listings
  List<Listing> get featuredListings =>
      activeListings.where((l) => l.isBoostActive || l.isFeatured).toList();

  /// Get listings by seller
  List<Listing> getListingsBySeller(String ownerId) =>
      _listings.where((l) => l.ownerId == ownerId).toList();

  /// Get listings by organization
  List<Listing> getListingsByOrg(String orgId) =>
      activeListings.where((l) => l.organizationId == orgId).toList();

  /// Get listings by category
  List<Listing> getListingsByCategory(String category) =>
      activeListings.where((l) => 
          l.category.toLowerCase() == category.toLowerCase()).toList();

  /// Search listings
  List<Listing> searchListings(String query) {
    final lowercaseQuery = query.toLowerCase();
    return activeListings.where((l) =>
        l.title.toLowerCase().contains(lowercaseQuery) ||
        l.description.toLowerCase().contains(lowercaseQuery) ||
        l.category.toLowerCase().contains(lowercaseQuery) ||
        l.tags.any((t) => t.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  /// Get listing by ID
  Listing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Add new listing
  Future<bool> addListing(Listing listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _listings.add(listing);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update listing
  Future<bool> updateListing(Listing updatedListing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _listings.indexWhere((l) => l.id == updatedListing.id);
      if (index != -1) {
        _listings[index] = updatedListing;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = 'Listing not found';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete listing
  Future<bool> deleteListing(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _listings.removeWhere((l) => l.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Boost a listing
  Future<bool> boostListing({
    required String listingId,
    required BoostType boostType,
    required int durationDays,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _listings.indexWhere((l) => l.id == listingId);
      
      if (index == -1) {
        _error = 'Listing not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final listing = _listings[index];
      final boostedListing = Listing(
        id: listing.id,
        title: listing.title,
        description: listing.description,
        category: listing.category,
        condition: listing.condition,
        images: listing.images,
        listingType: listing.listingType,
        salePrice: listing.salePrice,
        rentalPrice: listing.rentalPrice,
        rentalDuration: listing.rentalDuration,
        securityDeposit: listing.securityDeposit,
        ownerId: listing.ownerId,
        ownerName: listing.ownerName,
        ownerMajorYear: listing.ownerMajorYear,
        isVerifiedStudent: listing.isVerifiedStudent,
        status: listing.status,
        boostType: boostType,
        boostExpiresAt: DateTime.now().add(Duration(days: durationDays)),
        isFeatured: listing.isFeatured,
        createdAt: listing.createdAt,
        viewCount: listing.viewCount,
        favoriteCount: listing.favoriteCount,
        meetupLocation: listing.meetupLocation,
        tags: listing.tags,
        organizationId: listing.organizationId,
      );

      _listings[index] = boostedListing;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to boost listing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create rental request (Borrowing Management)
  Future<bool> createRentalRequest({
    required String listingId,
    required String borrowerId,
    required String borrowerName,
    required DateTime startDate,
    required DateTime endDate,
    String? message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final listing = getListingById(listingId);
      
      if (listing == null) {
        _error = 'Listing not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (listing.listingType == ListingType.forSale) {
        _error = 'This item is not available for rent';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final days = endDate.difference(startDate).inDays + 1;
      final rentalPrice = (listing.rentalPrice ?? 0) * days;

      final request = RentalRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        listingId: listingId,
        listingTitle: listing.title,
        borrowerId: borrowerId,
        borrowerName: borrowerName,
        lenderId: listing.ownerId,
        lenderName: listing.ownerName,
        requestedAt: DateTime.now(),
        startDate: startDate,
        endDate: endDate,
        rentalPrice: rentalPrice,
        securityDeposit: listing.securityDeposit ?? 0,
        status: RentalRequestStatus.pending,
        message: message,
      );

      _rentalRequests.add(request);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create rental request: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get rental requests for lender
  List<RentalRequest> getRentalRequestsForLender(String lenderId) =>
      _rentalRequests.where((r) => r.lenderId == lenderId).toList();

  /// Get rental requests for borrower
  List<RentalRequest> getRentalRequestsForBorrower(String borrowerId) =>
      _rentalRequests.where((r) => r.borrowerId == borrowerId).toList();

  /// Approve rental request
  Future<bool> approveRentalRequest(String requestId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _rentalRequests.indexWhere((r) => r.id == requestId);
      
      if (index == -1) return false;

      final request = _rentalRequests[index];
      _rentalRequests[index] = RentalRequest(
        id: request.id,
        listingId: request.listingId,
        listingTitle: request.listingTitle,
        borrowerId: request.borrowerId,
        borrowerName: request.borrowerName,
        lenderId: request.lenderId,
        lenderName: request.lenderName,
        requestedAt: request.requestedAt,
        startDate: request.startDate,
        endDate: request.endDate,
        rentalPrice: request.rentalPrice,
        securityDeposit: request.securityDeposit,
        status: RentalRequestStatus.approved,
        message: request.message,
      );

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reject rental request
  Future<bool> rejectRentalRequest(String requestId, {String? reason}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _rentalRequests.indexWhere((r) => r.id == requestId);
      
      if (index == -1) return false;

      final request = _rentalRequests[index];
      _rentalRequests[index] = RentalRequest(
        id: request.id,
        listingId: request.listingId,
        listingTitle: request.listingTitle,
        borrowerId: request.borrowerId,
        borrowerName: request.borrowerName,
        lenderId: request.lenderId,
        lenderName: request.lenderName,
        requestedAt: request.requestedAt,
        startDate: request.startDate,
        endDate: request.endDate,
        rentalPrice: request.rentalPrice,
        securityDeposit: request.securityDeposit,
        status: RentalRequestStatus.rejected,
        message: reason,
      );

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark item as returned
  Future<bool> markItemReturned(String requestId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _rentalRequests.indexWhere((r) => r.id == requestId);
      
      if (index == -1) return false;

      final request = _rentalRequests[index];
      _rentalRequests[index] = RentalRequest(
        id: request.id,
        listingId: request.listingId,
        listingTitle: request.listingTitle,
        borrowerId: request.borrowerId,
        borrowerName: request.borrowerName,
        lenderId: request.lenderId,
        lenderName: request.lenderName,
        requestedAt: request.requestedAt,
        startDate: request.startDate,
        endDate: request.endDate,
        rentalPrice: request.rentalPrice,
        securityDeposit: request.securityDeposit,
        status: RentalRequestStatus.returned,
        message: request.message,
      );

      // Update listing status back to active
      final listingIndex = _listings.indexWhere((l) => l.id == request.listingId);
      if (listingIndex != -1) {
        final listing = _listings[listingIndex];
        _listings[listingIndex] = Listing(
          id: listing.id,
          title: listing.title,
          description: listing.description,
          category: listing.category,
          condition: listing.condition,
          images: listing.images,
          listingType: listing.listingType,
          salePrice: listing.salePrice,
          rentalPrice: listing.rentalPrice,
          rentalDuration: listing.rentalDuration,
          securityDeposit: listing.securityDeposit,
          ownerId: listing.ownerId,
          ownerName: listing.ownerName,
          ownerMajorYear: listing.ownerMajorYear,
          isVerifiedStudent: listing.isVerifiedStudent,
          status: ListingStatus.active,
          boostType: listing.boostType,
          boostExpiresAt: listing.boostExpiresAt,
          isFeatured: listing.isFeatured,
          createdAt: listing.createdAt,
          viewCount: listing.viewCount,
          favoriteCount: listing.favoriteCount,
          meetupLocation: listing.meetupLocation,
          tags: listing.tags,
          organizationId: listing.organizationId,
        );
      }

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Increment view count
  void incrementViews(String listingId) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final listing = _listings[index];
      _listings[index] = Listing(
        id: listing.id,
        title: listing.title,
        description: listing.description,
        category: listing.category,
        condition: listing.condition,
        images: listing.images,
        listingType: listing.listingType,
        salePrice: listing.salePrice,
        rentalPrice: listing.rentalPrice,
        rentalDuration: listing.rentalDuration,
        securityDeposit: listing.securityDeposit,
        ownerId: listing.ownerId,
        ownerName: listing.ownerName,
        ownerMajorYear: listing.ownerMajorYear,
        isVerifiedStudent: listing.isVerifiedStudent,
        status: listing.status,
        boostType: listing.boostType,
        boostExpiresAt: listing.boostExpiresAt,
        isFeatured: listing.isFeatured,
        createdAt: listing.createdAt,
        viewCount: listing.viewCount + 1,
        favoriteCount: listing.favoriteCount,
        meetupLocation: listing.meetupLocation,
        tags: listing.tags,
        organizationId: listing.organizationId,
      );
      notifyListeners();
    }
  }

  /// Increment favorite count
  void incrementFavorites(String listingId) {
    final index = _listings.indexWhere((l) => l.id == listingId);
    if (index != -1) {
      final listing = _listings[index];
      _listings[index] = Listing(
        id: listing.id,
        title: listing.title,
        description: listing.description,
        category: listing.category,
        condition: listing.condition,
        images: listing.images,
        listingType: listing.listingType,
        salePrice: listing.salePrice,
        rentalPrice: listing.rentalPrice,
        rentalDuration: listing.rentalDuration,
        securityDeposit: listing.securityDeposit,
        ownerId: listing.ownerId,
        ownerName: listing.ownerName,
        ownerMajorYear: listing.ownerMajorYear,
        isVerifiedStudent: listing.isVerifiedStudent,
        status: listing.status,
        boostType: listing.boostType,
        boostExpiresAt: listing.boostExpiresAt,
        isFeatured: listing.isFeatured,
        createdAt: listing.createdAt,
        viewCount: listing.viewCount,
        favoriteCount: listing.favoriteCount + 1,
        meetupLocation: listing.meetupLocation,
        tags: listing.tags,
        organizationId: listing.organizationId,
      );
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
