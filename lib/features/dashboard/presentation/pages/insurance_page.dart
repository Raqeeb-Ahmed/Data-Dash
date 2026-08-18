import 'package:data_dash/features/dashboard/presentation/providers/bookings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/insurance_provider.dart';

class InsurancePage extends ConsumerStatefulWidget {
  const InsurancePage({super.key});

  @override
  ConsumerState<InsurancePage> createState() => _InsurancePageState();
}

class _InsurancePageState extends ConsumerState<InsurancePage> {
  int _itemsToShow = 10;
  late final TextEditingController _searchController;

  final List<String> _companies = [
    'Adamjee',
    'CSI',
    'DAMAN HEALTH AC',
    'UIC',
    'UNITED COMPANY INSURANCE',
    'UNITED INSURANCE COMPANY',
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
    final filter = ref.watch(insuranceFilterProvider);
    final filteredList = ref.watch(filteredInsuranceBookingsProvider);
    final stats = ref.watch(insuranceStatsProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x770B0F19)
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(bookingsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    children: [
                      // ──── HEADER ────
                      _buildHeader(primaryTextColor, secondaryTextColor),
                      const SizedBox(height: 16),

                      // ──── STATS CARDS (TOTAL RECEIVED, PAYABLE, PROFIT) ────
                      _buildStatsRow(stats, isDarkMode),
                      const SizedBox(height: 16),

                      // ──── SEARCH & DATE FILTERS ROW ────
                      _buildSearchAndFilters(
                        cardBg,
                        borderColor,
                        primaryTextColor,
                        secondaryTextColor,
                        isDarkMode,
                        filter,
                      ),
                      const SizedBox(height: 14),

                      // ──── BOOKINGS BY COMPANY CHIPS ────
                      _buildCompanyChips(
                        primaryTextColor,
                        secondaryTextColor,
                        isDarkMode,
                        filter,
                        borderColor,
                      ),
                      const SizedBox(height: 14),

                      // ──── CHARTS ────
                      _buildChartsSection(
                        cardBg,
                        borderColor,
                        primaryTextColor,
                        secondaryTextColor,
                        isDarkMode,
                        filteredList,
                      ),
                      const SizedBox(height: 14),

                      // ──── RECORDS TABLE LIST ────
                      _buildTableCard(
                        context,
                        cardBg,
                        borderColor,
                        primaryTextColor,
                        secondaryTextColor,
                        isDarkMode,
                        displayedList,
                        filteredList.length,
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

  // ── Header Title ──
  Widget _buildHeader(Color primaryColor, Color secondaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.domain_verification,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Insurance Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            Text(
              'Manage travel coverages, premium payables, and client profiles',
              style: TextStyle(fontSize: 11, color: secondaryColor),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stats Cards Row (TOTAL RECEIVED, TOTAL PAYABLE, TOTAL PROFIT) ──
  Widget _buildStatsRow(InsuranceStats stats, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total Received',
            amount: stats.totalReceived,
            gradient: const [
              Color(0xFF5B21B6),
              Color(0xFF4C1D95),
            ], // Purple theme
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            title: 'Total Payable',
            amount: stats.totalPayable,
            gradient: const [
              Color(0xFF991B1B),
              Color(0xFF7F1D1D),
            ], // Crimson/Red theme
            icon: Icons.money_off_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            title: 'Total Profit',
            amount: stats.totalProfit,
            gradient: const [
              Color(0xFF065F46),
              Color(0xFF064E3B),
            ], // Green theme
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required double amount,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, size: 12, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 13,
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

  // ── Search & Date Filters Card ──
  Widget _buildSearchAndFilters(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    InsuranceFilter filter,
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
          // Row containing search and custom range fields
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 3,
                child: Container(
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
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by name, passport, company...',
                            hintStyle: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onChanged: (v) {
                            ref
                                .read(insuranceFilterProvider.notifier)
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
              ),
              const SizedBox(width: 8),

              // Date pick range picker input buttons
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectCustomDate(isFrom: true),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filter.fromDate == null
                                ? 'dd/mm/yyyy'
                                : _formatDate(filter.fromDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('-', style: TextStyle(fontSize: 11)),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectCustomDate(isFrom: false),
                        child: Container(
                          height: 38,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filter.toDate == null
                                ? 'dd/mm/yyyy'
                                : _formatDate(filter.toDate!),
                            style: TextStyle(
                              fontSize: 10,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Date range filter buttons (All Time, Today, This Week, This Month)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Time', 'Today', 'This Week', 'This Month'].map((
                filterName,
              ) {
                final isSelected = filter.selectedDateFilter == filterName;
                return GestureDetector(
                  onTap: () {
                    ref
                        .read(insuranceFilterProvider.notifier)
                        .updateDateFilter(filterName);
                    ref
                        .read(insuranceFilterProvider.notifier)
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
                        color: isSelected ? Colors.transparent : borderColor,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      filterName,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white : primaryTextColor,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomDate({required bool isFrom}) async {
    final activeFilter = ref.read(insuranceFilterProvider);
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
      final from = isFrom ? picked : activeFilter.fromDate;
      final to = isFrom ? activeFilter.toDate : picked;
      ref
          .read(insuranceFilterProvider.notifier)
          .updateCustomDateRange(from, to);
      ref.read(insuranceFilterProvider.notifier).updateDateFilter('Custom');
      setState(() {
        _itemsToShow = 10;
      });
    }
  }

  // ── Bookings by Company chips list ──
  Widget _buildCompanyChips(
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    InsuranceFilter filter,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            'Bookings by Company',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _companyChip(
                'All Companies',
                filter.selectedCompany == 'All Companies',
                isDarkMode,
                borderColor,
              ),
              ..._companies.map((c) {
                final isSelected =
                    filter.selectedCompany.toLowerCase() == c.toLowerCase();
                return _companyChip(c, isSelected, isDarkMode, borderColor);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _companyChip(
    String label,
    bool isSelected,
    bool isDarkMode,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(insuranceFilterProvider.notifier).updateCompany(label);
        setState(() {
          _itemsToShow = 10;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDarkMode ? const Color(0x33FFFFFF) : Colors.white),
          border: Border.all(
            color: isSelected ? Colors.transparent : borderColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Charts section (Monthly Financials + Top Companies) ──
  Widget _buildChartsSection(
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    List<InsuranceBookingModel> filteredList,
  ) {
    final monthlyData = _computeMonthlyFinancials(filteredList);
    final monthsKeys = monthlyData.keys.toList();
    final companyData = _computeCompanyDistribution(filteredList);
    final companyList = companyData.entries.toList();

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
                height: 160,
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
                                  monthsKeys[i],
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
                      // Scale down by 1,000 for representation
                      double rec = d['received']! / 1000;
                      double pay = d['payable']! / 1000;
                      double prof = d['profit']! / 1000;
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

        // 2. Top Companies (Donut Chart)
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
                'Top Companies',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 14),
              if (companyList.isEmpty)
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('No company data available')),
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
                            companyList.length.clamp(0, 5),
                            (idx) {
                              final entry = companyList[idx];
                              return PieChartSectionData(
                                value: entry.value.toDouble(),
                                color: _getCompanyColor(idx),
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
                          companyList.length.clamp(0, 5),
                          (idx) {
                            final entry = companyList[idx];
                            final pct = filteredList.isEmpty
                                ? '0'
                                : (entry.value / filteredList.length * 100)
                                      .toStringAsFixed(0);
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
                                      color: _getCompanyColor(idx),
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
          ),
        ),
      ],
    );
  }

  Color _getCompanyColor(int idx) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF10B981),
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
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

  // ── Table Card ──
  Widget _buildTableCard(
    BuildContext context,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDarkMode,
    List<InsuranceBookingModel> displayedList,
    int totalCount,
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
                'Insurance Records (${displayedList.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              Text(
                'Showing ${displayedList.length} of $totalCount',
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
                  'No insurance records found matching filters.',
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
            )
          else ...[
            ...displayedList.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final b = entry.value;
              return _buildBookingRow(
                context,
                b,
                idx,
                isDarkMode,
                primaryTextColor,
                secondaryTextColor,
                borderColor,
              );
            }),

            // Load More button if total list exceeds shown items
            if (totalCount > _itemsToShow)
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
        ],
      ),
    );
  }

  // ── Record Row Widget ──
  Widget _buildBookingRow(
    BuildContext context,
    InsuranceBookingModel b,
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
          // Row Header: Index + ID + Actions
          Row(
            children: [
              Text(
                '#$idx',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
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
                  ),
                ),
              ),
              const Spacer(),
              // Actions
              GestureDetector(
                onTap: () => _openViewModal(context, b),
                child: _actionIcon(
                  Icons.visibility_outlined,
                  const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _openEditModal(context, b),
                child: _actionIcon(
                  Icons.edit_outlined,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _confirmDeleteDialog(context, b),
                child: _actionIcon(
                  Icons.delete_outline,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Insured Passenger & Passport
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: secondaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.insuredName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                'Passport: ${b.passportNumber}',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Company & Travel Country
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 11,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    b.company,
                    style: TextStyle(
                      fontSize: 10,
                      color: secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.flight_land, size: 11, color: secondaryColor),
                  const SizedBox(width: 4),
                  Text(
                    b.travelCountry,
                    style: TextStyle(fontSize: 10, color: secondaryColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Booking Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 10,
                    color: secondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(b.dateCreated),
                    style: TextStyle(fontSize: 9, color: secondaryColor),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 12, thickness: 0.3),

          // Financials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _finCell(
                'Received Amount',
                b.receivedAmount,
                const Color(0xFF10B981),
                secondaryColor,
              ),
              _finCell(
                'Payable Amount',
                b.payableAmount,
                const Color(0xFFEF4444),
                secondaryColor,
              ),
              _finCell(
                'Net Profit',
                b.netProfit,
                const Color(0xFF2563EB),
                secondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }

  Widget _finCell(String label, double val, Color valColor, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 8, color: labelColor)),
        Text(
          'PKR ${val.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }

  // ── Action Dialogs ──

  // 1. SEE DETAILS MODAL
  void _openViewModal(BuildContext context, InsuranceBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
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
              Icon(Icons.verified_user, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text(
                'Insurance policy details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _viewDetailRow(
                  'Policy Ref ID',
                  b.id,
                  primaryColor,
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Insurance Company',
                  b.company,
                  primaryColor,
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Insured Passenger Name',
                  b.insuredName,
                  primaryColor,
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Passport Number',
                  b.passportNumber,
                  primaryColor,
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Destination Country',
                  b.travelCountry,
                  primaryColor,
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Received Amount',
                  'PKR ${b.receivedAmount.toStringAsFixed(2)}',
                  const Color(0xFF10B981),
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Payable Amount',
                  'PKR ${b.payableAmount.toStringAsFixed(2)}',
                  const Color(0xFFEF4444),
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Net Profit',
                  'PKR ${b.netProfit.toStringAsFixed(2)}',
                  const Color(0xFF2563EB),
                  secondaryColor,
                ),
                _viewDetailRow(
                  'Policy Booking Date',
                  _formatDate(b.dateCreated),
                  primaryColor,
                  secondaryColor,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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

  // 2. EDIT MODAL
  void _openEditModal(BuildContext context, InsuranceBookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    final nameCtrl = TextEditingController(text: b.insuredName);
    final passportCtrl = TextEditingController(text: b.passportNumber);
    final countryCtrl = TextEditingController(text: b.travelCountry);
    final receivedCtrl = TextEditingController(
      text: b.receivedAmount.toString(),
    );
    final payableCtrl = TextEditingController(text: b.payableAmount.toString());

    String selectedCompany = b.company;
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.edit, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'Edit Insurance Booking',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField('Insured Name', nameCtrl),
                    _inputField('Passport Number', passportCtrl),
                    _inputField('Travel Country', countryCtrl),

                    // Company Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: DropdownButtonFormField<String>(
                        initialValue: _companies.contains(selectedCompany)
                            ? selectedCompany
                            : _companies.first,
                        decoration: const InputDecoration(
                          labelText: 'Insurance Company',
                          labelStyle: TextStyle(fontSize: 11),
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                        ),
                        items: _companies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setModalState(() {
                              selectedCompany = v;
                            });
                          }
                        },
                      ),
                    ),

                    // Date Picker OutlinedButton
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking Date: ${_formatDate(selectedDate)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _inputField(
                            'Received (PKR)',
                            receivedCtrl,
                            isNum: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _inputField(
                            'Payable (PKR)',
                            payableCtrl,
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
                      insuredName: nameCtrl.text,
                      passportNumber: passportCtrl.text,
                      travelCountry: countryCtrl.text,
                      company: selectedCompany,
                      dateCreated: selectedDate,
                      receivedAmount:
                          double.tryParse(receivedCtrl.text) ??
                          b.receivedAmount,
                      payableAmount:
                          double.tryParse(payableCtrl.text) ?? b.payableAmount,
                      netProfit: computedProfit,
                    );
                    ref
                        .read(insuranceBookingsProvider.notifier)
                        .updateBooking(updated);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Insurance booking updated successfully!',
                        ),
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
    TextEditingController ctrl, {
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

  // 3. CONFIRM DELETE DIALOG
  void _confirmDeleteDialog(BuildContext context, InsuranceBookingModel b) {
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
            'Are you sure you want to delete the Insurance policy for ${b.insuredName} (Ref: ${b.id})?',
            style: const TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(insuranceBookingsProvider.notifier)
                    .deleteBooking(b.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Insurance record deleted successfully!'),
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

  // Helpers
  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Map<String, Map<String, double>> _computeMonthlyFinancials(
    List<InsuranceBookingModel> list,
  ) {
    final months = [
      'Sep 2025',
      'Oct 2025',
      'Nov 2025',
      'Dec 2025',
      'Feb 2026',
      'Mar 2026',
    ];
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
      } else if (year == 2025 && month == 10) {
        mKey = 'Oct 2025';
      } else if (year == 2025 && month == 11) {
        mKey = 'Nov 2025';
      } else if (year == 2025 && month == 12) {
        mKey = 'Dec 2025';
      } else if (year == 2026 && month == 2) {
        mKey = 'Feb 2026';
      } else if (year == 2026 && month == 3) {
        mKey = 'Mar 2026';
      } else {
        mKey = 'Mar 2026';
      }

      if (data.containsKey(mKey)) {
        data[mKey]!['received'] = data[mKey]!['received']! + b.receivedAmount;
        data[mKey]!['payable'] = data[mKey]!['payable']! + b.payableAmount;
        data[mKey]!['profit'] = data[mKey]!['profit']! + b.netProfit;
      }
    }
    return data;
  }

  Map<String, int> _computeCompanyDistribution(
    List<InsuranceBookingModel> list,
  ) {
    Map<String, int> counts = {};
    for (var b in list) {
      final name = b.company.toUpperCase();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    final sortedEntries = counts.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));
    return Map.fromEntries(sortedEntries);
  }
}
