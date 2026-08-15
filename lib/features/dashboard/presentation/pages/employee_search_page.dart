import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../data/models/booking_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bookings_provider.dart';

class EmployeeSearchPage extends ConsumerStatefulWidget {
  const EmployeeSearchPage({super.key});

  @override
  ConsumerState<EmployeeSearchPage> createState() => _EmployeeSearchPageState();
}

class _EmployeeSearchPageState extends ConsumerState<EmployeeSearchPage> {
  String _searchQuery = '';
  String _selectedStatus = 'All Statuses';
  String _selectedPayment = 'All Payments';
  String _selectedCountry = 'All Countries';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 0;
  final int _perPage = 10;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'All Statuses';
      _selectedPayment = 'All Payments';
      _selectedCountry = 'All Countries';
      _fromDate = null;
      _toDate = null;
      _currentPage = 0;
      _searchController.clear();
    });
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF0F172A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
        _currentPage = 0;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final allBookings = ref.watch(bookingsProvider);
    final user = ref.watch(authControllerProvider).value;

    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0x1AFFFFFF)
        : const Color(0x1F000000);

    // 1. Filter to Visa bookings of current logged-in employee only
    final userVisaBookings = allBookings.where((b) {
      if (b.serviceType.toLowerCase() != 'visa') return false;

      // Match strictly to the logged-in employee
      if (user != null && user.role == 'employee') {
        return b.employeeId == user.uid ||
            b.employeeName.toLowerCase().trim() ==
                user.email.toLowerCase().trim();
      }
      return true;
    }).toList();

    // Compute dynamic country filter options based on employee's bookings
    final Set<String> uniqueCountries = {'All Countries'};
    for (final b in userVisaBookings) {
      if (b.destination.trim().isNotEmpty) {
        uniqueCountries.add(b.destination.trim());
      }
    }

    // 2. Compute search/filter results
    final filteredVisaBookings = userVisaBookings.where((b) {
      // Date Range Filter
      if (_fromDate != null && b.dateCreated.isBefore(_fromDate!)) return false;
      if (_toDate != null &&
          b.dateCreated.isAfter(_toDate!.add(const Duration(days: 1))))
        return false;

      // Status Filter
      if (_selectedStatus != 'All Statuses') {
        if (b.status.toLowerCase().trim() !=
            _selectedStatus.toLowerCase().trim())
          return false;
      }

      // Payment Filter
      if (_selectedPayment != 'All Payments') {
        if (b.paymentStatus.toLowerCase().trim() !=
            _selectedPayment.toLowerCase().trim())
          return false;
      }

      // Country Filter
      if (_selectedCountry != 'All Countries') {
        if (b.destination.toLowerCase().trim() !=
            _selectedCountry.toLowerCase().trim())
          return false;
      }

      // Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchName = b.customerName.toLowerCase().contains(q);
        final matchPassport = b.passportNumber.toLowerCase().contains(q);
        final matchCountry = b.destination.toLowerCase().contains(q);
        final matchType = (b.visaType ?? 'Tourism').toLowerCase().contains(q);
        if (!matchName && !matchPassport && !matchCountry && !matchType)
          return false;
      }

      return true;
    }).toList();

    // 3. Math stats cards (on filtered set or total employee set? Screenshot shows total statistics for user's scope)
    double totalInvoiced = 0;
    double totalReceived = 0;
    double netProfit = 0;
    double embassyFee = 0;
    double vendorFee = 0;

    for (final b in userVisaBookings) {
      totalInvoiced += b.totalPrice;
      totalReceived += b.receivedAmount;
      netProfit += b.netProfit;
      embassyFee += (b.embassyFee ?? 0.0);
      vendorFee += (b.vendorFee ?? 0.0);
    }
    final pendingReceive = totalInvoiced - totalReceived;

    // 4. Pagination math
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filteredVisaBookings.length);
    final pagedList = start >= filteredVisaBookings.length
        ? <BookingModel>[]
        : filteredVisaBookings.sublist(start, end);
    final totalPages = (filteredVisaBookings.length / _perPage).ceil().clamp(
      1,
      9999,
    );

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    if (screenWidth < 600) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Visa Records',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find and filter your visa applications by passport, name, country, or other criteria.',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              'Logged in as: ${user?.email ?? 'aftab@os.com'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Search Visa Records',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find and filter your visa applications by passport, name, country, or other criteria.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              'Logged in as: ${user?.email ?? 'aftab@os.com'}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),

                // ──── STATS CARDS GRID (Scroll-free responsive wrap layout) ────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double parentWidth = constraints.maxWidth;
                    final double cardWidth;
                    if (parentWidth > 1100) {
                      cardWidth = (parentWidth - (10 * 6)) / 7;
                    } else if (parentWidth > 700) {
                      cardWidth = (parentWidth - (10 * 3)) / 4;
                    } else {
                      cardWidth = (parentWidth - 10) / 2;
                    }

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildMetricCard(
                          'TOTAL BOOKINGS',
                          '${userVisaBookings.length}',
                          const Color(0xFF3B82F6),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'TOTAL INVOICED',
                          totalInvoiced.toStringAsFixed(2),
                          const Color(0xFF10B981),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'TOTAL RECEIVED',
                          totalReceived.toStringAsFixed(2),
                          const Color(0xFF10B981),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'NET PROFIT',
                          netProfit.toStringAsFixed(2),
                          const Color(0xFF10B981),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'EMBASSY FEE',
                          embassyFee.toStringAsFixed(2),
                          const Color(0xFFF59E0B),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'VENDOR FEE',
                          vendorFee.toStringAsFixed(2),
                          const Color(0xFF8B5CF6),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                        _buildMetricCard(
                          'PENDING RECEIVE',
                          pendingReceive.toStringAsFixed(2),
                          pendingReceive >= 0
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          isDarkMode,
                          cardBg,
                          borderColor,
                          cardWidth,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ──── MONTHLY OVERVIEW CHART ────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Overview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: _buildMonthlyChart(userVisaBookings, isDarkMode),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendItem('Embassy Fee', const Color(0xFFF59E0B)),
                          const SizedBox(width: 12),
                          _legendItem('Profit', const Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          _legendItem(
                            'Total Earnings',
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 12),
                          _legendItem('Vendor Fee', const Color(0xFF8B5CF6)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ──── SEARCH BAR & CLEAR ALL ────
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardBg,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 16,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Search by passport number, name, country, or visa type...',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (v) {
                                  setState(() {
                                    _searchQuery = v;
                                    _currentPage = 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _clearAll,
                      icon: const Icon(
                        Icons.clear_all,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ──── FILTERS CARD ────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final bool isMobile = constraints.maxWidth < 600;
                          if (isMobile) {
                            return Column(
                              children: [
                                _filterDropdown(
                                  label: 'Visa Status',
                                  value: _selectedStatus,
                                  items: const [
                                    'All Statuses',
                                    'Approved',
                                    'Processing',
                                    'Rejected',
                                  ],
                                  onChanged: (v) => setState(() {
                                    _selectedStatus = v!;
                                    _currentPage = 0;
                                  }),
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 10),
                                _filterDropdown(
                                  label: 'Payment Status',
                                  value: _selectedPayment,
                                  items: const [
                                    'All Payments',
                                    'Paid',
                                    'Partially Paid',
                                    'Unpaid',
                                  ],
                                  onChanged: (v) => setState(() {
                                    _selectedPayment = v!;
                                    _currentPage = 0;
                                  }),
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 10),
                                _filterDropdown(
                                  label: 'Country',
                                  value: _selectedCountry,
                                  items: uniqueCountries.toList(),
                                  onChanged: (v) => setState(() {
                                    _selectedCountry = v!;
                                    _currentPage = 0;
                                  }),
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  cardBg: cardBg,
                                  borderColor: borderColor,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _datePickerField(
                                        label: 'From Date',
                                        value: _fromDate,
                                        onTap: () => _pickDate(true),
                                        primaryTextColor: primaryTextColor,
                                        secondaryTextColor: secondaryTextColor,
                                        borderColor: borderColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _datePickerField(
                                        label: 'To Date',
                                        value: _toDate,
                                        onTap: () => _pickDate(false),
                                        primaryTextColor: primaryTextColor,
                                        secondaryTextColor: secondaryTextColor,
                                        borderColor: borderColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _filterDropdown(
                                      label: 'Visa Status',
                                      value: _selectedStatus,
                                      items: const [
                                        'All Statuses',
                                        'Approved',
                                        'Processing',
                                        'Rejected',
                                      ],
                                      onChanged: (v) => setState(() {
                                        _selectedStatus = v!;
                                        _currentPage = 0;
                                      }),
                                      primaryTextColor: primaryTextColor,
                                      secondaryTextColor: secondaryTextColor,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _filterDropdown(
                                      label: 'Payment Status',
                                      value: _selectedPayment,
                                      items: const [
                                        'All Payments',
                                        'Paid',
                                        'Partially Paid',
                                        'Unpaid',
                                      ],
                                      onChanged: (v) => setState(() {
                                        _selectedPayment = v!;
                                        _currentPage = 0;
                                      }),
                                      primaryTextColor: primaryTextColor,
                                      secondaryTextColor: secondaryTextColor,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _filterDropdown(
                                      label: 'Country',
                                      value: _selectedCountry,
                                      items: uniqueCountries.toList(),
                                      onChanged: (v) => setState(() {
                                        _selectedCountry = v!;
                                        _currentPage = 0;
                                      }),
                                      primaryTextColor: primaryTextColor,
                                      secondaryTextColor: secondaryTextColor,
                                      cardBg: cardBg,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _datePickerField(
                                      label: 'From Date',
                                      value: _fromDate,
                                      onTap: () => _pickDate(true),
                                      primaryTextColor: primaryTextColor,
                                      secondaryTextColor: secondaryTextColor,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _datePickerField(
                                      label: 'To Date',
                                      value: _toDate,
                                      onTap: () => _pickDate(false),
                                      primaryTextColor: primaryTextColor,
                                      secondaryTextColor: secondaryTextColor,
                                      borderColor: borderColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ──── SEARCH RESULTS TABLE ────
                Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Search Results',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              '${filteredVisaBookings.length} records found',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Horizontal Scrollable Data Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: const {
                            0: FixedColumnWidth(40), // #
                            1: FixedColumnWidth(90), // Passport
                            2: FixedColumnWidth(130), // Name
                            3: FixedColumnWidth(80), // Visa Type
                            4: FixedColumnWidth(90), // Country
                            5: FixedColumnWidth(90), // Date
                            6: FixedColumnWidth(90), // Embassy Fee
                            7: FixedColumnWidth(90), // Vendor Fee
                            8: FixedColumnWidth(90), // Total Fee
                            9: FixedColumnWidth(90), // Profit
                            10: FixedColumnWidth(100), // Payment Status
                            11: FixedColumnWidth(100), // Visa Status
                          },
                          children: [
                            // Header Row
                            TableRow(
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(
                                        0xFF1E293B,
                                      ).withValues(alpha: 0.3)
                                    : Colors.grey[100],
                              ),
                              children: [
                                _tableHeader('#', secondaryTextColor),
                                _tableHeader('Passport', secondaryTextColor),
                                _tableHeader('Name', secondaryTextColor),
                                _tableHeader('Visa Type', secondaryTextColor),
                                _tableHeader('Country', secondaryTextColor),
                                _tableHeader('Date', secondaryTextColor),
                                _tableHeader('Embassy Fee', secondaryTextColor),
                                _tableHeader('Vendor Fee', secondaryTextColor),
                                _tableHeader('Total Fee', secondaryTextColor),
                                _tableHeader('Profit', secondaryTextColor),
                                _tableHeader(
                                  'Payment Status',
                                  secondaryTextColor,
                                ),
                                _tableHeader('Visa Status', secondaryTextColor),
                              ],
                            ),

                            // Data Rows
                            ...List.generate(pagedList.length, (index) {
                              final b = pagedList[index];
                              final serial = start + index + 1;
                              return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: borderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                children: [
                                  _tableCell('$serial', primaryTextColor),
                                  _tableCell(
                                    b.passportNumber,
                                    primaryTextColor,
                                  ),
                                  _tableCell(
                                    b.customerName,
                                    primaryTextColor,
                                    isBold: true,
                                  ),
                                  _tableCell(
                                    b.visaType ?? 'Tourism',
                                    primaryTextColor,
                                  ),
                                  _tableCell(b.destination, primaryTextColor),
                                  _tableCell(
                                    _formatDate(b.dateCreated),
                                    primaryTextColor,
                                  ),
                                  _tableCell(
                                    (b.embassyFee ?? 0.0).toStringAsFixed(0),
                                    const Color(0xFFF59E0B),
                                    isBold: true,
                                  ),
                                  _tableCell(
                                    (b.vendorFee ?? 0.0).toStringAsFixed(0),
                                    const Color(0xFF8B5CF6),
                                    isBold: true,
                                  ),
                                  _tableCell(
                                    b.totalPrice.toStringAsFixed(0),
                                    const Color(0xFF10B981),
                                    isBold: true,
                                  ),
                                  _tableCell(
                                    b.netProfit.toStringAsFixed(0),
                                    const Color(0xFF10B981),
                                    isBold: true,
                                  ),
                                  _paymentBadge(b.paymentStatus),
                                  _statusBadge(b.status),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      if (filteredVisaBookings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'No records found matching your filters.',
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),

                      const Divider(height: 1),

                      // Pagination controls footer
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isMobileFooter = constraints.maxWidth < 550;
                            final showingText = Text(
                              'Showing ${filteredVisaBookings.isEmpty ? 0 : start + 1} to $end of ${filteredVisaBookings.length} entries',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                              textAlign: isMobileFooter ? TextAlign.center : TextAlign.start,
                            );

                            final controlsRow = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                                  child: const Text(
                                    'Previous',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Page ${_currentPage + 1} of $totalPages',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: _currentPage < totalPages - 1
                                      ? () => setState(() => _currentPage++)
                                      : null,
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            );

                            if (isMobileFooter) {
                              return Column(
                                children: [
                                  showingText,
                                  const SizedBox(height: 12),
                                  controlsRow,
                                ],
                              );
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                showingText,
                                controlsRow,
                              ],
                            );
                          },
                        ),
                      ),
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

  Widget _buildMetricCard(
    String title,
    String value,
    Color valueColor,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    double cardWidth,
  ) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: secondaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: cardBg,
              isExpanded: true,
              style: TextStyle(fontSize: 11, color: primaryTextColor),
              icon: Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: secondaryTextColor,
              ),
              items: items.map((val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: TextStyle(fontSize: 11, color: primaryTextColor),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: secondaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? _formatDate(value) : 'dd/mm/yyyy',
                  style: TextStyle(
                    fontSize: 11,
                    color: value != null
                        ? primaryTextColor
                        : secondaryTextColor,
                  ),
                ),
                Icon(Icons.calendar_today, size: 12, color: secondaryTextColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _tableCell(String text, Color textColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase().trim();
    Color bg = const Color(0x33EF4444);
    Color fg = const Color(0xFFEF4444);

    if (s == 'approved') {
      bg = const Color(0x3310B981);
      fg = const Color(0xFF10B981);
    } else if (s == 'processing') {
      bg = const Color(0x33F59E0B);
      fg = const Color(0xFFF59E0B);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentBadge(String paymentStatus) {
    final s = paymentStatus.toLowerCase().trim();
    Color bg = const Color(0x33EF4444);
    Color fg = const Color(0xFFEF4444);

    if (s == 'paid') {
      bg = const Color(0x3310B981);
      fg = const Color(0xFF10B981);
    } else if (s == 'partially paid') {
      bg = const Color(0x33F59E0B);
      fg = const Color(0xFFF59E0B);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            paymentStatus,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ──── MONTHLY BAR CHART PAINTER WIDGET ────
  Widget _buildMonthlyChart(List<BookingModel> visaBookings, bool isDarkMode) {
    // 1. Group bookings by month for the last 12 months (e.g. from Sep 2025 to Aug 2026, or current date rolling 12 months)
    final now = DateTime.now();
    final List<DateTime> months = [];
    for (int i = 11; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }

    final List<double> embassyFees = List.filled(12, 0);
    final List<double> profits = List.filled(12, 0);
    final List<double> earnings = List.filled(12, 0);
    final List<double> vendorFees = List.filled(12, 0);

    for (final b in visaBookings) {
      final created = b.dateCreated;
      for (int i = 0; i < 12; i++) {
        final m = months[i];
        if (created.year == m.year && created.month == m.month) {
          embassyFees[i] += (b.embassyFee ?? 0.0);
          profits[i] += b.netProfit;
          earnings[i] += b.totalPrice;
          vendorFees[i] += (b.vendorFee ?? 0.0);
          break;
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Find max value to scale chart
        double maxVal = 100000;
        for (int i = 0; i < 12; i++) {
          if (embassyFees[i] > maxVal) maxVal = embassyFees[i];
          if (profits[i] > maxVal) maxVal = profits[i];
          if (earnings[i] > maxVal) maxVal = earnings[i];
          if (vendorFees[i] > maxVal) maxVal = vendorFees[i];
        }
        maxVal = maxVal * 1.1; // 10% breathing room

        return CustomPaint(
          size: Size(width, height),
          painter: BarChartPainter(
            months: months,
            embassyFees: embassyFees,
            profits: profits,
            earnings: earnings,
            vendorFees: vendorFees,
            maxValue: maxVal,
            isDarkMode: isDarkMode,
          ),
        );
      },
    );
  }
}

// ── CUSTOM PAINTER FOR GRAPH ──
class BarChartPainter extends CustomPainter {
  final List<DateTime> months;
  final List<double> embassyFees;
  final List<double> profits;
  final List<double> earnings;
  final List<double> vendorFees;
  final double maxValue;
  final bool isDarkMode;

  BarChartPainter({
    required this.months,
    required this.embassyFees,
    required this.profits,
    required this.earnings,
    required this.vendorFees,
    required this.maxValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - 40;
    final chartHeight = size.height - 20;

    final paintLine = Paint()
      ..color = isDarkMode ? const Color(0x18FFFFFF) : const Color(0x1F000000)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    const int lines = 4;
    for (int i = 0; i <= lines; i++) {
      final y = chartHeight * (i / lines);
      canvas.drawLine(Offset(40, y), Offset(size.width, y), paintLine);

      // Value label on Y axis
      final val = maxValue * (1 - (i / lines));
      final textPainter = TextPainter(
        text: TextSpan(
          text: val >= 1000000
              ? '${(val / 1000000).toStringAsFixed(1)}M'
              : (val >= 1000
                    ? '${(val / 1000).toStringAsFixed(0)}K'
                    : '${val.toInt()}'),
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }

    final barGroupWidth = chartWidth / 12;

    for (int i = 0; i < 12; i++) {
      final groupX = 40 + (i * barGroupWidth);

      // Month Label on X axis
      final labelPainter = TextPainter(
        text: TextSpan(
          text: const [
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
          ][months[i].month - 1],
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(
          groupX + (barGroupWidth / 2) - (labelPainter.width / 2),
          chartHeight + 4,
        ),
      );

      // Bar Widths and gaps
      final singleBarWidth = barGroupWidth / 6;
      final gap = singleBarWidth / 2;

      // Draw 4 bars per month group
      _drawBar(
        canvas,
        groupX + gap,
        embassyFees[i],
        const Color(0xFFF59E0B),
        chartHeight,
      );
      _drawBar(
        canvas,
        groupX + gap + singleBarWidth,
        profits[i],
        const Color(0xFF10B981),
        chartHeight,
      );
      _drawBar(
        canvas,
        groupX + gap + (singleBarWidth * 2),
        earnings[i],
        const Color(0xFF3B82F6),
        chartHeight,
      );
      _drawBar(
        canvas,
        groupX + gap + (singleBarWidth * 3),
        vendorFees[i],
        const Color(0xFF8B5CF6),
        chartHeight,
      );
    }
  }

  void _drawBar(
    Canvas canvas,
    double x,
    double value,
    Color color,
    double chartHeight,
  ) {
    final barHeight = (value / maxValue) * chartHeight;
    final r = Rect.fromLTWH(x, chartHeight - barHeight, 4, barHeight);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw top rounded bar
    final rrect = RRect.fromRectAndCorners(
      r,
      topLeft: const Radius.circular(1.5),
      topRight: const Radius.circular(1.5),
    );
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
