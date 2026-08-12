import 'package:data_dash/features/dashboard/data/models/booking_model.dart';
import 'package:data_dash/features/dashboard/presentation/providers/bookings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HotelBookingModel {
  final String id;
  final String hotelName;
  final DateTime arrivalDate;
  final DateTime departureDate;
  final String clientName;
  final int nights;
  final int rooms;
  final double receivedAmount;
  final double payableAmount;
  final double profit;
  final String employeeEmail;
  final String status;

  HotelBookingModel({
    required this.id,
    required this.hotelName,
    required this.arrivalDate,
    required this.departureDate,
    required this.clientName,
    required this.nights,
    required this.rooms,
    required this.receivedAmount,
    required this.payableAmount,
    required this.profit,
    required this.employeeEmail,
    this.status = 'Confirmed',
  });

  HotelBookingModel copyWith({
    String? id,
    String? hotelName,
    DateTime? arrivalDate,
    DateTime? departureDate,
    String? clientName,
    int? nights,
    int? rooms,
    double? receivedAmount,
    double? payableAmount,
    double? profit,
    String? employeeEmail,
    String? status,
  }) {
    return HotelBookingModel(
      id: id ?? this.id,
      hotelName: hotelName ?? this.hotelName,
      arrivalDate: arrivalDate ?? this.arrivalDate,
      departureDate: departureDate ?? this.departureDate,
      clientName: clientName ?? this.clientName,
      nights: nights ?? this.nights,
      rooms: rooms ?? this.rooms,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      payableAmount: payableAmount ?? this.payableAmount,
      profit: profit ?? this.profit,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      status: status ?? this.status,
    );
  }
}

class HotelFilter {
  final String searchQuery;
  final String selectedDateFilter;
  final DateTime? fromDate;
  final DateTime? toDate;

  HotelFilter({
    this.searchQuery = '',
    this.selectedDateFilter = 'All',
    this.fromDate,
    this.toDate,
  });

  HotelFilter copyWith({
    String? searchQuery,
    String? selectedDateFilter,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return HotelFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDateFilter: selectedDateFilter ?? this.selectedDateFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class HotelFilterNotifier extends StateNotifier<HotelFilter> {
  HotelFilterNotifier() : super(HotelFilter());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateDateFilter(String filter) {
    state = state.copyWith(selectedDateFilter: filter);
  }

  void updateCustomDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(fromDate: from, toDate: to);
  }

  void reset() {
    state = HotelFilter();
  }
}

final hotelFilterProvider =
    StateNotifierProvider<HotelFilterNotifier, HotelFilter>((ref) {
      return HotelFilterNotifier();
    });

class HotelBookingsNotifier extends StateNotifier<List<HotelBookingModel>> {
  final Ref _ref;
  HotelBookingsNotifier(this._ref) : super([]) {
    _init();
  }
  void _init() {
    _ref.listen<List<BookingModel>>(bookingsProvider, (prev, next) {
      state = next.where((b) => b.serviceType == 'hotel').map((b) {
        final depDate = b.returnDate != null
            ? (DateTime.tryParse(b.returnDate!) ??
                  b.dateCreated.add(const Duration(days: 1)))
            : b.dateCreated.add(const Duration(days: 1));

        return HotelBookingModel(
          id: b.id,
          hotelName: b.destination,
          clientName: b.customerName,
          arrivalDate: b.dateCreated,
          departureDate: depDate,
          payableAmount: b.payableAmount,
          receivedAmount: b.receivedAmount,
          profit: b.netProfit,
          employeeEmail: b.employeeName,
          status: b.status,
          nights: depDate.difference(b.dateCreated).inDays.clamp(1, 100),
          rooms: int.tryParse(b.cabinClass ?? '1') ?? 1,
        );
      }).toList();
    }, fireImmediately: true);
  }

  Future<void> updateBooking(HotelBookingModel updated) async {
    final globalBookings = _ref.read(bookingsProvider);
    final booking = globalBookings.firstWhere((b) => b.id == updated.id);

    final updatedBooking = booking.copyWith(
      destination: updated.hotelName,
      customerName: updated.clientName,
      dateCreated: updated.arrivalDate,
      returnDate: updated.departureDate.toIso8601String().split('T')[0],
      payableAmount: updated.payableAmount,
      receivedAmount: updated.receivedAmount,
      netProfit: updated.profit,
      employeeName: updated.employeeEmail,
      status: updated.status,
      cabinClass: updated.rooms.toString(),
    );
    await _ref.read(bookingsProvider.notifier).updateBooking(updatedBooking);
  }

  Future<void> deleteBooking(String id) async {
    await _ref.read(bookingsProvider.notifier).deleteBooking(id);
  }
}

final hotelBookingsProvider =
    StateNotifierProvider<HotelBookingsNotifier, List<HotelBookingModel>>((
      ref,
    ) {
      return HotelBookingsNotifier(ref);
    });
final filteredHotelBookingsProvider = Provider<List<HotelBookingModel>>((ref) {
  final bookings = ref.watch(hotelBookingsProvider);
  final filter = ref.watch(hotelFilterProvider);
  return bookings.where((b) {
    final q = filter.searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        b.hotelName.toLowerCase().contains(q) ||
        b.clientName.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q) ||
        b.employeeEmail.toLowerCase().contains(q);
    bool matchDate = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(
      b.arrivalDate.year,
      b.arrivalDate.month,
      b.arrivalDate.day,
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
    return matchSearch && matchDate && matchRange;
  }).toList();
});

class HotelStats {
  final double totalReceived;
  final double totalPayable;
  final double totalProfit;
  final int totalBookingsCount;
  HotelStats({
    required this.totalReceived,
    required this.totalPayable,
    required this.totalProfit,
    required this.totalBookingsCount,
  });
}

final hotelStatsProvider = Provider<HotelStats>((ref) {
  final bookings = ref.watch(filteredHotelBookingsProvider);
  final totalReceived = bookings.fold(
    0.0,
    (sum, item) => sum + item.receivedAmount,
  );
  final totalPayable = bookings.fold(
    0.0,
    (sum, item) => sum + item.payableAmount,
  );

  // FIXED: Access .profit instead of non-existent .netProfit
  final totalProfit = bookings.fold(0.0, (sum, item) => sum + item.profit);
  return HotelStats(
    totalReceived: totalReceived,
    totalPayable: totalPayable,
    totalProfit: totalProfit,
    totalBookingsCount: bookings.length,
  );
});
