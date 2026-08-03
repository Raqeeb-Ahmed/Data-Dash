class BookingModel {
  final String id;
  final String serviceType; // 'visa' | 'ticket' | 'umrah' | 'hotel' | 'insurance'
  final String customerName;
  final String customerPhone;
  final String passportNumber;
  final String destination;
  final DateTime dateCreated;
  final String status; // 'Approved' | 'Processing' | 'Rejected'
  final String paymentStatus; // 'Paid' | 'Unpaid' | 'Partially Paid'
  final String employeeId;
  final String employeeName;
  
  // Financials
  final double totalPrice;
  final double receivedAmount;
  final double payableAmount; // amount left to receive (or pay to vendor)
  final double netProfit;

  // Visa specific details (nullable)
  final String? passportExpiryDate;
  final String? visaType;
  final double? embassyFee;
  final String? vendorName;
  final String? vendorContact;
  final double? vendorFee;
  final String? sentToEmbassyDate;
  final String? receivedFromEmbassyDate;
  final String? remarks;
  final String? email;
  final String? reference;

  // New Ticket specific details (nullable)
  final String? fromDestination;
  final String? returnDate;
  final int? travellersAdults;
  final int? travellersChildren;
  final int? travellersInfants;
  final String? cabinClass;
  final String? cnic;
  final String? pnr;
  final String? vendor;
  final String? airlinePreference;
  final String? promoCode;
  final String? notes;

  BookingModel({
    required this.id,
    required this.serviceType,
    required this.customerName,
    required this.customerPhone,
    required this.passportNumber,
    required this.destination,
    required this.dateCreated,
    required this.status,
    required this.paymentStatus,
    required this.employeeId,
    required this.employeeName,
    required this.totalPrice,
    required this.receivedAmount,
    required this.payableAmount,
    required this.netProfit,
    this.passportExpiryDate,
    this.visaType,
    this.embassyFee,
    this.vendorName,
    this.vendorContact,
    this.vendorFee,
    this.sentToEmbassyDate,
    this.receivedFromEmbassyDate,
    this.remarks,
    this.email,
    this.reference,
    this.fromDestination,
    this.returnDate,
    this.travellersAdults,
    this.travellersChildren,
    this.travellersInfants,
    this.cabinClass,
    this.cnic,
    this.pnr,
    this.vendor,
    this.airlinePreference,
    this.promoCode,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceType': serviceType,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'passportNumber': passportNumber,
      'destination': destination,
      'dateCreated': dateCreated.toIso8601String(),
      'status': status,
      'paymentStatus': paymentStatus,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'totalPrice': totalPrice,
      'receivedAmount': receivedAmount,
      'payableAmount': payableAmount,
      'netProfit': netProfit,
      if (passportExpiryDate != null) 'passportExpiryDate': passportExpiryDate,
      if (visaType != null) 'visaType': visaType,
      if (embassyFee != null) 'embassyFee': embassyFee,
      if (vendorName != null) 'vendorName': vendorName,
      if (vendorContact != null) 'vendorContact': vendorContact,
      if (vendorFee != null) 'vendorFee': vendorFee,
      if (sentToEmbassyDate != null) 'sentToEmbassyDate': sentToEmbassyDate,
      if (receivedFromEmbassyDate != null) 'receivedFromEmbassyDate': receivedFromEmbassyDate,
      if (remarks != null) 'remarks': remarks,
      if (email != null) 'email': email,
      if (reference != null) 'reference': reference,
      if (fromDestination != null) 'fromDestination': fromDestination,
      if (returnDate != null) 'returnDate': returnDate,
      if (travellersAdults != null) 'travellersAdults': travellersAdults,
      if (travellersChildren != null) 'travellersChildren': travellersChildren,
      if (travellersInfants != null) 'travellersInfants': travellersInfants,
      if (cabinClass != null) 'cabinClass': cabinClass,
      if (cnic != null) 'cnic': cnic,
      if (pnr != null) 'pnr': pnr,
      if (vendor != null) 'vendor': vendor,
      if (airlinePreference != null) 'airlinePreference': airlinePreference,
      if (promoCode != null) 'promoCode': promoCode,
      if (notes != null) 'notes': notes,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json, String docId) {
    return BookingModel(
      id: docId,
      serviceType: json['serviceType'] ?? 'visa',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      passportNumber: json['passportNumber'] ?? '',
      destination: json['destination'] ?? '',
      dateCreated: json['dateCreated'] != null 
          ? DateTime.parse(json['dateCreated']) 
          : DateTime.now(),
      status: json['status'] ?? 'Processing',
      paymentStatus: json['paymentStatus'] ?? 'Unpaid',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? 'Unassigned',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      receivedAmount: (json['receivedAmount'] ?? 0.0).toDouble(),
      payableAmount: (json['payableAmount'] ?? 0.0).toDouble(),
      netProfit: (json['netProfit'] ?? 0.0).toDouble(),
      passportExpiryDate: json['passportExpiryDate'],
      visaType: json['visaType'],
      embassyFee: json['embassyFee'] != null ? (json['embassyFee'] as num).toDouble() : null,
      vendorName: json['vendorName'],
      vendorContact: json['vendorContact'],
      vendorFee: json['vendorFee'] != null ? (json['vendorFee'] as num).toDouble() : null,
      sentToEmbassyDate: json['sentToEmbassyDate'],
      receivedFromEmbassyDate: json['receivedFromEmbassyDate'],
      remarks: json['remarks'],
      email: json['email'],
      reference: json['reference'],
      fromDestination: json['fromDestination'],
      returnDate: json['returnDate'],
      travellersAdults: json['travellersAdults'] != null ? (json['travellersAdults'] as num).toInt() : null,
      travellersChildren: json['travellersChildren'] != null ? (json['travellersChildren'] as num).toInt() : null,
      travellersInfants: json['travellersInfants'] != null ? (json['travellersInfants'] as num).toInt() : null,
      cabinClass: json['cabinClass'],
      cnic: json['cnic'],
      pnr: json['pnr'],
      vendor: json['vendor'],
      airlinePreference: json['airlinePreference'],
      promoCode: json['promoCode'],
      notes: json['notes'],
    );
  }

  // Helper method to generate mock bookings for development
  static List<BookingModel> getMockBookings() {
    return [
      BookingModel(
        id: '1',
        serviceType: 'visa',
        customerName: 'Muhammad Ali',
        customerPhone: '+92 300 1234567',
        passportNumber: 'AB123456',
        destination: 'United Kingdom',
        dateCreated: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Approved',
        paymentStatus: 'Paid',
        employeeId: 'emp_1',
        employeeName: 'Zainab',
        totalPrice: 250000,
        receivedAmount: 250000,
        payableAmount: 0,
        netProfit: 75000,
      ),
      BookingModel(
        id: '2',
        serviceType: 'ticket',
        customerName: 'Ayesha Khan',
        customerPhone: '+92 321 7654321',
        passportNumber: 'CD789012',
        destination: 'Saudi Arabia (JED)',
        dateCreated: DateTime.now().subtract(const Duration(days: 4)),
        status: 'Approved',
        paymentStatus: 'Paid',
        employeeId: 'emp_2',
        employeeName: 'Hamza',
        totalPrice: 180000,
        receivedAmount: 180000,
        payableAmount: 0,
        netProfit: 15000,
      ),
      BookingModel(
        id: '3',
        serviceType: 'umrah',
        customerName: 'Fatima Begum',
        customerPhone: '+92 333 5556667',
        passportNumber: 'EF345678',
        destination: 'Makkah & Madinah',
        dateCreated: DateTime.now().subtract(const Duration(days: 6)),
        status: 'Processing',
        paymentStatus: 'Unpaid',
        employeeId: 'emp_3',
        employeeName: 'Bilal',
        totalPrice: 450000,
        receivedAmount: 150000,
        payableAmount: 300000,
        netProfit: 60000,
      ),
      BookingModel(
        id: '4',
        serviceType: 'hotel',
        customerName: 'Khurram Shahzad',
        customerPhone: '+92 312 9998887',
        passportNumber: 'GH901234',
        destination: 'Dubai (5-Star Hotel)',
        dateCreated: DateTime.now().subtract(const Duration(days: 8)),
        status: 'Approved',
        paymentStatus: 'Paid',
        employeeId: 'emp_1',
        employeeName: 'Zainab',
        totalPrice: 120000,
        receivedAmount: 120000,
        payableAmount: 0,
        netProfit: 18000,
      ),
      BookingModel(
        id: '5',
        serviceType: 'insurance',
        customerName: 'Bilal Hassan',
        customerPhone: '+92 300 4443332',
        passportNumber: 'JK567890',
        destination: 'Schengen Area',
        dateCreated: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Rejected',
        paymentStatus: 'Unpaid',
        employeeId: 'emp_2',
        employeeName: 'Hamza',
        totalPrice: 15000,
        receivedAmount: 0,
        payableAmount: 15000,
        netProfit: 0,
      ),
    ];
  }
}
