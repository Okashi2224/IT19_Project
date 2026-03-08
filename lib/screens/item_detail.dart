import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/item_model.dart';
import '../providers/app_state.dart';
import '../providers/trade_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImageIndex = 0;
  late bool _isFavorite;
  late Item _item;
  int _currentNavIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _item = ModalRoute.of(context)?.settings.arguments as Item? ?? initialItems[0];
    _isFavorite = AppStateManager.instance.isFavorite(_item.id);
  }

  void _toggleFavorite() {
    AppStateManager.instance.toggleFavorite(_item.id);
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        backgroundColor: AppColors.darkWalnut,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMessageSellerPanel(Item item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MessageSellerPanel(item: item),
    );
  }

  void _showMakeOfferDialog(Item item) {
    showDialog(
      context: context,
      builder: (context) => _MakeOfferDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: isWide 
                ? _buildWideLayout(_item)
                : _buildNarrowLayout(_item),
            ),
            _buildBottomButtons(_item),
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

  Widget _buildWideLayout(Item item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Image
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildImageCarousel(item),
                _buildDotsIndicator(),
              ],
            ),
          ),
        ),
        // Right side - Details
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepEspresso,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPriceSection(item),
                const SizedBox(height: 20),
                _buildDescriptionSection(item),
                const SizedBox(height: 20),
                _buildSellerSection(item),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(Item item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 16),
          _buildImageCarousel(item),
          _buildDotsIndicator(),
          const SizedBox(height: 24),
          _buildPriceSection(item),
          const SizedBox(height: 20),
          _buildDescriptionSection(item),
          const SizedBox(height: 20),
          _buildSellerSection(item),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.beigeBadge,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.darkWalnut,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Item Details',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepEspresso,
              ),
            ),
          ),
          GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isFavorite ? AppColors.darkWalnut : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.white : AppColors.darkWalnut,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _shareItem(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: AppColors.darkWalnut,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareItem() {
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
            Text(
              'Share "${_item.title}"',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.espresso,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.copy, 'Copy Link', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }),
                _buildShareOption(Icons.message, 'Message', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/inbox');
                }),
                _buildShareOption(Icons.email_outlined, 'Email', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email...')),
                  );
                }),
                _buildShareOption(Icons.more_horiz, 'More', () {
                  Navigator.pop(context);
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.beigeBadge,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.darkWalnut),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.espresso,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Item item) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
                itemCount: 3,
                itemBuilder: (context, index) {
                  return item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.beigeBadge,
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.softOak,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.beigeBadge,
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.softOak,
                              size: 60,
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
          // Category badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkWalnut,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == _currentImageIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: index == _currentImageIndex
                  ? AppColors.darkWalnut
                  : AppColors.softOak.withOpacity(0.3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPriceSection(Item item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.softOak,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.price == 0 ? 'Free' : '₱${item.price.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkWalnut,
                ),
              ),
            ],
          ),
          if (item.price > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Negotiable',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Item item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.description ?? 'No description provided.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.deepEspresso.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection(Item item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seller Information',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.softOak, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.sellerName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepEspresso,
                          ),
                        ),
                        if (item.isVerifiedStudent) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: AppColors.success,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.sellerMajorYear ?? 'Student',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.softOak,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.beigeBadge,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(Item item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.softOak.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Message Seller button (outlined)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMessageSellerPanel(item),
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  'Message',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkWalnut,
                  side: const BorderSide(color: AppColors.darkWalnut, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Make Offer button (filled)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showMakeOfferDialog(item),
                icon: const Icon(Icons.local_offer_outlined, size: 20),
                label: Text(
                  item.price == 0 ? 'Claim Item' : 'Make Offer',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkWalnut,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Message Seller Slide-Over Panel
class _MessageSellerPanel extends StatefulWidget {
  final Item item;

  const _MessageSellerPanel({required this.item});

  @override
  State<_MessageSellerPanel> createState() => _MessageSellerPanelState();
}

class _MessageSellerPanelState extends State<_MessageSellerPanel> {
  final _messageController = TextEditingController();
  bool _messageSent = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    
    // Create a trade offer with the message
    await TradeContext.instance.createOffer(
      itemId: widget.item.id,
      itemTitle: widget.item.title,
      itemImageUrl: widget.item.imageUrl,
      itemPrice: widget.item.price,
      sellerId: widget.item.sellerId,
      sellerName: widget.item.sellerName,
      offerAmount: widget.item.price, // Full price for message (not a negotiation)
      message: _messageController.text.trim(),
    );
    
    setState(() {
      _messageSent = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        // Navigate to inbox to see the message
        Navigator.pushNamed(context, '/inbox');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.creamWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _messageSent ? _buildSuccessView() : _buildMessageForm(),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Message Sent!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.deepEspresso,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.item.sellerName} will be notified',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.softOak.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.softOak, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message ${widget.item.sellerName}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepEspresso,
                      ),
                    ),
                    Text(
                      'About: ${widget.item.title}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.softOak,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.softOak),
              ),
            ],
          ),
        ),
        
        const Divider(color: AppColors.cardBorder),
        
        // Quick messages
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Messages',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.softOak,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickMessage('Is this still available?'),
                  _buildQuickMessage('Can we meet on campus?'),
                  _buildQuickMessage('Would you accept ₱${(widget.item.price * 0.9).toStringAsFixed(0)}?'),
                ],
              ),
            ],
          ),
        ),
        
        // Message input
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _messageController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: GoogleFonts.inter(color: AppColors.deepEspresso),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: GoogleFonts.inter(color: AppColors.softOak.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
                ),
              ),
            ),
          ),
        ),
        
        // Send button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              label: Text(
                'Send Message',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkWalnut,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMessage(String text) {
    return GestureDetector(
      onTap: () => _messageController.text = text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.beigeBadge,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.darkWalnut,
          ),
        ),
      ),
    );
  }
}

// Make Offer Dialog
class _MakeOfferDialog extends StatefulWidget {
  final Item item;

  const _MakeOfferDialog({required this.item});

  @override
  State<_MakeOfferDialog> createState() => _MakeOfferDialogState();
}

class _MakeOfferDialogState extends State<_MakeOfferDialog> {
  final _offerController = TextEditingController();
  bool _offerSubmitted = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with 90% of the price
    if (widget.item.price > 0) {
      _offerController.text = (widget.item.price * 0.9).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _offerController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    final offer = double.tryParse(_offerController.text);
    if (offer == null || offer <= 0) {
      // For free items, set offer to 0
      if (widget.item.price == 0) {
        await _createOffer(0);
      }
      return;
    }
    await _createOffer(offer);
  }

  Future<void> _createOffer(double offerAmount) async {
    // Create the trade offer via TradeProvider
    await TradeContext.instance.createOffer(
      itemId: widget.item.id,
      itemTitle: widget.item.title,
      itemImageUrl: widget.item.imageUrl,
      itemPrice: widget.item.price,
      sellerId: widget.item.sellerId,
      sellerName: widget.item.sellerName,
      offerAmount: offerAmount,
      message: offerAmount == widget.item.price 
          ? 'I\'d like to buy this at full price!'
          : 'Can you do ₱${offerAmount.toStringAsFixed(0)}?',
    );
    
    setState(() {
      _offerSubmitted = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
        // Navigate to inbox to see the offer
        Navigator.pushNamed(context, '/inbox');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.creamWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: _offerSubmitted ? _buildSuccessView() : _buildOfferForm(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Offer Sent!',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.deepEspresso,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your offer of ₱${_offerController.text} has been sent to ${widget.item.sellerName}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.softOak,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.item.price == 0 ? 'Claim Item' : 'Make an Offer',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.deepEspresso,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.softOak),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Item preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.item.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: AppColors.softOak),
                      )
                    : const Icon(Icons.image, color: AppColors.softOak),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepEspresso,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Asking: ₱${widget.item.price.toStringAsFixed(2)}',
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
        ),
        const SizedBox(height: 20),
        
        if (widget.item.price > 0) ...[
          // Offer input
          Text(
            'Your Offer',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.softOak,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _offerController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.darkWalnut,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: '₱ ',
              prefixStyle: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.darkWalnut,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.darkWalnut, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Quick offer buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickOfferButton(0.8, '80%'),
              _buildQuickOfferButton(0.9, '90%'),
              _buildQuickOfferButton(1.0, 'Full'),
            ],
          ),
        ] else ...[
          Text(
            'This item is free!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click below to let the seller know you\'re interested.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.softOak,
            ),
          ),
        ],
        const SizedBox(height: 24),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.item.price == 0 ? () => _submitOffer() : _submitOffer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkWalnut,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              widget.item.price == 0 ? 'I\'m Interested!' : 'Send Offer',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOfferButton(double percentage, String label) {
    final value = (widget.item.price * percentage).toStringAsFixed(2);
    return GestureDetector(
      onTap: () => _offerController.text = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.beigeBadge,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.darkWalnut,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
