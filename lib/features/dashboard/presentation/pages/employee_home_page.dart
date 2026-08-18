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
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  const SizedBox(height: 48),
                  // ── 2. QUICK ACCESS SECTION ──
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your bookings and view live reports',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        int crossAxisCount = 2;
                        if (width >= 900) {
                          crossAxisCount = 4;
                        } else if (width >= 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.flight_takeoff_outlined,
                              title: 'My Bookings',
                              subtitle: 'Form & application',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                ref.read(navigationProvider.notifier).state = 1;
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.check_circle_outline,
                              title: 'Approved Visas',
                              subtitle: 'Track confirmations',
                              color: const Color(0xFF10B981),
                              onTap: () {
                                ref
                                    .read(bookingsFilterProvider.notifier)
                                    .updateService('visa');
                                ref
                                    .read(bookingsFilterProvider.notifier)
                                    .updateStatus('Approved');
                                ref.read(navigationProvider.notifier).state = 2;
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.public_outlined,
                              title: 'Countries',
                              subtitle: 'Supported destinations',
                              color: const Color(0xFFF59E0B),
                              onTap: () {
                                ref.read(navigationProvider.notifier).state = 4;
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.search_outlined,
                              title: 'Search',
                              subtitle: 'Find travelers instantly',
                              color: const Color(0xFF8B5CF6),
                              onTap: () {
                                ref.read(navigationProvider.notifier).state = 5;
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.bar_chart_outlined,
                              title: 'Reports',
                              subtitle: 'Visa & travel reports',
                              color: const Color(0xFFEC4899),
                              onTap: () {
                                ref.read(navigationProvider.notifier).state = 6;
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── 3. OUR SERVICES SECTION ──
                  Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quick options to book and manage client travel',
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double width = constraints.maxWidth;
                        int crossAxisCount = 2;
                        if (width >= 900) {
                          crossAxisCount = 4;
                        } else if (width >= 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.flight_takeoff,
                              title: 'Flight Ticketing',
                              subtitle: 'Air ticket reservation',
                              color: const Color(0xFF3B82F6),
                              onTap: () {
                                ref.read(navigationProvider.notifier).state = 3;
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.mosque,
                              title: 'Umrah Bookings',
                              subtitle: 'Umrah & packages',
                              color: const Color(0xFF10B981),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EmployeeUmrahBookingPage(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.hotel,
                              title: 'Hotel Booking',
                              subtitle: 'Reserve accommodations',
                              color: const Color(0xFFF59E0B),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EmployeeHotelBookingPage(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.verified_user,
                              title: 'Medical Insurance',
                              subtitle: 'Travel health plans',
                              color: const Color(0xFFEC4899),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EmployeeMedicalInsurancePage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0x660F172A)
              : Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode
                ? const Color(0x15FFFFFF)
                : const Color(0x1F000000),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDarkMode
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isDarkMode ? const Color(0xFF475569) : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
