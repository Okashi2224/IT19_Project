/// Premium Subscription Screen for CampusXchange
/// Implements BMC: Revenue Stream - Premium Seller Features
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final TransactionProvider _transactionProvider = TransactionProvider();
  PremiumTier? _selectedTier;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    final userId = AuthContext.instance.currentUser?.id;
    if (userId != null) {
      final currentTier = _transactionProvider.getUserPremiumTier(userId);
      _selectedTier = currentTier;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthContext.instance.currentUser?.id ?? '';
    final currentTier = _transactionProvider.getUserPremiumTier(userId);
    final subscription = _transactionProvider.getUserSubscription(userId);

    return Scaffold(
      backgroundColor: AppColors.warmBone,
      appBar: AppBar(
        backgroundColor: AppColors.warmBone,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepEspresso),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Premium',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.deepEspresso,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkWalnut, AppColors.softOak],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Go Premium',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Unlock exclusive seller features',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (subscription?.isValid ?? false) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Active ${currentTier.name.toUpperCase()} Plan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Plan cards
            Text(
              'Choose Your Plan',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepEspresso,
              ),
            ),
            const SizedBox(height: 16),
            
            // Free tier
            _buildPlanCard(
              tier: PremiumTier.free,
              isCurrentPlan: currentTier == PremiumTier.free,
            ),
            const SizedBox(height: 12),
            
            // Basic tier
            _buildPlanCard(
              tier: PremiumTier.basic,
              isCurrentPlan: currentTier == PremiumTier.basic,
              isRecommended: true,
            ),
            const SizedBox(height: 12),
            
            // Pro tier
            _buildPlanCard(
              tier: PremiumTier.pro,
              isCurrentPlan: currentTier == PremiumTier.pro,
            ),
            const SizedBox(height: 24),

            // Benefits comparison
            Text(
              'Compare Plans',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepEspresso,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonTable(),
            const SizedBox(height: 32),
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

  Widget _buildPlanCard({
    required PremiumTier tier,
    required bool isCurrentPlan,
    bool isRecommended = false,
  }) {
    final price = PremiumPricing.getMonthlyPrice(tier);
    final features = PremiumPricing.getFeatures(tier);
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTier = tier);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.darkWalnut 
                : isRecommended 
                    ? AppColors.accent 
                    : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.darkWalnut.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkWalnut,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    Text(
                      tier.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepEspresso,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isRecommended)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Popular',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Current',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price == 0 ? 'Free' : '₱${price.toStringAsFixed(0)}',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkWalnut,
                    ),
                  ),
                  if (price > 0)
                    TextSpan(
                      text: '/month',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.softOak,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            ...features.take(3).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.espresso,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (features.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${features.length - 3} more features',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softOak,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.softOak.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Feature',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                ),
                ...['Free', 'Basic', 'Pro'].map((tier) => Expanded(
                  child: Text(
                    tier,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepEspresso,
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Rows
          _buildComparisonRow('Active Listings', '5', '20', '∞'),
          _buildComparisonRow('Monthly Boosts', '0', '1', '3'),
          _buildComparisonRow('Analytics', '—', '✓', '✓'),
          _buildComparisonRow('Verified Badge', '—', '✓', '✓'),
          _buildComparisonRow('Priority Support', '—', '✓', '✓'),
          _buildComparisonRow('Featured Profile', '—', '—', '✓'),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature, 
    String free, 
    String basic, 
    String pro,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.espresso,
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: free == '—' ? AppColors.softOak : AppColors.espresso,
              ),
            ),
          ),
          Expanded(
            child: Text(
              basic,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: basic == '✓' ? AppColors.success : AppColors.espresso,
              ),
            ),
          ),
          Expanded(
            child: Text(
              pro,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: pro == '✓' || pro == '∞' ? FontWeight.w600 : null,
                color: pro == '✓' || pro == '∞' 
                    ? AppColors.success 
                    : AppColors.espresso,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
