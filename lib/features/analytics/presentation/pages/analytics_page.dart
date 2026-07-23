import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/animated_world_map_background.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedTimeFilter = '30 Days';
  DateTime? _fromDate;
  DateTime? _toDate;

  // Mock values that alter based on filter selection
  double get _multiplier {
    switch (_selectedTimeFilter) {
      case '7 Days':
        return 0.25;
      case '30 Days':
        return 1.0;
      case '90 Days':
        return 2.8;
      case 'YTD':
        return 6.5;
      case 'All':
        return 12.0;
      default:
        return 1.0;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = Colors.white;
    final secondaryTextColor = const Color(0xFF94A3B8);

    // Dynamic metrics
    final totalRecords = (3870 * _multiplier).round();
    final totalReceived = 42.5 * _multiplier;
    final netProfit = 12.4 * _multiplier;
    final pendingAmount = 5.2 * _multiplier;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
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
                      child: const Icon(Icons.bar_chart, color: Colors.white, size: 24),
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
                            style: TextStyle(fontSize: 12, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Quick Date Filters Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['7 Days', '30 Days', '90 Days', 'YTD', 'All'].map((time) {
                      final isSelected = _selectedTimeFilter == time;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          selectedColor: const Color(0xFF4F46E5),
                          backgroundColor: const Color(0x330F172A),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedTimeFilter = time;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Custom Date Range Selector (Card)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x660F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x15FFFFFF)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Date Range',
                        style: TextStyle(color: primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF334155)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                              label: Text(
                                _fromDate == null ? 'From' : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              onPressed: () => _selectDate(context, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF334155)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              icon: const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                              label: Text(
                                _toDate == null ? 'To' : '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                            child: const Text('Clear Dates', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Stat Summary Cards Grid (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard('Total Records', '$totalRecords', Icons.folder_open, const Color(0xFF6366F1)),
                    _buildStatCard('Total Received', '${totalReceived.toStringAsFixed(1)}M', Icons.payments_outlined, const Color(0xFF10B981)),
                    _buildStatCard('Net Profit', '${netProfit.toStringAsFixed(1)}M', Icons.trending_up, const Color(0xFF0EA5E9)),
                    _buildStatCard('Pending Amount', '${pendingAmount.toStringAsFixed(1)}M', Icons.hourglass_empty, const Color(0xFFF59E0B)),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. All Services Breakdown (Pie Chart Card)
                _buildChartCard(
                  title: 'All Services Breakdown',
                  subtitle: 'Distribution of document bookings',
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(value: 65, title: '65%', color: const Color(0xFF6366F1), radius: 18, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(value: 20, title: '20%', color: const Color(0xFF0EA5E9), radius: 18, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(value: 10, title: '10%', color: const Color(0xFFF59E0B), radius: 18, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(value: 5, title: '5%', color: const Color(0xFF10B981), radius: 18, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  legends: [
                    _buildLegend('Visas', const Color(0xFF6366F1)),
                    _buildLegend('Hotels', const Color(0xFF0EA5E9)),
                    _buildLegend('Umrah', const Color(0xFFF59E0B)),
                    _buildLegend('Tickets', const Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. Visa Status Breakdown (Pie Chart Card)
                _buildChartCard(
                  title: 'Visa Application Status',
                  subtitle: 'Approval vs Processing trends',
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          PieChartSectionData(value: 70, title: '70%', color: const Color(0xFF10B981), radius: 16, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(value: 20, title: '20%', color: const Color(0xFFF59E0B), radius: 16, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(value: 10, title: '10%', color: const Color(0xFFEF4444), radius: 16, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  legends: [
                    _buildLegend('Approved', const Color(0xFF10B981)),
                    _buildLegend('Processing', const Color(0xFFF59E0B)),
                    _buildLegend('Rejected', const Color(0xFFEF4444)),
                  ],
                ),
                const SizedBox(height: 20),

                // 7. Monthly Performance (Bar Chart Card)
                _buildChartCard(
                  title: 'Monthly Financials (PKR)',
                  subtitle: 'Trends over last 6 months',
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                                final index = value.toInt();
                                if (index >= 0 && index < months.length) {
                                  return Text(months[index], style: const TextStyle(fontSize: 10, color: Colors.white70));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          _buildBarGroup(0, 1.2 * _multiplier, 0.8 * _multiplier),
                          _buildBarGroup(1, 1.6 * _multiplier, 1.1 * _multiplier),
                          _buildBarGroup(2, 2.1 * _multiplier, 1.5 * _multiplier),
                          _buildBarGroup(3, 1.8 * _multiplier, 1.2 * _multiplier),
                          _buildBarGroup(4, 2.5 * _multiplier, 1.9 * _multiplier),
                          _buildBarGroup(5, 3.2 * _multiplier, 2.4 * _multiplier),
                        ],
                      ),
                    ),
                  ),
                  legends: [
                    _buildLegend('Received', AppColors.primary),
                    _buildLegend('Net Profit', AppColors.secondary),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x660F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x15FFFFFF)),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x660F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x15FFFFFF)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: legends,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double val1, double val2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: val1, color: AppColors.primary, width: 6),
        BarChartRodData(toY: val2, color: AppColors.secondary, width: 6),
      ],
    );
  }
}
