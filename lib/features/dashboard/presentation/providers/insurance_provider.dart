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
  final String selectedDateFilter; // All Time, Today, This Week, This Month, Custom
  final DateTime? fromDate;
  final DateTime? toDate;
  final String selectedCompany; // All Companies, Adamjee, CSI, DAMAN HEALTH AC, UIC, etc.

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

final insuranceFilterProvider = StateNotifierProvider<InsuranceFilterNotifier, InsuranceFilter>((ref) {
  return InsuranceFilterNotifier();
});

class InsuranceBookingsNotifier extends StateNotifier<List<InsuranceBookingModel>> {
  InsuranceBookingsNotifier() : super(_generateInitialBookings());

  void addBooking(InsuranceBookingModel booking) {
    state = [booking, ...state];
  }

  void updateBooking(InsuranceBookingModel booking) {
    state = [
      for (final b in state)
        if (b.id == booking.id) booking else b
    ];
  }

  void deleteBooking(String id) {
    state = state.where((b) => b.id != id).toList();
  }
}

final insuranceBookingsProvider = StateNotifierProvider<InsuranceBookingsNotifier, List<InsuranceBookingModel>>((ref) {
  return InsuranceBookingsNotifier();
});

final filteredInsuranceBookingsProvider = Provider<List<InsuranceBookingModel>>((ref) {
  final bookings = ref.watch(insuranceBookingsProvider);
  final filter = ref.watch(insuranceFilterProvider);

  return bookings.where((b) {
    // 1. Search Query
    final q = filter.searchQuery.toLowerCase();
    final matchSearch = q.isEmpty ||
        b.insuredName.toLowerCase().contains(q) ||
        b.passportNumber.toLowerCase().contains(q) ||
        b.company.toLowerCase().contains(q);

    // 2. Company Chip Filter
    // Note: The chips show company names. If filter is active, check if booking company matches
    final matchCompany = filter.selectedCompany == 'All Companies' || 
        b.company.toLowerCase() == filter.selectedCompany.toLowerCase();

    // 3. Quick Date Filter
    bool matchDate = true;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = DateTime(b.dateCreated.year, b.dateCreated.month, b.dateCreated.day);

    if (filter.selectedDateFilter == 'Today') {
      matchDate = bookingDate.isAtSameMomentAs(today);
    } else if (filter.selectedDateFilter == 'This Week') {
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = today.add(Duration(days: 7 - today.weekday));
      matchDate = bookingDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
          bookingDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
    } else if (filter.selectedDateFilter == 'This Month') {
      matchDate = bookingDate.year == today.year && bookingDate.month == today.month;
    }

    // 4. Custom Date Range
    bool matchRange = true;
    if (filter.fromDate != null && filter.toDate != null) {
      final start = DateTime(filter.fromDate!.year, filter.fromDate!.month, filter.fromDate!.day);
      final end = DateTime(filter.toDate!.year, filter.toDate!.month, filter.toDate!.day);
      matchRange = bookingDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          bookingDate.isBefore(end.add(const Duration(seconds: 1)));
    }

    return matchSearch && matchCompany && matchDate && matchRange;
  }).toList();
});

class InsuranceStats {
  final double totalReceived;
  final double totalPayable;
  final double totalProfit;
  final int totalCount;

  InsuranceStats({
    required this.totalReceived,
    required this.totalPayable,
    required this.totalProfit,
    required this.totalCount,
  });
}

final insuranceStatsProvider = Provider<InsuranceStats>((ref) {
  final bookings = ref.watch(filteredInsuranceBookingsProvider);

  double rec = 0;
  double pay = 0;
  double prof = 0;

  for (var b in bookings) {
    rec += b.receivedAmount;
    pay += b.payableAmount;
    prof += b.netProfit;
  }

  return InsuranceStats(
    totalReceived: rec,
    totalPayable: pay,
    totalProfit: prof,
    totalCount: bookings.length,
  );
});

// Generate 15 precise mock bookings from the screenshot
List<InsuranceBookingModel> _generateInitialBookings() {
  return [
    InsuranceBookingModel(
      id: 'INS-1001',
      company: 'United Insurance Company',
      insuredName: 'Muhammad Farooq Umar',
      passportNumber: 'AS9876755',
      travelCountry: 'Germany',
      receivedAmount: 14500.00,
      payableAmount: 9875.00,
      netProfit: 4625.00,
      dateCreated: DateTime(2025, 9, 10),
    ),
    InsuranceBookingModel(
      id: 'INS-1002',
      company: 'United Insurance Company',
      insuredName: 'MARIA HASSAN',
      passportNumber: 'LD5901573',
      travelCountry: 'UNITED KINGDOM',
      receivedAmount: 3500.00,
      payableAmount: 3183.00,
      netProfit: 317.00,
      dateCreated: DateTime(2025, 9, 25),
    ),
    InsuranceBookingModel(
      id: 'INS-1003',
      company: 'UNITED INSURANCE COMPANY',
      insuredName: 'SADIA BADAR',
      passportNumber: 'HU984032',
      travelCountry: 'MOROCCO',
      receivedAmount: 5000.00,
      payableAmount: 4600.00,
      netProfit: 400.00,
      dateCreated: DateTime(2025, 10, 5),
    ),
    InsuranceBookingModel(
      id: 'INS-1004',
      company: 'UIC',
      insuredName: 'SHEIKH FAISAL BIN FARID',
      passportNumber: 'AK9174270',
      travelCountry: 'WORLDWIDE',
      receivedAmount: 3500.00,
      payableAmount: 1720.00,
      netProfit: 1780.00,
      dateCreated: DateTime(2025, 10, 20),
    ),
    InsuranceBookingModel(
      id: 'INS-1005',
      company: 'UIC',
      insuredName: 'MUHAMMAD ALI',
      passportNumber: 'TM1825081',
      travelCountry: 'SCHENGEN',
      receivedAmount: 2900.00,
      payableAmount: 1740.00,
      netProfit: 1160.00,
      dateCreated: DateTime(2025, 12, 2),
    ),
    InsuranceBookingModel(
      id: 'INS-1006',
      company: 'UIC',
      insuredName: 'Tariq Mahmood',
      passportNumber: 'JD0167042',
      travelCountry: 'POLAND',
      receivedAmount: 2600.00,
      payableAmount: 1690.00,
      netProfit: 910.00,
      dateCreated: DateTime(2025, 12, 10),
    ),
    InsuranceBookingModel(
      id: 'INS-1007',
      company: 'UIC',
      insuredName: 'MUHAMMAD IMRAN',
      passportNumber: 'JE1228772',
      travelCountry: 'Greece',
      receivedAmount: 14000.00,
      payableAmount: 7035.00,
      netProfit: 6965.00,
      dateCreated: DateTime(2025, 11, 15),
    ),
    InsuranceBookingModel(
      id: 'INS-1008',
      company: 'UIC',
      insuredName: 'ZAHEER MUHAMMAD AHMAD',
      passportNumber: 'DN5120101',
      travelCountry: 'Malaysia',
      receivedAmount: 1700.00,
      payableAmount: 870.00,
      netProfit: 830.00,
      dateCreated: DateTime(2026, 2, 5),
    ),
    InsuranceBookingModel(
      id: 'INS-1009',
      company: 'UIC',
      insuredName: 'SHAHZAD AHMAD KHAN',
      passportNumber: 'SH4115108',
      travelCountry: 'Netherlands',
      receivedAmount: 9100.00,
      payableAmount: 6660.00,
      netProfit: 2440.00,
      dateCreated: DateTime(2025, 12, 18),
    ),
    InsuranceBookingModel(
      id: 'INS-1010',
      company: 'DAMAN HEALTH AC',
      insuredName: 'MAN ABDULLAH',
      passportNumber: '1073714DA',
      travelCountry: 'UAE',
      receivedAmount: 22203.00,
      payableAmount: 22203.00,
      netProfit: 0.00,
      dateCreated: DateTime(2025, 11, 22),
    ),
    InsuranceBookingModel(
      id: 'INS-1011',
      company: 'CSI',
      insuredName: 'AJMAL KHUDMAN',
      passportNumber: 'KW100761',
      travelCountry: 'RUSSIA',
      receivedAmount: 5000.00,
      payableAmount: 2700.00,
      netProfit: 2300.00,
      dateCreated: DateTime(2026, 2, 28),
    ),
    InsuranceBookingModel(
      id: 'INS-1012',
      company: 'Adamjee',
      insuredName: 'RABAB BASHIR',
      passportNumber: 'FP3841772',
      travelCountry: 'France',
      receivedAmount: 10697.00,
      payableAmount: 6541.00,
      netProfit: 4156.00,
      dateCreated: DateTime(2026, 3, 5),
    ),
    InsuranceBookingModel(
      id: 'INS-1013',
      company: 'UNITED INSURANCE COMPANY',
      insuredName: 'ABAS HUSSAIN',
      passportNumber: 'WK0888592',
      travelCountry: 'USA',
      receivedAmount: 8820.00,
      payableAmount: 6083.00,
      netProfit: 2737.00,
      dateCreated: DateTime(2026, 3, 12),
    ),
    InsuranceBookingModel(
      id: 'INS-1014',
      company: 'UIC',
      insuredName: 'FARRUKH RASHID',
      passportNumber: 'DU9842302',
      travelCountry: 'SCHENGEN COUNTRIES',
      receivedAmount: 10000.00,
      payableAmount: 5380.00,
      netProfit: 4620.00,
      dateCreated: DateTime(2026, 3, 20),
    ),
    InsuranceBookingModel(
      id: 'INS-1015',
      company: 'UNITED COMPANY INSURANCE',
      insuredName: 'HAROON SALEEM',
      passportNumber: 'JE751147',
      travelCountry: 'Greece',
      receivedAmount: 13500.00,
      payableAmount: 8775.00,
      netProfit: 4725.00,
      dateCreated: DateTime(2025, 11, 28),
    ),
  ];
}
