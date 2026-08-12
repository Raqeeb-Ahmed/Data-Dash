import 'package:data_dash/features/dashboard/data/models/booking_model.dart';
import 'package:data_dash/features/dashboard/presentation/providers/bookings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsuranceBookingModel {
  final String id;
  final String company; // e.g. United Insurance Company, UIC, CSI, Adamjee
  final String insuredName;
  final String passportNumber;
  final String travelCountry;
  final double receivedAmount;
  final double payableAmount;
  final double netProfit;
  final DateTime dateCreated;
  final String status; // Active, Confirmed, Cancelled

  InsuranceBookingModel({
    required this.id,
    required this.company,
    required this.insuredName,
    required this.passportNumber,
    required this.travelCountry,
    required this.receivedAmount,
    required this.payableAmount,
    required this.netProfit,
    required this.dateCreated,
    this.status = 'Confirmed',
  });

  InsuranceBookingModel copyWith({
    String? id,
    String? company,
    String? insuredName,
    String? passportNumber,
    String? travelCountry,
    double? receivedAmount,
    double? payableAmount,
    double? netProfit,
    DateTime? dateCreated,
    String? status,
  }) {
    return InsuranceBookingModel(
      id: id ?? this.id,
      company: company ?? this.company,
      insuredName: insuredName ?? this.insuredName,
      passportNumber: passportNumber ?? this.passportNumber,
      travelCountry: travelCountry ?? this.travelCountry,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      payableAmount: payableAmount ?? this.payableAmount,
      netProfit: netProfit ?? this.netProfit,
      dateCreated: dateCreated ?? this.dateCreated,
      status: status ?? this.status,
    );
  }
}

class InsuranceFilter {
  final String searchQuery;
  final String
  selectedDateFilter; // All Time, Today, This Week, This Month, Custom
  final DateTime? fromDate;
  final DateTime? toDate;
  final String
  selectedCompany; // All Companies, Adamjee, CSI, DAMAN HEALTH AC, UIC, etc.

  InsuranceFilter({
    this.searchQuery = '',
    this.selectedDateFilter = 'All Time',
    this.fromDate,
    this.toDate,
    this.selectedCompany = 'All Companies',
  });

  InsuranceFilter copyWith({
    String? searchQuery,
    String? selectedDateFilter,
    DateTime? fromDate,
    DateTime? toDate,
    String? selectedCompany,
  }) {
    return InsuranceFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      selectedCompany: selectedCompany ?? this.selectedCompany,
    );
  }
}

class InsuranceFilterNotifier extends StateNotifier<InsuranceFilter> {
  InsuranceFilterNotifier() : super(InsuranceFilter());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateDateFilter(String filter) {
    state = state.copyWith(selectedDateFilter: filter);
  }

  void updateCustomDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(fromDate: from, toDate: to);
  }

  void updateCompany(String company) {
    state = state.copyWith(selectedCompany: company);
  }

  void reset() {
    state = InsuranceFilter();
  }
}

final insuranceFilterProvider =
    StateNotifierProvider<InsuranceFilterNotifier, InsuranceFilter>((ref) {
      return InsuranceFilterNotifier();
    });

class InsuranceBookingsNotifier
    extends StateNotifier<List<InsuranceBookingModel>> {
  final Ref _ref;

  InsuranceBookingsNotifier(this._ref) : super([]);

  void _init() {
    _ref.listen<List<BookingModel>>(bookingsProvider, (prev, next) {
      state = next
          .where((b) => b.serviceType == 'insurance')
          .map(
            (b) => InsuranceBookingModel(
              id: b.id,
              company: b.vendorName ?? 'Insurance Corp',
              insuredName: b.customerName,
              passportNumber: b.passportNumber,
              travelCountry: b.destination,
              receivedAmount: b.receivedAmount,
              payableAmount: b.payableAmount,
              netProfit: b.netProfit,
              dateCreated: b.dateCreated,
              status: b.status,
            ),
          )
          .toList();
    }, fireImmediately: true);
  }

  // Forward updates back to global bookings provider -> writes to Firestore
  Future<void> updateBooking(InsuranceBookingModel updated) async {
    final globalBookings = _ref.read(bookingsProvider);
    final booking = globalBookings.firstWhere((b) => b.id == updated.id);

    final updatedBooking = booking.copyWith(
      vendorName: updated.company,
      customerName: updated.insuredName,
      passportNumber: updated.passportNumber,
      destination: updated.travelCountry,
      receivedAmount: updated.receivedAmount,
      payableAmount: updated.payableAmount,
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

final insuranceBookingsProvider =
    StateNotifierProvider<
      InsuranceBookingsNotifier,
      List<InsuranceBookingModel>
    >((ref) {
      final notifier = InsuranceBookingsNotifier(ref);
      notifier._init();
      return notifier;
    });

final filteredInsuranceBookingsProvider = Provider<List<InsuranceBookingModel>>(
  (ref) {
    final bookings = ref.watch(insuranceBookingsProvider);
    final filter = ref.watch(insuranceFilterProvider);

    return bookings.where((b) {
      final q = filter.searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          b.insuredName.toLowerCase().contains(q) ||
          b.passportNumber.toLowerCase().contains(q) ||
          b.company.toLowerCase().contains(q);

      final matchCompany =
          filter.selectedCompany == 'All Companies' ||
          b.company.toLowerCase() == filter.selectedCompany.toLowerCase();

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

      return matchSearch && matchCompany && matchDate && matchRange;
    }).toList();
  },
);

class InsuranceStats {
  final double totalReceived;
  final double totalPayable;
  final double totalProfit;
  final int totalBookingsCount;

  InsuranceStats({
    required this.totalReceived,
    required this.totalPayable,
    required this.totalProfit,
    required this.totalBookingsCount,
  });
}

final insuranceStatsProvider = Provider<InsuranceStats>((ref) {
  final bookings = ref.watch(filteredInsuranceBookingsProvider);
  final totalReceived = bookings.fold(
    0.0,
    (sum, item) => sum + item.receivedAmount,
  );
  final totalPayable = bookings.fold(
    0.0,
    (sum, item) => sum + item.payableAmount,
  );
  final totalProfit = bookings.fold(0.0, (sum, item) => sum + item.netProfit);

  return InsuranceStats(
    totalReceived: totalReceived,
    totalPayable: totalPayable,
    totalProfit: totalProfit,
    totalBookingsCount: bookings.length,
  );
});
