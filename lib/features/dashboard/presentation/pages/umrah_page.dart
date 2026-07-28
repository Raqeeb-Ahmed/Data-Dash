import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/umrah_provider.dart';

class UmrahPage extends ConsumerStatefulWidget {
  const UmrahPage({super.key});

  @override
  ConsumerState<UmrahPage> createState() => _UmrahPageState();
}

class _UmrahPageState extends ConsumerState<UmrahPage> {
  int _currentPage = 0;
  final int _perPage = 10;
  late final TextEditingController _searchController;

  final List<String> _quickDateFilters = [
    'All Time',
    'Today',
    'Yesterday',
    'This Month',
  ];

  final List<String> _vendors = [
    'All Vendors',
    'MEFZAB AIR (CST)',
    'MEEZAB AIR (CST)',
    'PAK HARMAIN TRAVELS',
  ];

  final List<String> _employees = [
    'All Employees',
    'hammad@os.com',
    'sameer@os.com',
    'noorul.fhade@os.com',
    'muqtaba@os.com',
  ];

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
    final filter = ref.watch(umrahFilterProvider);
    final filteredList = ref.watch(filteredUmrahBookingsProvider);
    final stats = ref.watch(umrahStatsProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final cardBg = isDarkMode ? const Color(0x770B0F19) : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDarkMode ? const Color(0x18FFFFFF) : const Color(0x1F000000);

    // Pagination calculations
    final int totalPages = (filteredList.length / _perPage).ceil();
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }
    final int startIdx = _currentPage * _perPage;
    final int endIdx = (startIdx + _perPage).clamp(0, filteredList.length);
    final displayedList = filteredList.isEmpty ? <UmrahBookingModel>[] : filteredList.sublist(startIdx, endIdx);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  children: [
                    // ──── HEADER ────
                    _buildHeader(primaryTextColor, secondaryTextColor, filter, isDarkMode, cardBg, borderColor),
                    const SizedBox(height: 14),

                    // ──── STATS CARDS (TOTAL RECEIVED, PAYABLE, PROFIT, BOOKINGS) ────
                    _buildStatsGrid(isDarkMode, stats),
                    const SizedBox(height: 14),

                    // ──── CHARTS ROW (MONTHLY FINANCIALS & TOP VENDORS) ────
                    _buildChartsSection(cardBg, borderColor, primaryTextColor, secondaryTextColor, isDarkMode, filteredList),
                    const SizedBox(height: 14),

                    // ──── SEARCH BAR & DROP FILTER DROPDOWNS ────
                    _buildFilterSection(cardBg, borderColor, primaryTextColor, secondaryTextColor, isDarkMode, filter),
                    const SizedBox(height: 14),

                    // ──── TABLE ────
                    _buildTableCard(
                      context,
                      cardBg,
                      borderColor,
                      primaryTextColor,
                      secondaryTextColor,
                      isDarkMode,
                      displayedList,
                      filteredList.length,
                      totalPages,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Widget ──
  Widget _buildHeader(
    Color primaryColor,
    Color secondaryColor,
    UmrahFilter filter,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.mosque_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Umrah Bookings Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    Text(
                      'Pilgrim lists, transport, vendor payables & profit analytics',
                      style: TextStyle(fontSize: 11, color: secondaryColor),
                    ),
                  ],
                ),
              ],
            ),

            // Quick date filter dropdown
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: filter.selectedDateFilter,
                  dropdownColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                  style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                  icon: Icon(Icons.keyboard_arrow_down, size: 14, color: secondaryColor),
                  items: _quickDateFilters
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(umrahFilterProvider.notifier).updateDateFilter(v);
                      ref.read(umrahFilterProvider.notifier).updateCustomDateRange(null, null);
                      setState(() {
                        _currentPage = 0;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Custom Date Range picker
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 14, color: secondaryColor),
              const SizedBox(width: 6),
              Text(
                'Custom Range:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectCustomDate(isFrom: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            filter.fromDate == null ? 'dd/mm/yyyy' : _formatDate(filter.fromDate!),
                            style: TextStyle(fontSize: 11, color: secondaryColor),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('to', style: TextStyle(fontSize: 11)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectCustomDate(isFrom: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            filter.toDate == null ? 'dd/mm/yyyy' : _formatDate(filter.toDate!),
                            style: TextStyle(fontSize: 11, color: secondaryColor),
                          ),
                        ),
                      ),
                    ),
                    if (filter.fromDate != null || filter.toDate != null) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          ref.read(umrahFilterProvider.notifier).updateCustomDateRange(null, null);
                          ref.read(umrahFilterProvider.notifier).updateDateFilter('All Time');
                        },
                        child: const Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Select Custom Date picker ──
  Future<void> _selectCustomDate({required bool isFrom}) async {
    final activeFilter = ref.read(umrahFilterProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF59E0B),
            surface: Color(0xFF0F172A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final from = isFrom ? picked : activeFilter.fromDate;
      final to = isFrom ? activeFilter.toDate : picked;
      ref.read(umrahFilterProvider.notifier).updateCustomDateRange(from, to);
      ref.read(umrahFilterProvider.notifier).updateDateFilter('Custom');
      setState(() {
        _currentPage = 0;
      });
    }
  }

  // ── Metrics Row (TOTAL RECEIVED, PAYABLE, PROFIT, BOOKINGS) ──
  Widget _buildStatsGrid(bool isDarkMode, UmrahStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.1,
      children: [
        _statCard(
          title: 'TOTAL RECEIVED',
          value: 'PKR ${_formatCurrency(stats.totalReceived)}',
          color: const Color(0xFF10B981),
          icon: Icons.account_balance_wallet,
          isDarkMode: isDarkMode,
          bgGradient: const [Color(0xFF065F46), Color(0xFF047857)],
        ),
        _statCard(
          title: 'TOTAL PAYABLE',
          value: 'PKR ${_formatCurrency(stats.totalPayable)}',
          color: const Color(0xFFEF4444),
          icon: Icons.payment,
          isDarkMode: isDarkMode,
          bgGradient: const [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
        _statCard(
          title: 'PROFIT',
          value: 'PKR ${_formatCurrency(stats.totalProfit)}',
          color: const Color(0xFFF59E0B),
          icon: Icons.trending_up,
          isDarkMode: isDarkMode,
          bgGradient: const [Color(0xFF78350F), Color(0xFF92400E)],
        ),
        _statCard(
          title: 'BOOKINGS',
          value: '${stats.totalBookingsCount}',
          color: const Color(0xFF8B5CF6),
          icon: Icons.people_outline,
          isDarkMode: isDarkMode,
          bgGradient: const [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required bool isDarkMode,
    required List<Color> bgGradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 8, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Charts Row ──
  Widget _buildChartsSection(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    List<UmrahBookingModel> filteredList,
  ) {
    final monthlyData = _computeMonthlyFinancials(filteredList);
    final monthsKeys = monthlyData.keys.toList();
    final vendorData = _computeVendorData(filteredList);
    final vendorList = vendorData.entries.toList();

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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: borderColor, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                  monthsKeys[i],
                                  style: TextStyle(fontSize: 9, color: secondaryTextColor),
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
                      // Scale down by 10,000 for representation
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
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                          BarChartRodData(
                            toY: prof,
                            color: const Color(0xFF10B981),
                            width: 6,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                          BarChartRodData(
                            toY: rec,
                            color: const Color(0xFF2563EB),
                            width: 6,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
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
                  _legendDot('Payable', const Color(0xFFEF4444)),
                  const SizedBox(width: 14),
                  _legendDot('Profit', const Color(0xFF10B981)),
                  const SizedBox(width: 14),
                  _legendDot('Received', const Color(0xFF2563EB)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Top Vendors (Donut Chart)
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
                'Top Vendors',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              const SizedBox(height: 14),
              if (vendorList.isEmpty)
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('No vendor data available')),
                )
              else
                Row(
                  children: [
                    SizedBox(
                      height: 110,
                      width: 110,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 24,
                          sections: List.generate(
                            vendorList.length.clamp(0, 5),
                            (idx) {
                              final entry = vendorList[idx];
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                color: _getVendorColor(idx),
                                radius: 12,
                                showTitle: false,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          vendorList.length.clamp(0, 5),
                          (idx) {
                            final entry = vendorList[idx];
                            final pct = filteredList.isEmpty
                                ? '0'
                                : (entry.value / filteredList.length * 100).toStringAsFixed(0);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: _getVendorColor(idx), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: TextStyle(fontSize: 9, color: primaryTextColor, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$pct%',
                                    style: TextStyle(fontSize: 9, color: secondaryTextColor),
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
          ),
        ),
      ],
    );
  }

  Color _getVendorColor(int idx) {
    const colors = [
      Color(0xFFF59E0B),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
    ];
    return colors[idx % colors.length];
  }

  Widget _legendDot(String label, Color color) {
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

  // ── Filters Section ──
  Widget _buildFilterSection(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    UmrahFilter filter,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Search box
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0x33000000) : Colors.grey.withValues(alpha: 0.1),
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
                      hintText: 'Search by name, passport, phone...',
                      hintStyle: TextStyle(fontSize: 12, color: secondaryTextColor),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) {
                      ref.read(umrahFilterProvider.notifier).updateSearchQuery(v);
                      setState(() {
                        _currentPage = 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Dropdowns
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filter.selectedVendor,
                      isExpanded: true,
                      dropdownColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      style: TextStyle(fontSize: 11, color: primaryTextColor),
                      icon: Icon(Icons.keyboard_arrow_down, size: 14, color: secondaryTextColor),
                      items: _vendors
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(umrahFilterProvider.notifier).updateVendor(v);
                          setState(() {
                            _currentPage = 0;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: filter.selectedEmployee,
                      isExpanded: true,
                      dropdownColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
                      style: TextStyle(fontSize: 11, color: primaryTextColor),
                      icon: Icon(Icons.keyboard_arrow_down, size: 14, color: secondaryTextColor),
                      items: _employees
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(umrahFilterProvider.notifier).updateEmployee(v);
                          setState(() {
                            _currentPage = 0;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Table / Records Card ──
  Widget _buildTableCard(
    BuildContext context,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    List<UmrahBookingModel> displayedList,
    int totalCount,
    int totalPages,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Umrah Bookings (${displayedList.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTextColor),
              ),
              Text(
                'Total $totalCount records',
                style: TextStyle(fontSize: 10, color: secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (displayedList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No bookings found matching filters.',
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
            )
          else ...[
            ...displayedList.asMap().entries.map((entry) {
              final idx = startIdx() + entry.key + 1;
              final b = entry.value;
              return _buildBookingRow(context, b, idx, isDarkMode, primaryTextColor, secondaryTextColor, borderColor);
            }),

            // Pagination Controls
            if (totalPages > 1) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Previous', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                  Text(
                    'Page ${_currentPage + 1} of $totalPages',
                    style: TextStyle(fontSize: 11, color: secondaryTextColor, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  int startIdx() {
    return _currentPage * _perPage;
  }

  // ── Record Row Widget ──
  Widget _buildBookingRow(
    BuildContext context,
    UmrahBookingModel b,
    int idx,
    bool isDarkMode,
    Color primaryColor,
    Color secondaryColor,
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
          // Header: Index + ID + Actions
          Row(
            children: [
              Text('#$idx', style: TextStyle(fontSize: 10, color: secondaryColor, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x22F59E0B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b.id,
                  style: const TextStyle(fontSize: 9, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              // Actions: See, Edit, Delete
              GestureDetector(
                onTap: () => _openViewModal(context, b),
                child: _actionIcon(Icons.visibility_outlined, const Color(0xFF0EA5E9)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _openEditModal(context, b),
                child: _actionIcon(Icons.edit_outlined, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _confirmDeleteDialog(context, b),
                child: _actionIcon(Icons.delete_outline, const Color(0xFFEF4444)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Name, Passport & Phone
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: secondaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.customerName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                ),
              ),
              Text(
                'Passport: ${b.passportNumber}',
                style: TextStyle(fontSize: 10, color: secondaryColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Phone & Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 11, color: secondaryColor),
                  const SizedBox(width: 4),
                  Text(b.customerPhone, style: TextStyle(fontSize: 10, color: secondaryColor)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 11, color: secondaryColor),
                  const SizedBox(width: 4),
                  Text(b.vendorName, style: TextStyle(fontSize: 10, color: secondaryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Employee Handler & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined, size: 11, color: secondaryColor),
                  const SizedBox(width: 4),
                  Text(b.employeeEmail, style: TextStyle(fontSize: 9, color: secondaryColor)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 10, color: secondaryColor),
                  const SizedBox(width: 4),
                  Text(_formatDate(b.dateCreated), style: TextStyle(fontSize: 9, color: secondaryColor)),
                ],
              ),
            ],
          ),
          const Divider(height: 12, thickness: 0.3),

          // Financial details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _finCell('Payable', b.payableAmount, const Color(0xFFEF4444), secondaryColor),
              _finCell('Received', b.receivedAmount, const Color(0xFF10B981), secondaryColor),
              _finCell('Profit', b.netProfit, const Color(0xFF2563EB), secondaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
      child: Icon(icon, size: 13, color: color),
    );
  }

  Widget _finCell(String label, double val, Color valColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: labelColor)),
        Text(
          'PKR ${_formatCurrency(val)}',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: valColor),
        ),
      ],
    );
  }

  // ── View Details Dialog ──
  void _openViewModal(BuildContext context, UmrahBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: modalBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          title: const Row(
            children: [
              Icon(Icons.mosque, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text('Umrah Booking details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _viewDetailRow('Booking Ref ID', b.id, primaryColor, secondaryColor),
                _viewDetailRow('Customer Name', b.customerName, primaryColor, secondaryColor),
                _viewDetailRow('Customer Phone', b.customerPhone, primaryColor, secondaryColor),
                _viewDetailRow('Passport Number', b.passportNumber, primaryColor, secondaryColor),
                _viewDetailRow('Vendor Name', b.vendorName, primaryColor, secondaryColor),
                _viewDetailRow('Handler Employee', b.employeeEmail, primaryColor, secondaryColor),
                _viewDetailRow('Payable (PKR)', _formatCurrency(b.payableAmount), const Color(0xFFEF4444), secondaryColor),
                _viewDetailRow('Received (PKR)', _formatCurrency(b.receivedAmount), const Color(0xFF10B981), secondaryColor),
                _viewDetailRow('Net Profit (PKR)', _formatCurrency(b.netProfit), const Color(0xFF2563EB), secondaryColor),
                _viewDetailRow('Booking Date', _formatDate(b.dateCreated), primaryColor, secondaryColor),
                _viewDetailRow('Status', b.status, const Color(0xFFF59E0B), secondaryColor),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
            ),
          ],
        );
      },
    );
  }

  Widget _viewDetailRow(String label, String val, Color valColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: labelColor)),
          const SizedBox(height: 2),
          Text(
            val,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valColor),
          ),
          const Divider(height: 8, thickness: 0.2),
        ],
      ),
    );
  }

  // ── Edit Booking Dialog ──
  void _openEditModal(BuildContext context, UmrahBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final nameCtrl = TextEditingController(text: b.customerName);
    final phoneCtrl = TextEditingController(text: b.customerPhone);
    final passportCtrl = TextEditingController(text: b.passportNumber);
    final receivedCtrl = TextEditingController(text: b.receivedAmount.toString());
    final payableCtrl = TextEditingController(text: b.payableAmount.toString());

    String selectedVendor = b.vendorName;
    String selectedEmployee = b.employeeEmail;
    DateTime selectedDate = b.dateCreated;

    double computedProfit = b.netProfit;

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFFF59E0B)),
                  SizedBox(width: 8),
                  Text('Edit Umrah Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField('Customer Name', nameCtrl),
                    _inputField('Customer Phone', phoneCtrl),
                    _inputField('Passport Number', passportCtrl),

                    // Vendor dropdown in modal
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedVendor,
                        decoration: const InputDecoration(
                          labelText: 'Vendor Name',
                          labelStyle: TextStyle(fontSize: 11),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                        items: _vendors
                            .where((v) => v != 'All Vendors')
                            .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 11))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              selectedVendor = v;
                            });
                          }
                        },
                      ),
                    ),

                    // Employee dropdown in modal
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedEmployee,
                        decoration: const InputDecoration(
                          labelText: 'Handler Employee',
                          labelStyle: TextStyle(fontSize: 11),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                        items: _employees
                            .where((e) => e != 'All Employees')
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 11))))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              selectedEmployee = v;
                            });
                          }
                        },
                      ),
                    ),

                    // Date pick picker button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: OutlinedButton(
                        onPressed: () async {
                          final dt = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (dt != null) {
                            setModalState(() => selectedDate = dt);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking Date: ${_formatDate(selectedDate)}',
                              style: const TextStyle(fontSize: 11, color: Colors.blueAccent),
                            ),
                            const Icon(Icons.calendar_today, size: 14, color: Colors.blueAccent),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(child: _inputField('Received (PKR)', receivedCtrl, isNum: true)),
                        const SizedBox(width: 8),
                        Expanded(child: _inputField('Payable (PKR)', payableCtrl, isNum: true)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Computed profit indicator
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x1FF59E0B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x33F59E0B)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Computed Profit:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'PKR ${_formatCurrency(computedProfit)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
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
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updated = b.copyWith(
                      customerName: nameCtrl.text,
                      customerPhone: phoneCtrl.text,
                      passportNumber: passportCtrl.text,
                      vendorName: selectedVendor,
                      employeeEmail: selectedEmployee,
                      dateCreated: selectedDate,
                      receivedAmount: double.tryParse(receivedCtrl.text) ?? b.receivedAmount,
                      payableAmount: double.tryParse(payableCtrl.text) ?? b.payableAmount,
                      netProfit: computedProfit,
                    );
                    ref.read(umrahBookingsProvider.notifier).updateBooking(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Umrah booking updated successfully!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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

  // ── Confirm Delete Dialog ──
  void _confirmDeleteDialog(BuildContext context, UmrahBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: modalBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the Umrah booking for ${b.customerName} (Ref: ${b.id})?',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(umrahBookingsProvider.notifier).deleteBooking(b.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Umrah booking deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Helpers formatting
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double val) {
    final intVal = val.toInt();
    // Regular expression for adding commas
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return intVal.toString().replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  Map<String, Map<String, double>> _computeMonthlyFinancials(List<UmrahBookingModel> list) {
    final months = ['Sep 2025', 'Dec 2025', 'Jan 2026', 'Feb 2026', 'Jun 2026'];
    Map<String, Map<String, double>> data = {};
    for (var m in months) {
      data[m] = {'received': 0.0, 'payable': 0.0, 'profit': 0.0};
    }

    for (var b in list) {
      String mKey = '';
      final month = b.dateCreated.month;
      final year = b.dateCreated.year;

      if (year == 2025 && month == 9) {
        mKey = 'Sep 2025';
      } else if (year == 2025 && month == 12) {
        mKey = 'Dec 2025';
      } else if (year == 2026 && month == 1) {
        mKey = 'Jan 2026';
      } else if (year == 2026 && month == 2) {
        mKey = 'Feb 2026';
      } else if (year == 2026 && month == 6) {
        mKey = 'Jun 2026';
      } else {
        mKey = 'Jun 2026'; // fallback
      }

      if (data.containsKey(mKey)) {
        data[mKey]!['received'] = data[mKey]!['received']! + b.receivedAmount;
        data[mKey]!['payable'] = data[mKey]!['payable']! + b.payableAmount;
        data[mKey]!['profit'] = data[mKey]!['profit']! + b.netProfit;
      }
    }
    return data;
  }

  Map<String, int> _computeVendorData(List<UmrahBookingModel> list) {
    Map<String, int> counts = {};
    for (var b in list) {
      final name = b.vendorName.toUpperCase();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final sortedEntries = counts.entries.toList()..sort((e1, e2) => e2.value.compareTo(e1.value));
    return Map.fromEntries(sortedEntries);
  }
}
