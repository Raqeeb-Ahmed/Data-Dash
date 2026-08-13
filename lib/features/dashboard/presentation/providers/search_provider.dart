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

  // Map remaining bookings from bookingsProvider
  for (final b in bookings) {
    if (!results.any((r) => r.id == b.id)) {
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
