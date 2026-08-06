import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/navigation_provider.dart';

class HomeDashboardPage extends ConsumerStatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  ConsumerState<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends ConsumerState<HomeDashboardPage> {
  bool _isExpanded = false;

  final List<Map<String, String>> _allDestinations = const [
    {'name': 'Malaysia', 'count': '1391', 'flag': '🇲🇾'},
    {'name': 'THAILAND', 'count': '15', 'flag': '🇹🇭'},
    {'name': 'Azerbaijan', 'count': '52', 'flag': '🇦🇿'},
    {'name': 'Indonesia', 'count': '241', 'flag': '🇮🇩'},
    {'name': 'Singapore', 'count': '163', 'flag': '🇸🇬'},
    {'name': 'Uzbekistan', 'count': '31', 'flag': '🇺🇿'},
    {'name': 'Nepal', 'count': '53', 'flag': '🇳🇵'},
    {'name': 'Thailand', 'count': '673', 'flag': '🇹🇭'},
    {'name': 'Austria', 'count': '6', 'flag': '🇦🇹'},
    {'name': 'Hungary', 'count': '17', 'flag': '🇭🇺'},
    {'name': 'Norway', 'count': '8', 'flag': '🇳🇴'},
    {'name': 'USA', 'count': '50', 'flag': '🇺🇸'},
    {'name': 'South Korea', 'count': '7', 'flag': '🇰🇷'},
    {'name': 'Morocco', 'count': '5', 'flag': '🇲🇦'},
    {'name': 'Pakistan', 'count': '11', 'flag': '🇵🇰'},
    {'name': 'Tajikistan', 'count': '9', 'flag': '🇹🇯'},
    {'name': 'Egypt', 'count': '9', 'flag': '🇪🇬'},
    {'name': 'KYRGYZSTAN', 'count': '2', 'flag': '🇰🇬'},
    {'name': 'Japan', 'count': '59', 'flag': '🇯🇵'},
    {'name': 'Bahrain', 'count': '27', 'flag': '🇧🇭'},
    {'name': 'France', 'count': '18', 'flag': '🇫🇷'},
    {'name': 'Spain', 'count': '27', 'flag': '🇪🇸'},
    {'name': 'United Kingdom', 'count': '22', 'flag': '🇬🇧'},
    {'name': 'Turkey', 'count': '18', 'flag': '🇹🇷'},
    {'name': 'Italy', 'count': '13', 'flag': '🇮🇹'},
    {'name': 'Netherlands', 'count': '22', 'flag': '🇳🇱'},
    {'name': 'Switzerland', 'count': '5', 'flag': '🇨🇭'},
    {'name': 'Germany', 'count': '4', 'flag': '🇩🇪'},
    {'name': 'South Africa', 'count': '7', 'flag': '🇿🇦'},
    {'name': 'Belgium', 'count': '11', 'flag': '🇧🇪'},
    {'name': 'SWITZERLAND', 'count': '1', 'flag': '🇨🇭'},
    {'name': 'Cambodia', 'count': '6', 'flag': '🇰🇭'},
    {'name': 'Philippines', 'count': '2', 'flag': '🇵🇭'},
    {'name': 'Canada', 'count': '4', 'flag': '🇨🇦'},
    {'name': 'Kazakhstan', 'count': '4', 'flag': '🇰🇿'},
    {'name': 'Uganda', 'count': '3', 'flag': '🇺🇬'},
    {'name': 'Vietnam', 'count': '5', 'flag': '🇻🇳'},
    {'name': 'Zimbabwe', 'count': '2', 'flag': '🇿🇼'},
    {'name': 'Sri Lanka', 'count': '27', 'flag': '🇱🇰'},
    {'name': 'Belgium', 'count': '2', 'flag': '🇧🇪'},
    {'name': 'China', 'count': '4', 'flag': '🇨🇳'},
    {'name': 'Greece', 'count': '15', 'flag': '🇬🇷'},
    {'name': 'Hungary', 'count': '1', 'flag': '🇭🇺'},
    {'name': 'Denmark', 'count': '2', 'flag': '🇩🇰'},
    {'name': 'Qatar', 'count': '8', 'flag': '🇶🇦'},
    {'name': 'LUXEMBOURG', 'count': '1', 'flag': '🇱🇺'},
    {'name': 'Hong Kong', 'count': '2', 'flag': '🇭🇰'},
    {'name': 'Costa Rica', 'count': '1', 'flag': '🇨🇷'},
    {'name': 'Poland', 'count': '8', 'flag': '🇵🇱'},
    {'name': 'Sweden', 'count': '17', 'flag': '🇸🇪'},
    {'name': 'Finland', 'count': '2', 'flag': '🇫🇮'},
    {'name': 'UAE', 'count': '10', 'flag': '🇦🇪'},
    {'name': 'Zambia', 'count': '2', 'flag': '🇿🇲'},
    {'name': 'Ireland', 'count': '2', 'flag': '🇮🇪'},
  ];

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
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

                      // Stat Cards Grid (Mobile optimized 2 columns, beautiful glowing glassmorphic cards)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.25,
                        children: [
                          // Card 1: Total Bookings (Interactive)
                          _buildInteractiveCard(
                            context: context,
                            title: 'Total Bookings',
                            onTap: () =>
                                ref.read(navigationProvider.notifier).state =
                                    2, // Navigate to Records/Search
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '3,040',
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
                                const Spacer(),
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

                          // Card 2: Total Handlers (Interactive)
                          _buildInteractiveCard(
                            context: context,
                            title: 'Active Agents',
                            onTap: () =>
                                ref.read(navigationProvider.notifier).state =
                                    8, // Navigate to Staff
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '7 Handlers',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const Spacer(),

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
                                          backgroundColor: colors[index],
                                          child: Text(
                                            initials[index],
                                            style: const TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
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

                          // Card 3: Global Reach (Interactive)
                          _buildInteractiveCard(
                            context: context,
                            title: 'Global Reach',
                            onTap: () =>
                                ref.read(navigationProvider.notifier).state =
                                    2, // Navigate to Destinations/Records
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '53 Countries',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.public,
                                      color: Color(0xFF8B5CF6),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Activations',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Card 4: Net Profit (Interactive)
                          _buildInteractiveCard(
                            context: context,
                            title: 'Net Profit',
                            onTap: () =>
                                ref.read(navigationProvider.notifier).state =
                                    1, // Navigate to Analytics
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '25.8M PKR',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.trending_up,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '28.9% Margin',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Universal Search Interactive Card
                      GestureDetector(
                        onTap: () =>
                            ref.read(navigationProvider.notifier).state =
                                10, // Navigate to Search/Records tab
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Universal Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find customer bookings, passports, PNR instantly.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1E293B)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? const Color(0xFF334155)
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 16,
                                      color: secondaryTextColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Find Anything',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

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
                      if (!_isExpanded)
                        SizedBox(
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildDestinationCard(
                                context,
                                'Uzbekistan',
                                '31',
                                '🇺🇿',
                              ),
                              _buildDestinationCard(
                                context,
                                'Malaysia',
                                '1391',
                                '🇲🇾',
                              ),
                              _buildDestinationCard(
                                context,
                                'Thailand',
                                '673',
                                '🇹🇭',
                              ),
                              _buildDestinationCard(
                                context,
                                'Indonesia',
                                '241',
                                '🇮🇩',
                              ),
                              _buildDestinationCard(
                                context,
                                'Singapore',
                                '163',
                                '🇸🇬',
                              ),
                            ],
                          ),
                        )
                      else ...[
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double width = constraints.maxWidth;
                            int crossAxisCount = 5;
                            if (width < 600) {
                              crossAxisCount = 2;
                            } else if (width < 900) {
                              crossAxisCount = 3;
                            } else if (width < 1200) {
                              crossAxisCount = 4;
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _allDestinations.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1.6,
                                  ),
                              itemBuilder: (context, index) {
                                final dest = _allDestinations[index];
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
                        const SizedBox(height: 24),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String country,
    String count,
    String flag,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDarkMode ? const Color(0x15FFFFFF) : const Color(0x1F000000),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            country,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          Text(
            '$count Bookings',
            style: TextStyle(
              fontSize: 11,
              color: isDarkMode
                  ? const Color(0xFF94A3B8)
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
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
