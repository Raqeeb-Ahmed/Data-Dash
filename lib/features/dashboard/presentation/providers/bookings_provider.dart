import 'dart:async';

import 'package:data_dash/features/dashboard/data/datasource/bookings_remote_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user_entity.dart';

class BookingsFilter {
  final String searchQuery;
  final String selectedService;
  final String selectedStatus;
  final String selectedPayment;
  final DateTime? fromDate;
  final DateTime? toDate;

  BookingsFilter({
    this.searchQuery = '',
    this.selectedService = 'All Services',
    this.selectedStatus = 'All Status',
    this.selectedPayment = 'All Payments',
    this.fromDate,
    this.toDate,
  });

  BookingsFilter copyWith({
    String? searchQuery,
    String? selectedService,
    String? selectedStatus,
    String? selectedPayment,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return BookingsFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedService: selectedService ?? this.selectedService,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPayment: selectedPayment ?? this.selectedPayment,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

class BookingsFilterNotifier extends StateNotifier<BookingsFilter> {
  BookingsFilterNotifier() : super(BookingsFilter());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateService(String service) {
    state = state.copyWith(selectedService: service);
  }

  void updateStatus(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void updatePayment(String payment) {
    state = state.copyWith(selectedPayment: payment);
  }

  void updateDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(fromDate: from, toDate: to);
  }

  void reset() {
    state = BookingsFilter();
  }
}

final bookingsFilterProvider =
    StateNotifierProvider<BookingsFilterNotifier, BookingsFilter>((ref) {
      return BookingsFilterNotifier();
    });
final bookingsDataSourceProvider = Provider<BookingsRemoteDataSource>((ref) {
  return BookingsRemoteDataSource();
});

class BookingsNotifier extends StateNotifier<List<BookingModel>> {
  final BookingsRemoteDataSource? _remoteDataSource;
  final UserEntity? _currentUser;
  StreamSubscription? _subscription;
  BookingsNotifier(this._remoteDataSource, this._currentUser) : super([]) {
    _init();
  }
  BookingsNotifier.empty()
    : _remoteDataSource = null,
      _currentUser = null,
      super([]);
  Future<void> refresh() async {
    _init();
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  void _init() {
    print(
      'BookingsNotifier _init: remoteDataSource is ${_remoteDataSource != null ? 'NOT null' : 'NULL'}',
    );
    if (_remoteDataSource != null) {
      _subscription = _remoteDataSource!.getBookingsStream().listen(
        (list) {
          print(
            'BookingsNotifier: Received ${list.length} merged bookings from remote datasource',
          );
          final activeList = list.where((b) {
            final s = b.status.toLowerCase().trim();
            return s != 'deleted' && s != 'trash';
          }).toList();

          if (_currentUser != null && _currentUser!.role == 'employee') {
            final filtered = activeList.where((b) {
              return b.employeeId == _currentUser!.uid ||
                  b.employeeName.toLowerCase().trim() ==
                      _currentUser!.email.toLowerCase().trim();
            }).toList();
            state = filtered;
          } else {
            state = activeList;
          }
        },
        onError: (e) {
          print('BookingsNotifier: stream error: $e');
        },
      );
    }
  }

  // --- Real-time write actions mapping to Firestore ---
  Future<void> addBooking(BookingModel booking) async {
    if (_remoteDataSource != null) {
      await _remoteDataSource!.addBooking(booking);
    }
  }

  Future<void> updateBooking(BookingModel booking) async {
    if (_remoteDataSource != null) {
      await _remoteDataSource!.updateBooking(booking);
    }
  }

  Future<void> deleteBooking(String id) async {
    if (_remoteDataSource != null) {
      final booking = state.firstWhere(
        (b) => b.id == id,
        orElse: () => BookingModel(
          id: '',
          serviceType: 'visa',
          customerName: '',
          customerPhone: '',
          passportNumber: '',
          destination: '',
          dateCreated: DateTime.now(),
          status: '',
          paymentStatus: '',
          employeeId: '',
          employeeName: '',
          totalPrice: 0,
          receivedAmount: 0,
          payableAmount: 0,
          netProfit: 0,
        ),
      );
      if (booking.id.isNotEmpty) {
        await _remoteDataSource!.deleteBooking(id, booking.serviceType);
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<BookingModel>>((ref) {
      final authState = ref.watch(authStateProvider);
      final dataSource = ref.watch(bookingsDataSourceProvider);
      return authState.when(
        data: (user) {
          if (user != null) {
            return BookingsNotifier(dataSource, user);
          } else {
            return BookingsNotifier.empty();
          }
        },
        loading: () => BookingsNotifier.empty(),
        error: (_, __) => BookingsNotifier.empty(),
      );
    });
final filteredBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  final filter = ref.watch(bookingsFilterProvider);
  return bookings.where((b) {
    // 1. Search Query
    final q = filter.searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        b.customerName.toLowerCase().contains(q) ||
        b.destination.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q) ||
        b.employeeName.toLowerCase().contains(q);

    // 2. Service Filter
    final matchService =
        filter.selectedService == 'All Services' ||
        b.serviceType.toLowerCase() == filter.selectedService.toLowerCase();

    // 3. Status Filter
    final matchStatus =
        filter.selectedStatus == 'All Status' ||
        filter.selectedStatus == 'All Statuses' ||
        b.status.toLowerCase() == filter.selectedStatus.toLowerCase();

    // 4. Custom Date Range
    bool matchRange = true;
    if (filter.fromDate != null && filter.toDate != null) {
      final bookingDate = DateTime(
        b.dateCreated.year,
        b.dateCreated.month,
        b.dateCreated.day,
      );
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

    return matchSearch && matchService && matchStatus && matchRange;
  }).toList();
});

class BookingStats {
  final int totalBookings;
  final int totalApproved;
  final int totalProcessing;
  final int totalRejected;
  final int visaCount;
  final int hotelCount;
  final int umrahCount;
  final int ticketCount;
  final double totalReceivable;
  final double totalReceived;
  final double totalPending;
  final double totalNetProfit;
  final int totalPaid;
  final int totalUnpaid;
  BookingStats({
    required this.totalBookings,
    required this.totalApproved,
    required this.totalProcessing,
    required this.totalRejected,
    required this.visaCount,
    required this.hotelCount,
    required this.umrahCount,
    required this.ticketCount,
    required this.totalReceivable,
    required this.totalReceived,
    required this.totalPending,
    required this.totalNetProfit,
    required this.totalPaid,
    required this.totalUnpaid,
  });
}

final bookingStatsProvider = Provider<BookingStats>((ref) {
  final bookings = ref.watch(bookingsProvider);

  final visaBookings = bookings
      .where((b) => b.serviceType.toLowerCase().trim() == 'visa')
      .toList();
  final totalBookings = bookings.length;
  final visaCount = visaBookings.length;
  final hotelCount = bookings
      .where((b) => b.serviceType.toLowerCase().trim() == 'hotel')
      .length;
  final umrahCount = bookings
      .where((b) => b.serviceType.toLowerCase().trim() == 'umrah')
      .length;
  final ticketCount = bookings
      .where((b) => b.serviceType.toLowerCase().trim() == 'ticket')
      .length;

  final totalApproved = visaBookings
      .where(
        (b) =>
            b.status.toLowerCase() == 'approved' ||
            b.status.toLowerCase() == 'confirmed' ||
            b.status.toLowerCase() == 'completed' ||
            b.status.toLowerCase() == 'active' ||
            b.status.toLowerCase() == 'success',
      )
      .length;
  final totalProcessing = visaBookings
      .where(
        (b) =>
            b.status.toLowerCase() == 'processing' ||
            b.status.toLowerCase() == 'pending' ||
            b.status.toLowerCase() == 'sent to embassy' ||
            b.status.toLowerCase() == 'submitted',
      )
      .length;
  final totalRejected = visaBookings
      .where(
        (b) =>
            b.status.toLowerCase() == 'rejected' ||
            b.status.toLowerCase() == 'cancelled',
      )
      .length;

  double totalReceived = 0;
  double totalPending = 0;
  double totalNetProfit = 0;
  int totalPaid = 0;
  int totalUnpaid = 0;

  for (final b in bookings) {
    final type = b.serviceType.toLowerCase().trim();

    totalReceived += b.receivedAmount;
    totalNetProfit += b.netProfit;

    if (type == 'visa') {
      if (b.payableAmount > 0) {
        totalPending += b.payableAmount;
      }

      final paymentStatus = b.paymentStatus.toLowerCase().trim();
      if (paymentStatus == 'paid') {
        totalPaid++;
      } else if (paymentStatus == 'unpaid' ||
          paymentStatus == 'partially paid') {
        totalUnpaid++;
      }
    }
  }

  final double totalReceivable = totalReceived + totalPending;

  return BookingStats(
    totalBookings: totalBookings,
    totalApproved: totalApproved,
    totalProcessing: totalProcessing,
    totalRejected: totalRejected,
    visaCount: visaCount,
    hotelCount: hotelCount,
    umrahCount: umrahCount,
    ticketCount: ticketCount,
    totalReceivable: totalReceivable,
    totalReceived: totalReceived,
    totalPending: totalPending,
    totalNetProfit: totalNetProfit,
    totalPaid: totalPaid,
    totalUnpaid: totalUnpaid,
  );
});
