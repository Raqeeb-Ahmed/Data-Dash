import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ServicesGridPage extends StatelessWidget {
  const ServicesGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OS Services Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select a category to view detailed bookings and stats.',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
            const SizedBox(height: 24),
            
            // Services Grid
            GridView.count(
              crossAxisCount: 1, // Single column on mobile is cleaner for list style list items
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              childAspectRatio: 2.8,
              children: [
                _buildServiceMenuItem(
                  context,
                  title: 'Visa Bookings',
                  subtitle: 'Manage client visa submissions, requirements, and statuses.',
                  count: '2,928 Records',
                  icon: Icons.card_membership_outlined,
                  color: AppColors.primary,
                ),
                _buildServiceMenuItem(
                  context,
                  title: 'Ticket Bookings',
                  subtitle: 'Flight ticket bookings, routing PNR references, and margins.',
                  count: '760 Records',
                  icon: Icons.confirmation_number_outlined,
                  color: AppColors.secondary,
                ),
                _buildServiceMenuItem(
                  context,
                  title: 'Umrah Packages',
                  subtitle: 'Umrah group listings, hotel details, transport, and visas.',
                  count: '33 Records',
                  icon: Icons.mosque_outlined,
                  color: AppColors.accent,
                ),
                _buildServiceMenuItem(
                  context,
                  title: 'Hotel Details',
                  subtitle: 'Accommodation bookings, night details, properties, and vouchers.',
                  count: '51 Records',
                  icon: Icons.hotel_outlined,
                  color: Colors.purple,
                ),
                _buildServiceMenuItem(
                  context,
                  title: 'Medical Insurance',
                  subtitle: 'Insurances, travel policies, passport list, and premiums.',
                  count: '98 Records',
                  icon: Icons.health_and_safety_outlined,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: BorderSide(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon block
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          count,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
