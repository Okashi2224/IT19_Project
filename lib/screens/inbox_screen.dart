import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../providers/trade_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TradeOffer? _selectedTrade;
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load mock data for demo
    TradeContext.instance.loadMockData('current_user');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CampusXchangeBottomNav(
        currentIndex: _currentNavIndex,
        onIndexChanged: (index) {
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.warmBone,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.darkWalnut,
          ),
          Expanded(
            child: Text(
              'Messages',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
          ),
          // Unread badge
          ListenableBuilder(
            listenable: TradeContext.instance,
            builder: (context, _) {
              final unread = TradeContext.instance.unreadCount;
              if (unread == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkWalnut,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unread new',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Sidebar - Conversation List
        Container(
          width: 360,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          child: _buildConversationList(),
        ),
        // Main Content - Chat or Empty State
        Expanded(
          child: _selectedTrade != null
              ? _buildChatView(_selectedTrade!)
              : _buildEmptyState(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return _buildConversationList();
  }

  Widget _buildConversationList() {
    return Column(
      children: [
        // Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.warmBone,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.darkWalnut,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.espresso,
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              dividerHeight: 0,
              tabs: const [
                Tab(
                  text: 'All',
                  height: 48,
                ),
                Tab(
                  text: 'Requests',
                  height: 48,
                ),
                Tab(
                  text: 'Active',
                  height: 48,
                ),
              ],
            ),
          ),
        ),
        
        // Conversation List
        Expanded(
          child: ListenableBuilder(
            listenable: TradeContext.instance,
            builder: (context, _) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildTradeList(TradeContext.instance.trades),
                  _buildTradeList(TradeContext.instance.pendingReceivedOffers),
                  _buildTradeList(TradeContext.instance.activeChats),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTradeList(List<TradeOffer> trades) {
    if (trades.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.softOak,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.espresso.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return _buildConversationTile(trade);
      },
    );
  }

  Widget _buildConversationTile(TradeOffer trade) {
    final isSelected = _selectedTrade?.id == trade.id;
    final isSeller = trade.sellerId == 'current_user';
    final otherName = isSeller ? trade.buyerName : trade.sellerName;
    
    // Get last message preview
    String preview = '';
    if (trade.messages.isNotEmpty) {
      final lastMsg = trade.messages.last;
      preview = lastMsg.content;
      if (preview.length > 50) {
        preview = '${preview.substring(0, 50)}...';
      }
    } else {
      preview = 'Offer: ₱${trade.offerAmount.toStringAsFixed(0)}';
    }

    // Status badge
    Widget statusBadge = const SizedBox.shrink();
    if (trade.status == TradeStatus.pending && isSeller) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Respond',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
          ),
        ),
      );
    } else if (trade.status == TradeStatus.accepted) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Active',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        TradeContext.instance.markAsRead(trade.id);
        final size = MediaQuery.of(context).size;
        if (size.width > 900) {
          setState(() => _selectedTrade = trade);
        } else {
          Navigator.of(context).pushNamed('/chat', arguments: trade);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.beigeBadge : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.5)),
            left: isSelected
                ? const BorderSide(color: AppColors.darkWalnut, width: 3)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 56,
                height: 56,
                color: AppColors.beigeBadge,
                child: trade.itemImageUrl.isNotEmpty
                    ? Image.network(
                        trade.itemImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          color: AppColors.softOak,
                        ),
                      )
                    : const Icon(Icons.image, color: AppColors.softOak),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: trade.hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.espresso,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      statusBadge,
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trade.itemTitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.darkWalnut,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.espresso.withOpacity(trade.hasUnread ? 0.9 : 0.6),
                      fontWeight: trade.hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (trade.hasUnread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.darkWalnut,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView(TradeOffer trade) {
    final isSeller = trade.sellerId == 'current_user';
    final otherName = isSeller ? trade.buyerName : trade.sellerName;

    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.cardBorder),
            ),
          ),
          child: Row(
            children: [
              // Item thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  color: AppColors.beigeBadge,
                  child: trade.itemImageUrl.isNotEmpty
                      ? Image.network(
                          trade.itemImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.softOak),
                        )
                      : const Icon(Icons.image, color: AppColors.softOak),
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 13,
                        color: AppColors.espresso.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Offer info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.beigeBadge,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '₱${trade.offerAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkWalnut,
                      ),
                    ),
                    Text(
                      'Offer',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.espresso.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Action Bar for Pending Offers
        if (trade.status == TradeStatus.pending && isSeller)
          _buildPendingActionBar(trade),
        
        // Messages
        Expanded(
          child: trade.isChatUnlocked
              ? _buildMessageList(trade)
              : _buildLockedChat(trade),
        ),
        
        // Input (only if chat unlocked)
        if (trade.isChatUnlocked) _buildMessageInput(trade),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_top, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Offer: ₱${trade.offerAmount.toStringAsFixed(0)} (${trade.discountPercent.toStringAsFixed(0)}% off)',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.espresso,
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
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCounterDialog(trade),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkWalnut,
                  ),
                  child: const Text('Counter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    await TradeContext.instance.acceptOffer(trade.id);
                  },
                  child: const Text('Accept Offer'),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.beigeBadge,
          borderRadius: BorderRadius.circular(12),
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

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
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
                  ? 'Chat will unlock when the offer is accepted'
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
    final controller = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          // AI Meetup suggestion button
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
                size: 20,
                color: AppColors.aiPurple,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.espresso.withOpacity(0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.darkWalnut),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                filled: true,
                fillColor: AppColors.warmBone,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                TradeContext.instance.sendMessage(trade.id, controller.text.trim());
                controller.clear();
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.darkWalnut,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.softOak,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a conversation',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.espresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from your messages on the left',
            style: GoogleFonts.inter(
              color: AppColors.espresso.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(TradeOffer trade) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Decline Offer', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to decline this ₱${trade.offerAmount.toStringAsFixed(0)} offer?',
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
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showCounterDialog(TradeOffer trade) {
    final controller = TextEditingController(text: trade.itemPrice.toStringAsFixed(0));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Counter Offer', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Their offer: ₱${trade.offerAmount.toStringAsFixed(0)}',
              style: GoogleFonts.inter(color: AppColors.espresso.withOpacity(0.7)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                TradeContext.instance.counterOffer(trade.id, amount);
              }
              Navigator.pop(context);
            },
            child: const Text('Send Counter'),
          ),
        ],
      ),
    );
  }

  void _showMeetupSuggestions(TradeOffer trade) {
    // AI-powered meetup suggestions based on time of day
    final hour = DateTime.now().hour;
    List<Map<String, String>> suggestions;
    
    if (hour < 12) {
      suggestions = [
        {'location': 'Student Union - Morning Coffee Area', 'time': 'This morning'},
        {'location': 'Library Entrance', 'time': 'Before noon'},
        {'location': 'Campus Center Lobby', 'time': 'Mid-morning'},
      ];
    } else if (hour < 18) {
      suggestions = [
        {'location': 'Student Union - Main Lobby', 'time': 'This afternoon'},
        {'location': 'Campus Bookstore Entrance', 'time': 'After class'},
        {'location': 'Dining Hall Patio', 'time': 'Before dinner'},
      ];
    } else {
      suggestions = [
        {'location': 'Library Study Lounge', 'time': 'This evening'},
        {'location': 'Campus Center - Near Info Desk', 'time': 'Tonight'},
        {'location': 'Student Union Cafe', 'time': 'After 7pm'},
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
        padding: const EdgeInsets.all(24),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.aiPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Meetup Suggestions',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.espresso,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Safe campus spots based on the time of day',
              style: GoogleFonts.inter(
                color: AppColors.espresso.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ...suggestions.map((s) => _buildMeetupOption(trade, s['location']!, s['time']!)),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetupOption(TradeOffer trade, String location, String time) {
    return InkWell(
      onTap: () {
        TradeContext.instance.suggestMeetup(
          trade.id,
          location: location,
          dateTime: DateTime.now(),
        );
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.warmBone,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.darkWalnut),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.espresso,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.espresso.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.send, size: 18, color: AppColors.softOak),
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
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.month}/${time.day}';
  }
}
