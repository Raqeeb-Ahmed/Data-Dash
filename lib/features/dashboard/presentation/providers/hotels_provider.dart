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

final hotelFilterProvider = StateNotifierProvider<HotelFilterNotifier, HotelFilter>((ref) {
  return HotelFilterNotifier();
});

class HotelBookingsNotifier extends StateNotifier<List<HotelBookingModel>> {
  HotelBookingsNotifier() : super(_generateInitialBookings());

  void addBooking(HotelBookingModel booking) {
    state = [booking, ...state];
  }

  void updateBooking(HotelBookingModel booking) {
    state = [
      for (final b in state)
        if (b.id == booking.id) booking else b
    ];
  }

  void deleteBooking(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}

final hotelBookingsProvider = StateNotifierProvider<HotelBookingsNotifier, List<HotelBookingModel>>((ref) {
  return HotelBookingsNotifier();
});

final filteredHotelBookingsProvider = Provider<List<HotelBookingModel>>((ref) {
  final bookings = ref.watch(hotelBookingsProvider);
  final filter = ref.watch(hotelFilterProvider);

  return bookings.where((b) {
    // 1. Search Query
    final q = filter.searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        b.hotelName.toLowerCase().contains(q) ||
        b.clientName.toLowerCase().contains(q) ||
        b.id.toLowerCase().contains(q) ||
        b.employeeEmail.toLowerCase().contains(q);

    // 2. Quick Date Filter
    bool matchDate = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(b.arrivalDate.year, b.arrivalDate.month, b.arrivalDate.day);

    if (filter.selectedDateFilter == 'Today') {
      matchDate = bookingDate.isAtSameMomentAs(today);
    } else if (filter.selectedDateFilter == 'Yesterday') {
      final yesterday = today.subtract(const Duration(days: 1));
      matchDate = bookingDate.isAtSameMomentAs(yesterday);
    } else if (filter.selectedDateFilter == 'This Week') {
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = today.add(Duration(days: 7 - today.weekday));
      matchDate = bookingDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          bookingDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
    } else if (filter.selectedDateFilter == 'This Month') {
      matchDate = bookingDate.year == today.year && bookingDate.month == today.month;
    }

    // 3. Custom Date Range
    bool matchRange = true;
    if (filter.fromDate != null && filter.toDate != null) {
      final start = DateTime(filter.fromDate!.year, filter.fromDate!.month, filter.fromDate!.day);
      final end = DateTime(filter.toDate!.year, filter.toDate!.month, filter.toDate!.day);
      matchRange = bookingDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
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
  final bookings = ref.watch(filteredHotelBookingsProvider); // Computed based on filtered list to match UI statistics behavior
  
  double totalReceived = 0;
  double totalPayable = 0;
  double totalProfit = 0;

  for (var b in bookings) {
    totalReceived += b.receivedAmount;
    totalPayable += b.payableAmount;
    totalProfit += b.profit;
  }

  return HotelStats(
    totalReceived: totalReceived,
    totalPayable: totalPayable,
    totalProfit: totalProfit,
    totalBookingsCount: bookings.length,
  );
});

// Initial mock list loaded matching user's screenshot
List<HotelBookingModel> _generateInitialBookings() {
  return [
    HotelBookingModel(
      id: '9474938472',
      hotelName: 'Romance Hotel Sukhumvit 97',
      arrivalDate: DateTime(2026, 3, 11),
      departureDate: DateTime(2026, 3, 13),
      clientName: 'Mujahid Sabri',
      nights: 17,
      rooms: 1,
      receivedAmount: 1500,
      payableAmount: 0,
      profit: 1500,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: '9474938491',
      hotelName: 'Marigold Sukhumvit',
      arrivalDate: DateTime(2026, 3, 14),
      departureDate: DateTime(2026, 3, 20),
      clientName: 'INAYATULLAH STANIKZAI',
      nights: 17,
      rooms: 1,
      receivedAmount: 1500,
      payableAmount: 0,
      profit: 1500,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: '692082',
      hotelName: 'capslock hotel',
      arrivalDate: DateTime(2026, 3, 12),
      departureDate: DateTime(2026, 3, 19),
      clientName: 'BASIT SIKANDAR SALAH UDDIN',
      nights: 2,
      rooms: 1,
      receivedAmount: 52000,
      payableAmount: 1746.10,
      profit: 50253.90,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: '7300301036064',
      hotelName: 'Deluxe City Hotel',
      arrivalDate: DateTime(2026, 3, 14),
      departureDate: DateTime(2026, 3, 15),
      clientName: 'Ahmed Hassan',
      nights: 2,
      rooms: 1,
      receivedAmount: 2000,
      payableAmount: 0,
      profit: 2000,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: '73001030114003',
      hotelName: 'Point Ls Luxury Marina View Formerly Happy Days Hotel',
      arrivalDate: DateTime(2026, 3, 11),
      departureDate: DateTime(2026, 3, 12),
      clientName: 'Abdul Rehman',
      nights: 5,
      rooms: 1,
      receivedAmount: 2000,
      payableAmount: 0,
      profit: 2000,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: '7300301031024',
      hotelName: 'Sansook Bangkok',
      arrivalDate: DateTime(2026, 3, 14),
      departureDate: DateTime(2026, 3, 21),
      clientName: 'mehmood ikram mohmaed',
      nights: 14,
      rooms: 1,
      receivedAmount: 1500,
      payableAmount: 0,
      profit: 1500,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'PC73002010111537',
      hotelName: 'Pearl Continental Lahore',
      arrivalDate: DateTime(2026, 3, 11),
      departureDate: DateTime(2026, 3, 20),
      clientName: 'SEEMA',
      nights: 2,
      rooms: 1,
      receivedAmount: 10972,
      payableAmount: 7973.47,
      profit: 2998.53,
      employeeEmail: 'sameer@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'MH7300301031037',
      hotelName: 'Marts Hotel Baku',
      arrivalDate: DateTime(2026, 3, 05),
      departureDate: DateTime(2026, 3, 08),
      clientName: 'HABIB MASIH',
      nights: 2,
      rooms: 1,
      receivedAmount: 22000,
      payableAmount: 17495.89,
      profit: 4504.11,
      employeeEmail: 'sameer@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'CD730030103',
      hotelName: 'Concorde Deira Hotel',
      arrivalDate: DateTime(2026, 3, 01),
      departureDate: DateTime(2026, 3, 10),
      clientName: 'Ghulam Murtaza',
      nights: 7,
      rooms: 1,
      receivedAmount: 27200,
      payableAmount: 17070.92,
      profit: 10129.08,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'GV73003010311248',
      hotelName: 'Gardenia Village Inn & Plaza',
      arrivalDate: DateTime(2026, 3, 15),
      departureDate: DateTime(2026, 3, 20),
      clientName: 'HASRATULLAH ZAKER',
      nights: 17,
      rooms: 1,
      receivedAmount: 1500,
      payableAmount: 0,
      profit: 1500,
      employeeEmail: 'muqtaba@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'RL73001031',
      hotelName: 'RL Continental Lahore',
      arrivalDate: DateTime(2025, 10, 12),
      departureDate: DateTime(2025, 10, 26),
      clientName: 'Mian Asif',
      nights: 14,
      rooms: 5,
      receivedAmount: 1200000.00,
      payableAmount: 850000.00,
      profit: 350000.00,
      employeeEmail: 'hammad@os.com',
      status: 'Confirmed',
    ),
    HotelBookingModel(
      id: 'SH73001032',
      hotelName: 'South Hotel Tashkent',
      arrivalDate: DateTime(2025, 12, 18),
      departureDate: DateTime(2025, 12, 25),
      clientName: 'Zubair Yousaf',
      nights: 7,
      rooms: 2,
      receivedAmount: 531535.00,
      payableAmount: 342069.90,
      profit: 189466.10,
      employeeEmail: 'ehab@os.com',
      status: 'Confirmed',
    ),
  ];
}
