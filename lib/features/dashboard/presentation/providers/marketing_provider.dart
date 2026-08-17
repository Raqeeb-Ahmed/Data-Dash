import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookings_provider.dart';
import 'umrah_provider.dart';
import 'insurance_provider.dart';

class MarketingCustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String passportNumber;
  final String dateCreated;
  final String country;

  MarketingCustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.passportNumber,
    required this.dateCreated,
    required this.country,
  });
}

class MarketingCountryStats {
  final String countryName;
  final int customerCount;
  final List<MarketingCustomerModel> customers;

  MarketingCountryStats({
    required this.countryName,
    required this.customerCount,
    required this.customers,
  });
}

String _getCountryFromDestination(String dest) {
  final d = dest.toLowerCase().trim();
  if (d.isEmpty) return 'General';

  if (d.contains('malaysia') || d.contains('kul') || d.contains('kuala')) return 'Malaysia';
  if (d.contains('thailand') || d.contains('bkk') || d.contains('bangkok') || d.contains('phuket')) return 'Thailand';
  if (d.contains('indonesia') || d.contains('cgk') || d.contains('jakarta') || d.contains('bali')) return 'Indonesia';
  if (d.contains('singapore') || d.contains('sin')) return 'Singapore';
  if (d.contains('saudi') || d.contains('jed') || d.contains('med') || d.contains('makkah') || d.contains('riyadh') || d.contains('ruh') || d.contains('umrah')) return 'Saudi Arabia';
  if (d.contains('dubai') || d.contains('dxb') || d.contains('uae') || d.contains('abu dhabi') || d.contains('sharjah') || d.contains('emirates')) return 'United Arab Emirates';
  if (d.contains('london') || d.contains('lhr') || d.contains('uk') || d.contains('united kingdom') || d.contains('manchester')) return 'United Kingdom';
  if (d.contains('azerbaijan') || d.contains('baku') || d.contains('gyd')) return 'Azerbaijan';
  if (d.contains('uzbekistan') || d.contains('tashkent') || d.contains('tas')) return 'Uzbekistan';
  if (d.contains('nepal') || d.contains('kathmandu') || d.contains('ktm')) return 'Nepal';
  if (d.contains('bahrain') || d.contains('manama') || d.contains('bah')) return 'Bahrain';
  if (d.contains('spain') || d.contains('madrid') || d.contains('barcelona')) return 'Spain';
  if (d.contains('sri lanka') || d.contains('colombo') || d.contains('cmb')) return 'Sri Lanka';
  if (d.contains('france') || d.contains('paris') || d.contains('cdg')) return 'France';
  if (d.contains('turkey') || d.contains('istanbul') || d.contains('ist')) return 'Turkey';
  if (d.contains('egypt') || d.contains('cairo') || d.contains('cai')) return 'Egypt';
  if (d.contains('usa') || d.contains('united states') || d.contains('jfk') || d.contains('new york') || d.contains('america')) return 'United States';
  if (d.contains('canada') || d.contains('toronto') || d.contains('yyz')) return 'Canada';
  if (d.contains('qatar') || d.contains('doha') || d.contains('doh')) return 'Qatar';
  if (d.contains('oman') || d.contains('muscat') || d.contains('mct')) return 'Oman';
  if (d.contains('pakistan') || d.contains('khi') || d.contains('lhe') || d.contains('isb') || d.contains('karachi') || d.contains('lahore') || d.contains('islamabad')) return 'Pakistan';

  return dest.split(' ').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

final marketingProvider = Provider<List<MarketingCountryStats>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  final umrahBookings = ref.watch(umrahBookingsProvider);
  final insuranceBookings = ref.watch(insuranceBookingsProvider);

  final Map<String, Map<String, MarketingCustomerModel>> countryMap = {};

  void addCustomer(String country, MarketingCustomerModel customer) {
    if (country.trim().isEmpty) return;
    final normalizedCountry = country.trim();
    if (!countryMap.containsKey(normalizedCountry)) {
      countryMap[normalizedCountry] = {};
    }
    final key = customer.passportNumber.isNotEmpty ? customer.passportNumber : customer.name;
    final existing = countryMap[normalizedCountry]![key];
    if (existing == null || (existing.email.isEmpty && customer.email.isNotEmpty)) {
      countryMap[normalizedCountry]![key] = customer;
    }
  }

  // 1. Process bookings (visa, ticket, hotel)
  for (final b in bookings) {
    var country = _getCountryFromDestination(b.destination);
    if (country == 'General' || country.isEmpty) {
      if (b.serviceType == 'hotel') {
        country = 'Hotel';
      } else if (b.serviceType == 'visa') {
        country = 'Visa';
      } else {
        country = 'General';
      }
    }

    addCustomer(
      country,
      MarketingCustomerModel(
        id: b.id,
        name: b.customerName,
        email: (b.email != null && b.email!.isNotEmpty) ? b.email! : '${b.customerName.replaceAll(' ', '').toLowerCase()}@gmail.com',
        phone: b.customerPhone,
        passportNumber: b.passportNumber,
        dateCreated: b.dateCreated.toString().split(' ')[0],
        country: country,
      ),
    );
  }

  // 2. Process umrah bookings
  for (final u in umrahBookings) {
    const country = 'Saudi Arabia';
    addCustomer(
      country,
      MarketingCustomerModel(
        id: u.id,
        name: u.customerName,
        email: '${u.customerName.replaceAll(' ', '').toLowerCase()}@gmail.com',
        phone: u.customerPhone,
        passportNumber: u.passportNumber,
        dateCreated: u.dateCreated.toString().split(' ')[0],
        country: country,
      ),
    );
  }

  // 3. Process insurance bookings
  for (final i in insuranceBookings) {
    var country = _getCountryFromDestination(i.travelCountry);
    if (country == 'General' || country.isEmpty) country = 'Insurance';
    addCustomer(
      country,
      MarketingCustomerModel(
        id: i.id,
        name: i.insuredName,
        email: '${i.insuredName.replaceAll(' ', '').toLowerCase()}@gmail.com',
        phone: '',
        passportNumber: i.passportNumber,
        dateCreated: i.dateCreated.toString().split(' ')[0],
        country: country,
      ),
    );
  }

  final List<MarketingCountryStats> stats = [];
  countryMap.forEach((countryName, customerMap) {
    final customers = customerMap.values.toList();
    stats.add(MarketingCountryStats(
      countryName: countryName,
      customerCount: customers.length,
      customers: customers,
    ));
  });

  stats.sort((a, b) => b.customerCount.compareTo(a.customerCount));
  return stats;
});
