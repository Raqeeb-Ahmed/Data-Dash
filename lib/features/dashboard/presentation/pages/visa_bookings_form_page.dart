import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/booking_model.dart';
import '../providers/bookings_provider.dart';

class VisaBookingsFormPage extends ConsumerStatefulWidget {
  const VisaBookingsFormPage({super.key});

  @override
  ConsumerState<VisaBookingsFormPage> createState() => _VisaBookingsFormPageState();
}

class _VisaBookingsFormPageState extends ConsumerState<VisaBookingsFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _passportNoController = TextEditingController(text: 'AB1234567');
  final _fullNameController = TextEditingController(text: 'John Doe');
  final _totalFeeController = TextEditingController(text: '120000');
  final _receivedFeeController = TextEditingController(text: '20000');
  final _remainingFeeController = TextEditingController();
  final _embassyFeeController = TextEditingController(text: '1000');
  final _profitController = TextEditingController();
  final _referenceController = TextEditingController(text: 'Wajahat Ali');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '03001234567');
  final _vendorNameController = TextEditingController();
  final _vendorContactController = TextEditingController();
  final _vendorFeeController = TextEditingController(text: '0');
  final _remarksController = TextEditingController();

  // Dropdown states
  String _selectedVisaType = 'Tourist';
  String _selectedCountry = 'Belgium';
  String _selectedVisaStatus = 'Approved';
  String _calculatedPaymentStatus = 'Partially Paid';

  // Dates
  DateTime _passportExpiryDate = DateTime(2026, 7, 1);
  DateTime _applicationDate = DateTime.now();
  DateTime? _sentToEmbassyDate;
  DateTime? _receivedFromEmbassyDate;

  @override
  void initState() {
    super.initState();
    // Set up listeners for calculations
    _totalFeeController.addListener(_calculateFinancials);
    _receivedFeeController.addListener(_calculateFinancials);
    _embassyFeeController.addListener(_calculateFinancials);
    _vendorFeeController.addListener(_calculateFinancials);
    
    // Initial run
    _calculateFinancials();
  }

  @override
  void dispose() {
    _passportNoController.dispose();
    _fullNameController.dispose();
    _totalFeeController.dispose();
    _receivedFeeController.dispose();
    _remainingFeeController.dispose();
    _embassyFeeController.dispose();
    _profitController.dispose();
    _referenceController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vendorNameController.dispose();
    _vendorContactController.dispose();
    _vendorFeeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _calculateFinancials() {
    final double totalFee = double.tryParse(_totalFeeController.text) ?? 0.0;
    final double receivedFee = double.tryParse(_receivedFeeController.text) ?? 0.0;
    final double embassyFee = double.tryParse(_embassyFeeController.text) ?? 0.0;
    final double vendorFee = double.tryParse(_vendorFeeController.text) ?? 0.0;

    // 1. Remaining Fee calculation
    final double remainingFee = totalFee - receivedFee;
    _remainingFeeController.text = remainingFee.toStringAsFixed(0);

    // 2. Profit calculation
    final double profit = totalFee - embassyFee - vendorFee;
    _profitController.text = profit.toStringAsFixed(0);

    // 3. Payment Status calculation
    setState(() {
      if (receivedFee == 0) {
        _calculatedPaymentStatus = 'Unpaid';
      } else if (remainingFee <= 0) {
        _calculatedPaymentStatus = 'Paid';
      } else {
        _calculatedPaymentStatus = 'Partially Paid';
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isExpiry, {bool isSent = false, bool isReceived = false}) async {
    final DateTime initial = isExpiry 
        ? _passportExpiryDate 
        : (isSent 
            ? (_sentToEmbassyDate ?? DateTime.now()) 
            : (isReceived ? (_receivedFromEmbassyDate ?? DateTime.now()) : _applicationDate));

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
        if (isExpiry) {
          _passportExpiryDate = picked;
        } else if (isSent) {
          _sentToEmbassyDate = picked;
        } else if (isReceived) {
          _receivedFromEmbassyDate = picked;
        } else {
          _applicationDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  void _handleSaveBooking() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(authControllerProvider).value;
      final double totalFee = double.tryParse(_totalFeeController.text) ?? 0.0;
      final double receivedFee = double.tryParse(_receivedFeeController.text) ?? 0.0;
      final double remainingFee = totalFee - receivedFee;
      final double profit = double.tryParse(_profitController.text) ?? 0.0;

      final newBooking = BookingModel(
        id: 'visa_mock_${DateTime.now().millisecondsSinceEpoch}',
        serviceType: 'visa',
        customerName: _fullNameController.text,
        customerPhone: _phoneController.text,
        passportNumber: _passportNoController.text,
        destination: _selectedCountry,
        dateCreated: _applicationDate,
        status: _selectedVisaStatus,
        paymentStatus: _calculatedPaymentStatus,
        employeeId: user?.uid ?? 'emp_unassigned',
        employeeName: user?.displayName ?? 'AFTAB',
        totalPrice: totalFee,
        receivedAmount: receivedFee,
        payableAmount: remainingFee,
        netProfit: profit,
        // Visa-specific
        passportExpiryDate: _formatDate(_passportExpiryDate),
        visaType: _selectedVisaType,
        embassyFee: double.tryParse(_embassyFeeController.text) ?? 0.0,
        vendorName: _vendorNameController.text.isNotEmpty ? _vendorNameController.text : null,
        vendorContact: _vendorContactController.text.isNotEmpty ? _vendorContactController.text : null,
        vendorFee: double.tryParse(_vendorFeeController.text) ?? 0.0,
        sentToEmbassyDate: _sentToEmbassyDate != null ? _formatDate(_sentToEmbassyDate) : null,
        receivedFromEmbassyDate: _receivedFromEmbassyDate != null ? _formatDate(_receivedFromEmbassyDate) : null,
        remarks: _remarksController.text.isNotEmpty ? _remarksController.text : null,
        email: _emailController.text,
        reference: _referenceController.text,
      );

      // Save to Riverpod bookings state (primed for Firebase repository implementation)
      ref.read(bookingsProvider.notifier).addBooking(newBooking);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visa booking saved successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      // Reset optional fields
      setState(() {
        _vendorNameController.clear();
        _vendorContactController.clear();
        _remarksController.clear();
        _sentToEmbassyDate = null;
        _receivedFromEmbassyDate = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final formBg = isDarkMode ? const Color(0xFF0B0F19).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.95);
    final inputBg = isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        watermarkText: 'VISA PORTAL',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Title Block
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight_takeoff, color: Color(0xFF3B82F6), size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'Visa Bookings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Main Form Grid Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: formBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1F000000),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 850;

                        if (isDesktop) {
                          // Three-Column Layout matching mockup
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildPassportNoField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildExpiryDateField(context, inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildFullNameField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildVisaTypeField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildApplicationDateField(context, inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildCountryField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildVisaStatusField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTotalFeeField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildReceivedFeeField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildRemainingFeeField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildEmbassyFeeField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildProfitField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildPaymentStatusField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildReferenceField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildEmailField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildPhoneField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildVendorNameField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildVendorContactField(inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildVendorFeeField(inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildSentToEmbassyField(context, inputBg, primaryTextColor, secondaryTextColor)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildReceivedFromEmbassyField(context, inputBg, primaryTextColor, secondaryTextColor)),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Mobile Responsive Single Column Layout
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildPassportNoField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildExpiryDateField(context, inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildFullNameField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildVisaTypeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildApplicationDateField(context, inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildCountryField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildVisaStatusField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildTotalFeeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildReceivedFeeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildRemainingFeeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildEmbassyFeeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildProfitField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildPaymentStatusField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildReferenceField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildEmailField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildPhoneField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildVendorNameField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildVendorContactField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildVendorFeeField(inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildSentToEmbassyField(context, inputBg, primaryTextColor, secondaryTextColor),
                              const SizedBox(height: 16),
                              _buildReceivedFromEmbassyField(context, inputBg, primaryTextColor, secondaryTextColor),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remarks Section & Save Button
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: formBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1F000000),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRemarksField(inputBg, primaryTextColor, secondaryTextColor),
                        const SizedBox(height: 24),
                        // Save Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: _handleSaveBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Save Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
    );
  }

  // ── Field Builder Widgets ──

  Widget _buildFieldWrapper(String label, Widget child, Color secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryTextColor),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required IconData icon,
    required String hintText,
    required Color inputBg,
    required Color secondaryTextColor,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 16, color: secondaryTextColor),
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12, color: secondaryTextColor.withValues(alpha: 0.6)),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildPassportNoField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Passport No', TextFormField(
      controller: _passportNoController,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.badge_outlined, hintText: 'e.g., AB1234567', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => v!.isEmpty ? 'Enter Passport No' : null,
    ), secondary);
  }

  Widget _buildExpiryDateField(BuildContext context, Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Expiry Date', GestureDetector(
      onTap: () => _selectDate(context, true),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _formatDate(_passportExpiryDate)),
          style: TextStyle(fontSize: 12, color: primary),
          decoration: _buildInputDecoration(icon: Icons.calendar_today_outlined, hintText: 'Select date', inputBg: inputBg, secondaryTextColor: secondary),
        ),
      ),
    ), secondary);
  }

  Widget _buildFullNameField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Full Name', TextFormField(
      controller: _fullNameController,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.person_outline, hintText: 'Enter traveler full name', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => v!.isEmpty ? 'Enter Full Name' : null,
    ), secondary);
  }

  Widget _buildVisaTypeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Visa Type', DropdownButtonFormField<String>(
      initialValue: _selectedVisaType,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.credit_card_outlined, hintText: '', inputBg: inputBg, secondaryTextColor: secondary),
      dropdownColor: inputBg,
      items: ['Tourist', 'Work', 'Student', 'Business']
          .map((type) => DropdownMenuItem(value: type, child: Text(type, style: TextStyle(color: primary))))
          .toList(),
      onChanged: (v) => setState(() => _selectedVisaType = v!),
    ), secondary);
  }

  Widget _buildApplicationDateField(BuildContext context, Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Application Date', GestureDetector(
      onTap: () => _selectDate(context, false),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _formatDate(_applicationDate)),
          style: TextStyle(fontSize: 12, color: primary),
          decoration: _buildInputDecoration(icon: Icons.calendar_month_outlined, hintText: 'Select date', inputBg: inputBg, secondaryTextColor: secondary),
        ),
      ),
    ), secondary);
  }

  Widget _buildCountryField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Country', DropdownButtonFormField<String>(
      initialValue: _selectedCountry,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.public_outlined, hintText: '', inputBg: inputBg, secondaryTextColor: secondary),
      dropdownColor: inputBg,
      items: ['Belgium', 'Malaysia', 'Uzbekistan', 'Thailand', 'Indonesia', 'Singapore', 'Austria', 'Hungary', 'Schengen']
          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: primary))))
          .toList(),
      onChanged: (v) => setState(() => _selectedCountry = v!),
    ), secondary);
  }

  Widget _buildVisaStatusField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Visa Status', DropdownButtonFormField<String>(
      initialValue: _selectedVisaStatus,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.check_circle_outline, hintText: '', inputBg: inputBg, secondaryTextColor: secondary),
      dropdownColor: inputBg,
      items: ['Approved', 'Processing', 'Rejected']
          .map((status) => DropdownMenuItem(value: status, child: Text(status, style: TextStyle(color: primary))))
          .toList(),
      onChanged: (v) => setState(() => _selectedVisaStatus = v!),
    ), secondary);
  }

  Widget _buildTotalFeeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Total Fee', TextFormField(
      controller: _totalFeeController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.monetization_on_outlined, hintText: 'e.g., 120000', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid fee' : null,
    ), secondary);
  }

  Widget _buildReceivedFeeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Received Fee', TextFormField(
      controller: _receivedFeeController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.account_balance_wallet_outlined, hintText: 'e.g., 20000', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter received amount' : null,
    ), secondary);
  }

  Widget _buildRemainingFeeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Remaining Fee (Locked)', TextFormField(
      controller: _remainingFeeController,
      enabled: false, // LOCKED
      style: TextStyle(fontSize: 12, color: primary.withValues(alpha: 0.7)),
      decoration: _buildInputDecoration(icon: Icons.lock_outline, hintText: '', inputBg: inputBg.withValues(alpha: 0.8), secondaryTextColor: secondary),
    ), secondary);
  }

  Widget _buildEmbassyFeeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Embassy Fee', TextFormField(
      controller: _embassyFeeController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.currency_exchange_outlined, hintText: 'e.g., 1000', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter embassy fee' : null,
    ), secondary);
  }

  Widget _buildProfitField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Profit (Locked)', TextFormField(
      controller: _profitController,
      enabled: false, // LOCKED
      style: TextStyle(fontSize: 12, color: primary.withValues(alpha: 0.7)),
      decoration: _buildInputDecoration(icon: Icons.lock_outline, hintText: '', inputBg: inputBg.withValues(alpha: 0.8), secondaryTextColor: secondary),
    ), secondary);
  }

  Widget _buildPaymentStatusField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Payment Status (Calculated)', TextFormField(
      controller: TextEditingController(text: _calculatedPaymentStatus),
      enabled: false, // LOCKED
      style: TextStyle(fontSize: 12, color: primary.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
      decoration: _buildInputDecoration(
        icon: Icons.payments_outlined,
        hintText: '',
        inputBg: inputBg.withValues(alpha: 0.8),
        secondaryTextColor: _calculatedPaymentStatus == 'Paid' 
            ? const Color(0xFF10B981) 
            : (_calculatedPaymentStatus == 'Partially Paid' ? Colors.amber : Colors.red),
      ),
    ), secondary);
  }

  Widget _buildReferenceField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Reference', TextFormField(
      controller: _referenceController,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.link_outlined, hintText: 'Enter reference handler', inputBg: inputBg, secondaryTextColor: secondary),
    ), secondary);
  }

  Widget _buildEmailField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Email', TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.mail_outline, hintText: 'traveler@email.com', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => v!.isNotEmpty && !v.contains('@') ? 'Enter valid email' : null,
    ), secondary);
  }

  Widget _buildPhoneField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Phone', TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.phone_outlined, hintText: '03XXXXXXXXX', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => v!.isEmpty ? 'Enter Phone Number' : null,
    ), secondary);
  }

  Widget _buildVendorNameField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Vendor Name (Optional)', TextFormField(
      controller: _vendorNameController,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.business_outlined, hintText: 'Enter vendor name', inputBg: inputBg, secondaryTextColor: secondary),
    ), secondary);
  }

  Widget _buildVendorContactField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Vendor Contact (Optional)', TextFormField(
      controller: _vendorContactController,
      keyboardType: TextInputType.phone,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.contact_phone_outlined, hintText: 'Enter vendor contact', inputBg: inputBg, secondaryTextColor: secondary),
    ), secondary);
  }

  Widget _buildVendorFeeField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Vendor Fee', TextFormField(
      controller: _vendorFeeController,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: _buildInputDecoration(icon: Icons.monetization_on_outlined, hintText: 'e.g., 0', inputBg: inputBg, secondaryTextColor: secondary),
      validator: (v) => double.tryParse(v ?? '') == null ? 'Enter vendor fee' : null,
    ), secondary);
  }

  Widget _buildSentToEmbassyField(BuildContext context, Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Sent To Embassy', GestureDetector(
      onTap: () => _selectDate(context, false, isSent: true),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _formatDate(_sentToEmbassyDate)),
          style: TextStyle(fontSize: 12, color: primary),
          decoration: _buildInputDecoration(icon: Icons.local_airport_outlined, hintText: 'e.g., 20/sep/2025', inputBg: inputBg, secondaryTextColor: secondary),
        ),
      ),
    ), secondary);
  }

  Widget _buildReceivedFromEmbassyField(BuildContext context, Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Received From Embassy', GestureDetector(
      onTap: () => _selectDate(context, false, isReceived: true),
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(text: _formatDate(_receivedFromEmbassyDate)),
          style: TextStyle(fontSize: 12, color: primary),
          decoration: _buildInputDecoration(icon: Icons.flight_land_outlined, hintText: 'e.g., 25/sep/2025', inputBg: inputBg, secondaryTextColor: secondary),
        ),
      ),
    ), secondary);
  }

  Widget _buildRemarksField(Color inputBg, Color primary, Color secondary) {
    return _buildFieldWrapper('Remarks', TextFormField(
      controller: _remarksController,
      maxLines: 4,
      style: TextStyle(fontSize: 12, color: primary),
      decoration: InputDecoration(
        hintText: 'Additional notes...',
        hintStyle: TextStyle(fontSize: 12, color: secondary.withValues(alpha: 0.6)),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondary.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondary.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    ), secondary);
  }
}
