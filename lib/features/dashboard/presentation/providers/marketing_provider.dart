import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class MarketingNotifier extends StateNotifier<List<MarketingCountryStats>> {
  MarketingNotifier() : super(_generateInitialMarketingData());
}

final marketingProvider = StateNotifierProvider<MarketingNotifier, List<MarketingCountryStats>>((ref) {
  return MarketingNotifier();
});

List<MarketingCountryStats> _generateInitialMarketingData() {
  final List<MarketingCountryStats> stats = [];

  // 1. Malaysia data (1389 customers)
  final List<MarketingCustomerModel> malaysiaCustomers = [];
  
  // First 10 explicit records from the screenshot
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1001',
    name: 'HASSAN RAZA',
    email: 'yousafzaitraves@gmail.com',
    phone: '03343434715',
    passportNumber: 'AE890213',
    dateCreated: '2026-03-04',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1002',
    name: 'MUNIR SHAH',
    email: 'bluelineholidayspvt@gmail.com',
    phone: '03339303155',
    passportNumber: 'FC951230',
    dateCreated: '2026-01-20',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1003',
    name: 'MEERAB AROOJ ABNER JANG BAHADUR',
    email: 'info@mosafir.pk',
    phone: '03008717360',
    passportNumber: 'FK820152',
    dateCreated: '2026-02-14',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1004',
    name: 'CHAUDHARY MUEEZ AHMED SANDHU',
    email: 'musaishaqtravel784@gmail.com',
    phone: '03456518356',
    passportNumber: 'BC277329',
    dateCreated: '2026-02-28',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1005',
    name: 'SAEED IQBAL',
    email: 'hilmandtravels@gmail.com',
    phone: '03333853858',
    passportNumber: '5134952M',
    dateCreated: '2026-03-12',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1006',
    name: 'MOHSIN HASSAN',
    email: 'umarnabi55478@gmail.com',
    phone: '03239180790',
    passportNumber: '417817UX',
    dateCreated: '2026-02-15',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1007',
    name: 'ALI HASSAN',
    email: 'yousafzaitraves@gmail.com',
    phone: '03343434715',
    passportNumber: 'TZ309822',
    dateCreated: '2026-03-01',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1008',
    name: 'BILAL HANIF',
    email: 'info@mosafir.pk',
    phone: '03245251459',
    passportNumber: 'G20G1341',
    dateCreated: '2026-02-20',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1009',
    name: 'SAM ALPHONS',
    email: 'info@360dtravels.com',
    phone: '03008717360',
    passportNumber: 'TP311194',
    dateCreated: '2026-03-05',
    country: 'Malaysia',
  ));
  malaysiaCustomers.add(MarketingCustomerModel(
    id: 'MC-1010',
    name: 'FAYYAZ IRSHAD',
    email: 'info.cameryintl@gmail.com',
    phone: '03005147966',
    passportNumber: '4125482N',
    dateCreated: '2026-03-08',
    country: 'Malaysia',
  ));

  // Programmatically generate remaining 1379 customers for Malaysia
  final List<String> generatingNames = [
    'Zafar Iqbal', 'Nadia Kausar', 'Tariq Mehmood', 'Amjad Ali', 'Sobia Malik',
    'Faisal Shah', 'Farzana Bibi', 'Tanveer Ahmed', 'Yasmin Rashid', 'Kamran Khan',
    'Riffat Sultana', 'Naveed Akhtar', 'Rukhsana Begum', 'Asif Mahmood', 'Kiran Shahzadi',
    'Saeed Anwar', 'Uzma Shaheen', 'Arshad Jamil', 'Sadaf Naeem', 'Zahid Hussain'
  ];

  for (int i = 11; i <= 1389; i++) {
    final name = '${generatingNames[i % generatingNames.length]} (${1000 + i})';
    malaysiaCustomers.add(MarketingCustomerModel(
      id: 'MC-$i',
      name: name,
      email: '${generatingNames[i % generatingNames.length].replaceAll(' ', '').toLowerCase()}$i@gmail.com',
      phone: '0300${1000000 + i * 7}',
      passportNumber: 'MY${400000 + i * 3}',
      dateCreated: '2026-03-10',
      country: 'Malaysia',
    ));
  }
  stats.add(MarketingCountryStats(countryName: 'Malaysia', customerCount: 1389, customers: malaysiaCustomers));

  // 2. Thailand data (620 customers)
  final List<MarketingCustomerModel> thailandCustomers = [];
  for (int i = 1; i <= 620; i++) {
    thailandCustomers.add(MarketingCustomerModel(
      id: 'TC-$i',
      name: 'Thai Client $i',
      email: 'thaiclient$i@gmail.com',
      phone: '066${2000000 + i * 5}',
      passportNumber: 'TH${300000 + i * 2}',
      dateCreated: '2026-02-18',
      country: 'Thailand',
    ));
  }
  stats.add(MarketingCountryStats(countryName: 'Thailand', customerCount: 620, customers: thailandCustomers));

  // 3. Indonesia data (245 customers)
  final List<MarketingCustomerModel> indonesiaCustomers = [];
  for (int i = 1; i <= 245; i++) {
    indonesiaCustomers.add(MarketingCustomerModel(
      id: 'IC-$i',
      name: 'Indo Passenger $i',
      email: 'indopass$i@gmail.com',
      phone: '062${5000000 + i}',
      passportNumber: 'ID${200000 + i}',
      dateCreated: '2026-01-12',
      country: 'Indonesia',
    ));
  }
  stats.add(MarketingCountryStats(countryName: 'Indonesia', customerCount: 245, customers: indonesiaCustomers));

  // Define other countries from the screenshot with their counts
  final List<Map<String, dynamic>> countriesConfig = [
    {'name': 'Singapore', 'count': 152},
    {'name': 'Japan', 'count': 95},
    {'name': 'Nepal', 'count': 50},
    {'name': 'Azerbaijan', 'count': 42},
    {'name': 'United States', 'count': 38},
    {'name': 'Uzbekistan', 'count': 31},
    {'name': 'Bahrain', 'count': 28},
    {'name': 'Spain', 'count': 23},
    {'name': 'Sri Lanka', 'count': 21},
    {'name': 'United Kingdom', 'count': 22},
    {'name': 'Netherlands', 'count': 22},
    {'name': 'France', 'count': 19},
    {'name': 'Turkey', 'count': 18},
    {'name': 'Hungary', 'count': 17},
    {'name': 'Sweden', 'count': 15},
    {'name': 'Greece', 'count': 12},
    {'name': 'Italy', 'count': 12},
    {'name': 'Belgium', 'count': 11},
    {'name': 'Pakistan', 'count': 10},
    {'name': 'United Arab Emirates', 'count': 10},
    {'name': 'Tajikistan', 'count': 9},
    {'name': 'Egypt', 'count': 9},
    {'name': 'Norway', 'count': 8},
    {'name': 'Qatar', 'count': 8},
    {'name': 'Poland', 'count': 8},
    {'name': 'South Korea', 'count': 7},
    {'name': 'South Africa', 'count': 7},
    {'name': 'Austria', 'count': 6},
    {'name': 'Morocco', 'count': 5},
    {'name': 'Switzerland', 'count': 5},
    {'name': 'Vietnam', 'count': 5},
    {'name': 'Germany', 'count': 4},
    {'name': 'Canada', 'count': 4},
    {'name': 'Kazakhstan', 'count': 3},
    {'name': 'China', 'count': 3},
    {'name': 'Uganda', 'count': 3},
    {'name': 'Kyrgyzstan', 'count': 2},
    {'name': 'Philippines', 'count': 2},
    {'name': 'Zimbabwe', 'count': 2},
    {'name': 'Denmark', 'count': 2},
    {'name': 'Hong Kong', 'count': 2},
    {'name': 'Finland', 'count': 2},
    {'name': 'Zambia', 'count': 2},
    {'name': 'Ireland', 'count': 2},
    {'name': 'Luxembourg', 'count': 1},
    {'name': 'Costa Rica', 'count': 1},
  ];

  for (final conf in countriesConfig) {
    final String cName = conf['name'];
    final int cCount = conf['count'];
    final List<MarketingCustomerModel> customersList = [];
    
    for (int i = 1; i <= cCount; i++) {
      customersList.add(MarketingCustomerModel(
        id: '${cName.substring(0, 2).toUpperCase()}-$i',
        name: '$cName Customer $i',
        email: '${cName.toLowerCase()}_client$i@gmail.com',
        phone: '0000000$i',
        passportNumber: '${cName.substring(0, 2).toUpperCase()}${100000 + i}',
        dateCreated: '2026-03-01',
        country: cName,
      ));
    }
    stats.add(MarketingCountryStats(countryName: cName, customerCount: cCount, customers: customersList));
  }

  return stats;
}
