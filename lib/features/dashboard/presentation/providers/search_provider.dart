import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookings_provider.dart';
import 'umrah_provider.dart';
import 'insurance_provider.dart';

class SearchResultModel {
  final String id;
  final String type; // visa, ticket, hotel, umrah, insurance
  final String name;
  final String details; // route, passport, travel destination
  final String status; // Approved, Processing, Booked, Active, Confirmed
  final double payable;
  final double received;
  final double profit;
  final DateTime date;

  SearchResultModel({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    required this.status,
    required this.payable,
    required this.received,
    required this.profit,
    required this.date,
  });
}

final universalSearchProvider = Provider<List<SearchResultModel>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  final umrahBookings = ref.watch(umrahBookingsProvider);
  final insuranceBookings = ref.watch(insuranceBookingsProvider);

  final List<SearchResultModel> results = [];

  // Add screenshot mock records at the top for exact visual matching
  results.add(SearchResultModel(
    id: 'TKT-9801',
    type: 'ticket',
    name: 'MR TAIMUR MUGHA',
    details: '14241714 • ISB → AUH',
    status: 'Booked',
    payable: 80505.00,
    received: 80704.00,
    profit: 203.00,
    date: DateTime(2026, 7, 16),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9802',
    type: 'visa',
    name: 'MEERAB AROOJ ABNER JANG BAHADUR',
    details: '1073715DA • Thailand',
    status: 'Approved',
    payable: 10500.00,
    received: 10500.00,
    profit: 3500.00,
    date: DateTime(2026, 7, 18),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9803',
    type: 'visa',
    name: 'NEELAM PATRICK',
    details: '551073703 • Thailand',
    status: 'Approved',
    payable: 16500.00,
    received: 16500.00,
    profit: 3500.00,
    date: DateTime(2026, 7, 6),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9804',
    type: 'visa',
    name: 'SHAGEL ASHRAF',
    details: '38107312 • Thailand',
    status: 'Approved',
    payable: 15500.00,
    received: 15500.00,
    profit: 2500.00,
    date: DateTime(2026, 7, 16),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9805',
    type: 'visa',
    name: 'ZABEEH UR REHMAN NASIK',
    details: '443107373 • Norway',
    status: 'Approved',
    payable: 25000.00,
    received: 25000.00,
    profit: 25000.00,
    date: DateTime(2026, 7, 13),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9806',
    type: 'visa',
    name: 'ZABEEH UR REHMAN NASIK',
    details: 'AD1007873 • Norway',
    status: 'Approved',
    payable: 25000.00,
    received: 25000.00,
    profit: 25000.00,
    date: DateTime(2026, 7, 10),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9807',
    type: 'visa',
    name: 'zoha kamil',
    details: '551073805 • Italy',
    status: 'Approved',
    payable: 25000.00,
    received: 25000.00,
    profit: 7500.00,
    date: DateTime(2026, 7, 13),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9808',
    type: 'visa',
    name: 'kamil karim khan',
    details: '551073775 • Italy',
    status: 'Approved',
    payable: 25000.00,
    received: 25000.00,
    profit: 7500.00,
    date: DateTime(2026, 7, 11),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9809',
    type: 'visa',
    name: 'AFSHAN ZULFIQAR',
    details: '413107370 • Netherlands',
    status: 'Approved',
    payable: 27000.00,
    received: 27000.00,
    profit: 20000.00,
    date: DateTime(2026, 7, 15),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9810',
    type: 'visa',
    name: 'SAGHAR MUKHTAR',
    details: '551042521 • Malaysia',
    status: 'Approved',
    payable: 16500.00,
    received: 16500.00,
    profit: 3500.00,
    date: DateTime(2026, 7, 13),
  ));

  results.add(SearchResultModel(
    id: 'TKT-9811',
    type: 'ticket',
    name: 'MUHAMMAD SAJAWAL',
    details: 'KUL → LHE',
    status: 'Booked',
    payable: 13910.00,
    received: 29030.00,
    profit: 15120.00,
    date: DateTime(2026, 7, 18),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9812',
    type: 'visa',
    name: 'AALIYAN UMAIR',
    details: '551073998 • Azerbaijan',
    status: 'Approved',
    payable: 13000.00,
    received: 13000.00,
    profit: 4000.00,
    date: DateTime(2026, 7, 13),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9813',
    type: 'visa',
    name: 'SHAZRAY JAMIL',
    details: '551078862 • Azerbaijan',
    status: 'Approved',
    payable: 13000.00,
    received: 13000.00,
    profit: 4000.00,
    date: DateTime(2026, 7, 11),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9814',
    type: 'visa',
    name: 'UMAIR ARIF',
    details: '551071203 • Azerbaijan',
    status: 'Approved',
    payable: 13000.00,
    received: 13000.00,
    profit: 4000.00,
    date: DateTime(2026, 7, 13),
  ));

  results.add(SearchResultModel(
    id: 'VSA-9815',
    type: 'visa',
    name: 'GULNAZ SARFRAZ',
    details: '551011431 • Azerbaijan',
    status: 'Approved',
    payable: 13000.00,
    received: 13000.00,
    profit: 4000.00,
    date: DateTime(2026, 7, 13),
  ));

  // Map remaining bookings from bookingsProvider
  for (final b in bookings) {
    // Avoid duplicating the ones we manually defined if names overlap
    if (b.customerName == 'Nasim Akhtar' || b.customerName == 'Irfan Ashraf' || !results.any((r) => r.name.toLowerCase() == b.customerName.toLowerCase())) {
      results.add(SearchResultModel(
        id: b.id,
        type: b.serviceType,
        name: b.customerName,
        details: '${b.passportNumber} • ${b.destination}',
        status: b.status,
        payable: b.payableAmount,
        received: b.receivedAmount,
        profit: b.netProfit,
        date: b.dateCreated,
      ));
    }
  }

  // Map umrahBookings
  for (final u in umrahBookings) {
    if (!results.any((r) => r.id == u.id)) {
      results.add(SearchResultModel(
        id: u.id,
        type: 'umrah',
        name: u.customerName,
        details: '${u.passportNumber} • ${u.vendorName}',
        status: u.status,
        payable: u.payableAmount,
        received: u.receivedAmount,
        profit: u.netProfit,
        date: u.dateCreated,
      ));
    }
  }

  // Map insuranceBookings
  for (final i in insuranceBookings) {
    if (!results.any((r) => r.id == i.id)) {
      results.add(SearchResultModel(
        id: i.id,
        type: 'insurance',
        name: i.insuredName,
        details: '${i.passportNumber} • ${i.company} • ${i.travelCountry}',
        status: i.status,
        payable: i.payableAmount,
        received: i.receivedAmount,
        profit: i.netProfit,
        date: i.dateCreated,
      ));
    }
  }

  return results;
});
