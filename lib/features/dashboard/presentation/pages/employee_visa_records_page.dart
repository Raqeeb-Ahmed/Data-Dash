import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../data/models/booking_model.dart';
import '../providers/bookings_provider.dart';

class EmployeeVisaRecordsPage extends ConsumerStatefulWidget {
  const EmployeeVisaRecordsPage({super.key});

  @override
  ConsumerState<EmployeeVisaRecordsPage> createState() =>
      _EmployeeVisaRecordsPageState();
}

class _EmployeeVisaRecordsPageState
    extends ConsumerState<EmployeeVisaRecordsPage> {
  String _searchQuery = '';
  String _selectedStatus = 'All Status';
  String _selectedReference = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 0;
  final int _perPage = 10;

  final List<String> _clientReferences = [
    'A TO Z TOURS',
    'A TO Z TRAVEL BLDRS',
    'A TRAVEL HOUSE',
    'AAK TRAVEL AND TOURS',
    'AAK TRAVELS AND TOURS',
    'ABDUL SALAM',
    'ABU IBRAHIM MULLAH',
    'ACE TRAVEL',
    'AEROMON TRAVELS',
    'AHMAD WORLD TRAVELS',
    'AHMED NOOR TRAVEL',
    'AHMED NOOR TRAVELS',
    'AIR EXCEL MALIK SB',
    'AIR EXCEL MALIK SG',
    'AL HARMAM TRAVELS',
    'AL JAZOLI TRAVELS',
  ];

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'All Status';
      _selectedReference = '';
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
      lastDate: DateTime(2035),
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
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 750;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x660F172A)
        : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDarkMode
        ? const Color(0x15FFFFFF)
        : const Color(0x1F000000);

    // 1. Filter dataset to show Visa service only
    final visaBookings = allBookings
        .where((b) => b.serviceType == 'visa')
        .toList();

    // 2. Scan unique references from visaBookings dynamically
    final Set<String> uniqueRefs = visaBookings
        .map((b) => b.reference?.trim() ?? '')
        .where((ref) => ref.isNotEmpty)
        .toSet();

    // Merge unique values with hardcoded list
    final List<String> displayReferences = [
      ...uniqueRefs,
      ..._clientReferences.where(
        (ref) => !uniqueRefs.any((u) => u.toLowerCase() == ref.toLowerCase()),
      ),
    ];

    // 3. Apply Date Range, Status, Reference, and Search Query Filters
    final filteredList = visaBookings.where((b) {
      // Date range filter
      if (_fromDate != null && b.dateCreated.isBefore(_fromDate!)) return false;
      if (_toDate != null &&
          b.dateCreated.isAfter(_toDate!.add(const Duration(days: 1))))
        return false;

      // Status filter
      if (_selectedStatus != 'All Status' &&
          b.status.toLowerCase() != _selectedStatus.toLowerCase())
        return false;

      // Reference filter
      if (_selectedReference.isNotEmpty) {
        final bookingRef = (b.reference == null || b.reference!.trim().isEmpty)
            ? 'direct'
            : b.reference!.trim().toLowerCase();
        if (bookingRef != _selectedReference.toLowerCase()) return false;
      }

      // Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nameMatch = b.customerName.toLowerCase().contains(query);
        final passportMatch = b.passportNumber.toLowerCase().contains(query);
        final destMatch = b.destination.toLowerCase().contains(query);
        final refMatch = (b.reference ?? '').toLowerCase().contains(query);
        final phoneMatch = b.customerPhone.toLowerCase().contains(query);
        if (!nameMatch &&
            !passportMatch &&
            !destMatch &&
            !refMatch &&
            !phoneMatch)
          return false;
      }

      return true;
    }).toList();

    // 4. Compute counts for Application Status circular chart dynamically
    int approvedCount = 0;
    int processingCount = 0;
    int rejectedCount = 0;
    for (final b in filteredList) {
      final s = b.status.toLowerCase().trim();
      if (s == 'approved') {
        approvedCount++;
      } else if (s == 'processing') {
        processingCount++;
      } else if (s == 'rejected') {
        rejectedCount++;
      }
    }

    // 5. Paginate
    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filteredList.length);
    final pagedList = start >= filteredList.length
        ? <BookingModel>[]
        : filteredList.sublist(start, end);
    final totalPages = (filteredList.length / _perPage).ceil();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        watermarkText: 'VISA RECORDS',
        child: SafeArea(
          child: Column(
            children: [
              // ── Header Controls Block (Responsive LayoutBuilder) ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 650;

                    final Widget titleWidget = Row(
                      children: [
                        Text(
                          'My Visa Records',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('🛂', style: TextStyle(fontSize: 20)),
                      ],
                    );

                    final Widget controlsWidget = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search Bar
                        Container(
                          width: isNarrow ? 160 : 240,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 16,
                                color: secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryColor,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    hintText: 'Search by name...',
                                    hintStyle: TextStyle(
                                      fontSize: 11,
                                      color: secondaryColor.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    isDense: true,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
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
                        const SizedBox(width: 12),
                        // Status Filter Dropdown
                        Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              items:
                                  [
                                        'All Status',
                                        'Approved',
                                        'Processing',
                                        'Rejected',
                                      ]
                                      .map(
                                      (st) => DropdownMenuItem(
                                        value: st,
                                        child: Text(
                                          st,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      )
                                      .toList(),
                              onChanged: (v) => setState(() {
                                _selectedStatus = v!;
                                _currentPage = 0;
                              }),
                            ),
                          ),
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          titleWidget,
                          const SizedBox(height: 12),
                          controlsWidget,
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [titleWidget, controlsWidget],
                      );
                    }
                  },
                ),
              ),

              // ── Date Filters Row (Scrollable wrapper to prevent overflow) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filter by Date: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // From Date picker
                      InkWell(
                        onTap: () => _pickDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            _fromDate == null
                                ? 'From: dd/mm/yyyy'
                                : 'From: ${_formatDate(_fromDate!)}',
                            style: TextStyle(fontSize: 11, color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // To Date picker
                      InkWell(
                        onTap: () => _pickDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E293B)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            _toDate == null
                                ? 'To: dd/mm/yyyy'
                                : 'To: ${_formatDate(_toDate!)}',
                            style: TextStyle(fontSize: 11, color: primaryColor),
                          ),
                        ),
                      ),
                      if (_fromDate != null ||
                          _toDate != null ||
                          _selectedReference.isNotEmpty ||
                          _selectedStatus != 'All Status') ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text(
                            'Clear Filters',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Scrollable Body Area ──
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                    // ── Visual Status & References Filters Layout ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 850;

                        final Widget statusCard = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pie_chart,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Application Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  // Donut Chart dynamic graphic
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CustomPaint(
                                      painter: DoughnutChartPainter(
                                        approved: approvedCount.toDouble(),
                                        processing: processingCount.toDouble(),
                                        rejected: rejectedCount.toDouble(),
                                        textColor: primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // Text legend metrics
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _legendText(
                                          'Approved',
                                          approvedCount,
                                          const Color(0xFF10B981),
                                          primaryColor,
                                        ),
                                        const SizedBox(height: 6),
                                        _legendText(
                                          'Processing',
                                          processingCount,
                                          const Color(0xFFF59E0B),
                                          primaryColor,
                                        ),
                                        const SizedBox(height: 6),
                                        _legendText(
                                          'Rejected',
                                          rejectedCount,
                                          const Color(0xFFEF4444),
                                          primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        final Widget referencesCard = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Filter by Client Reference',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Click on any reference below to isolate their associated clients in the table.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // References buttons grid
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: displayReferences.map((refName) {
                                  final isSelected =
                                      _selectedReference.toLowerCase() ==
                                      refName.toLowerCase();
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedReference = isSelected
                                            ? ''
                                            : refName;
                                        _currentPage = 0;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDarkMode
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.grey[200]),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.transparent
                                              : borderColor,
                                        ),
                                      ),
                                      child: Text(
                                        refName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );

                        if (isDesktop) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: statusCard),
                              const SizedBox(width: 16),
                              Expanded(flex: 4, child: referencesCard),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              statusCard,
                              const SizedBox(height: 16),
                              referencesCard,
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Table Container (Scrollable ScrollWrapper to solve RenderFlex table overflow) ──
                    if (isMobile) ...[
                      // Mobile Card View
                      if (pagedList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No visa bookings found matching filters.',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ...List.generate(pagedList.length, (idx) {
                          final b = pagedList[idx];
                          return _buildBookingMobileCard(
                            context: context,
                            booking: b,
                            serialIndex: start + idx + 1,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            borderColor: borderColor,
                          );
                        }),
                      if (totalPages > 1)
                        _buildPaginationFooter(
                          filteredList.length,
                          totalPages,
                          secondaryColor,
                        ),
                    ] else ...[
                      // Desktop Table View
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 1100, // Fixed desktop-friendly width
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildTableHeaderRow(
                                  isDarkMode,
                                  primaryColor,
                                  secondaryColor,
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(0x1Fffffff),
                                ),
                                if (pagedList.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Center(
                                      child: Text(
                                        'No visa bookings found matching filters.',
                                        style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...List.generate(pagedList.length, (idx) {
                                    final b = pagedList[idx];
                                    return _buildBookingTableRow(
                                      context: context,
                                      booking: b,
                                      serialIndex: start + idx + 1,
                                      isDarkMode: isDarkMode,
                                      primaryColor: primaryColor,
                                      secondaryColor: secondaryColor,
                                      borderColor: borderColor,
                                    );
                                  }),
                                if (totalPages > 1)
                                  _buildPaginationFooter(
                                    filteredList.length,
                                    totalPages,
                                    secondaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
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

  // ── Helper Widgets ──

  Widget _legendText(String label, int count, Color color, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeaderRow(
    bool isDarkMode,
    Color primaryColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDarkMode
          ? const Color(0xFF0F172A).withValues(alpha: 0.3)
          : Colors.grey[100],
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Passport / Name',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Country / Visa Type',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Financials',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Embassy Info',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Vendor Info',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
          ),
          const SizedBox(
            width: 210,
            child: Text(
              'Actions',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.transparent,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingMobileCard({
    required BuildContext context,
    required BookingModel booking,
    required int serialIndex,
    required bool isDarkMode,
    required Color primaryColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    final statusColor = booking.status == 'Approved'
        ? const Color(0xFF10B981)
        : (booking.status == 'Processing'
              ? const Color(0xFFF59E0B)
              : const Color(0xFFEF4444));

    final statusBgColor = booking.status == 'Approved'
        ? const Color(0x1A10B981)
        : (booking.status == 'Processing'
              ? const Color(0x1AF59E0B)
              : const Color(0x1AEF4444));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x0F000000),
          width: 1.0,
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Passport & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF334155)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#$serialIndex',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            booking.customerName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passport: ${booking.passportNumber}',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryColor,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
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

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5),
          ),

          // Details Grid (2-column layout)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Country & Visa Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardInfoRow(
                      icon: Icons.public,
                      label: 'Destination',
                      value: booking.destination,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildCardInfoRow(
                      icon: Icons.assignment_outlined,
                      label: 'Visa Type',
                      value: booking.visaType ?? 'Tourist',
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                    const SizedBox(height: 8),
                    _buildCardInfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Date Created',
                      value: _formatDate(booking.dateCreated),
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Column 2: Financials Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardFinancialsRow(
                      label: 'Total Price',
                      value: booking.totalPrice,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 4),
                    _buildCardFinancialsRow(
                      label: 'Received',
                      value: booking.receivedAmount,
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 4),
                    _buildCardFinancialsRow(
                      label: 'Remaining',
                      value: booking.payableAmount,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 4),
                    _buildCardFinancialsRow(
                      label: 'Profit Margin',
                      value: booking.netProfit,
                      color: const Color(0xFF10B981),
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Collapsible/Simple details row for Embassy & Vendor info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E293B).withValues(alpha: 0.2)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Embassy Status',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sent: ${booking.sentToEmbassyDate ?? '-'}',
                        style: TextStyle(fontSize: 10, color: primaryColor),
                      ),
                      Text(
                        'Recv: ${booking.receivedFromEmbassyDate ?? '-'}',
                        style: TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vendor & Reference',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${booking.reference ?? 'Direct'}',
                        style: TextStyle(fontSize: 10, color: primaryColor),
                      ),
                      Text(
                        'Contact: ${booking.vendorContact ?? '-'}',
                        style: TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions Panel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _openViewModal(context, booking),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 12,
                        color: Color(0xFF8B5CF6),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _openEditModal(context, booking),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _confirmDelete(context, booking),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 12,
                        color: Color(0xFFEF4444),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 9, color: secondaryColor)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFinancialsRow({
    required String label,
    required double value,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          'PKR ${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingTableRow({
    required BuildContext context,
    required BookingModel booking,
    required int serialIndex,
    required bool isDarkMode,
    required Color primaryColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 30,
            child: Text(
              '$serialIndex',
              style: TextStyle(fontSize: 11, color: secondaryColor),
            ),
          ),

          // Passport & Name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.passportNumber,
                  style: TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
            ),
          ),

          // Country / Visa Type
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.destination,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.visaType ?? 'Tourist',
                  style: TextStyle(fontSize: 10, color: secondaryColor),
                ),
              ],
            ),
          ),

          // Status Badge
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: booking.status == 'Approved'
                        ? const Color(0x3310B981)
                        : (booking.status == 'Processing'
                              ? const Color(0x33F59E0B)
                              : const Color(0x33EF4444)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: booking.status == 'Approved'
                          ? const Color(0xFF10B981)
                          : (booking.status == 'Processing'
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFEF4444)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Financials
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Total: ',
                      style: TextStyle(fontSize: 9, color: secondaryColor),
                    ),
                    Text(
                      booking.totalPrice.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Recv: ',
                      style: TextStyle(fontSize: 9, color: secondaryColor),
                    ),
                    Text(
                      booking.receivedAmount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Remn: ',
                      style: TextStyle(fontSize: 9, color: secondaryColor),
                    ),
                    Text(
                      booking.payableAmount.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Profit: ',
                      style: TextStyle(fontSize: 9, color: secondaryColor),
                    ),
                    Text(
                      booking.netProfit.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  booking.paymentStatus,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: booking.paymentStatus == 'Paid'
                        ? const Color(0xFF10B981)
                        : (booking.paymentStatus == 'Partially Paid'
                              ? Colors.amber
                              : Colors.red),
                  ),
                ),
              ],
            ),
          ),

          // Embassy Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sent: ${booking.sentToEmbassyDate ?? '-'}',
                  style: TextStyle(fontSize: 9, color: primaryColor),
                ),
                Text(
                  'Recv: ${booking.receivedFromEmbassyDate ?? '-'}',
                  style: TextStyle(fontSize: 9, color: primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ref: ${booking.reference ?? 'Direct'}',
                  style: TextStyle(fontSize: 8, color: secondaryColor),
                ),
              ],
            ),
          ),

          // Vendor Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cont: ${booking.vendorContact ?? '-'}',
                  style: TextStyle(fontSize: 9, color: primaryColor),
                ),
                Text(
                  'Vend Fee: ${(booking.vendorFee ?? 0.0).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 9, color: secondaryColor),
                ),
                Text(
                  'Emb Fee: ${(booking.embassyFee ?? 0.0).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 9, color: secondaryColor),
                ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 210,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View Button
                InkWell(
                  onTap: () => _openViewModal(context, booking),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'View',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Edit Button
                InkWell(
                  onTap: () => _openEditModal(context, booking),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 10, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Delete Button
                InkWell(
                  onTap: () => _confirmDelete(context, booking),
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 10,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(
    int totalItems,
    int totalPages,
    Color secondaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${(_currentPage * _perPage) + 1}-${((_currentPage + 1) * _perPage).clamp(0, totalItems)} of $totalItems',
            style: TextStyle(fontSize: 11, color: secondaryColor),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text(
                'Page ${_currentPage + 1} of $totalPages',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── VIEW details screen (3-Column Layout matching your mockup details pop-up) ──
  void _openViewModal(BuildContext context, BookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 750;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;

    final column1Children = [
      _detailCell('Full Name', b.customerName, secondaryColor, primaryColor),
      const SizedBox(height: 14),
      _detailCell('Passport', b.passportNumber, secondaryColor, primaryColor),
      const SizedBox(height: 14),
      _detailCell(
        'Passport Expiry',
        b.passportExpiryDate ?? '-',
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell('Email', b.email ?? '-', secondaryColor, primaryColor),
      const SizedBox(height: 14),
      _detailCell('Phone', b.customerPhone, secondaryColor, primaryColor),
    ];

    final column2Children = [
      _detailCell('Country', b.destination, secondaryColor, primaryColor),
      const SizedBox(height: 14),
      _detailCell(
        'Visa Type',
        b.visaType ?? 'Tourist',
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Date',
        _formatDate(b.dateCreated),
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Visa Status',
        b.status,
        secondaryColor,
        primaryColor,
        isStatus: true,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Payment Status',
        b.paymentStatus,
        secondaryColor,
        primaryColor,
        isPayment: true,
      ),
    ];

    final column3Children = [
      _detailCell(
        'Sent to Embassy',
        b.sentToEmbassyDate ?? '-',
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Reference',
        b.reference ?? 'Direct',
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Embassy Fee',
        (b.embassyFee ?? 0.0).toStringAsFixed(0),
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell('Vendor', b.vendorName ?? '-', secondaryColor, primaryColor),
      const SizedBox(height: 14),
      _detailCell(
        'Vendor Contact',
        b.vendorContact ?? '-',
        secondaryColor,
        primaryColor,
      ),
      const SizedBox(height: 14),
      _detailCell(
        'Vendor Fee',
        (b.vendorFee ?? 0.0).toStringAsFixed(0),
        secondaryColor,
        primaryColor,
      ),
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: isMobile
              ? MediaQuery.of(context).size.width * 0.95
              : 800, // Responsive width
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Visa Booking Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // ── Mockup 3-Column Grid Details (Responsive layout check) ──
                if (isMobile) ...[
                  ...column1Children,
                  const SizedBox(height: 14),
                  ...column2Children,
                  const SizedBox(height: 14),
                  ...column3Children,
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: column1Children,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: column2Children,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: column3Children,
                        ),
                      ),
                    ],
                  ),
                ],

                const Divider(height: 32),

                // Remarks span block
                Text(
                  'Remarks',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E293B)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.remarks ?? 'No remarks provided.',
                    style: TextStyle(fontSize: 11, color: primaryColor),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailCell(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isStatus = false,
    bool isPayment = false,
  }) {
    Widget valueWidget;
    if (isStatus) {
      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value == 'Approved'
              ? const Color(0x3310B981)
              : (value == 'Processing'
                    ? const Color(0x33F59E0B)
                    : const Color(0x33EF4444)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: value == 'Approved'
                ? const Color(0xFF10B981)
                : (value == 'Processing'
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFEF4444)),
          ),
        ),
      );
    } else if (isPayment) {
      valueWidget = Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: value == 'Paid'
              ? const Color(0xFF10B981)
              : (value == 'Partially Paid' ? Colors.amber : Colors.red),
        ),
      );
    } else {
      valueWidget = Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9, color: labelColor)),
        const SizedBox(height: 4),
        valueWidget,
      ],
    );
  }

  // ── EDIT modal popup dialog ──
  void _openEditModal(BuildContext context, BookingModel b) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bool isMobile = MediaQuery.of(context).size.width < 750;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final inputBg = isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100]!;

    final formKey = GlobalKey<FormState>();

    // Input fields setup
    final nameController = TextEditingController(text: b.customerName);
    final passportController = TextEditingController(text: b.passportNumber);
    final totalFeeController = TextEditingController(
      text: b.totalPrice.toStringAsFixed(0),
    );
    final receivedFeeController = TextEditingController(
      text: b.receivedAmount.toStringAsFixed(0),
    );
    final remainingFeeController = TextEditingController(
      text: b.payableAmount.toStringAsFixed(0),
    );
    final embassyFeeController = TextEditingController(
      text: (b.embassyFee ?? 0.0).toStringAsFixed(0),
    );
    final vendorFeeController = TextEditingController(
      text: (b.vendorFee ?? 0.0).toStringAsFixed(0),
    );
    final profitController = TextEditingController(
      text: b.netProfit.toStringAsFixed(0),
    );
    final refController = TextEditingController(text: b.reference ?? '');
    final emailController = TextEditingController(text: b.email ?? '');
    final phoneController = TextEditingController(text: b.customerPhone);
    final vendorNameController = TextEditingController(
      text: b.vendorName ?? '',
    );
    final vendorContactController = TextEditingController(
      text: b.vendorContact ?? '',
    );
    final remarksController = TextEditingController(text: b.remarks ?? '');

    String status = b.status;
    String visaType = b.visaType ?? 'Tourist';
    String country = b.destination;
    String calculatedPaymentStatus = b.paymentStatus;

    // Dynamic dropdown lists builder to avoid Assertion crashes if database has custom values
    final List<String> countryDropdownItems = [
      'Belgium',
      'Malaysia',
      'Uzbekistan',
      'Thailand',
      'Indonesia',
      'Singapore',
      'Austria',
      'Hungary',
      'Schengen',
    ];
    if (!countryDropdownItems.contains(country)) {
      countryDropdownItems.add(country);
    }

    final List<String> visaTypeDropdownItems = [
      'Tourist',
      'Work',
      'Student',
      'Business',
    ];
    if (!visaTypeDropdownItems.contains(visaType)) {
      visaTypeDropdownItems.add(visaType);
    }

    final List<String> statusDropdownItems = [
      'Approved',
      'Processing',
      'Rejected',
    ];
    if (!statusDropdownItems.contains(status)) {
      statusDropdownItems.add(status);
    }

    void calculate() {
      final double total = double.tryParse(totalFeeController.text) ?? 0.0;
      final double received =
          double.tryParse(receivedFeeController.text) ?? 0.0;
      final double embassy = double.tryParse(embassyFeeController.text) ?? 0.0;
      final double vendor = double.tryParse(vendorFeeController.text) ?? 0.0;

      final double remaining = (total - received) < 0 ? 0.0 : (total - received);
      remainingFeeController.text = remaining.toStringAsFixed(0);

      final double profit = total - embassy - vendor;
      profitController.text = profit.toStringAsFixed(0);

      if (received == 0) {
        calculatedPaymentStatus = 'Unpaid';
      } else if (remaining <= 0) {
        calculatedPaymentStatus = 'Paid';
      } else {
        calculatedPaymentStatus = 'Partially Paid';
      }
    }

    totalFeeController.addListener(calculate);
    receivedFeeController.addListener(calculate);
    embassyFeeController.addListener(calculate);
    vendorFeeController.addListener(calculate);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Dialog(
          backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: isMobile ? MediaQuery.of(context).size.width * 0.95 : 700,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Visa Booking Form',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Forms inputs (stacked on mobile, side-by-side on desktop)
                    _formRow(isMobile, [
                      Expanded(
                        child: _modalInput(
                          'Full Name',
                          nameController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                        ),
                      ),
                      Expanded(
                        child: _modalInput(
                          'Passport Number',
                          passportController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Country Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Country',
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: country,
                              style: TextStyle(fontSize: 12, color: primaryColor),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              decoration: _modalInputDecoration(
                                inputBg,
                                secondaryColor,
                              ),
                              items: countryDropdownItems
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => country = v!,
                            ),
                          ],
                        ),
                      ),
                      // Visa Type Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visa Type',
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: visaType,
                              style: TextStyle(fontSize: 12, color: primaryColor),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              decoration: _modalInputDecoration(
                                inputBg,
                                secondaryColor,
                              ),
                              items: visaTypeDropdownItems
                                  .map(
                                    (vt) => DropdownMenuItem(
                                      value: vt,
                                      child: Text(
                                        vt,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => visaType = v!,
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Visa Status Dropdown
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visa Status',
                              style: TextStyle(
                                fontSize: 10,
                                color: secondaryColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: status,
                              style: TextStyle(fontSize: 12, color: primaryColor),
                              dropdownColor: isDarkMode
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              decoration: _modalInputDecoration(
                                inputBg,
                                secondaryColor,
                              ),
                              items: statusDropdownItems
                                  .map(
                                    (st) => DropdownMenuItem(
                                      value: st,
                                      child: Text(
                                        st,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => status = v!,
                            ),
                          ],
                        ),
                      ),
                      // Total Fee
                      Expanded(
                        child: _modalInput(
                          'Total Fee',
                          totalFeeController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isNumeric: true,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Received Fee
                      Expanded(
                        child: _modalInput(
                          'Received Fee',
                          receivedFeeController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isNumeric: true,
                        ),
                      ),
                      // Remaining Fee (LOCKED)
                      Expanded(
                        child: _modalInput(
                          'Remaining Fee (Locked)',
                          remainingFeeController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isEnabled: false,
                          isRequired: false,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Embassy Fee
                      Expanded(
                        child: _modalInput(
                          'Embassy Fee',
                          embassyFeeController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isNumeric: true,
                          isRequired: false,
                        ),
                      ),
                      // Vendor Fee
                      Expanded(
                        child: _modalInput(
                          'Vendor Fee',
                          vendorFeeController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isNumeric: true,
                          isRequired: false,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Calculated Profit (LOCKED)
                      Expanded(
                        child: _modalInput(
                          'Calculated Profit (Locked)',
                          profitController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isEnabled: false,
                          isRequired: false,
                        ),
                      ),
                      // Reference
                      Expanded(
                        child: _modalInput(
                          'Reference',
                          refController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isRequired: false,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Email
                      Expanded(
                        child: _modalInput(
                          'Email Address',
                          emailController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isRequired: false,
                        ),
                      ),
                      // Phone
                      Expanded(
                        child: _modalInput(
                          'Contact Phone',
                          phoneController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _formRow(isMobile, [
                      // Vendor Name
                      Expanded(
                        child: _modalInput(
                          'Vendor Name',
                          vendorNameController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isRequired: false,
                        ),
                      ),
                      // Vendor Contact
                      Expanded(
                        child: _modalInput(
                          'Vendor Contact',
                          vendorContactController,
                          primaryColor,
                          secondaryColor,
                          inputBg,
                          isRequired: false,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    // Remarks
                    _modalInput(
                      'Remarks / Details',
                      remarksController,
                      primaryColor,
                      secondaryColor,
                      inputBg,
                      maxLines: 3,
                      isRequired: false,
                    ),
                    const SizedBox(height: 20),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updated = BookingModel(
                                id: b.id,
                                serviceType: 'visa',
                                customerName: nameController.text,
                                customerPhone: phoneController.text,
                                passportNumber: passportController.text,
                                destination: country,
                                dateCreated: b.dateCreated,
                                status: status,
                                paymentStatus: calculatedPaymentStatus,
                                employeeId: b.employeeId,
                                employeeName: b.employeeName,
                                totalPrice:
                                    double.tryParse(totalFeeController.text) ??
                                    0.0,
                                receivedAmount:
                                    double.tryParse(
                                      receivedFeeController.text,
                                    ) ??
                                    0.0,
                                payableAmount:
                                    double.tryParse(
                                      remainingFeeController.text,
                                    ) ??
                                    0.0,
                                netProfit:
                                    double.tryParse(profitController.text) ??
                                    0.0,
                                // Visa Details
                                passportExpiryDate: b.passportExpiryDate,
                                visaType: visaType,
                                embassyFee:
                                    double.tryParse(
                                      embassyFeeController.text,
                                    ) ??
                                    0.0,
                                vendorName: vendorNameController.text.isNotEmpty
                                    ? vendorNameController.text
                                    : null,
                                vendorContact:
                                    vendorContactController.text.isNotEmpty
                                    ? vendorContactController.text
                                    : null,
                                vendorFee:
                                    double.tryParse(vendorFeeController.text) ??
                                    0.0,
                                sentToEmbassyDate: b.sentToEmbassyDate,
                                receivedFromEmbassyDate:
                                    b.receivedFromEmbassyDate,
                                remarks: remarksController.text.isNotEmpty
                                    ? remarksController.text
                                    : null,
                                email: emailController.text.isNotEmpty
                                    ? emailController.text
                                    : null,
                                reference: refController.text.isNotEmpty
                                    ? refController.text
                                    : null,
                              );

                              ref
                                  .read(bookingsProvider.notifier)
                                  .updateBooking(updated);
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Visa booking updated successfully!',
                                  ),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Row widget that stacks elements vertically on mobile, and side-by-side on desktop
  Widget _formRow(bool isMobile, List<Widget> children) {
    // Strip Expanded wrappers for Column layout to prevent rendering issues in scroll view
    final List<Widget> processedChildren = children.map((c) {
      if (c is Expanded) return c.child;
      return c;
    }).toList();

    if (isMobile) {
      final List<Widget> spacedChildren = [];
      for (int i = 0; i < processedChildren.length; i++) {
        spacedChildren.add(processedChildren[i]);
        if (i < processedChildren.length - 1) {
          spacedChildren.add(const SizedBox(height: 12));
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spacedChildren,
      );
    } else {
      final List<Widget> spacedChildren = [];
      for (int i = 0; i < children.length; i++) {
        spacedChildren.add(children[i]);
        if (i < children.length - 1) {
          spacedChildren.add(const SizedBox(width: 12));
        }
      }
      return Row(children: spacedChildren);
    }
  }

  // Delete Action Confirmation alert popup
  void _confirmDelete(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : Colors.white,
        title: const Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete the visa booking for ${booking.customerName}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(bookingsProvider.notifier)
                    .deleteBooking(booking.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visa booking deleted successfully!'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Delete failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modalInput(
    String label,
    TextEditingController ctrl,
    Color primaryColor,
    Color secondaryColor,
    Color inputBg, {
    bool isNumeric = false,
    bool isEnabled = true,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: secondaryColor)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          enabled: isEnabled,
          maxLines: maxLines,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: TextStyle(
            fontSize: 12,
            color: isEnabled
                ? primaryColor
                : primaryColor.withValues(alpha: 0.6),
          ),
          decoration: _modalInputDecoration(inputBg, secondaryColor),
          validator: (v) {
            if (isRequired && (v == null || v.isEmpty)) {
              return 'Enter field data';
            }
            return null;
          },
        ),
      ],
    );
  }

  InputDecoration _modalInputDecoration(Color inputBg, Color secondaryColor) {
    return InputDecoration(
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.15)),
      ),
    );
  }
}

// ── CUSTOM PAINTER FOR RADIAL DONUT CHART ──
class DoughnutChartPainter extends CustomPainter {
  final double approved;
  final double processing;
  final double rejected;
  final Color textColor;

  DoughnutChartPainter({
    required this.approved,
    required this.processing,
    required this.rejected,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = approved + processing + rejected;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;

    final paintBg = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, paintBg);

    if (total == 0) return;

    final double approvedAngle = (approved / total) * 2 * math.pi;
    final double processingAngle = (processing / total) * 2 * math.pi;
    final double rejectedAngle = (rejected / total) * 2 * math.pi;

    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;

    // Approved Arc
    if (approvedAngle > 0) {
      final paintApproved = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        startAngle + 0.05,
        approvedAngle - 0.1,
        false,
        paintApproved,
      );
      startAngle += approvedAngle;
    }

    // Processing Arc
    if (processingAngle > 0) {
      final paintProcessing = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        startAngle + 0.05,
        processingAngle - 0.1,
        false,
        paintProcessing,
      );
      startAngle += processingAngle;
    }

    // Rejected Arc
    if (rejectedAngle > 0) {
      final paintRejected = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        startAngle + 0.05,
        rejectedAngle - 0.1,
        false,
        paintRejected,
      );
    }

    // Center text label displaying total
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${total.toInt()}',
        style: TextStyle(
          fontSize: 16,
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
  bool shouldRepaint(covariant DoughnutChartPainter oldDelegate) {
    return oldDelegate.approved != approved ||
        oldDelegate.processing != processing ||
        oldDelegate.rejected != rejected;
  }
}
