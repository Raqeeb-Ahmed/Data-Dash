import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../presentation/providers/navigation_provider.dart';
import '../providers/bookings_provider.dart';
import 'employee_home_page.dart';
import 'employee_tickets_page.dart';
import 'employee_visa_records_page.dart';
import 'employee_search_page.dart';
import 'employee_reports_page.dart';
import 'visa_bookings_form_page.dart';

class EmployeeNavigationShell extends ConsumerStatefulWidget {
  const EmployeeNavigationShell({super.key});

  @override
  ConsumerState<EmployeeNavigationShell> createState() =>
      _EmployeeNavigationShellState();
}

class _EmployeeNavigationShellState
    extends ConsumerState<EmployeeNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Define pages matching the tabs: Home, Bookings, Visa Records, Ticketing, Countries, Search, Reports
  List<Widget> get _pages => [
    const EmployeeHomePage(),
    const VisaBookingsFormPage(), // Bookings (Form)
    const EmployeeVisaRecordsPage(), // Visa Records (Custom page for employees)
    const EmployeeTicketsPage(), // Ticketing
    const EmployeeCountriesPage(), // Countries Grid
    const EmployeeSearchPage(), // Search
    const EmployeeReportsPage(), // Reports
  ];

  @override
  void initState() {
    super.initState();
    // Start on Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationProvider.notifier).state = 0;
    });
  }

  void _onTabSelected(int index) {
    // Apply dynamic filtering if switching to Bookings or Visa Records
    if (index == 1) {
      ref.read(bookingsFilterProvider.notifier).reset();
    } else if (index == 2) {
      ref.read(bookingsFilterProvider.notifier).updateService('visa');
    }
    ref.read(navigationProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final rawIndex = ref.watch(navigationProvider);
    final selectedIndex = rawIndex.clamp(0, _pages.length - 1);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).value;
    final bool isMobile = MediaQuery.of(context).size.width < 800;
    final Widget content = isMobile
        ? Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDarkMode
                ? const Color(0xFF070B13)
                : Colors.grey[50],
            appBar: AppBar(
              backgroundColor: isDarkMode
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              elevation: 1,
              leading: selectedIndex == 0
                  ? IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        ref.read(navigationProvider.notifier).state = 0;
                      },
                    ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DataDash',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              actions: [
                // if (selectedIndex != 0)
                //   IconButton(
                //     icon: Icon(
                //       Icons.home_outlined,
                //       color: isDarkMode ? Colors.white : Colors.black87,
                //     ),
                //     tooltip: 'Go to Home',
                //     onPressed: () {
                //       ref.read(navigationProvider.notifier).state = 0;
                //     },
                //   ),
                // User Avatar Indicator
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E293B)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user?.displayName ?? 'AFTAB',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            drawer: _buildMobileDrawer(
              context,
              selectedIndex,
              isDarkMode,
              user,
            ),
            body: IndexedStack(index: selectedIndex, children: _pages),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: isDarkMode
                  ? const Color(0xFF0F172A)
                  : Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: isDarkMode ? Colors.white60 : Colors.black54,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex < 4 ? selectedIndex : 4,
              onTap: (index) {
                if (index == 4) {
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  _onTabSelected(index);
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box_outlined),
                  label: 'Apply',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder_shared_outlined),
                  label: 'Visas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.airplane_ticket_outlined),
                  label: 'Tickets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'More',
                ),
              ],
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            backgroundColor: isDarkMode
                ? const Color(0xFF070B13)
                : Colors.grey[50],
            body: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Header tab row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: isDarkMode
                                  ? const Color(0x1AFFFFFF)
                                  : const Color(0x1F000000),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.trending_up,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DATADASH',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeaderTab(
                                  'Home',
                                  0,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Bookings',
                                  1,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Visa Records',
                                  2,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Ticketing',
                                  3,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Countries',
                                  4,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Search',
                                  5,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderTab(
                                  'Reports',
                                  6,
                                  selectedIndex,
                                  isDarkMode,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF1E293B)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Employee ${user?.displayName ?? 'AFTAB'}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    await ref
                                        .read(authControllerProvider.notifier)
                                        .logout();
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.logout_outlined,
                                    size: 14,
                                    color: AppColors.error,
                                  ),
                                  label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ref.read(navigationProvider.notifier).state = 0;
      },
      child: content,
    );
  }

  Widget _buildHeaderTab(
    String title,
    int index,
    int selectedIndex,
    bool isDarkMode,
  ) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(
    BuildContext context,
    int selectedIndex,
    bool isDarkMode,
    dynamic user,
  ) {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          // Drawer Profile Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : AppColors.primary,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 36, color: AppColors.primary),
            ),
            accountName: Text(
              user?.displayName ?? 'Employee AFTAB',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?.email ?? 'employee@gmail.com',
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // Drawer Navigation Items List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile('Home', Icons.home_outlined, 0, selectedIndex),
                _buildDrawerTile(
                  'Bookings (Visa Apply)',
                  Icons.add_box_outlined,
                  1,
                  selectedIndex,
                ),
                _buildDrawerTile(
                  'Visa Records',
                  Icons.folder_shared_outlined,
                  2,
                  selectedIndex,
                ),
                _buildDrawerTile(
                  'Ticketing',
                  Icons.airplane_ticket_outlined,
                  3,
                  selectedIndex,
                ),
                _buildDrawerTile(
                  'Countries',
                  Icons.public_outlined,
                  4,
                  selectedIndex,
                ),
                _buildDrawerTile(
                  'Search',
                  Icons.search_outlined,
                  5,
                  selectedIndex,
                ),
                _buildDrawerTile(
                  'Reports',
                  Icons.analytics_outlined,
                  6,
                  selectedIndex,
                ),
                const Divider(),
              ],
            ),
          ),

          // Drawer Footer Logout Button
          Padding(
            padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
    String title,
    IconData icon,
    int index,
    int selectedIndex,
  ) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        _onTabSelected(index);
      },
    );
  }
}

// ── Standalone Countries Grid Page ──
class EmployeeCountriesPage extends ConsumerStatefulWidget {
  const EmployeeCountriesPage({super.key});

  @override
  ConsumerState<EmployeeCountriesPage> createState() =>
      _EmployeeCountriesPageState();
}

class _EmployeeCountriesPageState extends ConsumerState<EmployeeCountriesPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingsProvider);
    final user = ref.watch(authControllerProvider).value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x660F172A)
        : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDarkMode
        ? const Color(0x15FFFFFF)
        : const Color(0x1F000000);

    // 1. Group active visa bookings of the current logged-in employee by destination
    final employeeBookings = allBookings.where((b) {
      return b.serviceType == 'visa' &&
          (b.employeeId == (user?.uid ?? '') ||
              b.employeeName.toLowerCase() ==
                  (user?.displayName ?? 'aftab').toLowerCase());
    }).toList();

    final Map<String, int> activeCounts = {};
    for (final b in employeeBookings) {
      final country = b.destination.trim().toLowerCase();
      if (country.isNotEmpty) {
        activeCounts[country] = (activeCounts[country] ?? 0) + 1;
      }
    }

    // 2. Specific countries list matching the mockup, with their flags and baseline counts
    final List<Map<String, dynamic>> mockupCountries = [
      {'name': 'Thailand', 'flag': '🇹🇭'},
      {'name': 'Malaysia', 'flag': '🇲🇾'},
      {'name': 'Azerbaijan', 'flag': '🇦🇿'},
      {'name': 'Indonesia', 'flag': '🇮🇩'},
      {'name': 'Singapore', 'flag': '🇸🇬'},
      {'name': 'Uzbekistan', 'flag': '🇺🇿'},
      {'name': 'Tajikistan', 'flag': '🇹🇯'},
      {'name': 'Egypt', 'flag': '🇪🇬'},
      {'name': 'Nepal', 'flag': '🇳🇵'},
      {'name': 'Kyrgyzstan', 'flag': '🇰🇬'},
      {'name': 'Bahrain', 'flag': '🇧🇭'},
      {'name': 'Uganda', 'flag': '🇺🇬'},
      {'name': 'Vietnam', 'flag': '🇻🇳'},
      {'name': 'Sri Lanka', 'flag': '🇱🇰'},
      {'name': 'Cambodia', 'flag': '🇰🇭'},
      {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    ];

    // Compute display list (actual count of applications logged-in employee applied for)
    final List<Map<String, dynamic>> displayList = mockupCountries.map((c) {
      final String countryName = c['name'] as String;
      final matchedCount = activeCounts[countryName.toLowerCase()] ?? 0;
      return {'name': countryName, 'flag': c['flag'], 'count': matchedCount};
    }).toList();

    // Check if there are other countries in activeCounts that aren't in the mockup list, and append them
    activeCounts.forEach((key, value) {
      final isAlreadyListed = mockupCountries.any(
        (c) => (c['name'] as String).toLowerCase() == key,
      );
      if (!isAlreadyListed) {
        final String capitalizedName = key
            .split(' ')
            .map((word) {
              if (word.isEmpty) return '';
              return word[0].toUpperCase() + word.substring(1);
            })
            .join(' ');

        displayList.add({
          'name': capitalizedName,
          'flag': '🌎',
          'count': value,
        });
      }
    });

    // Filter displayList by _searchText
    final filteredList = displayList.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return name.contains(_searchText.toLowerCase());
    }).toList();

    final double width = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 900) {
      crossAxisCount = 3;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        watermarkText: 'COUNTRIES',
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'My Visa Applications by Country',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'An overview of your travel destinations and applications.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 20),

              // Dynamic Info alert card banner
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 16,
              //     vertical: 12,
              //   ),
              //   decoration: BoxDecoration(
              //     color: isDarkMode
              //         ? const Color(0x331E293B)
              //         : Colors.grey[200],
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: borderColor),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Logged in as: ${user?.email ?? 'aftab@os.com'}',
              //         style: TextStyle(
              //           fontSize: 12,
              //           fontWeight: FontWeight.bold,
              //           color: primaryTextColor,
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         'You can only see your own visa applications grouped by country.',
              //         style: TextStyle(fontSize: 10, color: secondaryTextColor),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 20),

              // Search Text Field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  style: TextStyle(color: primaryTextColor, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search countries...',
                    hintStyle: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: secondaryTextColor,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchText = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Grid of Country cards
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,

                  crossAxisSpacing: 12,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final item = filteredList[index];
                  final int count = item['count'] as int;
                  final String applicantLabel = count == 1
                      ? 'Applicant'
                      : 'Applicants';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['flag'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count $applicantLabel',
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
