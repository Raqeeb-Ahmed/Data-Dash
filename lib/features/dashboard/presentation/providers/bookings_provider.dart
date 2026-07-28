import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';

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

final bookingsFilterProvider = StateNotifierProvider<BookingsFilterNotifier, BookingsFilter>((ref) {
  return BookingsFilterNotifier();
});

class BookingsNotifier extends StateNotifier<List<BookingModel>> {
  BookingsNotifier() : super(_generateMockBookings());

  void addBooking(BookingModel booking) {
    state = [...state, booking];
  }

  void updateBooking(BookingModel booking) {
    state = [
      for (final b in state)
        if (b.id == booking.id) booking else b
    ];
  }

  void deleteBooking(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<BookingModel>>((ref) {
  return BookingsNotifier();
});

final filteredBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  final filter = ref.watch(bookingsFilterProvider);

  return bookings.where((b) {
    final q = filter.searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        b.customerName.toLowerCase().contains(q) ||
        b.passportNumber.toLowerCase().contains(q) ||
        b.destination.toLowerCase().contains(q) ||
        b.employeeName.toLowerCase().contains(q);

    final matchService = filter.selectedService == 'All Services' ||
        b.serviceType.toLowerCase() == filter.selectedService.toLowerCase();

    final matchStatus = filter.selectedStatus == 'All Status' ||
        b.status.toLowerCase() == filter.selectedStatus.toLowerCase();

    final matchPayment = filter.selectedPayment == 'All Payments' ||
        b.paymentStatus.toLowerCase() == filter.selectedPayment.toLowerCase();

    bool matchDate = true;
    if (filter.fromDate != null) {
      matchDate = matchDate && b.dateCreated.isAfter(filter.fromDate!.subtract(const Duration(seconds: 1)));
    }
    if (filter.toDate != null) {
      matchDate = matchDate && b.dateCreated.isBefore(filter.toDate!.add(const Duration(days: 1)));
    }

    return matchSearch && matchService && matchStatus && matchPayment && matchDate;
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

  final totalBookings = bookings.length;
  final totalApproved = bookings.where((b) => b.status == 'Approved').length;
  final totalProcessing = bookings.where((b) => b.status == 'Processing').length;
  final totalRejected = bookings.where((b) => b.status == 'Rejected').length;
  
  final visaCount = bookings.where((b) => b.serviceType == 'visa').length;
  final hotelCount = bookings.where((b) => b.serviceType == 'hotel').length;
  final umrahCount = bookings.where((b) => b.serviceType == 'umrah').length;
  final ticketCount = bookings.where((b) => b.serviceType == 'ticket').length;

  final totalReceivable = bookings.fold(0.0, (s, b) => s + b.totalPrice);
  final totalReceived = bookings.fold(0.0, (s, b) => s + b.receivedAmount);
  final totalPending = bookings.fold(0.0, (s, b) => s + b.payableAmount);
  final totalNetProfit = bookings.fold(0.0, (s, b) => s + b.netProfit);

  final totalPaid = bookings.where((b) => b.paymentStatus == 'Paid').length;
  final totalUnpaid = bookings.where((b) => b.paymentStatus == 'Unpaid').length;

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

// ── Generate 50 realistic mock bookings ──
List<BookingModel> _generateMockBookings() {
  final names = [
    'Nasim Akhtar', 'Irfan Ashraf', 'Burman Ali', 'Deedar Ali', 'Muhammad Aamir',
    'Naeem Ahmed', 'Rida Amjad', 'Kiran Farooq', 'Humaira Amjad', 'Areeba Amjad',
    'Asad Khan', 'Sara Malik', 'Hamid Raza', 'Nadia Iqbal', 'Zubair Ahmed',
    'Fatima Bibi', 'Usman Ghani', 'Sana Tariq', 'Bilal Hassan', 'Aisha Noor',
  ];
  final destinations = ['Uzbekistan', 'Malaysia', 'Thailand', 'Indonesia', 'Saudi Arabia', 'UK', 'Germany', 'Canada', 'UAE', 'Singapore'];
  final services = ['visa', 'visa', 'visa', 'ticket', 'umrah', 'hotel', 'insurance'];
  final statuses = ['Processing', 'Processing', 'Approved', 'Approved', 'Rejected'];
  final payments = ['Unpaid', 'Paid', 'Paid', 'Paid'];
  final employees = ['atsh', 'ehab', 'afab'];
  final passportPrefixes = ['AM', 'AK', 'BA', 'DA', 'MA', 'NA', 'RA', 'KF', 'HA', 'AA'];

  return List.generate(50, (i) {
    final name = names[i % names.length];
    final service = services[i % services.length];
    final status = statuses[i % statuses.length];
    final payment = payments[i % payments.length];
    final emp = employees[i % employees.length];
    final dest = destinations[i % destinations.length];
    final total = (15000 + (i * 7123) % 120000).toDouble();
    final received = payment == 'Paid' ? total : total * 0.5;
    final remaining = total - received;
    return BookingModel(
      id: 'BK-${1000 + i}',
      serviceType: service,
      customerName: name,
      customerPhone: '+92 300 ${1000000 + i * 13}',
      passportNumber: '${passportPrefixes[i % passportPrefixes.length]}${100000 + i * 7}',
      destination: dest,
      dateCreated: DateTime.now().subtract(Duration(days: i)),
      status: status,
      paymentStatus: payment,
      employeeId: emp,
      employeeName: emp,
      totalPrice: total,
      receivedAmount: received,
      payableAmount: remaining,
      netProfit: total * 0.22,
    );
  });
}
