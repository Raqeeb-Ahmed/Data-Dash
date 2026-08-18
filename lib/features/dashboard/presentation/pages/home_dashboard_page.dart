import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/navigation_provider.dart';
import '../providers/bookings_provider.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  bool _isExpanded = false;

  String _getCountryFlag(String countryName) {
    final normalized = countryName.toLowerCase().trim();
    final Map<String, String> countryFlags = {
      'malaysia': '🇲🇾',
      'thailand': '🇹🇭',
      'azerbaijan': '🇦🇿',
      'indonesia': '🇮🇩',
      'singapore': '🇸🇬',
      'uzbekistan': '🇺🇿',
      'nepal': '🇳🇵',
      'austria': '🇦🇹',
      'hungary': '🇭🇺',
      'norway': '🇳🇴',
      'usa': '🇺🇸',
      'united states': '🇺🇸',
      'south korea': '🇰🇷',
      'korea': '🇰🇷',
      'morocco': '🇲🇦',
      'pakistan': '🇵🇰',
      'tajikistan': '🇹🇯',
      'egypt': '🇪🇬',
      'kyrgyzstan': '🇰🇬',
      'japan': '🇯🇵',
      'bahrain': '🇧🇭',
      'france': '🇫🇷',
      'spain': '🇪🇸',
      'united kingdom': '🇬🇧',
      'uk': '🇬🇧',
      'turkey': '🇹🇷',
      'türkiye': '🇹🇷',
      'italy': '🇮🇹',
      'netherlands': '🇳🇱',
      'switzerland': '🇨🇭',
      'germany': '🇩🇪',
      'south africa': '🇿🇦',
      'belgium': '🇧🇪',
      'cambodia': '🇰🇭',
      'philippines': '🇵🇭',
      'canada': '🇨🇦',
      'kazakhstan': '🇰🇿',
      'uganda': '🇺🇬',
      'vietnam': '🇻🇳',
      'zimbabwe': '🇿🇼',
      'sri lanka': '🇱🇰',
      'china': '🇨🇳',
      'greece': '🇬🇷',
      'denmark': '🇩🇰',
      'qatar': '🇶🇦',
      'luxembourg': '🇱🇺',
      'hong kong': '🇭🇰',
      'costa rica': '🇨🇷',
      'poland': '🇵🇱',
      'sweden': '🇸🇪',
      'finland': '🇫🇮',
      'uae': '🇦🇪',
      'united arab emirates': '🇦🇪',
      'zambia': '🇿🇲',
      'ireland': '🇮🇪',
      'saudi arabia': '🇸🇦',
      'saudi': '🇸🇦',
      'oman': '🇴🇲',
      'kuwait': '🇰🇼',
    };

    return countryFlags[normalized] ?? '🌍';
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider);
    final stats = ref.watch(bookingStatsProvider);
    final visaBookings = bookings
        .where((b) => b.serviceType.toLowerCase() == 'visa')
        .toList();

    // Group bookings by destination/country directly from Firestore values
    final Map<String, int> destinationCounts = {};
    for (final b in visaBookings) {
      final dest = b.destination.trim();
      if (dest.isNotEmpty) {
        destinationCounts[dest] = (destinationCounts[dest] ?? 0) + 1;
      }
    }

    // Convert to a list of maps
    final List<Map<String, String>> dynamicDestinations = destinationCounts
        .entries
        .map((entry) {
          final name = entry.key;
          final count = entry.value.toString();
          final flag = _getCountryFlag(name);
          return {'name': name, 'count': count, 'flag': flag};
        })
        .toList();

    // Sort destinations by count descending
    dynamicDestinations.sort((a, b) {
      final countA = int.tryParse(a['count'] ?? '0') ?? 0;
      final countB = int.tryParse(b['count'] ?? '0') ?? 0;
      return countB.compareTo(countA);
    });

    final totalCountries = dynamicDestinations.length;

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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Profile & Greeting
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, Admin 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Overview of OS Travels live dashboard",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      8, // Open staff leaderboard
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Stat Cards Grid (Mobile optimized 3 cards layout: Total Bookings, Active Agents, Global Reach)
                        Column(
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Card 1: Total Bookings (Interactive)
                                  Expanded(
                                    child: _buildInteractiveCard(
                                      context: context,
                                      title: 'Total Bookings',
                                      onTap: () =>
                                          ref
                                                  .read(
                                                    navigationProvider.notifier,
                                                  )
                                                  .state =
                                              2, // Navigate to Records/Search
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${stats.visaCount}',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryTextColor,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                '+102',
                                                style: TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Custom sparkline wave visual
                                          SizedBox(
                                            height: 28,
                                            width: double.infinity,
                                            child: CustomPaint(
                                              painter: SparklineMiniPainter(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Card 2: Total Handlers (Interactive)
                                  Expanded(
                                    child: _buildInteractiveCard(
                                      context: context,
                                      title: 'Active Agents',
                                      onTap: () =>
                                          ref
                                                  .read(
                                                    navigationProvider.notifier,
                                                  )
                                                  .state =
                                              8, // Navigate to Staff
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '7 Handlers',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: primaryTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Small avatar stack
                                          Row(
                                            children: List.generate(4, (index) {
                                              final List<Color> colors = [
                                                Colors.indigo,
                                                Colors.teal,
                                                Colors.amber,
                                                Colors.pink,
                                              ];
                                              final List<String> initials = [
                                                'AH',
                                                'ZA',
                                                'HA',
                                                'BI',
                                              ];
                                              return Align(
                                                widthFactor: 0.7,
                                                child: CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor: const Color(
                                                    0xFF0F172A,
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 11,
                                                    backgroundColor:
                                                        colors[index],
                                                    child: Text(
                                                      initials[index],
                                                      style: const TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Row 2: Global Reach + Universal Search side by side
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Card 3: Global Reach (Interactive)
                                  Expanded(
                                    child: _buildInteractiveCard(
                                      context: context,
                                      title: 'Global Reach',
                                      onTap: () =>
                                          ref
                                                  .read(
                                                    navigationProvider.notifier,
                                                  )
                                                  .state =
                                              2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$totalCountries',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: primaryTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.public,
                                                color: Color(0xFF8B5CF6),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'Countries Active',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: secondaryTextColor,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Card 4: Universal Search (Interactive)
                                  Expanded(
                                    child: _buildInteractiveCard(
                                      context: context,
                                      title: 'Universal Search',
                                      onTap: () =>
                                          ref
                                                  .read(
                                                    navigationProvider.notifier,
                                                  )
                                                  .state =
                                              10,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isDarkMode
                                                    ? const Color(0xFF334155)
                                                    : Colors.grey[300]!,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.search,
                                                  size: 14,
                                                  color: secondaryTextColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    'Find Anything',
                                                    style: TextStyle(
                                                      color: secondaryTextColor,
                                                      fontSize: 11,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Quick Access Section
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Navigate to any section instantly',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: [
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.bar_chart,
                              title: 'Analytics',
                              subtitle: 'Charts & Reports',
                              color: const Color(0xFF8B5CF6),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      1,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.dashboard,
                              title: 'Dashboard',
                              subtitle: 'Records & Stats',
                              color: const Color(0xFF6366F1),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      2,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.flight_takeoff,
                              title: 'Tickets',
                              subtitle: 'Air Ticketing',
                              color: const Color(0xFF0EA5E9),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      3,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.mosque,
                              title: 'Umrah',
                              subtitle: 'Umrah Packages',
                              color: const Color(0xFF10B981),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      4,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.hotel,
                              title: 'Hotels',
                              subtitle: 'Hotel Bookings',
                              color: const Color(0xFFF59E0B),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      5,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.verified_user,
                              title: 'Insurance',
                              subtitle: 'Travel Insurance',
                              color: const Color(0xFFEC4899),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      6,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.campaign,
                              title: 'Marketing',
                              subtitle: 'Campaigns & Leads',
                              color: const Color(0xFFEF4444),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      7,
                            ),
                            _buildQuickAccessCard(
                              context: context,
                              icon: Icons.people_alt,
                              title: 'Employees',
                              subtitle: 'Staff & Leaderboard',
                              color: const Color(0xFF14B8A6),
                              onTap: () =>
                                  ref.read(navigationProvider.notifier).state =
                                      8,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Active Destinations Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Destinations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            if (!_isExpanded)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Country cards in 2-column grid (same as other stat cards)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double width = constraints.maxWidth;
                            int crossAxisCount = 2;
                            if (width >= 900) {
                              crossAxisCount = 4;
                            } else if (width >= 600) {
                              crossAxisCount = 3;
                            }
                            final int displayCount = _isExpanded
                                ? dynamicDestinations.length
                                : dynamicDestinations.length.clamp(0, 6);
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayCount,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.8,
                                  ),
                              itemBuilder: (context, index) {
                                final dest = dynamicDestinations[index];
                                return _buildGridDestinationCard(
                                  context,
                                  dest['name']!,
                                  dest['count']!,
                                  dest['flag']!,
                                );
                              },
                            );
                          },
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = false;
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_upward,
                                size: 14,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Show Less',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0x990F172A),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                    color: Color(0x33FFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (!_isExpanded) ...[
                          const SizedBox(height: 4),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = true;
                                });
                              },
                              child: const Text(
                                'View All Countries →',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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

  Widget _buildInteractiveCard({
    required BuildContext context,
    required String title,
    required Widget child,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDarkMode
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondaryLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildGridDestinationCard(
    BuildContext context,
    String country,
    String count,
    String flag,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode ? const Color(0x15FFFFFF) : const Color(0x1F000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  country,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SparklineMiniPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x3310B981), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(0, h * 0.7);
    path.cubicTo(w * 0.25, h * 0.85, w * 0.35, h * 0.15, w * 0.6, h * 0.45);
    path.cubicTo(w * 0.8, h * 0.7, w * 0.9, h * 0.1, w, h * 0.3);

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
