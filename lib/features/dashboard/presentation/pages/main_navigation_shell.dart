import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../employee/presentation/pages/employee_leaderboard_page.dart';
import '../../presentation/providers/navigation_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'home_dashboard_page.dart';
import 'hotels_page.dart';
import 'insurance_page.dart';
import 'marketing_page.dart';
import 'records_dashboard_page.dart';
import 'services_grid_page.dart';
import 'tickets_page.dart';
import 'umrah_page.dart';

import 'universal_search_page.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  List<Widget> get _pages => [
    const HomeDashboardPage(),
    const AnalyticsPage(),
    const RecordsDashboardPage(),
    const TicketsPage(),
    const UmrahPage(),
    const HotelsPage(),
    const InsurancePage(),
    const MarketingPage(),
    const EmployeeLeaderboardPage(),
    const ServicesGridPage(),
    const UniversalSearchPage(),
  ];

  final List<String> _titles = [
    'Home',
    'Analytics',
    'Admin Dashboard',
    'Tickets',
    'Umrah',
    'Hotels',
    'Insurance',
    'Marketing',
    'Employees',
    'Services Grid',
    'Universal Search',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(navigationProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Go To Home Tab
        ref.read(navigationProvider.notifier).state = 0;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: selectedIndex != 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(navigationProvider.notifier).state = 0;
                  },
                )
              : null,
          title: Text(
            _titles[selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            // if (selectedIndex != 0)
            //   IconButton(
            //     icon: const Icon(Icons.home_outlined),
            //     tooltip: 'Go to Home',
            //     onPressed: () {
            //       ref.read(navigationProvider.notifier).state = 0;
            //     },
            //   ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search_outlined),
              onPressed: () {
                ref.read(navigationProvider.notifier).state =
                    10; // switch to Universal Search Page
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
          child: Column(
            children: [
              // Beautiful Custom Header with Gradient and Glow
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppColors.primary, const Color(0xFF4F46E5)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.flash_on,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'DATADASH ADMIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'admin@ostravel.com',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Navigation Sidebar List (All 9 Navbar Pages)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  children: [
                    _buildSidebarItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      title: 'Home',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 1,
                      icon: Icons.bar_chart_outlined,
                      title: 'Analytics',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 2,
                      icon: Icons.dashboard_outlined,
                      title: 'Admin Dashboard',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 3,
                      icon: Icons.flight_takeoff_outlined,
                      title: 'Tickets',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 4,
                      icon: Icons.mosque_outlined,
                      title: 'Umrah',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 5,
                      icon: Icons.hotel_outlined,
                      title: 'Hotels',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 6,
                      icon: Icons.verified_user_outlined,
                      title: 'Insurance',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 7,
                      icon: Icons.campaign_outlined,
                      title: 'Marketing',
                      selectedIndex: selectedIndex,
                    ),
                    _buildSidebarItem(
                      index: 8,
                      icon: Icons.people_alt_outlined,
                      title: 'Employees',
                      selectedIndex: selectedIndex,
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Logout Option styled beautifully
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E293B)
                        : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.transparent
                          : Colors.red.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout_outlined,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onTap: () async {
                      Navigator.pop(context); // Close drawer
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        body: IndexedStack(index: selectedIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex > 4 ? 0 : selectedIndex,
          onTap: (index) {
            ref.read(navigationProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDarkMode ? Colors.white60 : Colors.black45,
          backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flight_takeoff_outlined),
              activeIcon: Icon(Icons.flight_takeoff),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque),
              label: 'Umrah',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String title,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDarkMode
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.08))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? (isDarkMode
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.primary.withValues(alpha: 0.15))
              : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : (isDarkMode ? Colors.white60 : Colors.black54),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.primary
                : (isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context); // Close drawer
          ref.read(navigationProvider.notifier).state = index;
        },
      ),
    );
  }
}
