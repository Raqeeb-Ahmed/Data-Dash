import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/booking_model.dart';
import '../providers/bookings_provider.dart';

class EmployeeTicketsPage extends ConsumerStatefulWidget {
  const EmployeeTicketsPage({super.key});

  @override
  ConsumerState<EmployeeTicketsPage> createState() =>
      _EmployeeTicketsPageState();
}

class _EmployeeTicketsPageState extends ConsumerState<EmployeeTicketsPage> {
  final _formKey = GlobalKey<FormState>();

  // Page view toggle
  bool _showAllBookings = false;

  // Radio button choice
  bool _isReturn = false; // true = Return, false = One Way

  // Form controllers
  final _fromController = TextEditingController(text: 'Karachi, Pakistan');
  final _toController = TextEditingController(text: 'London, UK');
  final _priceController = TextEditingController(text: '55000');
  final _payableController = TextEditingController(text: '10000');
  final _profitController = TextEditingController();
  final _adultsController = TextEditingController(text: '2');
  final _childrenController = TextEditingController(text: '3');
  final _infantsController = TextEditingController(text: '2');
  final _passengerNameController = TextEditingController(text: 'John Doe');
  final _passportController = TextEditingController(text: 'AB123456');
  final _cnicController = TextEditingController(text: '42101-1234567-8');
  final _phoneController = TextEditingController(text: 'WhatsApp preferred');
  final _pnrController = TextEditingController(text: 'OS-XYZ123');
  final _vendorController = TextEditingController();
  final _emailController = TextEditingController(text: 'example@example.com');
  final _airlineController = TextEditingController(text: 'PIA, Emirates');
  final _promoController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected dropdowns
  String _selectedClass = 'Economy';

  // Dates
  DateTime _departureDate = DateTime(2026, 7, 10);
  DateTime? _returnDate;

  // Search Booked Tickets filters (Form-bottom panel)
  final _quickSearchPnrController = TextEditingController();
  final _quickSearchIdController = TextEditingController();

  // Find a Booking filters (All Bookings panel)
  String _filterTime = 'All Time';
  DateTime? _filterDate;
  final _filterPnrController = TextEditingController();
  final _filterIdController = TextEditingController();

  // Table pagination
  int _currentPage = 0;
  final int _perPage = 10;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_calculateProfit);
    _payableController.addListener(_calculateProfit);
    _calculateProfit();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _priceController.dispose();
    _payableController.dispose();
    _profitController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _infantsController.dispose();
    _passengerNameController.dispose();
    _passportController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _pnrController.dispose();
    _vendorController.dispose();
    _emailController.dispose();
    _airlineController.dispose();
    _promoController.dispose();
    _notesController.dispose();
    _quickSearchPnrController.dispose();
    _quickSearchIdController.dispose();
    _filterPnrController.dispose();
    _filterIdController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final double payable = double.tryParse(_payableController.text) ?? 0.0;
    final double profit = price - payable;
    _profitController.text = profit.toStringAsFixed(0);
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isDeparture, {
    bool isFilter = false,
  }) async {
    final DateTime initial = isFilter
        ? (_filterDate ?? DateTime.now())
        : (isDeparture
              ? _departureDate
              : (_returnDate ?? DateTime.now().add(const Duration(days: 7))));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF0F172A),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isFilter) {
          _filterDate = picked;
          _currentPage = 0;
        } else if (isDeparture) {
          _departureDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _handleSaveTicket() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authControllerProvider).value;
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final double payable = double.tryParse(_payableController.text) ?? 0.0;
      final double profit = price - payable;

      final newTicket = BookingModel(
        id: 'tkt_mock_${DateTime.now().millisecondsSinceEpoch}',
        serviceType: 'ticket',
        customerName: _passengerNameController.text,
        customerPhone: _phoneController.text,
        passportNumber: _passportController.text,
        destination: _toController.text,
        dateCreated: _departureDate,
        status: 'Approved',
        paymentStatus: payable <= 0 ? 'Paid' : 'Partially Paid',
        employeeId: user?.uid ?? 'emp_unassigned',
        employeeName: user?.displayName ?? 'AFTAB',
        totalPrice: price,
        receivedAmount: price - payable,
        payableAmount: payable,
        netProfit: profit,
        // Ticket-specific fields
        fromDestination: _fromController.text,
        returnDate: _isReturn && _returnDate != null
            ? _formatDate(_returnDate)
            : null,
        travellersAdults: int.tryParse(_adultsController.text) ?? 1,
        travellersChildren: int.tryParse(_childrenController.text) ?? 0,
        travellersInfants: int.tryParse(_infantsController.text) ?? 0,
        cabinClass: _selectedClass,
        cnic: _cnicController.text,
        pnr: _pnrController.text,
        vendor: _vendorController.text.isNotEmpty
            ? _vendorController.text
            : null,
        email: _emailController.text,
        airlinePreference: _airlineController.text,
        promoCode: _promoController.text.isNotEmpty
            ? _promoController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      // Save to Riverpod bookings state
      ref.read(bookingsProvider.notifier).addBooking(newTicket);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flight ticket booking saved successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      // Clear/Reset fields
      setState(() {
        _vendorController.clear();
        _promoController.clear();
        _notesController.clear();
        _returnDate = null;
      });
    }
  }

  void _triggerQuickSearch() {
    setState(() {
      _filterPnrController.text = _quickSearchPnrController.text;
      _filterIdController.text = _quickSearchIdController.text;
      _showAllBookings = true;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final formBg = isDarkMode
        ? const Color(0xFF0F172A).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.95);
    final inputBg = isDarkMode
        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
        : Colors.grey[100]!;
    final borderColor = isDarkMode
        ? const Color(0x15FFFFFF)
        : const Color(0x1F000000);

    // Filter tickets only
    final ticketBookings = allBookings
        .where((b) => b.serviceType == 'ticket')
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        watermarkText: 'TICKETING',
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: _showAllBookings
                ? _buildAllBookedTicketsView(
                    ticketBookings,
                    isDarkMode,
                    primaryColor,
                    secondaryColor,
                    cardBg: formBg,
                    borderColor: borderColor,
                  )
                : _buildBookNewTicketFormView(
                    ticketBookings,
                    isDarkMode,
                    primaryColor,
                    secondaryColor,
                    formBg: formBg,
                    inputBg: inputBg,
                    borderColor: borderColor,
                  ),
          ),
        ),
      ),
    );
  }

  // ── SCREEN 1: BOOK A NEW TICKET FORM ──
  Widget _buildBookNewTicketFormView(
    List<BookingModel> tickets,
    bool isDarkMode,
    Color primaryColor,
    Color secondaryColor, {
    required Color formBg,
    required Color inputBg,
    required Color borderColor,
  }) {
    final totalBookingsCount = tickets.length;
    final approvedCount = tickets.where((b) => b.status == 'Approved').length;
    final processingCount = tickets
        .where((b) => b.status == 'Processing')
        .length;
    final rejectedCount = tickets.where((b) => b.status == 'Rejected').length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.flight_takeoff,
                  color: Color(0xFF3B82F6),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Book a New Ticket',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Fill out the form below to save a new flight booking record.',
              style: TextStyle(fontSize: 13, color: secondaryColor),
            ),
            const SizedBox(height: 24),

            // Top Stats Bar
            Row(
              children: [
                Expanded(
                  child: _buildMetricMiniCard(
                    'Total Bookings',
                    '$totalBookingsCount',
                    const Color(0xFF3B82F6),
                    formBg,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricMiniCard(
                    'Approved',
                    '$approvedCount',
                    const Color(0xFF10B981),
                    formBg,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricMiniCard(
                    'Booked',
                    '$processingCount',
                    const Color(0xFFF59E0B),
                    formBg,
                    borderColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricMiniCard(
                    'Cancelled',
                    '$rejectedCount',
                    const Color(0xFFEF4444),
                    formBg,
                    borderColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // New Ticket Details Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: formBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Ticket Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // One Way vs Return custom toggle buttons
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _isReturn = false),
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: !_isReturn
                                      ? AppColors.primary
                                      : const Color.fromARGB(137, 0, 0, 0),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: !_isReturn
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'One Way',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      InkWell(
                        onTap: () => setState(() => _isReturn = true),
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isReturn
                                      ? AppColors.primary
                                      : const Color.fromARGB(137, 0, 0, 0),
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(3),
                              child: _isReturn
                                  ? Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Return',
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 850;

                      if (isDesktop) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'From (City / Country)',
                                    _fromController,
                                    'e.g. Karachi, Pakistan',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'To (City / Country)',
                                    _toController,
                                    'e.g. London, UK',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateField(
                                    context,
                                    'Departure Date',
                                    _departureDate,
                                    true,
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateField(
                                    context,
                                    'Return Date',
                                    _returnDate,
                                    false,
                                    inputBg,
                                    secondaryColor,
                                    isEnabled: _isReturn,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Price (PKR)',
                                    _priceController,
                                    'e.g. 55000',
                                    inputBg,
                                    secondaryColor,
                                    isNumeric: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Payable (PKR)',
                                    _payableController,
                                    'e.g. 10000',
                                    inputBg,
                                    secondaryColor,
                                    isNumeric: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Profit (PKR) (Locked)',
                                    _profitController,
                                    '',
                                    inputBg,
                                    secondaryColor,
                                    isEnabled: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Travellers (A / C / I)',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: secondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildMiniNumInput(
                                              _adultsController,
                                              inputBg,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildMiniNumInput(
                                              _childrenController,
                                              inputBg,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: _buildMiniNumInput(
                                              _infantsController,
                                              inputBg,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Class',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: secondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: _selectedClass,
                                        dropdownColor: isDarkMode
                                            ? const Color(0xFF0F172A)
                                            : Colors.white,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                        decoration: _inputDecoration(
                                          inputBg,
                                          secondaryColor,
                                        ),
                                        items: ['Economy', 'Business', 'First']
                                            .map(
                                              (cl) => DropdownMenuItem(
                                                value: cl,
                                                child: Text(
                                                  cl,
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) =>
                                            setState(() => _selectedClass = v!),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Passenger Full Name',
                                    _passengerNameController,
                                    'As per Passport',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Passport',
                                    _passportController,
                                    'e.g. LK123456',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'CNIC',
                                    _cnicController,
                                    '42101-1234567-8',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'Phone',
                                    _phoneController,
                                    'WhatsApp preferred',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'PNR',
                                    _pnrController,
                                    'Enter the pnr here..',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    'Vendor',
                                    _vendorController,
                                    'Enter the Vendor',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    'Email',
                                    _emailController,
                                    'example@example.com',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    'Airline Preference',
                                    _airlineController,
                                    'e.g. PIA, Emirates',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: _buildTextField(
                                    'Promo Code',
                                    _promoController,
                                    'Optional',
                                    inputBg,
                                    secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextField(
                              'From (City / Country)',
                              _fromController,
                              'e.g. Karachi, Pakistan',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'To (City / Country)',
                              _toController,
                              'e.g. London, UK',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              context,
                              'Departure Date',
                              _departureDate,
                              true,
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildDateField(
                              context,
                              'Return Date',
                              _returnDate,
                              false,
                              inputBg,
                              secondaryColor,
                              isEnabled: _isReturn,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Price (PKR)',
                              _priceController,
                              'e.g. 55000',
                              inputBg,
                              secondaryColor,
                              isNumeric: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Payable (PKR)',
                              _payableController,
                              'e.g. 10000',
                              inputBg,
                              secondaryColor,
                              isNumeric: true,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Profit (PKR) (Locked)',
                              _profitController,
                              '',
                              inputBg,
                              secondaryColor,
                              isEnabled: false,
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Travellers (A / C / I)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMiniNumInput(
                                        _adultsController,
                                        inputBg,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildMiniNumInput(
                                        _childrenController,
                                        inputBg,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: _buildMiniNumInput(
                                        _infantsController,
                                        inputBg,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Passenger Full Name',
                              _passengerNameController,
                              'As per Passport',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Passport',
                              _passportController,
                              'e.g. LK123456',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'CNIC',
                              _cnicController,
                              '42101-1234567-8',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Phone',
                              _phoneController,
                              'WhatsApp preferred',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'PNR',
                              _pnrController,
                              'Enter the pnr here..',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Vendor',
                              _vendorController,
                              'Enter the Vendor',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Email',
                              _emailController,
                              'example@example.com',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Airline Preference',
                              _airlineController,
                              'e.g. PIA, Emirates',
                              inputBg,
                              secondaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Promo Code',
                              _promoController,
                              'Optional',
                              inputBg,
                              secondaryColor,
                            ),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  _buildRemarksInput(
                    'Notes',
                    _notesController,
                    'Add any additional notes here...',
                    inputBg,
                    secondaryColor,
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _handleSaveTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Save Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () =>
                            setState(() => _showAllBookings = true),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'View All Bookings',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search Booked Tickets (Bottom Panel)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: formBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search Booked Tickets',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 768;
                      final Widget pnrField = _buildSearchInput(
                        'PNR e.g. OS-XY123',
                        _quickSearchPnrController,
                        inputBg,
                        secondaryColor,
                      );
                      final Widget idField = _buildSearchInput(
                        'Passport / CNIC',
                        _quickSearchIdController,
                        inputBg,
                        secondaryColor,
                      );
                      final Widget searchBtn = SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _triggerQuickSearch,
                          icon: const Icon(
                            Icons.search,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                        ),
                      );

                      if (isDesktop) {
                        return Row(
                          children: [
                            Expanded(child: pnrField),
                            const SizedBox(width: 12),
                            Expanded(child: idField),
                            const SizedBox(width: 12),
                            searchBtn,
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            pnrField,
                            const SizedBox(height: 12),
                            idField,
                            const SizedBox(height: 12),
                            searchBtn,
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SCREEN 2: ALL BOOKED TICKETS RECORDS VIEW ──
  Widget _buildAllBookedTicketsView(
    List<BookingModel> tickets,
    bool isDarkMode,
    Color primaryColor,
    Color secondaryColor, {
    required Color cardBg,
    required Color borderColor,
  }) {
    final filtered = tickets.where((b) {
      if (_filterDate != null) {
        final d1 = DateTime(
          b.dateCreated.year,
          b.dateCreated.month,
          b.dateCreated.day,
        );
        final d2 = DateTime(
          _filterDate!.year,
          _filterDate!.month,
          _filterDate!.day,
        );
        if (d1 != d2) return false;
      }

      if (_filterTime != 'All Time') {
        final now = DateTime.now();
        if (_filterTime == 'Today') {
          if (b.dateCreated.day != now.day ||
              b.dateCreated.month != now.month ||
              b.dateCreated.year != now.year)
            return false;
        } else if (_filterTime == 'This Month') {
          if (b.dateCreated.month != now.month ||
              b.dateCreated.year != now.year)
            return false;
        }
      }

      if (_filterPnrController.text.isNotEmpty) {
        final q = _filterPnrController.text.toLowerCase();
        if (!(b.pnr ?? '').toLowerCase().contains(q)) return false;
      }

      if (_filterIdController.text.isNotEmpty) {
        final q = _filterIdController.text.toLowerCase();
        final passportMatch = b.passportNumber.toLowerCase().contains(q);
        final cnicMatch = (b.cnic ?? '').toLowerCase().contains(q);
        if (!passportMatch && !cnicMatch) return false;
      }

      return true;
    }).toList();

    final totalBookings = filtered.length;
    final approvedCount = filtered.where((b) => b.status == 'Approved').length;
    final cancelledCount = filtered.where((b) => b.status == 'Rejected').length;
    final double totalProfit = filtered.fold(
      0.0,
      (sum, b) => sum + b.netProfit,
    );

    final start = _currentPage * _perPage;
    final end = (start + _perPage).clamp(0, filtered.length);
    final pagedList = start >= filtered.length
        ? <BookingModel>[]
        : filtered.sublist(start, end);
    final totalPages = (filtered.length / _perPage).ceil();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => setState(() {
                  _filterPnrController.clear();
                  _filterIdController.clear();
                  _showAllBookings = false;
                }),
              ),
              const SizedBox(width: 8),
              Text(
                'All Booked Tickets 📜',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Find a Booking filters panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find a Booking',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 850;

                    final Widget timeFilter = Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterTime,
                          dropdownColor: isDarkMode
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          items: ['All Time', 'Today', 'This Month']
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _filterTime = v!;
                            _currentPage = 0;
                          }),
                        ),
                      ),
                    );

                    final Widget datePicker = InkWell(
                      onTap: () => _selectDate(context, false, isFilter: true),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E293B)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: secondaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _filterDate == null
                                  ? 'Specific Date'
                                  : _formatDate(_filterDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    final Widget pnrSearch = Container(
                      height: 38,
                      width: 180,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _filterPnrController,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(fontSize: 12, color: primaryColor),
                        decoration: InputDecoration(
                          hintText: 'Search by PNR',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            color: secondaryColor.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          enabledBorder: .none,
                          disabledBorder: .none,
                          filled: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                        ),
                        onChanged: (_) => setState(() => _currentPage = 0),
                      ),
                    );

                    final Widget idSearch = Container(
                      height: 38,
                      width: 180,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF1E293B)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: _filterIdController,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(fontSize: 12, color: primaryColor),
                        decoration: InputDecoration(
                          hintText: 'Search by ID/CNIC',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            color: secondaryColor.withValues(alpha: 0.7),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          filled: false,
                          disabledBorder: .none,
                          enabledBorder: .none,
                          focusedBorder: .none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                        ),
                        onChanged: (_) => setState(() => _currentPage = 0),
                      ),
                    );

                    final Widget searchBtn = ElevatedButton.icon(
                      onPressed: () => setState(() => _currentPage = 0),
                      icon: const Icon(
                        Icons.search,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                    );

                    if (isDesktop) {
                      return Row(
                        children: [
                          timeFilter,
                          const SizedBox(width: 8),
                          datePicker,
                          const SizedBox(width: 8),
                          pnrSearch,
                          const SizedBox(width: 8),
                          idSearch,
                          const SizedBox(width: 12),
                          searchBtn,
                          if (_filterDate != null ||
                              _filterTime != 'All Time' ||
                              _filterPnrController.text.isNotEmpty ||
                              _filterIdController.text.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => setState(() {
                                _filterTime = 'All Time';
                                _filterDate = null;
                                _filterPnrController.clear();
                                _filterIdController.clear();
                                _currentPage = 0;
                              }),
                              child: const Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(child: timeFilter),
                              const SizedBox(width: 8),
                              Expanded(child: datePicker),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: pnrSearch),
                              const SizedBox(width: 8),
                              Expanded(child: idSearch),
                            ],
                          ),
                          const SizedBox(height: 12),
                          searchBtn,
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dashboard Metrics row
          Row(
            children: [
              Expanded(
                child: _buildMetricMiniCard(
                  'Total Bookings',
                  '$totalBookings',
                  const Color(0xFF3B82F6),
                  cardBg,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricMiniCard(
                  'Approved',
                  '$approvedCount',
                  const Color(0xFF10B981),
                  cardBg,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricMiniCard(
                  'Cancelled',
                  '$cancelledCount',
                  const Color(0xFFEF4444),
                  cardBg,
                  borderColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricMiniCard(
                  'Total Profit',
                  '${totalProfit.toStringAsFixed(0)} PKR',
                  const Color(0xFF10B981),
                  cardBg,
                  borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bookings Records Table
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: isDarkMode
                      ? const Color(0xFF0F172A).withValues(alpha: 0.3)
                      : Colors.grey[100],
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '#',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'PNR / Airline',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Route / Dates',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Passenger',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Cabin / Travellers',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Financials',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                if (pagedList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No bookings found for the selected criteria.',
                        style: TextStyle(fontSize: 13, color: secondaryColor),
                      ),
                    ),
                  )
                else
                  ...List.generate(pagedList.length, (idx) {
                    final b = pagedList[idx];
                    final num = start + idx + 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '$num',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.pnr ?? '-',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  b.airlinePreference ?? 'Any Airline',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${b.fromDestination ?? "Karachi"} -> ${b.destination}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  'Dep: ${_formatDate(b.dateCreated)}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: secondaryColor,
                                  ),
                                ),
                                if (b.returnDate != null)
                                  Text(
                                    'Ret: ${b.returnDate}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: secondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.customerName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  'Passport: ${b.passportNumber}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: secondaryColor,
                                  ),
                                ),
                                if (b.cnic != null)
                                  Text(
                                    'CNIC: ${b.cnic}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: secondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.cabinClass ?? 'Economy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  'Adults: ${b.travellersAdults ?? 1}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: secondaryColor,
                                  ),
                                ),
                                if (b.travellersChildren != null &&
                                    b.travellersChildren! > 0)
                                  Text(
                                    'Child: ${b.travellersChildren}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: secondaryColor,
                                    ),
                                  ),
                                if (b.travellersInfants != null &&
                                    b.travellersInfants! > 0)
                                  Text(
                                    'Infant: ${b.travellersInfants}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: secondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price: ${b.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                Text(
                                  'Payable: ${b.payableAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                                Text(
                                  'Profit: ${b.netProfit.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: b.status == 'Approved'
                                    ? const Color(0x3310B981)
                                    : const Color(0x33EF4444),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                b.status,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: b.status == 'Approved'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${(start + 1)}-$end of ${filtered.length}',
                          style: TextStyle(fontSize: 10, color: secondaryColor),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 16),
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                            ),
                            Text(
                              'Page ${_currentPage + 1} of $totalPages',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 16),
                              onPressed: _currentPage < totalPages - 1
                                  ? () => setState(() => _currentPage++)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Builders Helpers ──

  Widget _buildMetricMiniCard(
    String label,
    String value,
    Color color,
    Color cardBg,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    String hintText,
    Color inputBg,
    Color secondaryColor, {
    bool isNumeric = false,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: secondaryColor)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          enabled: isEnabled,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: TextStyle(
            fontSize: 12,
            color: isEnabled
                ? const Color.fromARGB(255, 0, 0, 0)
                : Colors.white60,
          ),
          decoration: _inputDecoration(
            inputBg,
            secondaryColor,
            hintText: hintText,
          ),
          validator: (v) => isEnabled && v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildSearchInput(
    String hintText,
    TextEditingController ctrl,
    Color inputBg,
    Color secondaryColor,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: secondaryColor.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: TextField(
          controller: ctrl,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 11,
              color: secondaryColor.withValues(alpha: 0.5),
            ),
            border: .none,
            filled: false,
            disabledBorder: .none,
            enabledBorder: .none,
            focusedBorder: .none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? date,
    bool isDep,
    Color inputBg,
    Color secondaryColor, {
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: secondaryColor)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: isEnabled ? () => _selectDate(context, isDep) : null,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(
                text: date == null ? 'dd/mm/yyyy' : _formatDate(date),
              ),
              enabled: isEnabled,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled
                    ? const Color.fromARGB(255, 0, 0, 0)
                    : Colors.white54,
              ),
              decoration: _inputDecoration(
                inputBg,
                secondaryColor,
                icon: Icons.calendar_today,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniNumInput(TextEditingController ctrl, Color inputBg) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildRemarksInput(
    String label,
    TextEditingController ctrl,
    String hintText,
    Color inputBg,
    Color secondaryColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: secondaryColor)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 12, color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 12,
              color: secondaryColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: secondaryColor.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    Color inputBg,
    Color secondaryColor, {
    IconData? icon,
    String? hintText,
  }) {
    return InputDecoration(
      prefixIcon: icon != null
          ? Icon(icon, size: 14, color: secondaryColor)
          : null,
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 12,
        color: secondaryColor.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryColor.withValues(alpha: 0.15)),
      ),
    );
  }
}
