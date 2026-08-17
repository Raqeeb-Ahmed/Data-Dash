import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../data/models/booking_model.dart';
import '../providers/bookings_provider.dart';

class RecordsDashboardPage extends ConsumerStatefulWidget {
  const RecordsDashboardPage({super.key});

  @override
  ConsumerState<RecordsDashboardPage> createState() =>
      _RecordsDashboardPageState();
}

class _RecordsDashboardPageState extends ConsumerState<RecordsDashboardPage> {
  String _searchQuery = '';
  String _selectedService = 'All Services';
  String _selectedStatus = 'All Status';
  String _selectedPayment = 'All Payments';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 0;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
  }

  void _applyFilters() {
    ref.read(bookingsFilterProvider.notifier).state = BookingsFilter(
      searchQuery: _searchQuery,
      selectedService: _selectedService,
      selectedStatus: _selectedStatus,
      selectedPayment: _selectedPayment,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    setState(() {
      _currentPage = 0;
    });
  }

  void _resetFilters() {
    ref.read(bookingsFilterProvider.notifier).reset();
    setState(() {
      _searchQuery = '';
      _selectedService = 'All Services';
      _selectedStatus = 'All Status';
      _selectedPayment = 'All Payments';
      _fromDate = null;
      _toDate = null;
      _currentPage = 0;
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
      setState(() => isFrom ? _fromDate = picked : _toDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(bookingStatsProvider);
    final filteredBookings = ref.watch(filteredBookingsProvider);

    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filteredBookings.length);
    final pagedBookings = start >= filteredBookings.length
        ? <BookingModel>[]
        : filteredBookings.sublist(start, end);
    final totalPages = (filteredBookings.length / _perPage).ceil();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primary = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondary = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x660F172A)
        : Colors.white.withValues(alpha: 0.90);
    final border = isDarkMode
        ? const Color(0x18FFFFFF)
        : const Color(0x1F000000);

    final cardTotalBookings = _card(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bookings',
                style: TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.copy_outlined,
                size: 12,
                color: Color(0xFF94A3BB),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${stats.visaCount}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 6),
          // Status Row: Closes immediately after the 3 chips
          Row(
            children: [
              _miniChip('${stats.totalApproved}', Colors.green, isDarkMode),
              const SizedBox(width: 4),
              _miniChip('${stats.totalProcessing}', Colors.amber, isDarkMode),
              const SizedBox(width: 4),
              _miniChip('${stats.totalRejected}', Colors.red, isDarkMode),
            ],
          ),
        ],
      ),
    );

    final cardAllServices = _card(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Services',
                style: TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.grid_view_outlined,
                size: 12,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${stats.totalBookings}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 8),
          _serviceRow('VISAS', stats.visaCount, const Color(0xFF6366F1)),
          _serviceRow('HOTELS', stats.hotelCount, const Color(0xFF10B981)),
          _serviceRow('UMRAH', stats.umrahCount, const Color(0xFFF59E0B)),
          _serviceRow('TICKETS', stats.ticketCount, const Color(0xFF0EA5E9)),
        ],
      ),
    );

    final cardTotalReceivable = _card(
      isDarkMode: isDarkMode,
      accentColor: const Color(0xFF10B981),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Receivable',
                style: TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 12,
                color: Color(0xFF10B981),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PKR ${_formatPKR(stats.totalReceivable)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECEIVED PKR',
                      style: TextStyle(fontSize: 8, color: secondary),
                    ),
                    Text(
                      _formatPKR(stats.totalReceived),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PENDING PKR',
                      style: TextStyle(fontSize: 8, color: secondary),
                    ),
                    Text(
                      _formatPKR(stats.totalPending),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final cardNetProfit = _card(
      isDarkMode: isDarkMode,
      accentColor: const Color(0xFF6366F1),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Profit',
                style: TextStyle(
                  fontSize: 10,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.trending_up, size: 12, color: Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'PKR ${_formatPKR(stats.totalNetProfit)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'MARGIN',
                style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
              ),
              Text(
                '${stats.totalReceivable > 0 ? (stats.totalNetProfit / stats.totalReceivable * 100).toStringAsFixed(1) : 0} %',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0x2210B981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HEALTHY',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final cardPaid = _smallCard(
      'Paid',
      '${stats.totalPaid}',
      const Color(0xFF10B981),
      Icons.check_circle_outline,
      isDarkMode,
    );
    final cardUnpaid = _smallCard(
      'Unpaid',
      '${stats.totalUnpaid}',
      const Color(0xFFEF4444),
      Icons.cancel_outlined,
      isDarkMode,
    );
    final cardEmployees = _smallCard(
      'Employees',
      '4',
      const Color(0xFF8B5CF6),
      Icons.people_outline,
      isDarkMode,
    );
    final cardPending = _smallCard(
      'Pending',
      'PKR ${_formatPKR(stats.totalPending)}',
      const Color(0xFFF59E0B),
      Icons.hourglass_empty,
      isDarkMode,
      compact: true,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ──────────────── Scrollable Content ────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(14),
                    children: [
                    // ── STAT METRICS GRID (RESPONSIVE) ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 800;

                        if (isDesktop) {
                          // Desktop/Tablet layout: 2 Rows of 4 equal columns
                          return Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardTotalBookings),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardAllServices),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardTotalReceivable),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardNetProfit),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardPaid),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardUnpaid),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardEmployees),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardPending),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // Mobile layout: 4 Rows of 2 equal columns (keeps layout readable)
                          return Column(
                            children: [
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardTotalBookings),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardAllServices),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardTotalReceivable),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardNetProfit),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardPaid),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardUnpaid),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: cardEmployees),
                                    const SizedBox(width: 10),
                                    Expanded(child: cardPending),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── SEARCH & FILTER BAR ──
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDarkMode
                                    ? const Color(0xFF334155)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(Icons.search, size: 16, color: secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    textAlignVertical: TextAlignVertical.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Search by name, passport, destination...',
                                      hintStyle: TextStyle(
                                        fontSize: 12,
                                        color: secondary,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),

                                      isDense: true,
                                    ),
                                    onChanged: (v) {
                                      _searchQuery = v;
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Date pickers row
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(true),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDarkMode
                                            ? const Color(0xFF334155)
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _fromDate == null
                                              ? 'From'
                                              : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _pickDate(false),
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDarkMode
                                            ? const Color(0xFF334155)
                                            : Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _toDate == null
                                              ? 'To'
                                              : '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Dropdowns row
                          Row(
                            children: [
                              Expanded(
                                child: _dropdown(
                                  value: _selectedService,
                                  items: [
                                    'All Services',
                                    'visa',
                                    'ticket',
                                    'umrah',
                                    'hotel',
                                    'insurance',
                                  ],
                                  onChanged: (v) {
                                    _selectedService = v!;
                                    _applyFilters();
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _dropdown(
                                  value: _selectedStatus,
                                  items: [
                                    'All Status',
                                    'Approved',
                                    'Processing',
                                    'Rejected',
                                  ],
                                  onChanged: (v) {
                                    _selectedStatus = v!;
                                    _applyFilters();
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _dropdown(
                                  value: _selectedPayment,
                                  items: ['All Payments', 'Paid', 'Unpaid'],
                                  onChanged: (v) {
                                    _selectedPayment = v!;
                                    _applyFilters();
                                  },
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: _resetFilters,
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── RECORDS COUNT ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${pagedBookings.length} of ${filteredBookings.length} records',
                          style: TextStyle(fontSize: 11, color: secondary),
                        ),
                        Row(
                          children: [
                            _exportBtn(
                              'PDF',
                              const Color(0xFFEF4444),
                              Icons.picture_as_pdf_outlined,
                            ),
                            const SizedBox(width: 8),
                            _exportBtn(
                              'CSV',
                              const Color(0xFF10B981),
                              Icons.table_view_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ── BOOKING CARDS LIST ──
                    ...pagedBookings.asMap().entries.map((e) {
                      final i = e.key;
                      final b = e.value;
                      return _buildRecordCard(
                        b,
                        _currentPage * _perPage + i + 1,
                        isDarkMode,
                        primary,
                        secondary,
                      );
                    }),

                    // ── PAGINATION ──
                    if (totalPages > 1) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _pageBtn(
                            'Prev',
                            _currentPage > 0,
                            () => setState(() => _currentPage--),
                            isDarkMode,
                          ),
                          const SizedBox(width: 6),
                          ...List.generate(totalPages.clamp(0, 5), (i) {
                            final isActive = i == _currentPage;
                            return GestureDetector(
                              onTap: () => setState(() => _currentPage = i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF6366F1)
                                      : (isDarkMode
                                            ? const Color(0x330F172A)
                                            : Colors.white),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.transparent
                                        : border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.white
                                          : secondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 6),
                          _pageBtn(
                            'Next',
                            _currentPage < totalPages - 1,
                            () => setState(() => _currentPage++),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _card({
    required bool isDarkMode,
    required Widget child,
    Color? accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor != null
              ? accentColor.withValues(alpha: 0.2)
              : (isDarkMode
                    ? const Color(0x18FFFFFF)
                    : const Color(0x1F000000)),
        ),
      ),
      child: child,
    );
  }

  Widget _smallCard(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDarkMode, {
    bool compact = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 9 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _miniChip(String val, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        val,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _serviceRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            '$label ',
            style: const TextStyle(fontSize: 8, color: Color(0xFF94A3B8)),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? const Color(0xFF334155) : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.white : AppColors.textPrimaryLight,
          ),
          dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: isDarkMode ? Colors.white60 : Colors.black45,
          ),
          items: items
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, style: const TextStyle(fontSize: 10)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _exportBtn(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _pageBtn(
    String label,
    bool enabled,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? (isDarkMode ? const Color(0x330F172A) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: enabled
                ? (isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x1F000000))
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: enabled
                ? (isDarkMode ? Colors.white70 : Colors.black54)
                : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    BookingModel b,
    int rowNum,
    bool isDarkMode,
    Color primary,
    Color secondary,
  ) {
    Color statusColor;
    Color statusBg;
    switch (b.status) {
      case 'Approved':
        statusColor = const Color(0xFF10B981);
        statusBg = const Color(0x2210B981);
        break;
      case 'Rejected':
        statusColor = const Color(0xFFEF4444);
        statusBg = const Color(0x22EF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusBg = const Color(0x22F59E0B);
    }

    Color serviceColor;
    switch (b.serviceType.toLowerCase()) {
      case 'visa':
        serviceColor = const Color(0xFF6366F1);
        break;
      case 'ticket':
        serviceColor = const Color(0xFF0EA5E9);
        break;
      case 'umrah':
        serviceColor = const Color(0xFFF59E0B);
        break;
      case 'hotel':
        serviceColor = const Color(0xFF10B981);
        break;
      default:
        serviceColor = const Color(0xFFEC4899);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0x660F172A)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0x18FFFFFF) : const Color(0x1F000000),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Number, Service badge, Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#$rowNum',
                    style: TextStyle(
                      fontSize: 11,
                      color: secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: serviceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.serviceType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: serviceColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Actions
                  _actionIcon(
                    Icons.visibility_outlined,
                    const Color(0xFF0EA5E9),
                  ),
                  const SizedBox(width: 4),
                  _actionIcon(Icons.edit_outlined, const Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  _actionIcon(Icons.delete_outline, const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Customer name + passport
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: secondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  b.customerName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.credit_card_outlined, size: 11, color: secondary),
              const SizedBox(width: 4),
              Text(
                b.passportNumber,
                style: TextStyle(fontSize: 10, color: secondary),
              ),
              const Spacer(),
              Icon(Icons.person_4_outlined, size: 11, color: secondary),
              const SizedBox(width: 4),
              Text(
                b.employeeName,
                style: TextStyle(fontSize: 10, color: secondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Row 3: Destination & Date
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 11, color: secondary),
              const SizedBox(width: 4),
              Text(
                b.destination,
                style: TextStyle(fontSize: 11, color: primary),
              ),
              const Spacer(),
              Icon(Icons.calendar_today, size: 11, color: secondary),
              const SizedBox(width: 4),
              Text(
                '${b.dateCreated.day}/${b.dateCreated.month}/${b.dateCreated.year}',
                style: TextStyle(fontSize: 10, color: secondary),
              ),
            ],
          ),
          const Divider(height: 14, thickness: 0.3),
          // Row 4: Financials
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _finRow(
                'Total',
                'PKR ${_formatPKR(b.totalPrice)}',
                primary,
                secondary,
              ),
              _finRow(
                'Paid',
                'PKR ${_formatPKR(b.receivedAmount)}',
                const Color(0xFF10B981),
                secondary,
              ),
              _finRow(
                'Remaining',
                'PKR ${_formatPKR(b.payableAmount)}',
                const Color(0xFFEF4444),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 13, color: color),
    );
  }

  Widget _finRow(
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

  String _formatPKR(double amount) {
    if (amount == amount.toInt()) {
      return _addCommas(amount.toInt().toString());
    } else {
      return _addCommas(amount.toStringAsFixed(2));
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
