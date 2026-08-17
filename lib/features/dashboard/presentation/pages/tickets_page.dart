import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/bookings_provider.dart';

class TicketsPage extends ConsumerStatefulWidget {
  const TicketsPage({super.key});

  @override
  ConsumerState<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends ConsumerState<TicketsPage> {
  String _selectedEmployee = 'All Employees';
  String _searchQuery = '';
  int _currentPage = 0;
  final int _perPage = 10;

  final List<String> _employees = [
    'All Employees',
    'hammad@os.com',
    'sameer@os.com',
    'noorul.fhade@os.com',
    'muqtaba@os.com',
    'waqahat@os.com',
  ];

  @override
  Widget build(BuildContext context) {
    // --- Read and parse dynamic Firestore data ---
    final rawBookings = ref.watch(bookingsProvider);
    final ticketBookings = rawBookings
        .where((b) => b.serviceType == 'ticket')
        .toList();

    // Map real Firebase bookings into the map structures expected by the UI
    final List<Map<String, dynamic>> _allBookings = ticketBookings.map((b) {
      return {
        'id': b.id,
        'pnr': b.pnr ?? 'N/A',
        'passenger': b.customerName,
        'phone': b.customerPhone,
        'route': b.fromDestination != null && b.fromDestination!.isNotEmpty
            ? '${b.fromDestination} → ${b.destination}'
            : b.destination,
        'price': b.totalPrice,
        'payable': b.payableAmount,
        'profit': b.netProfit,
        'status': b.status,
        'date': b.dateCreated.toIso8601String().split('T')[0],
        'employee': b.employeeName,
      };
    }).toList();

    // Filter list based on search and selected employee dropdown
    final List<Map<String, dynamic>> _filtered = _allBookings.where((b) {
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          (b['pnr'] as String).toLowerCase().contains(q) ||
          (b['passenger'] as String).toLowerCase().contains(q) ||
          (b['employee'] as String).toLowerCase().contains(q) ||
          (b['route'] as String).toLowerCase().contains(q);
      final matchEmp =
          _selectedEmployee == 'All Employees' ||
          b['employee'] == _selectedEmployee;
      return matchSearch && matchEmp;
    }).toList();

    final int start = _currentPage * _perPage;
    final int end = (start + _perPage).clamp(0, _filtered.length);
    final List<Map<String, dynamic>> _paged = start >= _filtered.length
        ? []
        : _filtered.sublist(start, end);

    final int _totalPages = (_filtered.length / _perPage).ceil();

    final double _totalEarnings = _allBookings.fold(
      0.0, // <-- 0.0 (double) kiya taake type crash na ho
      (s, b) => s + (b['price'] as double),
    );
    final double _totalPayable = _allBookings.fold(
      0.0, // <-- 0.0 (double) kiya taake type crash na ho
      (s, b) => s + (b['payable'] as double),
    );
    final double _totalProfit = _allBookings.fold(
      0.0, // <-- 0.0 (double) kiya taake type crash na ho
      (s, b) => s + (b['profit'] as double),
    );

    // --- Dynamic Monthly Aggregation for Graph ---
    final Map<int, List<Map<String, dynamic>>> monthlyMap = {
      9: [], // Sep
      12: [], // Dec
      1: [], // Jan
      2: [], // Feb
      6: [], // Jun
    };
    for (final b in _allBookings) {
      final dateStr = b['date'] as String;
      DateTime? parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate == null && dateStr.contains('/')) {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final m = int.tryParse(parts[0]) ?? 1;
          final d = int.tryParse(parts[1]) ?? 1;
          final y = int.tryParse(parts[2]) ?? 2026;
          parsedDate = DateTime(y, m, d);
        }
      }
      parsedDate ??= DateTime.now();
      if (monthlyMap.containsKey(parsedDate.month)) {
        monthlyMap[parsedDate.month]!.add(b);
      }
    }

    double getEarningsForMonth(int m) {
      return monthlyMap[m]!.fold(0.0, (s, b) => s + (b['price'] as double));
    }

    double getProfitForMonth(int m) {
      return monthlyMap[m]!.fold(0.0, (s, b) => s + (b['profit'] as double));
    }

    final double sepE = getEarningsForMonth(9);
    final double sepP = getProfitForMonth(9);

    final double decE = getEarningsForMonth(12);
    final double decP = getProfitForMonth(12);

    final double janE = getEarningsForMonth(1);
    final double janP = getProfitForMonth(1);

    final double febE = getEarningsForMonth(2);
    final double febP = getProfitForMonth(2);

    final double junE = getEarningsForMonth(6);
    final double junP = getProfitForMonth(6);

    double maxMonthlyE = [
      sepE,
      decE,
      janE,
      febE,
      junE,
    ].reduce((curr, next) => curr > next ? curr : next);
    if (maxMonthlyE == 0) maxMonthlyE = 1.0;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primary = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x880F172A)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = isDarkMode
        ? const Color(0x18FFFFFF)
        : const Color(0x1F000000);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              children: [
              // ──── HEADER ────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.flight_takeoff,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Ticket Bookings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.only(left: 34),
                        child: Text(
                          'Live bookings, employee leaderboard, and reports',
                          style: TextStyle(fontSize: 11, color: secondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Employee filter dropdown
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedEmployee,
                    isExpanded: true,
                    dropdownColor: isDarkMode
                        ? const Color(0xFF1E293B)
                        : Colors.white,
                    style: TextStyle(fontSize: 12, color: primary),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: secondary,
                    ),
                    items: _employees
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _selectedEmployee = v!;
                      _currentPage = 0;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ──── STAT CARDS (2x2) ────
              Row(
                children: [
                  Expanded(
                    child: _gradientCard(
                      colors: const [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                      label: 'BOOKINGS',
                      value: '${_allBookings.length}',
                      sub: 'Updated Now',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _gradientCard(
                      colors: const [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                      label: 'EARNINGS',
                      value: 'PKR ${_formatM(_totalEarnings)}',
                      sub: 'Sum of Price',
                      icon: Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _gradientCard(
                      colors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                      label: 'PAYABLE',
                      value: 'PKR ${_formatM(_totalPayable)}',
                      sub: 'Sum of Payable',
                      icon: Icons.account_balance_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _gradientCard(
                      colors: const [Color(0xFF10B981), Color(0xFF059669)],
                      label: 'PROFIT',
                      value: 'PKR ${_formatM(_totalProfit)}',
                      sub: 'Sum of Profit',
                      icon: Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ──── CHARTS SECTION (2 columns layout) ────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 650;
                  final content = [
                    // Chart 1: Monthly Financials
                    Expanded(
                      flex: isMobile ? 0 : 1,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Financials',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earnings & profit compared by month',
                              style: TextStyle(fontSize: 9, color: secondary),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: maxMonthlyE > 0
                                      ? maxMonthlyE * 1.2
                                      : 100.0,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                            final isEarnings = rodIndex == 0;
                                            return BarTooltipItem(
                                              '${isEarnings ? 'Earnings' : 'Profit'}\nPKR ${_formatM(rod.toY)}',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (val, meta) {
                                          const style = TextStyle(
                                            color: Colors.white60,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          );
                                          switch (val.toInt()) {
                                            case 0:
                                              return const Text(
                                                'Sep',
                                                style: style,
                                              );
                                            case 1:
                                              return const Text(
                                                'Dec',
                                                style: style,
                                              );
                                            case 2:
                                              return const Text(
                                                'Jan',
                                                style: style,
                                              );
                                            case 3:
                                              return const Text(
                                                'Feb',
                                                style: style,
                                              );
                                            case 4:
                                              return const Text(
                                                'Jun',
                                                style: style,
                                              );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 35,
                                        getTitlesWidget: (value, meta) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: Text(
                                              _formatM(value),
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: secondary,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                      color: borderColor,
                                      strokeWidth: 0.5,
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    _barGroup(0, sepE, sepP),
                                    _barGroup(1, decE, decP),
                                    _barGroup(2, janE, janP),
                                    _barGroup(3, febE, febP),
                                    _barGroup(4, junE, junP),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _legendDot('Earnings', const Color(0xFF6366F1)),
                                const SizedBox(width: 14),
                                _legendDot('Profit', const Color(0xFF10B981)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isMobile) const SizedBox(height: 14),
                    const SizedBox(width: 14),
                    // Chart 2: Top Destinations
                    Expanded(
                      flex: isMobile ? 0 : 1,
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Destinations',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Distribution of ticketed destination routes',
                              style: TextStyle(fontSize: 9, color: secondary),
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                  sections: [
                                    PieChartSectionData(
                                      value: 40,
                                      title: 'ISB 40%',
                                      color: const Color(0xFF6366F1),
                                      radius: 14,
                                      titleStyle: const TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: 30,
                                      title: 'KHI 30%',
                                      color: const Color(0xFF0EA5E9),
                                      radius: 14,
                                      titleStyle: const TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: 20,
                                      title: 'LHE 20%',
                                      color: const Color(0xFF10B981),
                                      radius: 14,
                                      titleStyle: const TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      value: 10,
                                      title: 'Others 10%',
                                      color: const Color(0xFFF59E0B),
                                      radius: 14,
                                      titleStyle: const TextStyle(
                                        fontSize: 7,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];

                  return isMobile
                      ? Column(children: content)
                      : Row(children: content);
                },
              ),
              const SizedBox(height: 14),

              // ──── SEARCH BAR ────
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(fontSize: 12, color: primary),
                        decoration: InputDecoration(
                          hintText:
                              'Search by PNR, passenger, employee, route...',
                          hintStyle: TextStyle(fontSize: 12, color: secondary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (v) => setState(() {
                          _searchQuery = v;
                          _currentPage = 0;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ──── EMPLOYEE LEADERBOARD ────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Employee Leaderboard',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        Text(
                          'Sort by: Bookings',
                          style: TextStyle(fontSize: 10, color: secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _leaderboardHeader(secondary),
                    const Divider(height: 12, thickness: 0.3),
                    ..._computeEmployeeLeaderboard(_allBookings).map(
                      (e) => _leaderboardRow(e, primary, secondary, isDarkMode),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ──── BOOKINGS TABLE ────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bookings (${_filtered.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                        Text(
                          'Click icons to view, edit or delete',
                          style: TextStyle(fontSize: 10, color: secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ..._paged.asMap().entries.map((entry) {
                      final i = entry.key;
                      final b = entry.value;
                      return _buildBookingRow(
                        b,
                        _currentPage * _perPage + i + 1,
                        isDarkMode,
                        primary,
                        secondary,
                        borderColor,
                      );
                    }),
                    if (_totalPages > 1) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _paginateBtn(
                            '<<',
                            _currentPage > 0,
                            () => setState(() => _currentPage = 0),
                            isDarkMode,
                            secondary,
                          ),
                          const SizedBox(width: 8),
                          _paginateBtn(
                            '< Prev',
                            _currentPage > 0,
                            () => setState(() => _currentPage--),
                            isDarkMode,
                            secondary,
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Page ${_currentPage + 1} of $_totalPages',
                            style: TextStyle(fontSize: 11, color: secondary),
                          ),
                          const SizedBox(width: 14),
                          _paginateBtn(
                            'Next >',
                            _currentPage < _totalPages - 1,
                            () => setState(() => _currentPage++),
                            isDarkMode,
                            secondary,
                          ),
                          const SizedBox(width: 8),
                          _paginateBtn(
                            '>>',
                            _currentPage < _totalPages - 1,
                            () =>
                                setState(() => _currentPage = _totalPages - 1),
                            isDarkMode,
                            secondary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──

  Widget _gradientCard({
    required List<Color> colors,
    required String label,
    required String value,
    required String sub,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, size: 16, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 9, color: Colors.white54)),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double earnings, double profit) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: earnings,
          color: const Color(0xFF6366F1),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
        BarChartRodData(
          toY: profit,
          color: const Color(0xFF10B981),
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ],
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _leaderboardHeader(Color secondary) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'EMPLOYEE',
            style: TextStyle(
              fontSize: 8,
              color: secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'BOOKINGS',
            style: TextStyle(
              fontSize: 8,
              color: secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'EARNINGS',
            style: TextStyle(
              fontSize: 8,
              color: secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'PROFIT',
            style: TextStyle(
              fontSize: 8,
              color: secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _leaderboardRow(
    Map<String, dynamic> e,
    Color primary,
    Color secondary,
    bool isDarkMode,
  ) {
    final pct = (e['bookings'] as int) / 400.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              e['email'] as String,
              style: TextStyle(
                fontSize: 10,
                color: primary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${e['bookings']}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatM(e['earnings'] as double),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatM(e['profit'] as double),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                LinearProgressIndicator(
                  value: pct.clamp(0.0, 1.0),
                  backgroundColor: const Color(0x226366F1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1),
                  ),
                  minHeight: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingRow(
    Map<String, dynamic> b,
    int rowNum,
    bool isDarkMode,
    Color primary,
    Color secondary,
    Color borderColor,
  ) {
    Color statusColor;
    Color statusBg;
    final status = b['status'] as String;
    switch (status.toLowerCase()) {
      case 'booked':
      case 'confirmed':
      case 'approved':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0x2210B981);
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0x22EF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0x22F59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x330F172A)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#$rowNum ',
                style: TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x226366F1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  b['pnr'] as String,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _actionIcon(
                Icons.visibility_outlined,
                const Color(0xFF0EA5E9),
                onTap: () => _showViewTicketDialog(b),
              ),
              const SizedBox(width: 4),
              _actionIcon(
                Icons.edit_outlined,
                const Color(0xFF10B981),
                onTap: () => _showEditTicketDialog(b),
              ),
              const SizedBox(width: 4),
              _actionIcon(
                Icons.delete_outline,
                const Color(0xFFEF4444),
                onTap: () => _showDeleteTicketDialog(b),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b['passenger'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
              Icon(Icons.work_outline, size: 11, color: secondary),
              const SizedBox(width: 3),
              Text(
                b['employee'] as String,
                style: TextStyle(fontSize: 10, color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.flight, size: 11, color: const Color(0xFF6366F1)),
              const SizedBox(width: 4),
              Text(
                b['route'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today, size: 10, color: secondary),
              const SizedBox(width: 4),
              Text(
                b['date'] as String,
                style: TextStyle(fontSize: 10, color: secondary),
              ),
            ],
          ),
          const Divider(height: 12, thickness: 0.3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _finCell(
                'Price',
                'PKR ${_formatM(b['price'] as double)}',
                primary,
                secondary,
              ),
              _finCell(
                'Payable',
                'PKR ${_formatM(b['payable'] as double)}',
                const Color(0xFFF59E0B),
                secondary,
              ),
              _finCell(
                'Profit',
                'PKR ${_formatM(b['profit'] as double)}',
                const Color(0xFF10B981),
                secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }

  Widget _finCell(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: labelColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _paginateBtn(
    String label,
    bool enabled,
    VoidCallback onTap,
    bool isDarkMode,
    Color secondary,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: enabled
              ? (isDarkMode ? const Color(0x330F172A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: enabled ? const Color(0x18FFFFFF) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: enabled ? secondary : Colors.grey,
          ),
        ),
      ),
    );
  }

  // --- Dynamic Leaderboard Generator ---
  List<Map<String, dynamic>> _computeEmployeeLeaderboard(
    List<Map<String, dynamic>> bookings,
  ) {
    final Map<String, Map<String, dynamic>> leaderboard = {};

    for (final b in bookings) {
      final email = b['employee'] as String;
      final price = b['price'] as double;
      final profit = b['profit'] as double;

      if (email.isEmpty || email == 'Unassigned') continue;

      if (!leaderboard.containsKey(email)) {
        leaderboard[email] = {
          'email': email,
          'bookings': 0,
          'earnings': 0.0,
          'profit': 0.0,
        };
      }

      leaderboard[email]!['bookings'] =
          (leaderboard[email]!['bookings'] as int) + 1;
      leaderboard[email]!['earnings'] =
          (leaderboard[email]!['earnings'] as double) + price;
      leaderboard[email]!['profit'] =
          (leaderboard[email]!['profit'] as double) + profit;
    }

    final list = leaderboard.values.toList();
    list.sort((a, b) => (b['bookings'] as int).compareTo(a['bookings'] as int));
    return list;
  }

  // --- View Details Dialog ---
  void _showViewTicketDialog(Map<String, dynamic> b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ticket Details (PNR: ${b['pnr']})'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Passenger Name:', b['passenger']),
              _detailRow('Phone:', b['phone'] ?? 'N/A'),
              _detailRow('Route:', b['route']),
              _detailRow('Date:', b['date']),
              _detailRow('Employee:', b['employee']),
              const Divider(),
              _detailRow('Total Price:', 'PKR ${_formatM(b['price'])}'),
              _detailRow('Payable Amount:', 'PKR ${_formatM(b['payable'])}'),
              _detailRow('Net Profit:', 'PKR ${_formatM(b['profit'])}'),
              _detailRow('Status:', b['status']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  // --- Delete Booking Dialog ---
  void _showDeleteTicketDialog(Map<String, dynamic> b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ticket Booking'),
        content: Text(
          'Are you sure you want to delete the ticket booking for ${b['passenger']} (PNR: ${b['pnr']})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(bookingsProvider.notifier).deleteBooking(b['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket booking deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- Edit Booking Dialog ---
  void _showEditTicketDialog(Map<String, dynamic> b) {
    final nameCtrl = TextEditingController(text: b['passenger']);
    final phoneCtrl = TextEditingController(text: b['phone']);
    final pnrCtrl = TextEditingController(text: b['pnr']);
    final routeCtrl = TextEditingController(text: b['route']);
    final priceCtrl = TextEditingController(text: b['price'].toString());
    final payableCtrl = TextEditingController(text: b['payable'].toString());
    String selectedStatus = b['status'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Ticket Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Passenger Name',
                  ),
                ),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: pnrCtrl,
                  decoration: const InputDecoration(labelText: 'PNR'),
                ),
                TextField(
                  controller: routeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Route (e.g. Origin → Destination)',
                  ),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: payableCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Payable to Vendor',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value:
                      [
                        'Booked',
                        'Pending',
                        'Cancelled',
                      ].contains(selectedStatus)
                      ? selectedStatus
                      : 'Booked',
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'Booked', child: Text('Booked')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedStatus = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final double price = double.tryParse(priceCtrl.text) ?? 0.0;
                final double payable = double.tryParse(payableCtrl.text) ?? 0.0;
                final double profit = price - payable;

                final rawBookings = ref.read(bookingsProvider);
                final originalBooking = rawBookings.firstWhere(
                  (item) => item.id == b['id'],
                );

                String origin = '';
                String destination = routeCtrl.text;
                if (routeCtrl.text.contains('→')) {
                  final parts = routeCtrl.text.split('→');
                  origin = parts[0].trim();
                  destination = parts[1].trim();
                }

                final updatedBooking = originalBooking.copyWith(
                  customerName: nameCtrl.text,
                  customerPhone: phoneCtrl.text,
                  pnr: pnrCtrl.text,
                  fromDestination: origin,
                  destination: destination,
                  totalPrice: price,
                  payableAmount: payable,
                  receivedAmount: price,
                  netProfit: profit,
                  status: selectedStatus,
                );

                Navigator.pop(ctx);
                await ref
                    .read(bookingsProvider.notifier)
                    .updateBooking(updatedBooking);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket booking updated successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatM(double v) {
    if (v == v.toInt()) {
      return _addCommas(v.toInt().toString());
    } else {
      return _addCommas(v.toStringAsFixed(2));
    }
  }

  String _addCommas(String str) {
    final parts = str.split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String Function(Match) matchFunc = (Match match) => '${match[1]},';
    final firstPart = parts[0].replaceAllMapped(reg, matchFunc);
    if (parts.length > 1) {
      return '$firstPart.${parts[1]}';
    }
    return firstPart;
  }
}
