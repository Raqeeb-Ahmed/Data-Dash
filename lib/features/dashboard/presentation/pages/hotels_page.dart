import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/hotels_provider.dart';
import '../providers/bookings_provider.dart';

class HotelsPage extends ConsumerStatefulWidget {
  const HotelsPage({super.key});

  @override
  ConsumerState<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends ConsumerState<HotelsPage> {
  int _itemsToShow = 10;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(hotelFilterProvider);
    final filteredList = ref.watch(filteredHotelBookingsProvider);
    final stats = ref.watch(hotelStatsProvider);

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
        ? const Color(0x18FFFFFF)
        : const Color(0x1F000000);

    final displayedList = filteredList.take(_itemsToShow).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable area
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    children: [
                    // Header Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.hotel_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hotel Bookings Admin Dashboard 🏨',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              Text(
                                'Worldwide room reservations & lodgings',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Metrics row
                    _buildMetricsGrid(isDarkMode, stats),
                    const SizedBox(height: 14),

                    // Search & Filters card
                    _buildFiltersSection(
                      context,
                      cardBg,
                      borderColor,
                      primaryTextColor,
                      secondaryTextColor,
                      isDarkMode,
                      filter,
                    ),
                    const SizedBox(height: 14),

                    // Charts Section (Bar chart & Donut Chart stacked)
                    _buildChartsSection(
                      cardBg,
                      borderColor,
                      primaryTextColor,
                      secondaryTextColor,
                      isDarkMode,
                      filteredList,
                    ),
                    const SizedBox(height: 14),

                    // Bookings table title & list count
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Booking Details (${filteredList.length})',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              Text(
                                'Showing ${displayedList.length} of ${filteredList.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (filteredList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'No hotel bookings found matching filters.',
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...displayedList.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final booking = entry.value;
                              return _buildBookingMobileCard(
                                context,
                                booking,
                                idx,
                                isDarkMode,
                                primaryTextColor,
                                secondaryTextColor,
                                borderColor,
                              );
                            }),

                          // Load More Button
                          if (filteredList.length > _itemsToShow)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _itemsToShow += 10;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Load More',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Metrics Grid (3 elegant horizontal cards) ──
  Widget _buildMetricsGrid(bool isDarkMode, HotelStats stats) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            title: 'Total Received',
            amount: stats.totalReceived,
            gradient: const [Color(0xFF10B981), Color(0xFF059669)],
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            title: 'Total Payable',
            amount: stats.totalPayable,
            gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _metricCard(
            title: 'Total Profit',
            amount: stats.totalProfit,
            gradient: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required double amount,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 10, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PKR ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Filters & Search ──
  Widget _buildFiltersSection(
    BuildContext context,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    HotelFilter filter,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0x33000000)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.search, size: 15, color: secondaryTextColor),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 12, color: primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or hotel...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                      border: InputBorder.none,
                      filled: false,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      ref
                          .read(hotelFilterProvider.notifier)
                          .updateSearchQuery(v);
                      setState(() {
                        _itemsToShow = 10;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Range Filter Buttons (Horizontal Scrolling)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Today', 'Yesterday', 'This Week', 'This Month']
                  .map((filterName) {
                    final isSelected = filter.selectedDateFilter == filterName;
                    return GestureDetector(
                      onTap: () {
                        ref
                            .read(hotelFilterProvider.notifier)
                            .updateDateFilter(filterName);
                        ref
                            .read(hotelFilterProvider.notifier)
                            .updateCustomDateRange(null, null);
                        setState(() {
                          _itemsToShow = 10;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDarkMode
                                    ? const Color(0xFF1E293B)
                                    : Colors.white),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : borderColor,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          filterName,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : primaryTextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Custom Date Range Picker
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectCustomDate(context, isFrom: true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filter.fromDate == null
                              ? 'Start Date'
                              : _formatDate(filter.fromDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'to',
                style: TextStyle(fontSize: 11, color: secondaryTextColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectCustomDate(context, isFrom: false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E293B)
                          : Colors.white,
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filter.toDate == null
                              ? 'End Date'
                              : _formatDate(filter.toDate!),
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (filter.fromDate != null || filter.toDate != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(hotelFilterProvider.notifier)
                        .updateCustomDateRange(null, null);
                    ref
                        .read(hotelFilterProvider.notifier)
                        .updateDateFilter('All');
                    setState(() {
                      _itemsToShow = 10;
                    });
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomDate(
    BuildContext context, {
    required bool isFrom,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF2563EB),
            surface: Color(0xFF0F172A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final activeFilter = ref.read(hotelFilterProvider);
      final from = isFrom ? picked : activeFilter.fromDate;
      final to = isFrom ? activeFilter.toDate : picked;
      ref.read(hotelFilterProvider.notifier).updateCustomDateRange(from, to);
      ref.read(hotelFilterProvider.notifier).updateDateFilter('Custom');
      setState(() {
        _itemsToShow = 10;
      });
    }
  }

  // ── Charts Section ──
  Widget _buildChartsSection(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    List<HotelBookingModel> filteredList,
  ) {
    final monthlyData = _computeMonthlyFinancials(filteredList);
    final monthsKeys = monthlyData.keys.toList();
    final propertyData = _computeTopProperties(filteredList);
    final topPropertiesList = propertyData.entries.toList();

    return Column(
      children: [
        // 1. Monthly Financials (Bar Chart)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Financials',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                          FlLine(color: borderColor, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i >= 0 && i < monthsKeys.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  monthsKeys[i].split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(monthsKeys.length, (idx) {
                      final m = monthsKeys[idx];
                      final d = monthlyData[m]!;
                      double rec = d['received']! / 10000;
                      double pay = d['payable']! / 10000;
                      double prof = d['profit']! / 10000;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: pay,
                            color: const Color(0xFFEF4444),
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                          BarChartRodData(
                            toY: prof,
                            color: const Color(0xFF10B981),
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                          BarChartRodData(
                            toY: rec,
                            color: const Color(0xFF2563EB),
                            width: 6,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendIndicator('Payable', const Color(0xFFEF4444)),
                  const SizedBox(width: 14),
                  _legendIndicator('Profit', const Color(0xFF10B981)),
                  const SizedBox(width: 14),
                  _legendIndicator('Received', const Color(0xFF2563EB)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Top Properties (Donut Chart)
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Properties',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 14),
              if (topPropertiesList.isEmpty)
                const SizedBox(
                  height: 120,
                  child: Center(child: Text('No property data available')),
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 110,
                      width: 110,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          sections: List.generate(
                            topPropertiesList.length.clamp(0, 5),
                            (idx) {
                              final entry = topPropertiesList[idx];
                              final color = _getPieColor(idx);
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                color: color,
                                radius: 12,
                                showTitle: false,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          topPropertiesList.length.clamp(0, 5),
                          (idx) {
                            final entry = topPropertiesList[idx];
                            final totalBookings = filteredList.length;
                            final pct = totalBookings > 0
                                ? (entry.value / totalBookings * 100)
                                      .toStringAsFixed(0)
                                : '0';
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getPieColor(idx),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: primaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$pct%',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getPieColor(int index) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    return colors[index % colors.length];
  }

  Widget _legendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ],
    );
  }

  // ── Booking Mobile Card Row Widget ──
  Widget _buildBookingMobileCard(
    BuildContext context,
    HotelBookingModel b,
    int serialNo,
    bool isDarkMode,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0x330F172A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: S.No + ID + Actions
          Row(
            children: [
              Text(
                '#$serialNo',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x222563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b.id,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              // Action Buttons: View, Edit, Delete
              GestureDetector(
                onTap: () => _openViewModal(context, b),
                child: _actionButton(
                  Icons.visibility_outlined,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _openEditModal(context, b),
                child: _actionButton(
                  Icons.edit_outlined,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _confirmDeleteDialog(context, b),
                child: _actionButton(
                  Icons.delete_outline,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hotel name & Dates
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.hotel_outlined,
                size: 13,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b.hotelName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Client & Nights info
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: secondaryTextColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  b.clientName,
                  style: TextStyle(
                    fontSize: 11,
                    color: primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0x22FFFFFF)
                      : const Color(0x0D000000),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${b.nights} N • ${b.rooms} R',
                  style: TextStyle(
                    fontSize: 9,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Financial rows (Received, Payable, Profit)
          const Divider(height: 10, thickness: 0.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _financeCell(
                'Received',
                b.receivedAmount,
                const Color(0xFF10B981),
                secondaryTextColor,
              ),
              _financeCell(
                'Payable',
                b.payableAmount,
                const Color(0xFFEF4444),
                secondaryTextColor,
              ),
              _financeCell(
                'Profit',
                b.profit,
                const Color(0xFF2563EB),
                secondaryTextColor,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Employee Email and Checkin Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.mail_outline, size: 11, color: secondaryTextColor),
                  const SizedBox(width: 4),
                  Text(
                    b.employeeEmail,
                    style: TextStyle(fontSize: 9, color: secondaryTextColor),
                  ),
                ],
              ),
              Text(
                '${_formatDate(b.arrivalDate)} to ${_formatDate(b.departureDate)}',
                style: TextStyle(
                  fontSize: 9,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }

  Widget _financeCell(String label, double val, Color color, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: labelColor)),
        Text(
          'PKR ${val.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Action Dialogs/Modals ──

  // 1. VIEW DIALOG
  void _openViewModal(BuildContext context, HotelBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: modalBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          title: const Row(
            children: [
              Icon(Icons.hotel, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Booking details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _viewDetailRow(
                  'Booking Ref ID',
                  b.id,
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Hotel Name',
                  b.hotelName,
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Client Name',
                  b.clientName,
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Arrival Date',
                  _formatDate(b.arrivalDate),
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Departure Date',
                  _formatDate(b.departureDate),
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Nights',
                  '${b.nights} Nights',
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Rooms',
                  '${b.rooms} Rooms',
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Received Amount',
                  'PKR ${b.receivedAmount.toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Payable Amount',
                  'PKR ${b.payableAmount.toStringAsFixed(2)}',
                  const Color(0xFFEF4444),
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Net Profit',
                  'PKR ${b.profit.toStringAsFixed(2)}',
                  const Color(0xFF2563EB),
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Handler Employee',
                  b.employeeEmail,
                  primaryTextColor,
                  secondaryTextColor,
                ),
                _viewDetailRow(
                  'Status',
                  b.status,
                  const Color(0xFF10B981),
                  secondaryTextColor,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _viewDetailRow(
    String label,
    String val,
    Color valColor,
    Color labelColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: labelColor)),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valColor,
            ),
          ),
          const Divider(height: 8, thickness: 0.2),
        ],
      ),
    );
  }

  // 2. EDIT DIALOG
  void _openEditModal(BuildContext context, HotelBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final hotelCtrl = TextEditingController(text: b.hotelName);
    final clientCtrl = TextEditingController(text: b.clientName);
    final receivedCtrl = TextEditingController(
      text: b.receivedAmount.toString(),
    );
    final payableCtrl = TextEditingController(text: b.payableAmount.toString());
    final emailCtrl = TextEditingController(text: b.employeeEmail);
    final nightsCtrl = TextEditingController(text: b.nights.toString());
    final roomsCtrl = TextEditingController(text: b.rooms.toString());

    DateTime arrival = b.arrivalDate;
    DateTime departure = b.departureDate;

    double computedProfit = b.profit;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void updateProfit() {
              final rec = double.tryParse(receivedCtrl.text) ?? 0.0;
              final pay = double.tryParse(payableCtrl.text) ?? 0.0;
              setModalState(() {
                computedProfit = rec - pay;
              });
            }

            receivedCtrl.addListener(updateProfit);
            payableCtrl.addListener(updateProfit);

            return AlertDialog(
              backgroundColor: modalBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.edit, color: const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Booking',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField('Hotel Name', hotelCtrl, isDarkMode),
                    _inputField('Client Name', clientCtrl, isDarkMode),
                    _inputField('Employee Email', emailCtrl, isDarkMode),

                    // Date pickers row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final dt = await showDatePicker(
                                  context: context,
                                  initialDate: arrival,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (dt != null) {
                                  setModalState(() => arrival = dt);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                'Checkin: ${_formatDate(arrival)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final dt = await showDatePicker(
                                  context: context,
                                  initialDate: departure,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (dt != null) {
                                  setModalState(() => departure = dt);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              child: Text(
                                'Checkout: ${_formatDate(departure)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            'Nights',
                            nightsCtrl,
                            isDarkMode,
                            isNum: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _inputField(
                            'Rooms',
                            roomsCtrl,
                            isDarkMode,
                            isNum: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            'Received (PKR)',
                            receivedCtrl,
                            isDarkMode,
                            isNum: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _inputField(
                            'Payable (PKR)',
                            payableCtrl,
                            isDarkMode,
                            isNum: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Computed profit indicator
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x1F2563EB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x332563EB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Computed Profit:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PKR ${computedProfit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = b.copyWith(
                      hotelName: hotelCtrl.text,
                      clientName: clientCtrl.text,
                      employeeEmail: emailCtrl.text,
                      arrivalDate: arrival,
                      departureDate: departure,
                      nights: int.tryParse(nightsCtrl.text) ?? b.nights,
                      rooms: int.tryParse(roomsCtrl.text) ?? b.rooms,
                      receivedAmount:
                          double.tryParse(receivedCtrl.text) ??
                          b.receivedAmount,
                      payableAmount:
                          double.tryParse(payableCtrl.text) ?? b.payableAmount,
                      profit: computedProfit,
                    );
                    ref
                        .read(hotelBookingsProvider.notifier)
                        .updateBooking(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking updated successfully!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _inputField(
    String label,
    TextEditingController ctrl,
    bool isDarkMode, {
    bool isNum = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          isDense: true,
          contentPadding: const EdgeInsets.all(10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // 3. DELETE DIALOG
  void _confirmDeleteDialog(BuildContext context, HotelBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: modalBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Confirm Delete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this booking for ${b.clientName} at ${b.hotelName}?',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(hotelBookingsProvider.notifier).deleteBooking(b.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper date formatting
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // Group bookings by month to draw in charts
  Map<String, Map<String, double>> _computeMonthlyFinancials(
    List<HotelBookingModel> bookingsList,
  ) {
    final months = ['Oct 2025', 'Dec 2025', 'Feb 2026', 'Apr 2026', 'Jul 2026'];
    Map<String, Map<String, double>> data = {};
    for (var m in months) {
      data[m] = {'received': 0.0, 'payable': 0.0, 'profit': 0.0};
    }

    for (var b in bookingsList) {
      String mKey = '';
      final month = b.arrivalDate.month;
      final year = b.arrivalDate.year;

      if (year == 2025 && month == 10) {
        mKey = 'Oct 2025';
      } else if (year == 2025 && month == 12) {
        mKey = 'Dec 2025';
      } else if (year == 2026 && month == 2) {
        mKey = 'Feb 2026';
      } else if (year == 2026 && month == 4) {
        mKey = 'Apr 2026';
      } else if (year == 2026 && month == 7) {
        mKey = 'Jul 2026';
      } else {
        mKey = 'Jul 2026'; // fallback
      }

      if (data.containsKey(mKey)) {
        data[mKey]!['received'] = data[mKey]!['received']! + b.receivedAmount;
        data[mKey]!['payable'] = data[mKey]!['payable']! + b.payableAmount;
        data[mKey]!['profit'] = data[mKey]!['profit']! + b.profit;
      }
    }
    return data;
  }

  // Count bookings by property to render donut chart
  Map<String, int> _computeTopProperties(List<HotelBookingModel> bookingsList) {
    Map<String, int> counts = {};
    for (var b in bookingsList) {
      final parts = b.hotelName.split(' ');
      final key = parts.length > 2 ? '${parts[0]} ${parts[1]}' : b.hotelName;
      final name = key.toUpperCase();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final sortedEntries = counts.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));
    return Map.fromEntries(sortedEntries);
  }
}
