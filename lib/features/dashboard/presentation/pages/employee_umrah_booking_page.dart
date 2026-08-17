import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bookings_provider.dart';
import 'umrah_page.dart';

class EmployeeUmrahBookingPage extends ConsumerStatefulWidget {
  const EmployeeUmrahBookingPage({super.key});

  @override
  ConsumerState<EmployeeUmrahBookingPage> createState() =>
      _EmployeeUmrahBookingPageState();
}

class _EmployeeUmrahBookingPageState
    extends ConsumerState<EmployeeUmrahBookingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passportNoController = TextEditingController();
  final _visaNoController = TextEditingController();

  // Makkah Hotel
  final _makkahHotelController = TextEditingController();
  final _makkahNightsController = TextEditingController();
  DateTime? _makkahCheckIn;
  DateTime? _makkahCheckOut;

  // Madinah Hotel
  final _madinahHotelController = TextEditingController();
  final _madinahNightsController = TextEditingController();
  DateTime? _madinahCheckIn;
  DateTime? _madinahCheckOut;

  // 2nd Makkah Hotel
  final _secondMakkahHotelController = TextEditingController();
  final _secondMakkahNightsController = TextEditingController();
  DateTime? _secondMakkahCheckIn;
  DateTime? _secondMakkahCheckOut;

  // Financials
  final _vendorController = TextEditingController();
  final _payableController = TextEditingController();
  final _receivedController = TextEditingController();
  final _profitController = TextEditingController();

  // Search
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _payableController.addListener(_calculateProfit);
    _receivedController.addListener(_calculateProfit);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passportNoController.dispose();
    _visaNoController.dispose();
    _makkahHotelController.dispose();
    _makkahNightsController.dispose();
    _madinahHotelController.dispose();
    _madinahNightsController.dispose();
    _secondMakkahHotelController.dispose();
    _secondMakkahNightsController.dispose();
    _vendorController.dispose();
    _payableController.dispose();
    _receivedController.dispose();
    _profitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final double payable = double.tryParse(_payableController.text) ?? 0.0;
    final double received = double.tryParse(_receivedController.text) ?? 0.0;
    final double profit = received - payable;
    _profitController.text = profit.toStringAsFixed(0);
  }

  void _calculateNights(int section) {
    DateTime? checkIn;
    DateTime? checkOut;
    TextEditingController ctrl;

    if (section == 1) {
      checkIn = _makkahCheckIn;
      checkOut = _makkahCheckOut;
      ctrl = _makkahNightsController;
    } else if (section == 2) {
      checkIn = _madinahCheckIn;
      checkOut = _madinahCheckOut;
      ctrl = _madinahNightsController;
    } else {
      checkIn = _secondMakkahCheckIn;
      checkOut = _secondMakkahCheckOut;
      ctrl = _secondMakkahNightsController;
    }

    if (checkIn != null && checkOut != null) {
      final diff = checkOut.difference(checkIn).inDays;
      ctrl.text = diff > 0 ? diff.toString() : '0';
    }
  }

  Future<void> _selectDate(
    BuildContext context,
    int section,
    bool isCheckIn,
  ) async {
    DateTime? initial;
    if (section == 1) {
      initial = isCheckIn ? _makkahCheckIn : _makkahCheckOut;
    } else if (section == 2) {
      initial = isCheckIn ? _madinahCheckIn : _madinahCheckOut;
    } else {
      initial = isCheckIn ? _secondMakkahCheckIn : _secondMakkahCheckOut;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
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
        if (section == 1) {
          if (isCheckIn) {
            _makkahCheckIn = picked;
          } else {
            _makkahCheckOut = picked;
          }
        } else if (section == 2) {
          if (isCheckIn) {
            _madinahCheckIn = picked;
          } else {
            _madinahCheckOut = picked;
          }
        } else {
          if (isCheckIn) {
            _secondMakkahCheckIn = picked;
          } else {
            _secondMakkahCheckOut = picked;
          }
        }
        _calculateNights(section);
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'dd/mm/yyyy';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authControllerProvider).value;

      await FirebaseFirestore.instance.collection('ummrahBookings').add({
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'passportNumber': _passportNoController.text,
        'visaNumber': _visaNoController.text,
        // Hotels
        'makkahHotel': _makkahHotelController.text,
        'makkahCheckIn': _makkahCheckIn?.toIso8601String() ?? '',
        'makkahCheckOut': _makkahCheckOut?.toIso8601String() ?? '',
        'makkahNights': _makkahNightsController.text,
        'madinahHotel': _madinahHotelController.text,
        'madinahCheckIn': _madinahCheckIn?.toIso8601String() ?? '',
        'madinahCheckOut': _madinahCheckOut?.toIso8601String() ?? '',
        'madinahNights': _madinahNightsController.text,
        'secondMakkahHotel': _secondMakkahHotelController.text,
        'secondMakkahCheckIn': _secondMakkahCheckIn?.toIso8601String() ?? '',
        'secondMakkahCheckOut': _secondMakkahCheckOut?.toIso8601String() ?? '',
        'secondMakkahNights': _secondMakkahNightsController.text,
        // Financials
        'vendor': _vendorController.text,
        'payable': double.tryParse(_payableController.text) ?? 0.0,
        'received': double.tryParse(_receivedController.text) ?? 0.0,
        'profit': double.tryParse(_profitController.text) ?? 0.0,
        'createdByUid': currentUser?.uid ?? '',
        'createdByEmail': currentUser?.email ?? 'Unassigned',
        'status': 'Approved',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Umrah Booking added successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _formKey.currentState!.reset();
        _fullNameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _passportNoController.clear();
        _visaNoController.clear();
        _makkahHotelController.clear();
        _makkahNightsController.clear();
        _madinahHotelController.clear();
        _madinahNightsController.clear();
        _secondMakkahHotelController.clear();
        _secondMakkahNightsController.clear();
        _vendorController.clear();
        _payableController.clear();
        _receivedController.clear();
        _profitController.clear();
        setState(() {
          _makkahCheckIn = null;
          _makkahCheckOut = null;
          _madinahCheckIn = null;
          _madinahCheckOut = null;
          _secondMakkahCheckIn = null;
          _secondMakkahCheckOut = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final formBg = isDarkMode
        ? const Color(0xFF0B0F19).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.95);
    final inputBg = isDarkMode
        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
        : Colors.grey[100]!;
    final isMobile = MediaQuery.of(context).size.width < 750;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        title: Text(
          'Umrah Bookings',
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
        elevation: 1,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF070B13) : Colors.grey[50],
      body: AnimatedWorldMapBackground(
        watermarkText: 'UMRAH SERVICES',
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(bookingsProvider.notifier).refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Umrah Bookings Management 🕋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add, view, and manage your Umrah booking records.',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Add New Booking Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: formBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0x1AFFFFFF)
                            : const Color(0x1F000000),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Booking',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Form Layout
                        if (isMobile) ...[
                          _buildTextField(
                            'Full Name',
                            _fullNameController,
                            Icons.person,
                            'Full Name',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Phone Number',
                            _phoneController,
                            Icons.phone,
                            'Phone Number',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Customer Email',
                            _emailController,
                            Icons.email,
                            'Customer Email (for confirmation) — optional',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                            isRequired: false,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Passport Number',
                            _passportNoController,
                            Icons.card_membership,
                            'Passport Number',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Visa Number',
                            _visaNoController,
                            Icons.verified,
                            'Visa Number',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Full Name',
                                  _fullNameController,
                                  Icons.person,
                                  'Full Name',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Phone Number',
                                  _phoneController,
                                  Icons.phone,
                                  'Phone Number',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Customer Email',
                                  _emailController,
                                  Icons.email,
                                  'Customer Email (for confirmation) — optional',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                  isRequired: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Passport Number',
                                  _passportNoController,
                                  Icons.card_membership,
                                  'Passport Number',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Visa Number',
                            _visaNoController,
                            Icons.verified,
                            'Visa Number',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // ── Sub-section: Makkah Hotel ──
                        _buildSectionHeader(
                          'Makkah Hotel Details',
                          Colors.amber[700]!,
                          primaryTextColor,
                        ),
                        const SizedBox(height: 10),
                        _buildHotelSection(
                          1,
                          _makkahHotelController,
                          _makkahCheckIn,
                          _makkahCheckOut,
                          _makkahNightsController,
                          inputBg,
                          secondaryTextColor,
                          primaryTextColor,
                          isMobile,
                        ),

                        const SizedBox(height: 20),

                        // ── Sub-section: Madinah Hotel ──
                        _buildSectionHeader(
                          'Madinah Hotel Details',
                          Colors.green[700]!,
                          primaryTextColor,
                        ),
                        const SizedBox(height: 10),
                        _buildHotelSection(
                          2,
                          _madinahHotelController,
                          _madinahCheckIn,
                          _madinahCheckOut,
                          _madinahNightsController,
                          inputBg,
                          secondaryTextColor,
                          primaryTextColor,
                          isMobile,
                        ),

                        const SizedBox(height: 20),

                        // ── Sub-section: 2nd Makkah Hotel ──
                        _buildSectionHeader(
                          '2nd Makkah Hotel (If applicable)',
                          Colors.blue[700]!,
                          primaryTextColor,
                        ),
                        const SizedBox(height: 10),
                        _buildHotelSection(
                          3,
                          _secondMakkahHotelController,
                          _secondMakkahCheckIn,
                          _secondMakkahCheckOut,
                          _secondMakkahNightsController,
                          inputBg,
                          secondaryTextColor,
                          primaryTextColor,
                          isMobile,
                          isRequired: false,
                        ),

                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        const SizedBox(height: 20),

                        // Financials
                        if (isMobile) ...[
                          _buildTextField(
                            'Vendor',
                            _vendorController,
                            Icons.business,
                            'Vendor',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Payable Amount',
                            _payableController,
                            Icons.attach_money,
                            'Payable Amount',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                            isNumeric: true,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Received Amount',
                            _receivedController,
                            Icons.account_balance_wallet,
                            'Received Amount',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                            isNumeric: true,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            'Profit',
                            _profitController,
                            Icons.attach_money,
                            'Profit',
                            inputBg,
                            secondaryTextColor,
                            primaryTextColor,
                            isNumeric: true,
                            isEnabled: false,
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Vendor',
                                  _vendorController,
                                  Icons.business,
                                  'Vendor',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Payable Amount',
                                  _payableController,
                                  Icons.attach_money,
                                  'Payable Amount',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                  isNumeric: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  'Received Amount',
                                  _receivedController,
                                  Icons.account_balance_wallet,
                                  'Received Amount',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                  isNumeric: true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  'Profit',
                                  _profitController,
                                  Icons.attach_money,
                                  'Profit',
                                  inputBg,
                                  secondaryTextColor,
                                  primaryTextColor,
                                  isNumeric: true,
                                  isEnabled: false,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),
                        // Add Booking Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    '+ Add Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Find a Booking panel
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: formBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0x1AFFFFFF)
                            : const Color(0x1F000000),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find a Booking',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryTextColor,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      'Search by Name, Passport, or Phone...',
                                  hintStyle: TextStyle(
                                    fontSize: 12,
                                    color: secondaryTextColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: inputBg,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 16,
                                    color: secondaryTextColor,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: secondaryTextColor.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UmrahPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UmrahPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'View All Bookings',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accent, Color textColor) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHotelSection(
    int section,
    TextEditingController hotelCtrl,
    DateTime? checkIn,
    DateTime? checkOut,
    TextEditingController nightsCtrl,
    Color inputBg,
    Color secondary,
    Color primary,
    bool isMobile, {
    bool isRequired = true,
  }) {
    if (isMobile) {
      return Column(
        children: [
          _buildTextField(
            'Hotel Name',
            hotelCtrl,
            Icons.hotel,
            'Hotel Name',
            inputBg,
            secondary,
            primary,
            isRequired: isRequired,
          ),
          const SizedBox(height: 8),
          _buildDateField(
            'Check-in Date',
            checkIn,
            () => _selectDate(context, section, true),
            inputBg,
            secondary,
            primary,
          ),
          const SizedBox(height: 8),
          _buildDateField(
            'Check-out Date',
            checkOut,
            () => _selectDate(context, section, false),
            inputBg,
            secondary,
            primary,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            'Nights',
            nightsCtrl,
            Icons.edit,
            'Nights',
            inputBg,
            secondary,
            primary,
            isNumeric: true,
            isRequired: isRequired,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Hotel Name',
                  hotelCtrl,
                  Icons.hotel,
                  'Hotel Name',
                  inputBg,
                  secondary,
                  primary,
                  isRequired: isRequired,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'Check-in Date',
                  checkIn,
                  () => _selectDate(context, section, true),
                  inputBg,
                  secondary,
                  primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Check-out Date',
                  checkOut,
                  () => _selectDate(context, section, false),
                  inputBg,
                  secondary,
                  primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Nights',
                  nightsCtrl,
                  Icons.edit,
                  'Nights',
                  inputBg,
                  secondary,
                  primary,
                  isNumeric: true,
                  isRequired: isRequired,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    String hint,
    Color inputBg,
    Color secondary,
    Color primary, {
    bool isNumeric = false,
    bool isRequired = true,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: secondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          enabled: isEnabled,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontSize: 12, color: primary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 16, color: secondary),
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: secondary.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: isEnabled ? inputBg : inputBg.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: secondary.withValues(alpha: 0.2)),
            ),
          ),
          validator: (v) {
            if (isRequired && (v == null || v.trim().isEmpty)) {
              return 'Enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    VoidCallback onTap,
    Color inputBg,
    Color secondary,
    Color primary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: secondary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: _formatDate(value)),
              style: TextStyle(fontSize: 12, color: primary),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: secondary,
                ),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: secondary.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
