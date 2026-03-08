import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/trade_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  int _currentNavIndex = 2;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // Handle both TradeOffer and Map (from notifications)
    TradeOffer? trade;
    if (args is TradeOffer) {
      trade = args;
    } else if (args is Map<String, dynamic>) {
      // Try to get tradeId from payload
      final tradeId = args['tradeId'] as String?;
      if (tradeId != null) {
        trade = TradeContext.instance.getTradeById(tradeId);
      }
    }
    
    if (trade == null) {
      return Scaffold(
        backgroundColor: AppColors.warmBone,
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('No conversation selected')),
      );
    }

    final isSeller = trade.sellerId == 'current_user';
    final otherName = isSeller ? trade.buyerName : trade.sellerName;

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.darkWalnut,
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.beigeBadge,
              child: Text(
                otherName.isNotEmpty ? otherName[0] : '?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkWalnut,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.espresso,
                    ),
                  ),
                  Text(
                    trade.itemTitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.espresso.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.beigeBadge,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₱${trade.offerAmount.toStringAsFixed(0)}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkWalnut,
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: TradeContext.instance,
        builder: (context, _) {
          final currentTrade = TradeContext.instance.getTradeById(trade!.id);
          if (currentTrade == null) return const SizedBox();
          
          return Column(
            children: [
              // Action bar for pending offers (seller)
              if (currentTrade.status == TradeStatus.pending && isSeller)
                _buildPendingActionBar(currentTrade),
              
              // Messages
              Expanded(
                child: currentTrade.isChatUnlocked
                    ? _buildMessageList(currentTrade)
                    : _buildLockedChat(currentTrade),
              ),
              
              // Input
              if (currentTrade.isChatUnlocked) _buildMessageInput(currentTrade),
            ],
          );
        },
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildPendingActionBar(TradeOffer trade) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppColors.warning.withOpacity(0.3)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_offer, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'Offer: ₱${trade.offerAmount.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.espresso,
                ),
              ),
              Text(
                ' (${trade.discountPercent.toStringAsFixed(0)}% off)',
                style: GoogleFonts.inter(
                  color: AppColors.espresso.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDeclineDialog(trade),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCounterDialog(trade),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkWalnut,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Counter'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    // Accept offer and navigate to active chat
                    await TradeContext.instance.acceptOffer(trade.id);
                    // Status changes to "Active" after acceptance
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(TradeOffer trade) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: trade.messages.length,
      itemBuilder: (context, index) {
        final message = trade.messages[trade.messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == 'current_user';
    final isSystem = message.type == MessageType.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.beigeBadge,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.espresso.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (message.type == MessageType.meetup && message.meetupSuggestion != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? AppColors.darkWalnut : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: isMe ? null : Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isMe ? AppColors.oak : AppColors.darkWalnut,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Meetup Suggestion',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMe ? AppColors.oak : AppColors.darkWalnut,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.meetupSuggestion!.location,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isMe ? Colors.white : AppColors.espresso,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.sentAt),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isMe ? Colors.white60 : AppColors.espresso.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.darkWalnut : Colors.white,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: isMe ? const Radius.circular(4) : null,
            bottomLeft: !isMe ? const Radius.circular(4) : null,
          ),
          border: isMe ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isMe ? Colors.white : AppColors.espresso,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.sentAt),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isMe ? Colors.white60 : AppColors.espresso.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedChat(TradeOffer trade) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.beigeBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 36,
                color: AppColors.softOak,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chat Locked',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trade.status == TradeStatus.pending
                  ? 'Chat unlocks when offer is accepted'
                  : 'This offer was ${trade.status.name}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.espresso.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(TradeOffer trade) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // AI Meetup button
            IconButton(
              onPressed: () => _showMeetupSuggestions(trade),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.aiGlow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.aiPurple,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    color: AppColors.espresso.withOpacity(0.4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.warmBone,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(trade),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _sendMessage(trade),
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.darkWalnut,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(TradeOffer trade) {
    if (_messageController.text.trim().isNotEmpty) {
      TradeContext.instance.sendMessage(trade.id, _messageController.text.trim());
      _messageController.clear();
    }
  }

  void _showDeclineDialog(TradeOffer trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Decline Offer',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Decline this ₱${trade.offerAmount.toStringAsFixed(0)} offer?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              TradeContext.instance.declineOffer(trade.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(TradeOffer trade) {
    final counterController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Counter Offer', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current offer: ₱${trade.offerAmount.toStringAsFixed(0)}', style: GoogleFonts.inter()),
            const SizedBox(height: 16),
            TextField(
              controller: counterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your counter',
                prefixText: '₱ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(counterController.text) ?? 0;
              if (amount > 0) {
                TradeContext.instance.counterOffer(trade.id, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }

  /// AI Meetup Suggestion - suggests location based on DateTime.now()
  void _showMeetupSuggestions(TradeOffer trade) {
    final now = DateTime.now();
    final hour = now.hour;
    final isWeekend = now.weekday >= 6;
    
    // Generate AI suggestions based on current time
    List<Map<String, String>> suggestions;
    String timeContext;
    
    if (isWeekend) {
      timeContext = 'Weekend meetup spots';
      suggestions = [
        {'location': 'Campus Center Food Court', 'time': 'Open weekends', 'note': 'Moderate crowd, safe location'},
        {'location': 'Library Weekend Hours Area', 'time': 'Check hours', 'note': 'Quiet but secure'},
        {'location': 'Athletic Facility Entrance', 'time': 'During events', 'note': 'Lots of people around'},
      ];
    } else if (hour < 12) {
      timeContext = 'Morning meetup spots';
      suggestions = [
        {'location': 'Library Lobby', 'time': 'This morning', 'note': 'Opens early, security nearby'},
        {'location': 'Student Union Coffee Area', 'time': 'Before noon', 'note': 'Busy with morning crowd'},
        {'location': 'Campus Center Lobby', 'time': 'Mid-morning', 'note': 'Central, lots of foot traffic'},
      ];
    } else if (hour < 18) {
      timeContext = 'Afternoon meetup spots';
      suggestions = [
        {'location': 'Student Center Main Lobby', 'time': 'This afternoon', 'note': 'Peak activity, very safe'},
        {'location': 'Bookstore Entrance', 'time': 'After lunch', 'note': 'High traffic, monitored'},
        {'location': 'Quad/Main Green', 'time': 'Between classes', 'note': 'Open space, many students'},
      ];
    } else {
      timeContext = 'Evening meetup spots';
      suggestions = [
        {'location': 'Library Study Lounge', 'time': 'This evening', 'note': 'Open late, security desk'},
        {'location': 'Student Union Info Desk', 'time': 'Before closing', 'note': 'Staffed location'},
        {'location': '24-Hour Study Room', 'time': 'Tonight', 'note': 'Always occupied, well-lit'},
      ];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.aiGlow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.aiPurple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Meetup Suggestion',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeContext,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.softOak,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((s) => ListTile(
              onTap: () {
                TradeContext.instance.suggestMeetup(
                  trade.id,
                  location: s['location']!,
                  dateTime: DateTime.now(),
                );
                Navigator.pop(context);
              },
              leading: const Icon(Icons.location_on_outlined, color: AppColors.darkWalnut),
              title: Text(s['location']!, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['time']!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.softOak)),
                  Text(s['note']!, style: GoogleFonts.inter(fontSize: 10, color: AppColors.aiPurple)),
                ],
              ),
              trailing: const Icon(Icons.send, size: 18, color: AppColors.softOak),
              contentPadding: EdgeInsets.zero,
            )),
            const SizedBox(height: 12),
            // Safety tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.beigeBadge,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Always meet in public places with people around',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.espresso),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${time.month}/${time.day}';
  }
}
