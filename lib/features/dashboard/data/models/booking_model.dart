class BookingModel {
  final String id;
  final String serviceType; // 'visa' | 'ticket' | 'umrah' | 'hotel' | 'insurance'
  final String customerName;
  final String customerPhone;
  final String passportNumber;
  final String destination;
  final DateTime dateCreated;
  final String status; // 'Approved' | 'Processing' | 'Rejected'
  final String paymentStatus; // 'Paid' | 'Unpaid'
  final String employeeId;
  final String employeeName;
  
  // Financials
  final double totalPrice;
  final double receivedAmount;
  final double payableAmount; // amount left to receive (or pay to vendor)
  final double netProfit;

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
