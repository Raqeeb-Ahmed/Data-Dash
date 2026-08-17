import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../dashboard/presentation/providers/bookings_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String _selectedTimeFilter = 'All';
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: Color(0xFF0F172A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  String _formatNum(double val) {
    final intVal = val.round();
    return intVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x660F172A)
        : Colors.white.withValues(alpha: 0.88);
    final borderColor = isDarkMode
        ? const Color(0x15FFFFFF)
        : const Color(0x1F000000);

    // 1. Filter bookings based on selected filter or custom date range
    final now = DateTime.now();

    final filteredBookings = bookings.where((b) {
      if (_fromDate != null && b.dateCreated.isBefore(_fromDate!)) {
        return false;
      }
      if (_toDate != null &&
          b.dateCreated.isAfter(_toDate!.add(const Duration(days: 1)))) {
        return false;
      }
      if (_fromDate == null && _toDate == null) {
        switch (_selectedTimeFilter) {
          case '7 Days':
            return b.dateCreated.isAfter(now.subtract(const Duration(days: 7)));
          case '30 Days':
            return b.dateCreated.isAfter(
              now.subtract(const Duration(days: 30)),
            );
          case '90 Days':
            return b.dateCreated.isAfter(
              now.subtract(const Duration(days: 90)),
            );
          case 'YTD':
            return b.dateCreated.isAfter(DateTime(now.year, 1, 1));
          case 'All':
          default:
            return true;
        }
      }
      return true;
    }).toList();

    // 2. Calculations
    int calculatedRecords = filteredBookings.length;
    double calculatedReceived = filteredBookings.fold(
      0.0,
      (s, b) => s + b.receivedAmount,
    );
    double calculatedProfit = filteredBookings.fold(
      0.0,
      (s, b) => s + b.netProfit,
    );
    double calculatedPending = filteredBookings.fold(0.0, (s, b) {
      final type = b.serviceType.toLowerCase().trim();
      if (type == 'visa') {
        if (b.payableAmount > 0) {
          return s + b.payableAmount;
        }
      }
      return s;
    });

    final totalRecords = calculatedRecords;
    final totalReceived = calculatedReceived;
    final totalNetProfit = calculatedProfit;
    final totalPending = calculatedPending;

    // 3. Service Breakdown counts
    final visaCount = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'visa')
        .length;
    final hotelCount = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'hotel')
        .length;
    final umrahCount = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'umrah')
        .length;
    final ticketCount = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'ticket')
        .length;
    final insuranceCount = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'insurance')
        .length;

    // 4. Visa status counts
    final visaBookingsFiltered = filteredBookings
        .where((b) => b.serviceType.toLowerCase() == 'visa')
        .toList();
    final totalVisaFiltered = visaBookingsFiltered.length;
    final approvedVisa = visaBookingsFiltered
        .where((b) => b.status.toLowerCase() == 'approved')
        .length;
    final processingVisa = visaBookingsFiltered
        .where((b) => b.status.toLowerCase() == 'processing')
        .length;
    final rejectedVisa = visaBookingsFiltered
        .where((b) => b.status.toLowerCase() == 'rejected')
        .length;

    // 5. Monthly financials (Last 6 months)
    final now1 = DateTime.now();
    final List<DateTime> months = List.generate(
      6,
      (i) => DateTime(now1.year, now1.month - i, 1),
    ).reversed.toList();
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < months.length; i++) {
      final m = months[i];
      final nextM = DateTime(m.year, m.month + 1, 1);
      final mBookings = bookings.where(
        (b) => b.dateCreated.isAfter(m) && b.dateCreated.isBefore(nextM),
      );
      final mReceived =
          mBookings.fold(0.0, (s, b) => s + b.receivedAmount) /
          1000000; // in Millions
      final mProfit =
          mBookings.fold(0.0, (s, b) => s + b.netProfit) /
          1000000; // in Millions
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: mReceived, color: AppColors.primary, width: 6),
            BarChartRodData(toY: mProfit, color: AppColors.secondary, width: 6),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.bar_chart,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'View Analytics',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          Text(
                            'Live charts across all services',
                            style: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Date Filters Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['7 Days', '30 Days', '90 Days', 'YTD', 'All']
                        .map((time) {
                          final isSelected = _selectedTimeFilter == time;
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(time),
                              selected: isSelected,
                              selectedColor: const Color(0xFF4F46E5),
                              backgroundColor: isDarkMode
                                  ? const Color(0x330F172A)
                                  : Colors.grey[200],
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : secondaryTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setState(() {
                                    _selectedTimeFilter = time;
                                    _fromDate = null;
                                    _toDate = null;
                                  });
                                }
                              },
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Custom Date Range Selector (Card)
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Date Range',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkMode
                                      ? const Color(0xFF334155)
                                      : Colors.grey[400]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              icon: Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              label: Text(
                                _fromDate == null
                                    ? 'From'
                                    : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDarkMode
                                      ? const Color(0xFF334155)
                                      : Colors.grey[400]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              icon: Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                              ),
                              label: Text(
                                _toDate == null
                                    ? 'To'
                                    : '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () => _selectDate(context, false),
                            ),
                          ),
                        ],
                      ),
                      if (_fromDate != null || _toDate != null) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _fromDate = null;
                                _toDate = null;
                              });
                            },
                            child: const Text(
                              'Clear Dates',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stat Summary Cards Grid (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                  children: [
                    _buildStatCard(
                      'Total Records',
                      _formatNum(totalRecords.toDouble()),
                      Icons.folder_open,
                      const Color(0xFF6366F1),
                      isDarkMode,
                    ),
                    _buildStatCard(
                      'Total Received',
                      _formatNum(totalReceived),
                      Icons.payments_outlined,
                      const Color(0xFF10B981),
                      isDarkMode,
                    ),
                    _buildStatCard(
                      'Net Profit',
                      _formatNum(totalNetProfit),
                      Icons.trending_up,
                      const Color(0xFF0EA5E9),
                      isDarkMode,
                    ),
                    _buildStatCard(
                      'Pending Amount',
                      _formatNum(totalPending),
                      Icons.hourglass_empty,
                      const Color(0xFFF59E0B),
                      isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // All Services Breakdown (Pie Chart Card)
                _buildChartCard(
                  title: 'All Services Breakdown',
                  subtitle: 'Distribution of document bookings',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  child: SizedBox(
                    height: 160,
                    child: totalRecords == 0
                        ? Center(
                            child: Text(
                              'No data for this range',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: [
                                if (visaCount > 0)
                                  PieChartSectionData(
                                    value: visaCount.toDouble(),
                                    title:
                                        '${((visaCount / totalRecords) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFF6366F1),
                                    radius: 18,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (hotelCount > 0)
                                  PieChartSectionData(
                                    value: hotelCount.toDouble(),
                                    title:
                                        '${((hotelCount / totalRecords) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFF0EA5E9),
                                    radius: 18,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (umrahCount > 0)
                                  PieChartSectionData(
                                    value: umrahCount.toDouble(),
                                    title:
                                        '${((umrahCount / totalRecords) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFFF59E0B),
                                    radius: 18,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (ticketCount > 0)
                                  PieChartSectionData(
                                    value: ticketCount.toDouble(),
                                    title:
                                        '${((ticketCount / totalRecords) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFF10B981),
                                    radius: 18,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (insuranceCount > 0)
                                  PieChartSectionData(
                                    value: insuranceCount.toDouble(),
                                    title:
                                        '${((insuranceCount / totalRecords) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFFEC4899),
                                    radius: 18,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  legends: [
                    _buildLegend('Visas', const Color(0xFF6366F1), isDarkMode),
                    _buildLegend('Hotels', const Color(0xFF0EA5E9), isDarkMode),
                    _buildLegend('Umrah', const Color(0xFFF59E0B), isDarkMode),
                    _buildLegend(
                      'Tickets',
                      const Color(0xFF10B981),
                      isDarkMode,
                    ),
                    if (insuranceCount > 0)
                      _buildLegend(
                        'Insurance',
                        const Color(0xFFEC4899),
                        isDarkMode,
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Visa Status Breakdown (Pie Chart Card)
                _buildChartCard(
                  title: 'Visa Application Status',
                  subtitle: 'Approval vs Processing trends',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  child: SizedBox(
                    height: 160,
                    child: totalVisaFiltered == 0
                        ? Center(
                            child: Text(
                              'No visa data for this range',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              sections: [
                                if (approvedVisa > 0)
                                  PieChartSectionData(
                                    value: approvedVisa.toDouble(),
                                    title:
                                        '${((approvedVisa / totalVisaFiltered) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFF10B981),
                                    radius: 16,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (processingVisa > 0)
                                  PieChartSectionData(
                                    value: processingVisa.toDouble(),
                                    title:
                                        '${((processingVisa / totalVisaFiltered) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFFF59E0B),
                                    radius: 16,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                if (rejectedVisa > 0)
                                  PieChartSectionData(
                                    value: rejectedVisa.toDouble(),
                                    title:
                                        '${((rejectedVisa / totalVisaFiltered) * 100).toStringAsFixed(0)}%',
                                    color: const Color(0xFFEF4444),
                                    radius: 16,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                  legends: [
                    _buildLegend(
                      'Approved',
                      const Color(0xFF10B981),
                      isDarkMode,
                    ),
                    _buildLegend(
                      'Processing',
                      const Color(0xFFF59E0B),
                      isDarkMode,
                    ),
                    _buildLegend(
                      'Rejected',
                      const Color(0xFFEF4444),
                      isDarkMode,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Monthly Performance (Bar Chart Card)
                _buildChartCard(
                  title: 'Monthly Financials (PKR Millions)',
                  subtitle: 'Trends over last 6 months',
                  cardBg: cardBg,
                  borderColor: borderColor,
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
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
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < months.length) {
                                  final m = months[index];
                                  const monthNames = [
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec',
                                  ];
                                  return Text(
                                    monthNames[m.month - 1],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                  legends: [
                    _buildLegend('Received', AppColors.primary, isDarkMode),
                    _buildLegend('Net Profit', AppColors.secondary, isDarkMode),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0x15FFFFFF) : const Color(0x1F000000),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
    required List<Widget> legends,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: legends,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color, bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
