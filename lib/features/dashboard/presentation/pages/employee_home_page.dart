import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../presentation/providers/navigation_provider.dart';
import '../providers/bookings_provider.dart';
import 'employee_umrah_booking_page.dart';
import 'employee_hotel_booking_page.dart';
import 'employee_medical_insurance_page.dart';

class EmployeeHomePage extends ConsumerWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        watermarkText: 'DATADASH',
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                // ── 1. HERO SECTION ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            fontFamily: 'Inter',
                            color: primaryTextColor,
                          ),
                          children: [
                            const TextSpan(text: 'Travel '),
                            const TextSpan(
                              text: 'Simplified',
                              style: TextStyle(color: Color(0xFF3B82F6)),
                            ),
                            const TextSpan(text: ',\nBookings '),
                            const TextSpan(
                              text: 'Managed',
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your all-in-one platform for visas, flights, and travel services.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: secondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Scroll down or switch to search
                          ref.read(navigationProvider.notifier).state =
                              5; // Search Tab
                        },
                        icon: const Icon(
                          Icons.rocket_launch,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // ── 2. QUICK ACCESS SECTION ──
                Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      int crossAxisCount = 3;
                      if (width < 600) {
                        crossAxisCount = 1;
                      } else if (width < 950) {
                        crossAxisCount = 2;
                      }

                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.6,
                        children: [
                          _buildQuickAccessCard(
                            context: context,
                            title: 'My Bookings',
                            description:
                                'View and manage your visa bookings easily.',
                            buttonText: 'Go to My Bookings',
                            icon: Icons.flight_takeoff_outlined,
                            iconColor: const Color(0xFF3B82F6),
                            onTap: () {
                              ref.read(navigationProvider.notifier).state =
                                  1; // Bookings tab
                            },
                          ),
                          _buildQuickAccessCard(
                            context: context,
                            title: 'Approved Visas',
                            description:
                                'Track your approved applications hassle-free.',
                            buttonText: 'Go to Approved Visas',
                            icon: Icons.check_circle_outline,
                            iconColor: const Color(0xFF10B981),
                            onTap: () {
                              // Pre-filter bookings list to show approved visas
                              ref
                                  .read(bookingsFilterProvider.notifier)
                                  .updateService('visa');
                              ref
                                  .read(bookingsFilterProvider.notifier)
                                  .updateStatus('Approved');
                              ref.read(navigationProvider.notifier).state =
                                  2; // Visa Records tab
                            },
                          ),
                          // _buildQuickAccessCard(
                          //   context: context,
                          //   title: 'Deleted Visas',
                          //   description:
                          //       'Restore or permanently delete visa records.',
                          //   buttonText: 'Go to Deleted Visas',
                          //   icon: Icons.delete_outline,
                          //   iconColor: const Color(0xFFEF4444),
                          //   onTap: () {
                          //     // Show snackbar / message
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       const SnackBar(
                          //         content: Text(
                          //           'No deleted visas found in trash.',
                          //         ),
                          //         backgroundColor: AppColors.primary,
                          //       ),
                          //     );
                          //   },
                          // ),
                          _buildQuickAccessCard(
                            context: context,
                            title: 'Countries',
                            description:
                                'Browse and manage supported destinations.',
                            buttonText: 'Go to Countries',
                            icon: Icons.public_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            onTap: () {
                              ref.read(navigationProvider.notifier).state =
                                  4; // Countries Tab
                            },
                          ),
                          _buildQuickAccessCard(
                            context: context,
                            title: 'Search',
                            description:
                                'Find bookings by passport or traveler name.',
                            buttonText: 'Go to Search',
                            icon: Icons.search_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            onTap: () {
                              ref.read(navigationProvider.notifier).state =
                                  5; // Search Tab
                            },
                          ),
                          _buildQuickAccessCard(
                            context: context,
                            title: 'Reports',
                            description:
                                'Download insightful visa & travel reports.',
                            buttonText: 'Go to Reports',
                            icon: Icons.bar_chart_outlined,
                            iconColor: const Color(0xFFEC4899),
                            onTap: () {
                              ref.read(navigationProvider.notifier).state =
                                  6; // Reports Tab
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 64),

                // ── 3. OUR SERVICES SECTION ──
                Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final cards = _buildServicesList(context, ref);
                      if (width < 768) {
                        return Column(
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              cards[i],
                              if (i < cards.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: cards[i],
                                ),
                              ),
                              if (i < cards.length - 1)
                                const SizedBox(width: 12),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 64),

                // ── 4. WHY CHOOSE SECTION ──
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      const TextSpan(text: 'Why Choose '),
                      const TextSpan(
                        text: 'OS Travels',
                        style: TextStyle(color: Color(0xFF3B82F6)),
                      ),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.maxWidth;
                      final cards = _buildWhyChooseCards(context);
                      if (width < 768) {
                        return Column(
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              cards[i],
                              if (i < cards.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: cards[i],
                                ),
                              ),
                              if (i < cards.length - 1)
                                const SizedBox(width: 16),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 34),

                // ── 5. BRAND FOOTER ──
                // _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0B0F19).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFF10B981,
          ).withValues(alpha: 0.2), // Light green border
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 180,
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDarkMode ? const Color(0x33FFFFFF) : Colors.grey[400]!,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: isDarkMode ? Colors.transparent : Colors.white,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServicesList(BuildContext context, WidgetRef ref) {
    return [
      _buildServiceCard(
        context: context,
        title: 'Flight Ticketing',
        description:
            'Book flights to destinations worldwide at the best rates.',
        icon: Icons.flight_takeoff,
        onTap: () {
          ref.read(navigationProvider.notifier).state = 3; // Ticketing tab
        },
      ),
      _buildServiceCard(
        context: context,
        title: 'UMRAH BOOKINGS',
        description:
            'Plan your spiritual journey with our dedicated Umrah packages.',
        icon: Icons.mosque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeUmrahBookingPage(),
            ),
          );
        },
      ),
      _buildServiceCard(
        context: context,
        title: 'Hotel Booking',
        description: 'Find and reserve top-rated hotels and accommodations.',
        icon: Icons.hotel,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeHotelBookingPage(),
            ),
          );
        },
      ),
      _buildServiceCard(
        context: context,
        title: 'Medical Insurance',
        description: 'Get personalized tips for your trips and destinations.',
        icon: Icons.verified_user,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmployeeMedicalInsurancePage(),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF0F172A).withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(
            0xFFEC4899,
          ).withValues(alpha: 0.2), // Pinkish tint outline
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: const Color(0xFFEC4899), size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          InkWell(
            onTap: onTap,
            child: const Text(
              'Learn More',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEC4899),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }



  List<Widget> _buildWhyChooseCards(BuildContext context) {
    return [
      _buildWhyCard(
        context: context,
        title: 'Global Reach',
        description:
            'We cover 50+ countries to make your travel truly international.',
        icon: Icons.public,
        iconColor: const Color(0xFF3B82F6),
      ),
      _buildWhyCard(
        context: context,
        title: 'Fast Processing',
        description:
            'Quick approvals and streamlined processes for stress-free journeys.',
        icon: Icons.flash_on,
        iconColor: const Color(0xFFF59E0B),
      ),
      _buildWhyCard(
        context: context,
        title: 'Trusted Service',
        description:
            'Thousands of happy clients rely on us for smooth travel experiences.',
        icon: Icons.thumb_up_alt_outlined,
        iconColor: const Color(0xFF10B981),
      ),
    ];
  }

  Widget _buildWhyCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0x0FFFFFFF) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: secondaryTextColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
