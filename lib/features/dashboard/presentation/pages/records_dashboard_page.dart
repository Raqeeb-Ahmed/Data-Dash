import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/booking_model.dart';

class RecordsDashboardPage extends StatefulWidget {
  const RecordsDashboardPage({super.key});

  @override
  State<RecordsDashboardPage> createState() => _RecordsDashboardPageState();
}

class _RecordsDashboardPageState extends State<RecordsDashboardPage> {
  final List<BookingModel> _allBookings = BookingModel.getMockBookings();
  List<BookingModel> _filteredBookings = [];

  String _searchQuery = '';
  String _selectedService = 'All';
  String _selectedPaymentStatus = 'All';

  @override
  void initState() {
    super.initState();
    _filteredBookings = _allBookings;
  }

  void _applyFilters() {
    setState(() {
      _filteredBookings = _allBookings.where((booking) {
        // Search filter
        final matchesSearch =
            booking.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            booking.passportNumber.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            booking.destination.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            booking.employeeName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        // Service type filter
        final matchesService =
            _selectedService == 'All' ||
            booking.serviceType.toLowerCase() == _selectedService.toLowerCase();

        // Payment status filter
        final matchesPayment =
            _selectedPaymentStatus == 'All' ||
            booking.paymentStatus.toLowerCase() ==
                _selectedPaymentStatus.toLowerCase();

        return matchesSearch && matchesService && matchesPayment;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedService = 'All';
      _selectedPaymentStatus = 'All';
      _filteredBookings = _allBookings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      body: Column(
        children: [
          // Filter Panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Input
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search by client, passport, route...',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdowns and reset
                Row(
                  children: [
                    // Service Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedService,
                            isExpanded: true,
                            items:
                                <String>[
                                  'All',
                                  'Visa',
                                  'Ticket',
                                  'Umrah',
                                  'Hotel',
                                  'Insurance',
                                ].map((String val) {
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(
                                      val,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _selectedService = val;
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Payment Status Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDarkMode
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultBorderRadius,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPaymentStatus,
                            isExpanded: true,
                            items: <String>['All', 'Paid', 'Unpaid'].map((
                              String val,
                            ) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(
                                  val,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _selectedPaymentStatus = val;
                                _applyFilters();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Reset button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Reset Filters',
                      style: IconButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? AppColors.backgroundDark
                            : Colors.grey[100],
                      ),
                      onPressed: _resetFilters,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions Header (PDF, CSV Export)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${_filteredBookings.length} records',
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 16,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'PDF',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.table_view_outlined,
                        size: 16,
                        color: AppColors.success,
                      ),
                      label: const Text(
                        'CSV',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Records List
          Expanded(
            child: _filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 64,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No records found matching filters',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return _buildRecordCard(context, booking);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, BookingModel booking) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    Color statusColor;
    switch (booking.status.toLowerCase()) {
      case 'approved':
        statusColor = AppColors.success;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        side: BorderSide(
          color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Service Badge & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    booking.serviceType.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Customer details
            Text(
              booking.customerName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.public, size: 14, color: secondaryTextColor),
                const SizedBox(width: 4),
                Text(
                  booking.destination,
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
                const SizedBox(width: 12),
                Icon(Icons.badge_outlined, size: 14, color: secondaryTextColor),
                const SizedBox(width: 4),
                Text(
                  booking.passportNumber,
                  style: TextStyle(fontSize: 12, color: secondaryTextColor),
                ),
              ],
            ),
            const Divider(height: 24),

            // Financial summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PRICE',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.totalPrice.toStringAsFixed(0)} PKR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECEIVED',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.receivedAmount.toStringAsFixed(0)} PKR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYABLE',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.payableAmount.toStringAsFixed(0)} PKR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: booking.payableAmount > 0
                            ? AppColors.error
                            : secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Handler info & Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDarkMode
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      child: Text(
                        booking.employeeName[0],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.employeeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.info,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.success,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
