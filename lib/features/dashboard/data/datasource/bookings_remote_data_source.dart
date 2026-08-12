import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/booking_model.dart';

class BookingsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Type-safe helper parsers to prevent casting crashes ---
  double _parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  String _parseString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      final val =
          value['name'] ??
          value['title'] ??
          value['text'] ??
          value['city'] ??
          value['code'] ??
          '';
      if (val.toString().isNotEmpty) return val.toString();
      return value.toString();
    }
    return value.toString();
  }

  String _parseName(dynamic value) {
    if (value == null) return 'Unknown';
    if (value is String) return value;
    if (value is Map) {
      final first =
          value['first'] ?? value['firstName'] ?? value['fName'] ?? '';
      final last = value['last'] ?? value['lastName'] ?? value['lName'] ?? '';
      final full = value['full'] ?? value['fullName'] ?? '';
      if (full.toString().isNotEmpty) return full.toString();
      final combined = '$first $last'.trim();
      return combined.isNotEmpty ? combined : value.toString();
    }
    return value.toString();
  }

  Stream<List<BookingModel>> getBookingsStream() {
    final controller = StreamController<List<BookingModel>>();

    final Map<String, List<BookingModel>> latestData = {
      'visa': [],
      'hotel': [],
      'umrah': [],
      'ticket': [],
      'insurance': [],
    };

    void emitMerged() {
      if (!controller.isClosed) {
        final allBookings = latestData.values.expand((list) => list).toList();
        allBookings.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        print('emitMerged: Merged total ${allBookings.length} bookings');
        controller.add(allBookings);
      }
    }

    // 1. Visa Stream (bookings)
    final s1 = _firestore.collection('bookings').snapshots().listen((snapshot) {
      try {
        print('Visa Stream: Received ${snapshot.docs.length} documents');
        latestData['visa'] = snapshot.docs
            .map((doc) {
              try {
                return _mapVisa(doc);
              } catch (e) {
                print('Error mapping Visa doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<BookingModel>()
            .toList();
        emitMerged();
      } catch (e) {
        print('Visa Stream Error: $e');
      }
    }, onError: (e) => print('Visa Stream Listener Error: $e'));

    // 2. Hotel Stream (HotelBookings)
    final s2 = _firestore.collection('HotelBookings').snapshots().listen((
      snapshot,
    ) {
      try {
        print('Hotel Stream: Received ${snapshot.docs.length} documents');
        latestData['hotel'] = snapshot.docs
            .map((doc) {
              try {
                return _mapHotel(doc);
              } catch (e) {
                print('Error mapping Hotel doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<BookingModel>()
            .toList();
        emitMerged();
      } catch (e) {
        print('Hotel Stream Error: $e');
      }
    }, onError: (e) => print('Hotel Stream Listener Error: $e'));

    // 3. Umrah Stream (ummrahBookings)
    final s3 = _firestore.collection('ummrahBookings').snapshots().listen((
      snapshot,
    ) {
      try {
        print('Umrah Stream: Received ${snapshot.docs.length} documents');
        latestData['umrah'] = snapshot.docs
            .map((doc) {
              try {
                return _mapUmrah(doc);
              } catch (e) {
                print('Error mapping Umrah doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<BookingModel>()
            .toList();
        emitMerged();
      } catch (e) {
        print('Umrah Stream Error: $e');
      }
    }, onError: (e) => print('Umrah Stream Listener Error: $e'));

    // 4. Ticket Stream (ticketBookings)
    final s4 = _firestore.collection('ticketBookings').snapshots().listen((
      snapshot,
    ) {
      try {
        print('Ticket Stream: Received ${snapshot.docs.length} documents');
        latestData['ticket'] = snapshot.docs
            .map((doc) {
              try {
                return _mapTicket(doc);
              } catch (e) {
                print('Error mapping Ticket doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<BookingModel>()
            .toList();
        emitMerged();
      } catch (e) {
        print('Ticket Stream Error: $e');
      }
    }, onError: (e) => print('Ticket Stream Listener Error: $e'));

    // 5. Insurance Stream (medical_insurance)
    final s5 = _firestore.collection('medical_insurance').snapshots().listen((
      snapshot,
    ) {
      try {
        print('Insurance Stream: Received ${snapshot.docs.length} documents');
        latestData['insurance'] = snapshot.docs
            .map((doc) {
              try {
                return _mapInsurance(doc);
              } catch (e) {
                print('Error mapping Insurance doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<BookingModel>()
            .toList();
        emitMerged();
      } catch (e) {
        print('Insurance Stream Error: $e');
      }
    }, onError: (e) => print('Insurance Stream Listener Error: $e'));

    controller.onCancel = () {
      s1.cancel();
      s2.cancel();
      s3.cancel();
      s4.cancel();
      s5.cancel();
    };

    return controller.stream;
  }

  // --- Collection Mappers (Type-Safe) ---

  BookingModel _mapVisa(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final payable = _parseNum(data['remainingFee']);
    final profit = _parseNum(data['profit']);
    final received = _parseNum(data['receivedFee']);
    final total = _parseNum(data['totalFee'] ?? (received + payable));
    return BookingModel(
      id: doc.id,
      serviceType: 'visa',
      customerName: _parseName(data['fullName'] ?? data['clientName']),
      customerPhone: _parseString(data['phone']),
      passportNumber: _parseString(data['passport']),
      destination: _parseString(data['country']),
      dateCreated: _parseDateTime(data['createdAt']),
      status: _parseString(data['visaStatus'] ?? 'Processing'),
      paymentStatus: _parseString(data['paymentStatus'] ?? 'Unpaid'),
      employeeId: _parseString(data['userId']),
      employeeName: _parseString(data['userEmail'] ?? 'Unassigned'),
      totalPrice: total,
      receivedAmount: received,
      payableAmount: payable,
      netProfit: profit,
      passportExpiryDate: _parseString(data['expiryDate']),
      visaType: _parseString(data['visaType']),
      embassyFee: data['embassyFee'] != null
          ? _parseNum(data['embassyFee'])
          : null,
      vendorName: _parseString(data['vendor']),
      vendorContact: _parseString(data['vendorContact']),
      vendorFee: data['vendorFee'] != null
          ? _parseNum(data['vendorFee'])
          : null,
      sentToEmbassyDate: _parseString(data['sentToEmbassy']),
      receivedFromEmbassyDate: _parseString(data['receivedFromEmbassy']),
      remarks: _parseString(data['remarks']),
      email: _parseString(data['email']),
      reference: _parseString(data['reference']),
    );
  }

  BookingModel _mapHotel(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final payable = _parseNum(data['payable']);
    final profit = _parseNum(data['profit']);
    final received = _parseNum(data['received']);
    final total = received + payable;
    return BookingModel(
      id: doc.id,
      serviceType: 'hotel',
      customerName: _parseName(data['clientName']),
      customerPhone: _parseString(data['careContact']),
      passportNumber: '',
      destination: _parseString(data['property'] ?? 'Hotel'),
      dateCreated: _parseDateTime(data['createdAt']),
      status: _parseString(data['status'] ?? 'Approved'),
      paymentStatus: received >= total
          ? 'Paid'
          : (received > 0 ? 'Partially Paid' : 'Unpaid'),
      employeeId: _parseString(data['createdByUid']),
      employeeName: _parseString(data['userEmail'] ?? 'Unassigned'),
      totalPrice: total,
      receivedAmount: received,
      payableAmount: payable,
      netProfit: profit,
      returnDate: _parseString(data['departureDate']),
      notes: _parseString(data['notes']),
      travellersAdults: _parseInt(data['numberOfAdults']),
      travellersChildren: _parseInt(data['numberOfChildren']),
      cabinClass: _parseString(data['numberOfRooms']),
    );
  }

  BookingModel _mapUmrah(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final payable = _parseNum(data['payable']);
    final profit = _parseNum(data['profit']);
    final received = _parseNum(data['received']);
    final total = received + payable;
    return BookingModel(
      id: doc.id,
      serviceType: 'umrah',
      customerName: _parseName(data['fullName']),
      customerPhone: _parseString(data['phone']),
      passportNumber: _parseString(data['passportNumber']),
      destination: _parseString(data['makkahHotel'] ?? 'Makkah'),
      dateCreated: _parseDateTime(data['createdAt']),
      status: _parseString(data['status'] ?? 'Approved'),
      paymentStatus: received >= total
          ? 'Paid'
          : (received > 0 ? 'Partially Paid' : 'Unpaid'),
      employeeId: _parseString(data['createdByUid']),
      employeeName: _parseString(data['createdByEmail'] ?? 'Unassigned'),
      totalPrice: total,
      receivedAmount: received,
      payableAmount: payable,
      netProfit: profit,
      vendorName: _parseString(data['vendor']),
    );
  }

  BookingModel _mapTicket(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final payable = _parseNum(data['payable'] ?? data['payableAmount']);
    final profit = _parseNum(
      data['profit'] ?? data['netProfit'] ?? data['totalProfit'],
    );
    final received = _parseNum(
      data['received'] ?? data['receivedAmount'] ?? data['totalReceivedAmount'],
    );
    final total = received + payable;
    return BookingModel(
      id: doc.id,
      serviceType: 'ticket',
      customerName: _parseName(
        data['fullName'] ??
            data['clientName'] ??
            data['passengerName'] ??
            data['passenger'] ??
            data['Name'],
      ),
      customerPhone: _parseString(
        data['phone'] ?? data['contactNumber'] ?? data['phoneNo'],
      ),
      passportNumber: _parseString(data['passportNumber'] ?? data['passport']),
      destination: _parseString(
        data['destination'] ?? data['toDestination'] ?? data['route'],
      ),
      dateCreated: _parseDateTime(data['createdAt'] ?? data['date']),
      status: _parseString(
        data['status'] ?? data['ticketStatus'] ?? 'Approved',
      ),
      paymentStatus: received >= total
          ? 'Paid'
          : (received > 0 ? 'Partially Paid' : 'Unpaid'),
      employeeId: _parseString(data['createdByUid'] ?? data['userId']),
      employeeName: _parseString(
        data['userEmail'] ??
            data['createdByEmail'] ??
            data['employee'] ??
            data['employeeEmail'] ??
            'Unassigned',
      ),
      totalPrice: total,
      receivedAmount: received,
      payableAmount: payable,
      netProfit: profit,
      fromDestination: _parseString(data['fromDestination'] ?? data['from']),
      returnDate: _parseString(data['returnDate']),
      travellersAdults: _parseInt(
        data['travellersAdults'] ?? data['numberOfAdults'],
      ),
      travellersChildren: _parseInt(
        data['travellersChildren'] ?? data['numberOfChildren'],
      ),
      travellersInfants: _parseInt(data['travellersInfants']),
      cabinClass: _parseString(data['cabinClass'] ?? data['class']),
      cnic: _parseString(data['cnic']),
      pnr: _parseString(data['pnr'] ?? data['PNR']),
      vendor: _parseString(data['vendor']),
      email: _parseString(data['email']),
      airlinePreference: _parseString(data['airlinePreference']),
      promoCode: _parseString(data['promoCode']),
      notes: _parseString(data['notes']),
    );
  }

  BookingModel _mapInsurance(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final payable = _parseNum(data['totalPayableAmount'] ?? data['payable']);
    final profit = _parseNum(data['totalProfit'] ?? data['profit']);
    final received = _parseNum(data['totalReceivedAmount'] ?? data['received']);
    final total = received + payable;
    return BookingModel(
      id: doc.id,
      serviceType: 'insurance',
      customerName: _parseName(data['NameofInsured']),
      customerPhone: _parseString(data['contactNumber']),
      passportNumber: _parseString(data['passportNumber']),
      destination: _parseString(data['countryofTravel']),
      dateCreated: _parseDateTime(data['createdAt']),
      status: _parseString(data['status'] ?? 'Approved'),
      paymentStatus: received >= total
          ? 'Paid'
          : (received > 0 ? 'Partially Paid' : 'Unpaid'),
      employeeId: _parseString(data['createdByUid']),
      employeeName: _parseString(data['userEmail'] ?? 'Unassigned'),
      totalPrice: total,
      receivedAmount: received,
      payableAmount: payable,
      netProfit: profit,
      vendorName: _parseString(data['NameofCompany']),
    );
  }

  // --- WRITE OPERATIONS TO FIRESTORE ---

  String _getCollectionName(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'visa':
        return 'bookings';
      case 'hotel':
        return 'HotelBookings';
      case 'umrah':
        return 'ummrahBookings';
      case 'ticket':
        return 'ticketBookings';
      case 'insurance':
        return 'medical_insurance';
      default:
        return 'bookings';
    }
  }

  Future<void> addBooking(BookingModel b) async {
    final col = _getCollectionName(b.serviceType);
    final data = _mapModelToDbMap(b);
    data['createdAt'] = FieldValue.serverTimestamp();
    await _firestore.collection(col).add(data);
  }

  Future<void> updateBooking(BookingModel b) async {
    final col = _getCollectionName(b.serviceType);
    final data = _mapModelToDbMap(b);
    await _firestore.collection(col).doc(b.id).update(data);
  }

  Future<void> deleteBooking(String id, String serviceType) async {
    final col = _getCollectionName(serviceType);
    await _firestore.collection(col).doc(id).delete();
  }

  Map<String, dynamic> _mapModelToDbMap(BookingModel b) {
    switch (b.serviceType.toLowerCase()) {
      case 'visa':
        return {
          'fullName': b.customerName,
          'phone': b.customerPhone,
          'passport': b.passportNumber,
          'country': b.destination,
          'visaStatus': b.status,
          'paymentStatus': b.paymentStatus,
          'userId': b.employeeId,
          'userEmail': b.employeeName,
          'totalFee': b.totalPrice,
          'receivedFee': b.receivedAmount,
          'remainingFee': b.payableAmount,
          'profit': b.netProfit,
          'expiryDate': b.passportExpiryDate,
          'visaType': b.visaType,
          'embassyFee': b.embassyFee,
          'vendor': b.vendorName,
          'vendorContact': b.vendorContact,
          'vendorFee': b.vendorFee,
          'sentToEmbassy': b.sentToEmbassyDate,
          'receivedFromEmbassy': b.receivedFromEmbassyDate,
          'remarks': b.remarks,
          'email': b.email,
          'reference': b.reference,
        };
      case 'hotel':
        return {
          'clientName': b.customerName,
          'careContact': b.customerPhone,
          'property': b.destination,
          'createdByUid': b.employeeId,
          'userEmail': b.employeeName,
          'received': b.receivedAmount,
          'payable': b.payableAmount,
          'profit': b.netProfit,
          'departureDate': b.returnDate,
          'notes': b.notes,
          'numberOfAdults': b.travellersAdults?.toString() ?? '1',
          'numberOfChildren': b.travellersChildren?.toString() ?? '0',
          'numberOfRooms': b.cabinClass ?? '1',
        };
      case 'umrah':
        return {
          'fullName': b.customerName,
          'phone': b.customerPhone,
          'passportNumber': b.passportNumber,
          'makkahHotel': b.destination,
          'createdByUid': b.employeeId,
          'createdByEmail': b.employeeName,
          'received': b.receivedAmount,
          'payable': b.payableAmount,
          'profit': b.netProfit,
          'vendor': b.vendorName,
        };
      case 'ticket':
        return {
          'fullName': b.customerName,
          'phone': b.customerPhone,
          'passportNumber': b.passportNumber,
          'destination': b.destination,
          'createdByUid': b.employeeId,
          'userEmail': b.employeeName,
          'received': b.receivedAmount,
          'payable': b.payableAmount,
          'profit': b.netProfit,
          'fromDestination': b.fromDestination,
          'returnDate': b.returnDate,
          'travellersAdults': b.travellersAdults,
          'travellersChildren': b.travellersChildren,
          'travellersInfants': b.travellersInfants,
          'cabinClass': b.cabinClass,
          'cnic': b.cnic,
          'pnr': b.pnr,
          'vendor': b.vendor,
          'email': b.email,
          'airlinePreference': b.airlinePreference,
          'promoCode': b.promoCode,
          'notes': b.notes,
        };
      case 'insurance':
        return {
          'NameofInsured': b.customerName,
          'contactNumber': b.customerPhone,
          'passportNumber': b.passportNumber,
          'countryofTravel': b.destination,
          'createdByUid': b.employeeId,
          'userEmail': b.employeeName,
          'totalReceivedAmount': b.receivedAmount,
          'totalPayableAmount': b.payableAmount,
          'totalProfit': b.netProfit,
          'NameofCompany': b.vendorName,
        };
      default:
        return b.toJson();
    }
  }
}
