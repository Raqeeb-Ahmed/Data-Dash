import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/search_provider.dart';

class UniversalSearchPage extends ConsumerStatefulWidget {
  const UniversalSearchPage({super.key});

  @override
  ConsumerState<UniversalSearchPage> createState() =>
      _UniversalSearchPageState();
}

class _UniversalSearchPageState extends ConsumerState<UniversalSearchPage> {
  String _searchQuery = '';
  String _selectedCategory = 'all'; // all, visa, ticket, umrah, insurance
  int _currentPage = 1;
  final int _itemsPerPage = 15;
  late final TextEditingController _searchController;

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
    final allResults = ref.watch(universalSearchProvider);
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

    // 1. Filtering
    final filteredResults = allResults.where((r) {
      // Category filter
      if (_selectedCategory != 'all' && r.type != _selectedCategory) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(query);
        final matchDetails = r.details.toLowerCase().contains(query);
        final matchId = r.id.toLowerCase().contains(query);
        return matchName || matchDetails || matchId;
      }
      return true;
    }).toList();

    // 2. Pagination math
    final totalResults = filteredResults.length;
    final totalPages = (totalResults / _itemsPerPage).ceil().clamp(1, 99999);
    if (_currentPage > totalPages) {
      _currentPage = totalPages;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, totalResults);
    final paginatedResults = filteredResults.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ──── HEADER ────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      'Universal Search',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Instantly query across all your operations. Filter by names, ticket numbers, statuses, and more.',
                      style: TextStyle(fontSize: 11, color: secondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ──── SEARCH INPUT ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
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
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Start typing a name, passport, destination...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: secondaryTextColor,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) {
                            setState(() {
                              _searchQuery = v;
                              _currentPage = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ──── CATEGORY PILLS & STATS COUNTER ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter Pills
                    Row(
                      children: [
                        _buildFilterPill('All Records', 'all', isDarkMode),
                        const SizedBox(width: 6),
                        _buildFilterPill('Visas', 'visa', isDarkMode),
                        const SizedBox(width: 6),
                        _buildFilterPill('Tickets', 'ticket', isDarkMode),
                        const SizedBox(width: 6),
                        _buildFilterPill('Umrah', 'umrah', isDarkMode),
                        const SizedBox(width: 6),
                        _buildFilterPill('Insurance', 'insurance', isDarkMode),
                      ],
                    ),
                    // Stats
                    Text(
                      'Found ${totalResults.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} results',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ──── RESULTS LIST VIEW ────
              Expanded(
                child: paginatedResults.isEmpty
                    ? Center(
                        child: Text(
                          'No records found matching your query.',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: paginatedResults.length,
                        itemBuilder: (context, idx) {
                          final r = paginatedResults[idx];
                          return _buildSearchResultCard(
                            r,
                            cardBg,
                            borderColor,
                            primaryTextColor,
                            secondaryTextColor,
                            isDarkMode,
                          );
                        },
                      ),
              ),

              // ──── PAGINATION CONTROLS FOOTER ────
              if (totalResults > 0)
                _buildPaginationFooter(
                  totalResults,
                  startIndex + 1,
                  endIndex,
                  totalPages,
                  primaryTextColor,
                  secondaryTextColor,
                  cardBg,
                  borderColor,
                  isDarkMode,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Filter Pill Button
  Widget _buildFilterPill(String label, String categoryKey, bool isDarkMode) {
    final isSelected = _selectedCategory == categoryKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
          _currentPage = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5)
              : (isDarkMode ? const Color(0x33FFFFFF) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDarkMode
                      ? const Color(0x18FFFFFF)
                      : const Color(0x1F000000)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDarkMode ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  // Individual Search Result Card
  Widget _buildSearchResultCard(
    SearchResultModel r,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
    Color secondaryColor,
    bool isDarkMode,
  ) {
    // Icon selection
    IconData icon;
    Color iconColor;
    String badgeText;

    switch (r.type) {
      case 'visa':
        icon = Icons.assignment_turned_in_outlined;
        iconColor = const Color(0xFF6366F1);
        badgeText = 'VISA';
        break;
      case 'ticket':
        icon = Icons.flight_takeoff_outlined;
        iconColor = const Color(0xFFEC4899);
        badgeText = 'TICKET';
        break;
      case 'umrah':
        icon = Icons.mosque_outlined;
        iconColor = const Color(0xFFEAB308);
        badgeText = 'UMRAH';
        break;
      case 'insurance':
        icon = Icons.verified_user_outlined;
        iconColor = const Color(0xFF06B6D4);
        badgeText = 'INSURANCE';
        break;
      default:
        icon = Icons.hotel_outlined;
        iconColor = const Color(0xFF10B981);
        badgeText = 'HOTEL';
    }

    // Status colors
    Color statusBg;
    Color statusText;
    if (r.status.toLowerCase() == 'approved' ||
        r.status.toLowerCase() == 'confirmed' ||
        r.status.toLowerCase() == 'active') {
      statusBg = const Color(0x1110B981);
      statusText = const Color(0xFF10B981);
    } else if (r.status.toLowerCase() == 'pending' ||
        r.status.toLowerCase() == 'booked' ||
        r.status.toLowerCase() == 'processing') {
      statusBg = const Color(0x11EAB308);
      statusText = const Color(0xFFEAB308);
    } else {
      statusBg = const Color(0x11EF4444);
      statusText = const Color(0xFFEF4444);
    }

    final numberFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formatNum(double num) {
      return num.toStringAsFixed(
        0,
      ).replaceAllMapped(numberFormat, (Match m) => '${m[1]},');
    }

    return GestureDetector(
      onTap: () => _showDetailsModal(context, r, isDarkMode),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
          // Category Icon Circle
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),

          // Name and Travel Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 7,
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.details,
                      style: TextStyle(fontSize: 10, color: secondaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              r.status.toUpperCase(),
              style: TextStyle(
                fontSize: 8,
                color: statusText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Financial Columns
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildAmountColumn(
                  'PAYABLE',
                  formatNum(r.payable),
                  isDarkMode ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 12),
                _buildAmountColumn(
                  'RECEIVED',
                  formatNum(r.received),
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                _buildAmountColumn(
                  'PROFIT',
                  formatNum(r.profit),
                  const Color(0xFF06B6D4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Navigation Button
          Icon(Icons.chevron_right, size: 16, color: secondaryColor),
        ],
      ),
    ),
  );
}

  Widget _buildAmountColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 7,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Pagination Footer
  Widget _buildPaginationFooter(
    int total,
    int from,
    int to,
    int totalPages,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $from to $to of $total entries',
            style: TextStyle(fontSize: 10, color: secondaryColor),
          ),
          // Pagination numbers Row
          Row(
            children: [
              // Prev Button
              _buildPaginationButton(
                child: Icon(
                  Icons.chevron_left,
                  size: 12,
                  color: _currentPage > 1 ? primaryColor : Colors.grey,
                ),
                onTap: _currentPage > 1
                    ? () => setState(() => _currentPage--)
                    : null,
                borderColor: borderColor,
              ),
              const SizedBox(width: 4),

              // Page Numbers
              ..._buildPageNumbers(
                totalPages,
                cardBg,
                borderColor,
                primaryColor,
              ),

              const SizedBox(width: 4),
              // Next Button
              _buildPaginationButton(
                child: Icon(
                  Icons.chevron_right,
                  size: 12,
                  color: _currentPage < totalPages ? primaryColor : Colors.grey,
                ),
                onTap: _currentPage < totalPages
                    ? () => setState(() => _currentPage++)
                    : null,
                borderColor: borderColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(
    int totalPages,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
  ) {
    final List<Widget> list = [];
    int start = (_currentPage - 2).clamp(1, totalPages);
    int end = (start + 4).clamp(1, totalPages);
    if (end - start < 4) {
      start = (end - 4).clamp(1, totalPages);
    }

    for (int i = start; i <= end; i++) {
      final isSelected = _currentPage == i;
      list.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: _buildPaginationButton(
            child: Text(
              '$i',
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
            onTap: () => setState(() => _currentPage = i),
            isSelected: isSelected,
            borderColor: borderColor,
          ),
        ),
      );
    }
    return list;
  }

  Widget _buildPaginationButton({
    required Widget child,
    required VoidCallback? onTap,
    bool isSelected = false,
    required Color borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.transparent : borderColor,
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  void _showDetailsModal(BuildContext context, SearchResultModel r, bool isDarkMode) {
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final dialogBg = isDarkMode ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDarkMode ? const Color(0x18FFFFFF) : const Color(0x1F000000);
    
    Color statusColor;
    if (r.status.toLowerCase() == 'approved' || r.status.toLowerCase() == 'confirmed' || r.status.toLowerCase() == 'active') {
      statusColor = const Color(0xFF10B981);
    } else if (r.status.toLowerCase() == 'pending' || r.status.toLowerCase() == 'booked' || r.status.toLowerCase() == 'processing') {
      statusColor = const Color(0xFFEAB308);
    } else {
      statusColor = const Color(0xFFEF4444);
    }

    final dateStr = '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
    
    // Extracting details for the modal columns
    String destination = r.details.split('•').last.trim();
    String vendor = r.type == 'insurance' ? r.details.split('•')[1].trim() : 'HILAL';
    if (r.type == 'ticket') {
      destination = r.details;
      vendor = 'Airline Booking';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dialogBg.withValues(alpha: 0.96),
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Date Added and Status
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalDetailItem('DATE ADDED', dateStr, secondaryColor, primaryColor),
                      ),
                      Expanded(
                        child: _buildModalDetailItem('STATUS', r.status.toUpperCase(), secondaryColor, statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Destination / Route and Vendor / Info
                  Row(
                    children: [
                      Expanded(
                        child: _buildModalDetailItem('DESTINATION / ROUTE', destination, secondaryColor, primaryColor),
                      ),
                      Expanded(
                        child: _buildModalDetailItem('VENDOR / INFO', vendor, secondaryColor, primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Agent / Info
                  _buildModalDetailItem('AGENT / INFO', 'Tourism', secondaryColor, primaryColor),
                  const SizedBox(height: 20),

                  // ── INTERNAL FINANCIALS ──
                  Text(
                    'INTERNAL FINANCIALS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 16, thickness: 0.3),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _buildModalDetailItem(
                          'PAYABLE VIA / COST',
                          r.payable.toStringAsFixed(0),
                          secondaryColor,
                          isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      Expanded(
                        child: _buildModalDetailItem(
                          'REC. VIA/INVOICE',
                          r.received.toStringAsFixed(0),
                          secondaryColor,
                          const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: _buildModalDetailItem(
                          'NET PROFIT',
                          r.profit.toStringAsFixed(0),
                          secondaryColor,
                          const Color(0xFF06B6D4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── REMARKS ──
                  Text(
                    'REMARKS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 16, thickness: 0.3),
                  const SizedBox(height: 6),
                  Text(
                    'Standard booking processing completed. Profit recorded correctly.',
                    style: TextStyle(fontSize: 11, color: primaryColor),
                  ),
                  const SizedBox(height: 24),

                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalDetailItem(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 8, color: labelColor, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}
