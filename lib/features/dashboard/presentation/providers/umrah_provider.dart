import 'package:data_dash/features/dashboard/data/models/booking_model.dart';
import 'package:data_dash/features/dashboard/presentation/providers/bookings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UmrahBookingModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String passportNumber;
  final String vendorName;
  final String employeeEmail;
  final double payableAmount;
  final double receivedAmount;
  final double netProfit;
  final DateTime dateCreated;
  final String status; // Active, Confirmed, Pending, Cancelled

  UmrahBookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.passportNumber,
    required this.vendorName,
    required this.employeeEmail,
    required this.payableAmount,
    required this.receivedAmount,
    required this.netProfit,
    required this.dateCreated,
    this.status = 'Confirmed',
  });

  UmrahBookingModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? passportNumber,
    String? vendorName,
    String? employeeEmail,
    double? payableAmount,
    double? receivedAmount,
    double? netProfit,
    DateTime? dateCreated,
    String? status,
  }) {
    return UmrahBookingModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      passportNumber: passportNumber ?? this.passportNumber,
      vendorName: vendorName ?? this.vendorName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      payableAmount: payableAmount ?? this.payableAmount,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      netProfit: netProfit ?? this.netProfit,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
    );
  }
}

class UmrahFilter {
  final String searchQuery;
  final String
  selectedDateFilter; // All Time, Today, Yesterday, This Month, Custom
  final DateTime? fromDate;
  final DateTime? toDate;
  final String selectedVendor;
  final String selectedEmployee;

  UmrahFilter({
    this.searchQuery = '',
    this.selectedDateFilter = 'All Time',
    this.fromDate,
    this.toDate,
    this.selectedVendor = 'All Vendors',
    this.selectedEmployee = 'All Employees',
  });

  UmrahFilter copyWith({
    String? searchQuery,
    String? selectedDateFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedVendor,
    String? selectedEmployee,
  }) {
    return UmrahFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedVendor: selectedVendor ?? this.selectedVendor,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
    );
  }
}

class UmrahFilterNotifier extends StateNotifier<UmrahFilter> {
  UmrahFilterNotifier() : super(UmrahFilter());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateDateFilter(String filter) {
    state = state.copyWith(selectedDateFilter: filter);
  }

  void updateCustomDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(fromDate: from, toDate: to);
  }

  void updateVendor(String vendor) {
    state = state.copyWith(selectedVendor: vendor);
  }

  void updateEmployee(String employee) {
    state = state.copyWith(selectedEmployee: employee);
  }

  void reset() {
    state = UmrahFilter();
  }
}

final umrahFilterProvider =
    StateNotifierProvider<UmrahFilterNotifier, UmrahFilter>((ref) {
      return UmrahFilterNotifier();
    });

class UmrahBookingsNotifier extends StateNotifier<List<UmrahBookingModel>> {
  final Ref _ref;

  UmrahBookingsNotifier(this._ref) : super([]) {
    _init();
  }

  void _init() {
    _ref.listen<List<BookingModel>>(bookingsProvider, (prev, next) {
      state = next
          .where((b) => b.serviceType == 'umrah')
          .map(
            (b) => UmrahBookingModel(
              id: b.id,
              customerName: b.customerName,
              customerPhone: b.customerPhone,
              passportNumber: b.passportNumber,
              vendorName: b.vendorName ?? 'Unknown',
              employeeEmail: b.employeeName,
              payableAmount: b.payableAmount,
              receivedAmount: b.receivedAmount,
              netProfit: b.netProfit,
              dateCreated: b.dateCreated,
              status: b.status,
            ),
          )
          .toList();
    }, fireImmediately: true);
  }

  // Forward updates back to global bookings provider -> writes to Firestore
  Future<void> updateBooking(UmrahBookingModel updated) async {
    final globalBookings = _ref.read(bookingsProvider);
    final booking = globalBookings.firstWhere((b) => b.id == updated.id);

    final updatedBooking = booking.copyWith(
      customerName: updated.customerName,
      customerPhone: updated.customerPhone,
      passportNumber: updated.passportNumber,
      vendorName: updated.vendorName,
      employeeName: updated.employeeEmail,
      payableAmount: updated.payableAmount,
      receivedAmount: updated.receivedAmount,
      netProfit: updated.netProfit,
      dateCreated: updated.dateCreated,
      status: updated.status,
    );

    await _ref.read(bookingsProvider.notifier).updateBooking(updatedBooking);
  }

  Future<void> deleteBooking(String id) async {
    await _ref.read(bookingsProvider.notifier).deleteBooking(id);
  }
}

final umrahBookingsProvider =
    StateNotifierProvider<UmrahBookingsNotifier, List<UmrahBookingModel>>((
      ref,
    ) {
      return UmrahBookingsNotifier(ref);
    });

final filteredUmrahBookingsProvider = Provider<List<UmrahBookingModel>>((ref) {
  final bookings = ref.watch(umrahBookingsProvider);
  final filter = ref.watch(umrahFilterProvider);

  return bookings.where((b) {
    final q = filter.searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        b.customerName.toLowerCase().contains(q) ||
        b.passportNumber.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q);

    bool matchDate = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(
      b.dateCreated.year,
      b.dateCreated.month,
      b.dateCreated.day,
    );

    if (filter.selectedDateFilter == 'Today') {
      matchDate = bookingDate.isAtSameMomentAs(today);
    } else if (filter.selectedDateFilter == 'Yesterday') {
      final yesterday = today.subtract(const Duration(days: 1));
      matchDate = bookingDate.isAtSameMomentAs(yesterday);
    } else if (filter.selectedDateFilter == 'This Month') {
      matchDate =
          bookingDate.year == today.year && bookingDate.month == today.month;
    }

    bool matchRange = true;
    if (filter.fromDate != null && filter.toDate != null) {
      final start = DateTime(
        filter.fromDate!.year,
        filter.fromDate!.month,
        filter.fromDate!.day,
      );
      final end = DateTime(
        filter.toDate!.year,
        filter.toDate!.month,
        filter.toDate!.day,
      );
      matchRange =
          bookingDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          bookingDate.isBefore(end.add(const Duration(seconds: 1)));
    }

    final matchVendor =
        filter.selectedVendor == 'All Vendors' ||
        b.vendorName.toLowerCase() == filter.selectedVendor.toLowerCase();

    final matchEmp =
        filter.selectedEmployee == 'All Employees' ||
        b.employeeEmail.toLowerCase() == filter.selectedEmployee.toLowerCase();

    return matchSearch && matchDate && matchRange && matchVendor && matchEmp;
  }).toList();
});

class UmrahStats {
  final double totalReceived;
  final double totalPayable;
  final double totalProfit;
  final int totalBookingsCount;

  UmrahStats({
    required this.totalReceived,
    required this.totalPayable,
    required this.totalProfit,
    required this.totalBookingsCount,
  });
}

final umrahStatsProvider = Provider<UmrahStats>((ref) {
  final bookings = ref.watch(filteredUmrahBookingsProvider);
  final totalReceived = bookings.fold(
    0.0,
    (sum, item) => sum + item.receivedAmount,
  );
  final totalPayable = bookings.fold(
    0.0,
    (sum, item) => sum + item.payableAmount,
  );
  final totalProfit = bookings.fold(0.0, (sum, item) => sum + item.netProfit);

  return UmrahStats(
    totalReceived: totalReceived,
    totalPayable: totalPayable,
    totalProfit: totalProfit,
    totalBookingsCount: bookings.length,
  );
});
