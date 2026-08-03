import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
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

  final List<Map<String, dynamic>> _allBookings = _generateTicketBookings();

  List<Map<String, dynamic>> get _filtered {
    return _allBookings.where((b) {
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
  }

  List<Map<String, dynamic>> get _paged {
    final f = _filtered;
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, f.length);
    if (start >= f.length) return [];
    return f.sublist(start, end);
  }

  int get _totalPages => (_filtered.length / _perPage).ceil();

  // Computed stats
  double get _totalEarnings =>
      _allBookings.fold(0, (s, b) => s + (b['price'] as double));
  double get _totalPayable =>
      _allBookings.fold(0, (s, b) => s + (b['payable'] as double));
  double get _totalProfit =>
      _allBookings.fold(0, (s, b) => s + (b['profit'] as double));

  @override
  Widget build(BuildContext context) {
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
          child: ListView(
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
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                              ),
                              borderRadius: BorderRadius.circular(8),
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
              // Employee filter
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

              // ──── MONTHLY FINANCIALS CHART ────
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
                    Text(
                      'Monthly Financials',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  const months = [
                                    'Sep',
                                    'Nov',
                                    'Jan',
                                    'Mar',
                                    'May',
                                    'Jul',
                                  ];
                                  final i = value.toInt();
                                  if (i < months.length) {
                                    return Text(
                                      months[i],
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: secondary,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            _barGroup(0, 18, 4),
                            _barGroup(1, 28, 8),
                            _barGroup(2, 35, 10),
                            _barGroup(3, 42, 12),
                            _barGroup(4, 55, 15),
                            _barGroup(5, 48, 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendDot('Earnings', const Color(0xFF6366F1)),
                        const SizedBox(width: 16),
                        _legendDot('Profit', const Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ──── TOP 10 DESTINATIONS PIE ────
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
                    Text(
                      'Top 10 Destinations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              value: 24,
                              title: 'ISB 24%',
                              color: const Color(0xFF6366F1),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 13,
                              title: 'KHI 13%',
                              color: const Color(0xFF0EA5E9),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 10,
                              title: 'DXB 10%',
                              color: const Color(0xFF10B981),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 9,
                              title: 'JED 9%',
                              color: const Color(0xFFF59E0B),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 9,
                              title: 'DMM 9%',
                              color: const Color(0xFFEC4899),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 8,
                              title: 'RUH 8%',
                              color: const Color(0xFF8B5CF6),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 7,
                              title: 'LHE 7%',
                              color: const Color(0xFFEF4444),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 7,
                              title: 'BGX 7%',
                              color: const Color(0xFF14B8A6),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 6,
                              title: 'JUL 6%',
                              color: const Color(0xFFF97316),
                              radius: 14,
                              titleStyle: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: 5,
                              title: 'DOH 5%',
                              color: const Color(0xFF64748B),
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
                    // Headers
                    _leaderboardHeader(secondary),
                    const Divider(height: 12, thickness: 0.3),
                    // Rows
                    ..._employeeLeaderboardData().map(
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
                          'Click row to see details',
                          style: TextStyle(fontSize: 10, color: secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Bookings list
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

                    // Pagination
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
                          const SizedBox(width: 4),
                          _paginateBtn(
                            '<',
                            _currentPage > 0,
                            () => setState(() => _currentPage--),
                            isDarkMode,
                            secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Page ${_currentPage + 1} of $_totalPages',
                            style: TextStyle(fontSize: 11, color: secondary),
                          ),
                          const SizedBox(width: 8),
                          _paginateBtn(
                            '>',
                            _currentPage < _totalPages - 1,
                            () => setState(() => _currentPage++),
                            isDarkMode,
                            secondary,
                          ),
                          const SizedBox(width: 4),
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
                      const SizedBox(height: 8),
                      Text(
                        'Showing ${_currentPage * _perPage + 1}–${(_currentPage * _perPage + _perPage).clamp(0, _filtered.length)} of ${_filtered.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: secondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
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
    switch (status) {
      case 'Booked':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0x2210B981);
        break;
      case 'Cancelled':
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
          // Row 1: Num + PNR + Status + Actions
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
              _actionIcon(Icons.visibility_outlined, const Color(0xFF0EA5E9)),
              const SizedBox(width: 4),
              _actionIcon(Icons.edit_outlined, const Color(0xFF10B981)),
              const SizedBox(width: 4),
              _actionIcon(Icons.delete_outline, const Color(0xFFEF4444)),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Passenger + Employee
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
          // Row 3: Route + Date
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
          // Row 4: Financials
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

  Widget _actionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 12, color: color),
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

  String _formatM(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Employee Leaderboard Data ──
List<Map<String, dynamic>> _employeeLeaderboardData() => [
  {
    'email': 'hammad@os.com',
    'bookings': 395,
    'earnings': 60033188.0,
    'profit': 3215196.0,
  },
  {
    'email': 'sameer@os.com',
    'bookings': 209,
    'earnings': 39011929.0,
    'profit': 919711.0,
  },
  {
    'email': 'noorul.fhade@os.com',
    'bookings': 176,
    'earnings': 27454665.0,
    'profit': 1517490.0,
  },
  {
    'email': 'muqtaba@os.com',
    'bookings': 10,
    'earnings': 16080.0,
    'profit': 16080.0,
  },
  {
    'email': 'waqahat@os.com',
    'bookings': 2,
    'earnings': 4000.0,
    'profit': 4000.0,
  },
];

// ── Mock Ticket Bookings ──
List<Map<String, dynamic>> _generateTicketBookings() {
  final passengers = [
    'Muhammad Usman Aslam',
    'Shahid Bashir',
    'Kamwal Kamran',
    'Simal Kamran',
    'Ali Abdullah',
    'Muhammad Talha Riaz',
    'Sadaqat Hussain',
    'Liaqat Ali',
    'Seema/Mrs',
    'Syed Abdullah Anwar',
    'Ayesha Noor',
    'Bilal Raza',
    'Fatima Khan',
    'Hamid Shah',
    'Sara Ahmed',
  ];
  final employees = [
    'noorul.fhade@os.com',
    'hammad@os.com',
    'sameer@os.com',
    'muqtaba@os.com',
  ];
  final routes = [
    'ISB → AM',
    'ISB → DXB',
    'LHE → BKK',
    'KHI → JED',
    'ISB → LHR',
    'EPS → KUL',
    'ISB → BEI',
    'CMF → LHE',
  ];
  final pnrs = [
    '5R2FSS',
    '2RM.KW',
    '2RM.OE',
    '2RM.OE',
    'EI287KA',
    'MFMHID',
    'FI93LS',
    'AIFVKZ',
    'HGK49IJ',
    '20OBGP',
  ];
  final statuses = ['Booked', 'Booked', 'Booked', 'Pending', 'Cancelled'];

  return List.generate(79, (i) {
    final total = (2300.0 + (i * 13987) % 210000);
    final payable = i % 4 == 0 ? 0.0 : total * 0.3;
    final profit = total * 0.05 + (i * 234) % 42000;
    final day = (1 + i % 28);
    return {
      'pnr': pnrs[i % pnrs.length],
      'passenger': passengers[i % passengers.length],
      'employee': employees[i % employees.length],
      'route': routes[i % routes.length],
      'price': total,
      'payable': payable,
      'profit': profit,
      'status': statuses[i % statuses.length],
      'date': '7/$day/2026',
    };
  });
}
