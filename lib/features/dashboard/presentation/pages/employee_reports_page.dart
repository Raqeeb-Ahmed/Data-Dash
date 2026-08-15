import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bookings_provider.dart';

class EmployeeReportsPage extends ConsumerStatefulWidget {
  const EmployeeReportsPage({super.key});

  @override
  ConsumerState<EmployeeReportsPage> createState() => _EmployeeReportsPageState();
}

class _EmployeeReportsPageState extends ConsumerState<EmployeeReportsPage> {
  String _searchQuery = '';
  String _selectedRange = 'Current Month';
  String? _selectedBookingId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double val) {
    return val.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

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
      'morocco': '🇲🇦',
      'pakistan': '🇵🇰',
      'france': '🇫🇷',
      'united kingdom': '🇬🇧',
      'saudi arabia': '🇸🇦',
      'turkey': '🇹🇷',
      'türkiye': '🇹🇷',
      'egypt': '🇪🇬',
      'sri lanka': '🇱🇰',
    };
    return countryFlags[normalized] ?? '🌍';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final allBookings = ref.watch(bookingsProvider);
    final user = ref.watch(authControllerProvider).value;

    final primaryTextColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final cardBg = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1F000000);

    // 1. Filter bookings to current employee only
    final employeeBookings = allBookings.where((b) {
      if (user != null && user.role == 'employee') {
        return b.employeeId == user.uid ||
            b.employeeName.toLowerCase().trim() == user.email.toLowerCase().trim();
      }
      return true;
    }).toList();

    // 2. Perform Month-Wise range boundary calculations
    final now = DateTime.now();
    DateTime rangeFrom;
    DateTime rangeTo;
    DateTime prevRangeFrom;
    DateTime prevRangeTo;

    if (_selectedRange == 'Current Month') {
      rangeFrom = DateTime(now.year, now.month, 1);
      rangeTo = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      // Previous month
      prevRangeFrom = DateTime(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1, 1);
      prevRangeTo = DateTime(now.year, now.month, 0, 23, 59, 59);
    } else if (_selectedRange == 'Last Month') {
      rangeFrom = DateTime(now.month == 1 ? now.year - 1 : now.year, now.month == 1 ? 12 : now.month - 1, 1);
      rangeTo = DateTime(now.year, now.month, 0, 23, 59, 59);
      // Month before last
      final twoMonthsAgoMonth = now.month <= 2 ? now.month + 10 : now.month - 2;
      final twoMonthsAgoYear = now.month <= 2 ? now.year - 1 : now.year;
      prevRangeFrom = DateTime(twoMonthsAgoYear, twoMonthsAgoMonth, 1);
      prevRangeTo = DateTime(rangeFrom.year, rangeFrom.month, 0, 23, 59, 59);
    } else if (_selectedRange == 'Last 3 Months') {
      rangeFrom = DateTime(now.month <= 3 ? now.year - 1 : now.year, now.month <= 3 ? now.month + 9 : now.month - 3, 1);
      rangeTo = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      // 3-month period before that
      final prev3FromYear = rangeFrom.month <= 3 ? rangeFrom.year - 1 : rangeFrom.year;
      final prev3FromMonth = rangeFrom.month <= 3 ? rangeFrom.month + 9 : rangeFrom.month - 3;
      prevRangeFrom = DateTime(prev3FromYear, prev3FromMonth, 1);
      prevRangeTo = DateTime(rangeFrom.year, rangeFrom.month, 0, 23, 59, 59);
    } else {
      // All Time
      rangeFrom = DateTime(2020, 1, 1);
      rangeTo = DateTime(now.year + 1, 1, 1);
      prevRangeFrom = DateTime(2019, 1, 1);
      prevRangeTo = DateTime(2020, 1, 1);
    }

    // 3. Filter employee bookings to the SELECTED DATE RANGE strictly
    final monthBookings = employeeBookings.where((b) {
      return b.dateCreated.isAfter(rangeFrom.subtract(const Duration(seconds: 1))) &&
          b.dateCreated.isBefore(rangeTo.add(const Duration(seconds: 1)));
    }).toList();

    // 4. Counts by service type for the selected month set
    int visaCount = 0;
    int hotelCount = 0;
    int umrahCount = 0;
    int ticketCount = 0;
    int insuranceCount = 0;

    for (final b in monthBookings) {
      final type = b.serviceType.toLowerCase().trim();
      if (type == 'visa') {
        visaCount++;
      } else if (type == 'hotel') {
        hotelCount++;
      } else if (type == 'umrah') {
        umrahCount++;
      } else if (type == 'ticket') {
        ticketCount++;
      } else if (type == 'insurance') {
        insuranceCount++;
      }
    }

    // MoM comparison totals
    final currentPeriodCount = monthBookings.length;
    final prevPeriodCount = employeeBookings.where((b) {
      return b.dateCreated.isAfter(prevRangeFrom.subtract(const Duration(seconds: 1))) &&
          b.dateCreated.isBefore(prevRangeTo.add(const Duration(seconds: 1)));
    }).length;

    // Group countries for the bar chart based on selected month set
    final Map<String, int> countryCounts = {};
    for (final b in monthBookings) {
      if (b.destination.trim().isNotEmpty) {
        final c = b.destination.trim();
        countryCounts[c] = (countryCounts[c] ?? 0) + 1;
      }
    }
    final sortedCountries = countryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCountries = sortedCountries.take(5).toList();

    // Filtered transaction list based on search bar query & selected month
    final filteredTransactions = monthBookings.where((b) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchClient = b.customerName.toLowerCase().contains(q);
        final matchDest = b.destination.toLowerCase().contains(q);
        final matchPassport = b.passportNumber.toLowerCase().contains(q);
        return matchClient || matchDest || matchPassport;
      }
      return true;
    }).toList();

    // Default select first item if selection is null or not found in current filtered set
    if (_selectedBookingId == null && filteredTransactions.isNotEmpty) {
      _selectedBookingId = filteredTransactions.first.id;
    }

    final selectedBooking = filteredTransactions.where((b) => b.id == _selectedBookingId).firstOrNull ??
        (filteredTransactions.isNotEmpty ? filteredTransactions.first : null);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ──── HEADER ────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics Hub',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time visualization and insights for OS Travels operations.',
                            style: TextStyle(fontSize: 11, color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _selectedRange = value;
                          _selectedBookingId = null;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'Current Month', child: Text('Current Month')),
                        const PopupMenuItem(value: 'Last Month', child: Text('Last Month')),
                        const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
                        const PopupMenuItem(value: 'All Time', child: Text('All Time')),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: secondaryTextColor),
                            const SizedBox(width: 6),
                            Text(
                              _selectedRange,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, size: 14, color: secondaryTextColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ──── DYNAMIC CHARTS ROW (Side-by-side or stacked on mobile) ────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isSplit = constraints.maxWidth > 800;
                    final donutWidget = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service Distribution',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CustomPaint(
                                    painter: ServiceDonutPainter(
                                      visa: visaCount.toDouble(),
                                      hotel: hotelCount.toDouble(),
                                      ticket: ticketCount.toDouble(),
                                      umrah: umrahCount.toDouble(),
                                      insurance: insuranceCount.toDouble(),
                                      textColor: primaryTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _donutLegend('Visas', visaCount, const Color(0xFF3B82F6)),
                                      _donutLegend('Hotels', hotelCount, const Color(0xFF10B981)),
                                      _donutLegend('Tickets', ticketCount, const Color(0xFFF59E0B)),
                                      _donutLegend('Umrah', umrahCount, const Color(0xFF8B5CF6)),
                                      _donutLegend('Insurance', insuranceCount, const Color(0xFFEF4444)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                    final barWidget = Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Performing Destinations',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: topCountries.isEmpty
                                ? Center(
                                    child: Text(
                                      'No destinations data in this range.',
                                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                                    ),
                                  )
                                : CustomPaint(
                                    size: const Size(double.infinity, 120),
                                    painter: DestinationBarPainter(
                                      countries: topCountries,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );

                    if (isSplit) {
                      return Row(
                        children: [
                          Expanded(child: donutWidget),
                          const SizedBox(width: 16),
                          Expanded(child: barWidget),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          donutWidget,
                          const SizedBox(height: 16),
                          barWidget,
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // ──── SEARCH BAR WITH FILTER ICON ────
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 18, color: secondaryTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(fontSize: 12, color: primaryTextColor),
                          decoration: InputDecoration(
                            hintText: 'Search transactions by name, passport, country, or status...',
                            hintStyle: TextStyle(fontSize: 12, color: secondaryTextColor),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          onChanged: (v) {
                            setState(() {
                              _searchQuery = v;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, size: 16, color: secondaryTextColor),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      Container(
                        width: 1,
                        height: 20,
                        color: borderColor,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      Icon(Icons.tune, size: 18, color: secondaryTextColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ──── TWO-COLUMN DETAIL PANELS ────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isSplit = constraints.maxWidth > 800;

                    final transactionsList = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Activity History',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                              ),
                            ),
                            Text(
                              '${filteredTransactions.length} items',
                              style: TextStyle(fontSize: 11, color: secondaryTextColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (filteredTransactions.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                            child: Center(
                              child: Text(
                                'No matching records in selected range.',
                                style: TextStyle(fontSize: 12, color: secondaryTextColor),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, index) {
                              final b = filteredTransactions[index];
                              final flag = _getCountryFlag(b.destination);
                              final isSelected = b.id == _selectedBookingId;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedBookingId = b.id;
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : borderColor,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Circular flag badge
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          flag,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.customerName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${b.serviceType.toUpperCase()} • ${b.destination} • ${_formatDate(b.dateCreated)}',
                                              style: TextStyle(fontSize: 10, color: secondaryTextColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status Badge on the right
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: b.status.toLowerCase().trim() == 'approved'
                                              ? const Color(0x2210B981)
                                              : (b.status.toLowerCase().trim() == 'processing'
                                                  ? const Color(0x22F59E0B)
                                                  : const Color(0x22EF4444)),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          b.status,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: b.status.toLowerCase().trim() == 'approved'
                                                ? const Color(0xFF10B981)
                                                : (b.status.toLowerCase().trim() == 'processing'
                                                    ? const Color(0xFFF59E0B)
                                                    : const Color(0xFFEF4444)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );

                    // ──── DYNAMIC GRADIENT STATS CARD (MATCHING USER TAP SPECIFICALLY) ────
                    final summaryCard = Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: const Icon(Icons.description, color: Colors.white, size: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Details Panel',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (selectedBooking == null) ...[
                            const Text(
                              'Select a Record',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap any booking card in the left list to load specific metrics.',
                              style: TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ] else ...[
                            Text(
                              selectedBooking.customerName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Passport: ${selectedBooking.passportNumber}',
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'PKR ${_formatCurrency(selectedBooking.totalPrice)}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Text(
                              'Booking Invoiced Value',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24, height: 1),
                            const SizedBox(height: 16),
                            _mockupMetricRow('Embassy Fee', 'PKR ${_formatCurrency(selectedBooking.embassyFee ?? 0.0)}'),
                            const SizedBox(height: 10),
                            _mockupMetricRow('Vendor Fee', 'PKR ${_formatCurrency(selectedBooking.vendorFee ?? 0.0)}'),
                            const SizedBox(height: 10),
                            _mockupMetricRow('Net Profit Generated', 'PKR ${_formatCurrency(selectedBooking.netProfit)}'),
                            const SizedBox(height: 10),
                            _mockupMetricRow('Payments Received', 'PKR ${_formatCurrency(selectedBooking.receivedAmount)}'),
                          ],
                          const SizedBox(height: 20),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'MONTH-OVER-MONTH BOOKINGS',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currentPeriodCount records',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Selected Range',
                                    style: TextStyle(fontSize: 9, color: Colors.white70),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.white24,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$prevPeriodCount records',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Previous Period',
                                    style: TextStyle(fontSize: 9, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );

                    if (isSplit) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: transactionsList),
                          const SizedBox(width: 24),
                          Expanded(flex: 2, child: summaryCard),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          summaryCard,
                          const SizedBox(height: 24),
                          transactionsList,
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _donutLegend(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _mockupMetricRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 8,
            color: Colors.white60,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── CUSTOM DONUT CHART PAINTER ──
class ServiceDonutPainter extends CustomPainter {
  final double visa;
  final double hotel;
  final double ticket;
  final double umrah;
  final double insurance;
  final Color textColor;

  ServiceDonutPainter({
    required this.visa,
    required this.hotel,
    required this.ticket,
    required this.umrah,
    required this.insurance,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = visa + hotel + ticket + umrah + insurance;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 6;

    final paintPlaceholder = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    if (total == 0) {
      canvas.drawCircle(center, radius, paintPlaceholder);
      return;
    }

    final rect = Rect.fromCircle(center: center, radius: radius);

    void drawSegment(double value, Color color, _DoubleRef refDoubleRef) {
      if (value <= 0) return;
      final startAngle = (refDoubleRef.value / total) * 2 * math.pi - math.pi / 2;
      final sweepAngle = (value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      refDoubleRef.value += value;
    }

    final currentSum = _DoubleRef(0.0);
    drawSegment(visa, const Color(0xFF3B82F6), currentSum);
    drawSegment(hotel, const Color(0xFF10B981), currentSum);
    drawSegment(ticket, const Color(0xFFF59E0B), currentSum);
    drawSegment(umrah, const Color(0xFF8B5CF6), currentSum);
    drawSegment(insurance, const Color(0xFFEF4444), currentSum);

    // Center total count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${total.toInt()}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DoubleRef {
  double value;
  _DoubleRef(this.value);
}

// ── CUSTOM BAR CHART PAINTER FOR TOP DESTINATIONS ──
class DestinationBarPainter extends CustomPainter {
  final List<MapEntry<String, int>> countries;
  final bool isDarkMode;

  DestinationBarPainter({required this.countries, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    if (countries.isEmpty) return;

    final chartWidth = size.width - 60;
    final chartHeight = size.height - 20;

    final paintLine = Paint()
      ..color = isDarkMode ? const Color(0x18FFFFFF) : const Color(0x1F000000)
      ..strokeWidth = 0.5;

    // Draw Y grid line baseline
    canvas.drawLine(Offset(50, chartHeight), Offset(size.width, chartHeight), paintLine);

    int maxCount = 5;
    for (final e in countries) {
      if (e.value > maxCount) maxCount = e.value;
    }

    final barSpacing = chartWidth / countries.length;

    for (int i = 0; i < countries.length; i++) {
      final item = countries[i];
      final label = item.key;
      final count = item.value;

      final barX = 50 + (i * barSpacing);

      // Label X
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label.length > 8 ? '${label.substring(0, 6)}..' : label,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(canvas, Offset(barX + (barSpacing / 2) - (labelPainter.width / 2), chartHeight + 4));

      // Bar Height
      final barHeight = (count / maxCount) * (chartHeight - 15);
      final r = Rect.fromLTWH(barX + (barSpacing / 4), chartHeight - barHeight, barSpacing / 2, barHeight);

      final paint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndCorners(
        r,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rrect, paint);

      // Value label top of bar
      final valuePainter = TextPainter(
        text: TextSpan(
          text: '$count',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valuePainter.paint(canvas, Offset(barX + (barSpacing / 2) - (valuePainter.width / 2), chartHeight - barHeight - 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
