import 'package:flutter/material.dart';

enum TradeStatus {
  pending,    // Offer sent, waiting for response
  accepted,   // Seller accepted, chat unlocked
  declined,   // Seller declined
  completed,  // Trade completed
  cancelled,  // Buyer cancelled
}

enum MessageType {
  text,
  offer,
  system,
  meetup,
}

class TradeOffer {
  final String id;
  final String itemId;
  final String itemTitle;
  final String itemImageUrl;
  final double itemPrice;
  final String buyerId;
  final String buyerName;
  final String buyerAvatar;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final double offerAmount;
  final String? message;
  final TradeStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ChatMessage> messages;
  final bool hasUnread;

  TradeOffer({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.itemImageUrl,
    required this.itemPrice,
    required this.buyerId,
    required this.buyerName,
    required this.buyerAvatar,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.offerAmount,
    this.message,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
    this.hasUnread = false,
  });

  bool get isChatUnlocked => status == TradeStatus.accepted;
  
  double get discountPercent => ((itemPrice - offerAmount) / itemPrice * 100);

  TradeOffer copyWith({
    TradeStatus? status,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
    bool? hasUnread,
  }) {
    return TradeOffer(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      itemImageUrl: itemImageUrl,
      itemPrice: itemPrice,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerAvatar: buyerAvatar,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: sellerAvatar,
      offerAmount: offerAmount,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }
}

class ChatMessage {
  final String id;
  final String tradeId;
  final String senderId;
  final String senderName;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final bool isRead;
  final MeetupSuggestion? meetupSuggestion;

  ChatMessage({
    required this.id,
    required this.tradeId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.sentAt,
    this.isRead = false,
    this.meetupSuggestion,
  });

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      tradeId: tradeId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      sentAt: sentAt,
      isRead: isRead ?? this.isRead,
      meetupSuggestion: meetupSuggestion,
    );
  }
}

class MeetupSuggestion {
  final String location;
  final DateTime dateTime;
  final String? notes;
  final bool isAccepted;

  MeetupSuggestion({
    required this.location,
    required this.dateTime,
    this.notes,
    this.isAccepted = false,
  });
}

class TradeProvider extends ChangeNotifier {
  final List<TradeOffer> _trades = [];
  String? _currentUserId;

  List<TradeOffer> get trades => List.unmodifiable(_trades);
  
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Get trades where user is the buyer (sent offers)
  List<TradeOffer> get sentOffers {
    if (_currentUserId == null) return [];
    return _trades.where((t) => t.buyerId == _currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get trades where user is the seller (received offers)
  List<TradeOffer> get receivedOffers {
    if (_currentUserId == null) return [];
    return _trades.where((t) => t.sellerId == _currentUserId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get all active chats (accepted trades)
  List<TradeOffer> get activeChats {
    if (_currentUserId == null) return [];
    return _trades
        .where((t) =>
            t.status == TradeStatus.accepted &&
            (t.buyerId == _currentUserId || t.sellerId == _currentUserId))
        .toList()
      ..sort((a, b) {
        final aLast = a.messages.isNotEmpty ? a.messages.last.sentAt : a.createdAt;
        final bLast = b.messages.isNotEmpty ? b.messages.last.sentAt : b.createdAt;
        return bLast.compareTo(aLast);
      });
  }

  // Get pending offers that need response
  List<TradeOffer> get pendingReceivedOffers {
    return receivedOffers.where((t) => t.status == TradeStatus.pending).toList();
  }

  int get unreadCount {
    return _trades.where((t) => t.hasUnread).length;
  }

  TradeOffer? getTradeById(String id) {
    try {
      return _trades.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Create a new trade offer
  Future<TradeOffer> createOffer({
    required String itemId,
    required String itemTitle,
    required String itemImageUrl,
    required double itemPrice,
    required String sellerId,
    required String sellerName,
    required double offerAmount,
    String? message,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final trade = TradeOffer(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      itemTitle: itemTitle,
      itemImageUrl: itemImageUrl,
      itemPrice: itemPrice,
      buyerId: _currentUserId ?? 'unknown',
      buyerName: 'You', // Would come from auth in real app
      buyerAvatar: '',
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatar: '',
      offerAmount: offerAmount,
      message: message,
      status: TradeStatus.pending,
      createdAt: DateTime.now(),
      messages: message != null
          ? [
              ChatMessage(
                id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
                tradeId: 'trade_${DateTime.now().millisecondsSinceEpoch}',
                senderId: _currentUserId ?? 'unknown',
                senderName: 'You',
                content: message,
                type: MessageType.text,
                sentAt: DateTime.now(),
              ),
            ]
          : [],
    );

    _trades.add(trade);
    notifyListeners();
    return trade;
  }

  /// Accept an offer (seller action)
  Future<bool> acceptOffer(String tradeId) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    final trade = _trades[index];
    final systemMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: 'system',
      senderName: 'System',
      content: '🎉 Offer accepted! You can now chat to arrange the exchange.',
      type: MessageType.system,
      sentAt: DateTime.now(),
    );

    _trades[index] = trade.copyWith(
      status: TradeStatus.accepted,
      updatedAt: DateTime.now(),
      messages: [...trade.messages, systemMessage],
      hasUnread: trade.buyerId == _currentUserId,
    );

    notifyListeners();
    return true;
  }

  /// Decline an offer (seller action)
  Future<bool> declineOffer(String tradeId, {String? reason}) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    final trade = _trades[index];
    final systemMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: 'system',
      senderName: 'System',
      content: reason != null
          ? 'Offer declined: $reason'
          : 'Offer declined by seller.',
      type: MessageType.system,
      sentAt: DateTime.now(),
    );

    _trades[index] = trade.copyWith(
      status: TradeStatus.declined,
      updatedAt: DateTime.now(),
      messages: [...trade.messages, systemMessage],
      hasUnread: trade.buyerId == _currentUserId,
    );

    notifyListeners();
    return true;
  }

  /// Counter offer (seller action)
  Future<bool> counterOffer(String tradeId, double newAmount) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    final trade = _trades[index];
    final counterMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: trade.sellerId,
      senderName: trade.sellerName,
      content: 'Counter offer: ₱${newAmount.toStringAsFixed(0)}',
      type: MessageType.offer,
      sentAt: DateTime.now(),
    );

    _trades[index] = trade.copyWith(
      messages: [...trade.messages, counterMessage],
      hasUnread: trade.buyerId == _currentUserId,
    );

    notifyListeners();
    return true;
  }

  /// Send a chat message (only works for accepted trades)
  Future<bool> sendMessage(String tradeId, String content) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    final trade = _trades[index];
    if (trade.status != TradeStatus.accepted) return false;

    await Future.delayed(const Duration(milliseconds: 200));

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: _currentUserId ?? 'unknown',
      senderName: 'You',
      content: content,
      type: MessageType.text,
      sentAt: DateTime.now(),
    );

    final isBuyer = trade.buyerId == _currentUserId;
    _trades[index] = trade.copyWith(
      messages: [...trade.messages, message],
      hasUnread: !isBuyer, // Notify the other party
    );

    notifyListeners();
    return true;
  }

  /// Suggest a meetup location
  Future<bool> suggestMeetup(
    String tradeId, {
    required String location,
    required DateTime dateTime,
    String? notes,
  }) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    final trade = _trades[index];
    if (trade.status != TradeStatus.accepted) return false;

    await Future.delayed(const Duration(milliseconds: 200));

    final meetup = MeetupSuggestion(
      location: location,
      dateTime: dateTime,
      notes: notes,
    );

    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: _currentUserId ?? 'unknown',
      senderName: 'You',
      content: '📍 Suggested meetup: $location',
      type: MessageType.meetup,
      sentAt: DateTime.now(),
      meetupSuggestion: meetup,
    );

    _trades[index] = trade.copyWith(
      messages: [...trade.messages, message],
    );

    notifyListeners();
    return true;
  }

  /// Mark trade messages as read
  void markAsRead(String tradeId) {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return;

    _trades[index] = _trades[index].copyWith(hasUnread: false);
    notifyListeners();
  }

  /// Complete a trade
  Future<bool> completeTrade(String tradeId) async {
    final index = _trades.indexWhere((t) => t.id == tradeId);
    if (index == -1) return false;

    await Future.delayed(const Duration(milliseconds: 300));

    final trade = _trades[index];
    final systemMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      tradeId: tradeId,
      senderId: 'system',
      senderName: 'System',
      content: '✅ Trade completed! Thanks for using CampusXchange.',
      type: MessageType.system,
      sentAt: DateTime.now(),
    );

    _trades[index] = trade.copyWith(
      status: TradeStatus.completed,
      updatedAt: DateTime.now(),
      messages: [...trade.messages, systemMessage],
    );

    notifyListeners();
    return true;
  }

  /// Load mock data for testing
  void loadMockData(String userId) {
    _currentUserId = userId;
    
    // Mock received offer
    _trades.add(TradeOffer(
      id: 'trade_mock_1',
      itemId: 'item_1',
      itemTitle: 'Organic Chemistry Textbook',
      itemImageUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
      itemPrice: 45.0,
      buyerId: 'buyer_1',
      buyerName: 'Sarah M.',
      buyerAvatar: '',
      sellerId: userId,
      sellerName: 'You',
      sellerAvatar: '',
      offerAmount: 35.0,
      message: 'Hi! Would you consider ₱35? I\'m a chemistry major.',
      status: TradeStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      hasUnread: true,
      messages: [
        ChatMessage(
          id: 'msg_mock_1',
          tradeId: 'trade_mock_1',
          senderId: 'buyer_1',
          senderName: 'Sarah M.',
          content: 'Hi! Would you consider ₱35? I\'m a chemistry major.',
          type: MessageType.text,
          sentAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ));

    // Mock accepted trade with chat
    _trades.add(TradeOffer(
      id: 'trade_mock_2',
      itemId: 'item_2',
      itemTitle: 'TI-84 Calculator',
      itemImageUrl: 'https://images.unsplash.com/photo-1564466809058-bf4114d55352?w=400',
      itemPrice: 75.0,
      buyerId: userId,
      buyerName: 'You',
      buyerAvatar: '',
      sellerId: 'seller_2',
      sellerName: 'Mike J.',
      sellerAvatar: '',
      offerAmount: 65.0,
      status: TradeStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 20)),
      messages: [
        ChatMessage(
          id: 'msg_mock_2a',
          tradeId: 'trade_mock_2',
          senderId: 'system',
          senderName: 'System',
          content: '🎉 Offer accepted! You can now chat to arrange the exchange.',
          type: MessageType.system,
          sentAt: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        ChatMessage(
          id: 'msg_mock_2b',
          tradeId: 'trade_mock_2',
          senderId: 'seller_2',
          senderName: 'Mike J.',
          content: 'Hey! Happy to sell for ₱65. When works for you?',
          type: MessageType.text,
          sentAt: DateTime.now().subtract(const Duration(hours: 18)),
        ),
      ],
    ));

    notifyListeners();
  }
}

// Singleton instance
class TradeContext {
  static final TradeProvider _instance = TradeProvider();
  static TradeProvider get instance => _instance;
}
