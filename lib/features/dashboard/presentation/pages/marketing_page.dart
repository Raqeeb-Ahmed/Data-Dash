import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';

class MarketingPage extends StatelessWidget {
  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketing & Campaigns',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
                        ),
                        Text(
                          'Lead generation, ad performance & conversion rates',
                          style: TextStyle(fontSize: 12, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMarketingCard(context, 'FB Campaign: Umrah 2026 Promo', 'Leads: 1,420 • CTR: 4.8%', 'Spend: \$450', 'Active', isDarkMode),
                _buildMarketingCard(context, 'IG Ad: UK Student Visa Assistance', 'Leads: 890 • CTR: 6.2%', 'Spend: \$320', 'Active', isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketingCard(BuildContext context, String campaign, String stats, String spend, String status, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0x660F172A) : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? const Color(0x15FFFFFF) : const Color(0x1F000000)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? Colors.white : AppColors.textPrimaryLight)),
              const SizedBox(height: 4),
              Text('$stats\nBudget $spend', style: TextStyle(fontSize: 12, color: isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0x228B5CF6), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
