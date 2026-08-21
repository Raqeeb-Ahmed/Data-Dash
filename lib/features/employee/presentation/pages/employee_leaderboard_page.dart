import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/employee_provider.dart';
import '../../../dashboard/presentation/providers/bookings_provider.dart';
import '../../../dashboard/data/models/booking_model.dart';

class EmployeeLeaderboardPage extends ConsumerStatefulWidget {
  const EmployeeLeaderboardPage({super.key});

  @override
  ConsumerState<EmployeeLeaderboardPage> createState() =>
      _EmployeeLeaderboardPageState();
}

class _EmployeeLeaderboardPageState
    extends ConsumerState<EmployeeLeaderboardPage> {
  // Administrative Account Creation Controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Search & Filter State
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _filterFromDate;
  DateTime? _filterToDate;
  String? _selectedEmployeeEmail;
  String _selectedTab = 'visa'; // 'visa', 'ticket', 'umrah'
  int _recordsToShow = 10;
  String _activeLeaderboard = 'general'; // 'general', 'ticketing'

  // Expandable state for detailed record cards
  final Map<String, bool> _expandedRecords = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _recordsToShow = 10; // Reset pagination on search
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- Date Picker Helpers ---
  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF1E293B),
            onSurface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF0F172A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _filterFromDate = picked;
        } else {
          _filterToDate = picked;
        }
        _recordsToShow = 10; // Reset pagination
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _filterFromDate = null;
      _filterToDate = null;
      _searchController.clear();
      _searchQuery = '';
      _recordsToShow = 10;
    });
  }

  // --- Formatting Utilities ---
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
    String matchFunc(Match match) => '${match[1]},';
    final firstPart = parts[0].replaceAllMapped(reg, matchFunc);
    if (parts.length > 1) {
      return '$firstPart.${parts[1]}';
    }
    return firstPart;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_getMonthName(dt.month)} ${dt.year}';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeeListProvider);
    final bookings = ref.watch(bookingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Standard Theme Colors
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final scaffoldBg = isDarkMode
        ? const Color(0xFF0F172A)
        : AppColors.backgroundLight;
    final borderColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    // --- AGGREGATE DASHBOARD METRICS ---
    final totalEmployeesCount = employees.length;
    final activeEmployeesCount = employees.where((e) => e.isEnabled).length;
    final totalBookingsCount = bookings.where((b) {
      final s = b.status.toLowerCase().trim();
      return s != 'deleted' && s != 'trash';
    }).length;

    // --- COMPUTE LEADERBOARDS ---
    final List<Map<String, dynamic>> leaderboardData = employees.map((emp) {
      // Find employee bookings using exact business mapping
      final empBookings = bookings.where((b) {
        final s = b.status.toLowerCase().trim();
        if (s == 'deleted' || s == 'trash') return false;
        return b.employeeId == emp.uid ||
            b.employeeName.toLowerCase().trim() ==
                emp.email.toLowerCase().trim();
      }).toList();

      final approved = empBookings.where((b) {
        final s = b.status.toLowerCase().trim();
        return s == 'approved' ||
            s == 'confirmed' ||
            s == 'completed' ||
            s == 'active' ||
            s == 'success';
      }).length;

      double total = 0.0;
      double received = 0.0;
      double pending = 0.0;
      double profit = 0.0;

      for (final b in empBookings) {
        total += b.totalPrice;
        received += b.receivedAmount;
        pending += b.payableAmount;
        profit += b.netProfit;
      }

      // Calculate Ticketing-specific statistics
      final ticketBookings = empBookings
          .where((b) => b.serviceType.toLowerCase().trim() == 'ticket')
          .toList();

      double ticketEarnings = 0.0;
      double ticketPayable = 0.0;
      double ticketProfit = 0.0;

      for (final tb in ticketBookings) {
        ticketEarnings += tb.totalPrice;
        ticketPayable += tb.payableAmount;
        ticketProfit += tb.netProfit;
      }

      return {
        'employee': emp,
        'email': emp.email,
        'bookings': empBookings.length,
        'approved': approved,
        'total': total,
        'received': received,
        'pending': pending,
        'profit': profit,
        'ticketBookings': ticketBookings.length,
        'ticketEarnings': ticketEarnings,
        'ticketPayable': ticketPayable,
        'ticketProfit': ticketProfit,
      };
    }).toList();

    // Sort Lists dynamically
    final generalLeaderboard = List<Map<String, dynamic>>.from(leaderboardData)
      ..sort((a, b) => (b['bookings'] as int).compareTo(a['bookings'] as int));

    final ticketingLeaderboard =
        List<Map<String, dynamic>>.from(leaderboardData)..sort(
          (a, b) => (b['ticketBookings'] as int).compareTo(
            a['ticketBookings'] as int,
          ),
        );

    // Default select first employee on load
    if (_selectedEmployeeEmail == null && generalLeaderboard.isNotEmpty) {
      _selectedEmployeeEmail = generalLeaderboard.first['email'];
    }

    // --- SELECTED EMPLOYEE DETAIL RECORDS & TABS ---
    final selectedEmpModel = employees.firstWhere(
      (e) => e.email == _selectedEmployeeEmail,
      orElse: () =>
          EmployeeModel(uid: '', email: 'Unassigned', isEnabled: false),
    );

    // Filter bookings belonging to selected employee
    final selectedEmpBookings = bookings.where((b) {
      final s = b.status.toLowerCase().trim();
      if (s == 'deleted' || s == 'trash') return false;
      return b.employeeId == selectedEmpModel.uid ||
          b.employeeName.toLowerCase().trim() ==
              selectedEmpModel.email.toLowerCase().trim();
    }).toList();

    // Filter by Service Tabs (VISA, TICKET, UMRAH)
    final tabBookings = selectedEmpBookings.where((b) {
      return b.serviceType.toLowerCase().trim() == _selectedTab;
    }).toList();

    // Filter by Date Range & Search Text query
    final filteredBookings = tabBookings.where((b) {
      // Date filter
      if (_filterFromDate != null) {
        final start = DateTime(
          _filterFromDate!.year,
          _filterFromDate!.month,
          _filterFromDate!.day,
        );
        if (b.dateCreated.isBefore(start)) return false;
      }
      if (_filterToDate != null) {
        final end = DateTime(
          _filterToDate!.year,
          _filterToDate!.month,
          _filterToDate!.day,
          23,
          59,
          59,
        );
        if (b.dateCreated.isAfter(end)) return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match =
            b.customerName.toLowerCase().contains(q) ||
            b.id.toLowerCase().contains(q) ||
            b.destination.toLowerCase().contains(q) ||
            b.status.toLowerCase().contains(q) ||
            b.paymentStatus.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();

    // Sort filtered bookings by date created descending
    filteredBookings.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));

    // Calculate Summary statistics for selected employee's current filtered category
    double selectedTotalReceived = 0.0;
    double selectedTotalPayable = 0.0;
    double selectedTotalProfit = 0.0;

    for (final b in filteredBookings) {
      selectedTotalReceived += b.receivedAmount;
      selectedTotalPayable += b.payableAmount;
      selectedTotalProfit += b.netProfit;
    }

    // Pagination slice
    final visibleBookings = filteredBookings.take(_recordsToShow).toList();

    // Group Visible Bookings by formatted creation date
    final Map<String, List<BookingModel>> groupedBookings = {};
    for (final b in visibleBookings) {
      final dateStr = _formatDate(b.dateCreated);
      if (!groupedBookings.containsKey(dateStr)) {
        groupedBookings[dateStr] = [];
      }
      groupedBookings[dateStr]!.add(b);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Trigger refresh logic
            ref.invalidate(bookingsProvider);
            ref.invalidate(employeeListProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ──── HEADER ────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employee Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real-time Firestore stats & records',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  // Manage employee account access / add logins button
                  ElevatedButton.icon(
                    onPressed: () => _showManageLoginsBottomSheet(context),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: const Text(
                      'Manage Logins',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ──── SUMMARY CARDS ────
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Employees',
                      value: '$totalEmployeesCount',
                      subtitle: 'Total profiles',
                      icon: Icons.people_outline,
                      color: AppColors.primary,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      title: 'Active Agents',
                      value: '$activeEmployeesCount',
                      subtitle: 'Status: Active',
                      icon: Icons.check_circle_outline,
                      color: AppColors.secondary,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMetricCard(
                title: 'Total Active Bookings',
                value: '$totalBookingsCount',
                subtitle: 'Merged from all categories',
                icon: Icons.confirmation_number_outlined,
                color: AppColors.accent,
                isFullWidth: true,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),

              // ──── LEADERBOARD CONTAINER ────
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Performance Leaderboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        // Dropdown to switch leaderboards
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF0F172A)
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButton<String>(
                            value: _activeLeaderboard,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down, size: 18),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                            dropdownColor: cardBg,
                            onChanged: (String? val) {
                              if (val != null) {
                                setState(() {
                                  _activeLeaderboard = val;
                                });
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: 'general',
                                child: Text('All Bookings'),
                              ),
                              DropdownMenuItem(
                                value: 'ticketing',
                                child: Text('Ticketing Only'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Render selected leaderboard list
                    if (_activeLeaderboard == 'general') ...[
                      ...generalLeaderboard.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return _buildLeaderboardCard(
                          rank: index + 1,
                          email: data['email'],
                          bookings: data['bookings'],
                          approved: data['approved'],
                          total: data['total'],
                          received: data['received'],
                          pending: data['pending'],
                          profit: data['profit'],
                          isDarkMode: isDarkMode,
                          isSelected: _selectedEmployeeEmail == data['email'],
                          onTap: () {
                            setState(() {
                              _selectedEmployeeEmail = data['email'];
                              _recordsToShow = 10; // Reset pagination
                            });
                          },
                        );
                      }),
                    ] else ...[
                      ...ticketingLeaderboard.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return _buildTicketingLeaderboardCard(
                          rank: index + 1,
                          email: data['email'],
                          bookings: data['ticketBookings'],
                          earnings: data['ticketEarnings'],
                          payable: data['ticketPayable'],
                          profit: data['ticketProfit'],
                          isDarkMode: isDarkMode,
                          isSelected: _selectedEmployeeEmail == data['email'],
                          onTap: () {
                            setState(() {
                              _selectedEmployeeEmail = data['email'];
                              _recordsToShow = 10;
                            });
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ──── RECORDS FOR SELECTED EMPLOYEE SECTION ────
              Text(
                'Records for ${selectedEmpModel.email}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              const SizedBox(height: 12),

              // Filter Controls Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      style: TextStyle(color: primaryTextColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by client, ID, status...',
                        hintStyle: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: secondaryTextColor,
                          size: 18,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: isDarkMode
                            ? const Color(0xFF0F172A)
                            : AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date Filters Row
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF0F172A)
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _filterFromDate == null
                                          ? 'From Date'
                                          : _formatDate(_filterFromDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _filterFromDate == null
                                            ? secondaryTextColor
                                            : primaryTextColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF0F172A)
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _filterToDate == null
                                          ? 'To Date'
                                          : _formatDate(_filterToDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _filterToDate == null
                                            ? secondaryTextColor
                                            : primaryTextColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_filterFromDate != null ||
                            _filterToDate != null ||
                            _searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _clearFilters,
                            icon: const Icon(
                              Icons.filter_alt_off_outlined,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Clear Filters',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category Tabs (VISA, TICKET, UMRAH)
              Row(
                children: [
                  _buildTabChip('VISA', 'visa'),
                  const SizedBox(width: 8),
                  _buildTabChip('TICKET', 'ticket'),
                  const SizedBox(width: 8),
                  _buildTabChip('UMRAH', 'umrah'),
                ],
              ),
              const SizedBox(height: 16),

              // Records Summary Statistics
              Row(
                children: [
                  Expanded(
                    child: _buildRecordSummaryCard(
                      label: 'Total Bookings',
                      value: '${filteredBookings.length}',
                      color: AppColors.primary,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRecordSummaryCard(
                      label: 'Total Profit',
                      value: 'PKR ${_formatM(selectedTotalProfit)}',
                      color: AppColors.secondary,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRecordSummaryCard(
                      label: 'Total Received',
                      value: 'PKR ${_formatM(selectedTotalReceived)}',
                      color: const Color(0xFF0EA5E9),
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRecordSummaryCard(
                      label: 'Total Payable',
                      value: 'PKR ${_formatM(selectedTotalPayable)}',
                      color: AppColors.accent,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ──── RECORDS GROUPED BY DATE ────
              if (groupedBookings.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.folder_open_outlined,
                        color: secondaryTextColor,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No matching records found',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...groupedBookings.entries.map((entry) {
                  final date = entry.key;
                  final groupList = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Group Header
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 8,
                          left: 4,
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? const Color(0xFF6366F1)
                                : AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Records list under this date
                      ...groupList.map((booking) {
                        return _buildIndividualRecordCard(
                          booking: booking,
                          isDarkMode: isDarkMode,
                          borderColor: borderColor,
                          cardBg: cardBg,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                        );
                      }),
                    ],
                  );
                }),

                // Load More Button
                if (filteredBookings.length > _recordsToShow) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _recordsToShow += 10;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        foregroundColor: isDarkMode
                            ? Colors.white
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: borderColor),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Load More',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Subcomponents ---

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
    required bool isDarkMode,
  }) {
    final bg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final border = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final pText = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final sText = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isFullWidth ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: pText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: sText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard({
    required int rank,
    required String email,
    required int bookings,
    required int approved,
    required double total,
    required double received,
    required double pending,
    required double profit,
    required bool isDarkMode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color rankColor = rank == 1
        ? const Color(0xFFF59E0B) // Gold
        : rank == 2
        ? const Color(0xFF94A3B8) // Silver
        : rank == 3
        ? const Color(0xFFB45309) // Bronze
        : isDarkMode
        ? Colors.white30
        : Colors.black26;

    final primary = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final border = isSelected
        ? Colors.purple.withValues(alpha: 0.6)
        : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final cardBg = isSelected
        ? (isDarkMode
              ? Colors.purple.withValues(alpha: 0.08)
              : Colors.purple.withValues(alpha: 0.04))
        : (isDarkMode ? const Color(0xFF0F172A) : AppColors.backgroundLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isSelected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Rank, Name, Bookings)
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            rankColor == Colors.white30 ||
                                rankColor == Colors.black26
                            ? primary
                            : rankColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: primary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$bookings Bookings',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Detail financial values
              Row(
                children: [
                  _buildLeaderboardValueColumn(
                    'Approved',
                    '$approved',
                    Colors.green,
                    secondary,
                  ),
                  _buildLeaderboardValueColumn(
                    'Total Price',
                    'PKR ${_formatM(total)}',
                    const Color(0xFF0EA5E9),
                    secondary,
                  ),
                  _buildLeaderboardValueColumn(
                    'Profit',
                    'PKR ${_formatM(profit)}',
                    const Color(0xFFF59E0B),
                    secondary,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildLeaderboardValueColumn(
                    'Received',
                    'PKR ${_formatM(received)}',
                    Colors.teal,
                    secondary,
                  ),
                  _buildLeaderboardValueColumn(
                    'Pending',
                    'PKR ${_formatM(pending)}',
                    Colors.redAccent,
                    secondary,
                  ),
                  Expanded(child: const SizedBox()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketingLeaderboardCard({
    required int rank,
    required String email,
    required int bookings,
    required double earnings,
    required double payable,
    required double profit,
    required bool isDarkMode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color rankColor = rank == 1
        ? const Color(0xFFF59E0B) // Gold
        : rank == 2
        ? const Color(0xFF94A3B8) // Silver
        : rank == 3
        ? const Color(0xFFB45309) // Bronze
        : isDarkMode
        ? Colors.white30
        : Colors.black26;

    final primary = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final border = isSelected
        ? Colors.purple.withValues(alpha: 0.6)
        : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    final cardBg = isSelected
        ? (isDarkMode
              ? Colors.purple.withValues(alpha: 0.08)
              : Colors.purple.withValues(alpha: 0.04))
        : (isDarkMode ? const Color(0xFF0F172A) : AppColors.backgroundLight);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: isSelected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (Rank, Name, Bookings)
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            rankColor == Colors.white30 ||
                                rankColor == Colors.black26
                            ? primary
                            : rankColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: primary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$bookings Tickets',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Detail financial values
              Row(
                children: [
                  _buildLeaderboardValueColumn(
                    'Earnings',
                    'PKR ${_formatM(earnings)}',
                    const Color(0xFF06B6D4),
                    secondary,
                  ),
                  _buildLeaderboardValueColumn(
                    'Payable',
                    'PKR ${_formatM(payable)}',
                    Colors.redAccent,
                    secondary,
                  ),
                  _buildLeaderboardValueColumn(
                    'Profit',
                    'PKR ${_formatM(profit)}',
                    const Color(0xFFF59E0B),
                    secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardValueColumn(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: labelColor)),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, String tabValue) {
    final isSelected = _selectedTab == tabValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabValue;
          _recordsToShow = 10; // Reset pagination slice
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFF334155),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordSummaryCard({
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    final bg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final border = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final sText = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: sText)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualRecordCard({
    required BookingModel booking,
    required bool isDarkMode,
    required Color borderColor,
    required Color cardBg,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final isExpanded = _expandedRecords[booking.id] ?? false;

    // Status chips styling
    final status = booking.status.toLowerCase().trim();
    Color statusColor = Colors.grey;
    if (status == 'approved' ||
        status == 'completed' ||
        status == 'success' ||
        status == 'active') {
      statusColor = AppColors.secondary;
    } else if (status == 'processing' || status == 'pending') {
      statusColor = AppColors.accent;
    } else if (status == 'rejected' || status == 'cancelled') {
      statusColor = AppColors.error;
    }

    final payStatus = booking.paymentStatus.toLowerCase().trim();
    Color payColor = Colors.grey;
    if (payStatus == 'paid') {
      payColor = Colors.green;
    } else if (payStatus == 'partially paid') {
      payColor = Colors.teal;
    } else {
      payColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Basic Row always visible
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            onTap: () {
              setState(() {
                _expandedRecords[booking.id] = !isExpanded;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.customerName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${booking.id}',
                      style: TextStyle(fontSize: 10, color: secondaryTextColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: payColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.paymentStatus,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: payColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Financial values brief
                Row(
                  children: [
                    _buildBriefFinancialColumn(
                      'Total',
                      'PKR ${_formatM(booking.totalPrice)}',
                      const Color(0xFF0EA5E9),
                    ),
                    _buildBriefFinancialColumn(
                      'Received',
                      'PKR ${_formatM(booking.receivedAmount)}',
                      Colors.teal,
                    ),
                    _buildBriefFinancialColumn(
                      'Pending',
                      'PKR ${_formatM(booking.payableAmount)}',
                      Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: secondaryTextColor,
            ),
          ),

          // Detailed secondary metadata visible only when expanded
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Category:',
                    booking.serviceType.toUpperCase(),
                  ),
                  _buildDetailRow('Destination/Property:', booking.destination),
                  _buildDetailRow('Client Phone:', booking.customerPhone),
                  if (booking.passportNumber.isNotEmpty)
                    _buildDetailRow('Passport No:', booking.passportNumber),
                  if (booking.email != null && booking.email!.isNotEmpty)
                    _buildDetailRow('Client Email:', booking.email!),
                  if (booking.serviceType.toLowerCase() == 'ticket') ...[
                    if (booking.fromDestination != null)
                      _buildDetailRow(
                        'From Destination:',
                        booking.fromDestination!,
                      ),
                    if (booking.returnDate != null)
                      _buildDetailRow('Return Date:', booking.returnDate!),
                    if (booking.pnr != null)
                      _buildDetailRow('PNR Code:', booking.pnr!),
                    if (booking.airlinePreference != null)
                      _buildDetailRow(
                        'Airline Pref:',
                        booking.airlinePreference!,
                      ),
                    if (booking.vendor != null)
                      _buildDetailRow('Vendor Name:', booking.vendor!),
                  ],
                  if (booking.serviceType.toLowerCase() == 'visa') ...[
                    if (booking.visaType != null)
                      _buildDetailRow('Visa Type:', booking.visaType!),
                    if (booking.vendorName != null)
                      _buildDetailRow('Vendor:', booking.vendorName!),
                    if (booking.remarks != null && booking.remarks!.isNotEmpty)
                      _buildDetailRow('Remarks:', booking.remarks!),
                  ],
                  _buildDetailRow(
                    'Net Profit:',
                    'PKR ${_formatM(booking.netProfit)}',
                    valueColor: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBriefFinancialColumn(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontSize: 10,
                color: valueColor ?? Colors.white70,
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──── BOTTOM SHEET: CREATE EMPLOYEE & TOGGLE SWITCHES ────
  void _showManageLoginsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter sheetSetState) {
            return Consumer(
              builder: (context, ref, _) {
                final employeesList = ref.watch(employeeListProvider);
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final sheetTextColor = isDarkMode
                    ? Colors.white
                    : AppColors.textPrimaryLight;
                final sheetSecondaryColor = isDarkMode
                    ? const Color(0xFF94A3B8)
                    : AppColors.textSecondaryLight;
                final sheetBg = isDarkMode
                    ? const Color(0xFF0F172A)
                    : Colors.white;
                final fieldBg = isDarkMode
                    ? const Color(0xFF1E293B)
                    : AppColors.backgroundLight;
                final border = isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0);

                return Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  decoration: BoxDecoration(
                    color: sheetBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pull handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Manage Logins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: sheetTextColor,
                        ),
                      ),
                      Text(
                        'Create new employee accounts or toggle active status.',
                        style: TextStyle(
                          fontSize: 11,
                          color: sheetSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // NEW EMPLOYEE FORM CARD
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADD NEW EMPLOYEE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sheetTextColor,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter Email',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: sheetSecondaryColor,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Email is required';
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(v))
                                    return 'Enter valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sheetTextColor,
                                ),
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Temp Password (min 6)',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: sheetSecondaryColor,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Password is required';
                                  if (v.length < 6) return 'Min 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _createEmployee(sheetSetState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Employee Directory (${employeesList.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: sheetTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // SCROLLABLE LIST OF SWITCHES
                      Expanded(
                        child: ListView.builder(
                          itemCount: employeesList.length,
                          itemBuilder: (context, i) {
                            final emp = employeesList[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          emp.email,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: sheetTextColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          emp.isEnabled
                                              ? 'ACCESS ENABLED'
                                              : 'ACCESS DISABLED',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: emp.isEnabled
                                                ? Colors.green
                                                : Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: emp.isEnabled,
                                    activeThumbColor: const Color(0xFF10B981),
                                    onChanged: (v) async {
                                      sheetSetState(() {});
                                      try {
                                        await ref
                                            .read(employeeListProvider.notifier)
                                            .toggleEmployeeAccess(
                                              emp.uid,
                                              emp.isEnabled,
                                            );
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to update status: $e',
                                              ),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _createEmployee(StateSetter sheetSetState) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final messenger = ScaffoldMessenger.of(context);

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await ref
            .read(employeeListProvider.notifier)
            .addEmployee(email, password);
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loader
        _emailController.clear();
        _passwordController.clear();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Employee login created successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        sheetSetState(() {}); // Force bottom sheet update
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loader
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
