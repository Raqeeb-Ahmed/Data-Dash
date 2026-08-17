import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/bookings_provider.dart';
import 'hotels_page.dart';

class EmployeeHotelBookingPage extends ConsumerStatefulWidget {
  const EmployeeHotelBookingPage({super.key});

  @override
  ConsumerState<EmployeeHotelBookingPage> createState() =>
      _EmployeeHotelBookingPageState();
}

class _EmployeeHotelBookingPageState
    extends ConsumerState<EmployeeHotelBookingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _bookingIdController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _propertyNameController = TextEditingController();
  final _numberOfRoomsController = TextEditingController(text: '1');
  final _numberOfAdultsController = TextEditingController(text: '1');
  final _numberOfChildrenController = TextEditingController(text: '0');
  final _nightsStayedController = TextEditingController();
  final _careNameController = TextEditingController();
  final _careContactController = TextEditingController();
  final _careEmailController = TextEditingController();
  final _paymentMethodController = TextEditingController(text: 'Cash');
  final _payableAmountController = TextEditingController();
  final _receivedAmountController = TextEditingController();
  final _profitController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _arrivalDate;
  DateTime? _departureDate;

  @override
  void initState() {
    super.initState();
    _payableAmountController.addListener(_calculateProfit);
    _receivedAmountController.addListener(_calculateProfit);
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    _clientNameController.dispose();
    _propertyNameController.dispose();
    _numberOfRoomsController.dispose();
    _numberOfAdultsController.dispose();
    _numberOfChildrenController.dispose();
    _nightsStayedController.dispose();
    _careNameController.dispose();
    _careContactController.dispose();
    _careEmailController.dispose();
    _paymentMethodController.dispose();
    _payableAmountController.dispose();
    _receivedAmountController.dispose();
    _profitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final double payable = double.tryParse(_payableAmountController.text) ?? 0.0;
    final double received = double.tryParse(_receivedAmountController.text) ?? 0.0;
    // Profit = Received - Payable to vendor
    final double profit = received - payable;
    _profitController.text = profit.toStringAsFixed(0);
  }

  void _calculateNights() {
    if (_arrivalDate != null && _departureDate != null) {
      final difference = _departureDate!.difference(_arrivalDate!).inDays;
      if (difference > 0) {
        _nightsStayedController.text = difference.toString();
      } else {
        _nightsStayedController.text = '0';
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isArrival) async {
    final DateTime initial = (isArrival ? _arrivalDate : _departureDate) ?? DateTime.now();
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
        if (isArrival) {
          _arrivalDate = picked;
        } else {
          _departureDate = picked;
        }
        _calculateNights();
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'dd/mm/yyyy';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_arrivalDate == null || _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Arrival and Departure Dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authControllerProvider).value;

      await FirebaseFirestore.instance.collection('HotelBookings').add({
        'bookingId': _bookingIdController.text,
        'clientName': _clientNameController.text,
        'property': _propertyNameController.text,
        'numberOfRooms': _numberOfRoomsController.text,
        'numberOfAdults': _numberOfAdultsController.text,
        'numberOfChildren': _numberOfChildrenController.text,
        'arrivalDate': _arrivalDate!.toIso8601String(),
        'departureDate': _departureDate!.toIso8601String(),
        'nights': _nightsStayedController.text,
        'careName': _careNameController.text,
        'careContact': _careContactController.text,
        'careEmail': _careEmailController.text,
        'paymentMethod': _paymentMethodController.text,
        'payable': double.tryParse(_payableAmountController.text) ?? 0.0,
        'received': double.tryParse(_receivedAmountController.text) ?? 0.0,
        'profit': double.tryParse(_profitController.text) ?? 0.0,
        'notes': _notesController.text,
        'createdByUid': currentUser?.uid ?? '',
        'userEmail': currentUser?.email ?? 'Unassigned',
        'status': 'Approved',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hotel Booking added successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        // Clear Form
        _formKey.currentState!.reset();
        _bookingIdController.clear();
        _clientNameController.clear();
        _propertyNameController.clear();
        _careNameController.clear();
        _careContactController.clear();
        _careEmailController.clear();
        _payableAmountController.clear();
        _receivedAmountController.clear();
        _profitController.clear();
        _notesController.clear();
        setState(() {
          _arrivalDate = null;
          _departureDate = null;
          _numberOfRoomsController.text = '1';
          _numberOfAdultsController.text = '1';
          _numberOfChildrenController.text = '0';
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
    final primaryTextColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight;
    final formBg = isDarkMode ? const Color(0xFF0B0F19).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.95);
    final inputBg = isDarkMode ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.grey[100]!;
    final isMobile = MediaQuery.of(context).size.width < 750;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        title: Text(
          'Hotel Bookings',
          style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
        elevation: 1,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF070B13) : Colors.grey[50],
      body: AnimatedWorldMapBackground(
        watermarkText: 'HOTEL BOOKINGS',
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
                  // Header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Hotel Bookings 🏨',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add and manage your hotel booking records.',
                        style: TextStyle(fontSize: 12, color: secondaryTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: formBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1F000000),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Hotel Booking',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Form Fields
                        if (isMobile) ...[
                          _buildTextField('Booking ID', _bookingIdController, Icons.qr_code, 'Booking ID', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Client Name', _clientNameController, Icons.person, 'Client Name', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Property Name', _propertyNameController, Icons.domain, 'Property Name', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Number of Rooms', _numberOfRoomsController, Icons.bed, 'Number of Rooms', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Number of Adults', _numberOfAdultsController, Icons.people, 'Number of Adults', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Number of Children', _numberOfChildrenController, Icons.child_care, 'Number of Children', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildDateField('Arrival Date', _arrivalDate, () => _selectDate(context, true), inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildDateField('Departure Date', _departureDate, () => _selectDate(context, false), inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Nights Stayed', _nightsStayedController, Icons.edit, 'Nights Stayed', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Care Name', _careNameController, Icons.person_outline, 'Care Name', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('Care Contact', _careContactController, Icons.phone, 'Care Contact', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Care Email', _careEmailController, Icons.email, 'Care Email', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('Payment Method', _paymentMethodController, Icons.payment, 'Payment Method', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Payable Amount', _payableAmountController, Icons.attach_money, 'Payable Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Received Amount', _receivedAmountController, Icons.account_balance_wallet, 'Received Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Profit', _profitController, Icons.attach_money, 'Profit', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true, isEnabled: false),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Booking ID', _bookingIdController, Icons.qr_code, 'Booking ID', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Client Name', _clientNameController, Icons.person, 'Client Name', inputBg, secondaryTextColor, primaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Property Name', _propertyNameController, Icons.domain, 'Property Name', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Number of Rooms', _numberOfRoomsController, Icons.bed, 'Number of Rooms', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Number of Adults', _numberOfAdultsController, Icons.people, 'Number of Adults', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Number of Children', _numberOfChildrenController, Icons.child_care, 'Number of Children', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildDateField('Arrival Date', _arrivalDate, () => _selectDate(context, true), inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDateField('Departure Date', _departureDate, () => _selectDate(context, false), inputBg, secondaryTextColor, primaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Nights Stayed', _nightsStayedController, Icons.edit, 'Nights Stayed', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Care Name', _careNameController, Icons.person_outline, 'Care Name', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Care Contact', _careContactController, Icons.phone, 'Care Contact', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Care Email', _careEmailController, Icons.email, 'Care Email', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Payment Method', _paymentMethodController, Icons.payment, 'Payment Method', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Payable Amount', _payableAmountController, Icons.attach_money, 'Payable Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Received Amount', _receivedAmountController, Icons.account_balance_wallet, 'Received Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Profit', _profitController, Icons.attach_money, 'Profit', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true, isEnabled: false)),
                            ],
                          ),
                        ],

                        const SizedBox(height: 16),
                        // Notes Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes / Additional Details',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondaryTextColor),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _notesController,
                              style: TextStyle(fontSize: 12, color: primaryTextColor),
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: 'Add any additional notes here...',
                                hintStyle: TextStyle(fontSize: 12, color: secondaryTextColor.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: inputBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: secondaryTextColor.withValues(alpha: 0.2)),
                                ),
                              ),
                            ),
                          ],
                        ),

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
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

                  const SizedBox(height: 16),

                  // View All Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HotelsPage()),
                        );
                      },
                      icon: const Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
                      label: const Text(
                        'View All Hotel Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondary),
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
            hintStyle: TextStyle(fontSize: 12, color: secondary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: isEnabled ? inputBg : inputBg.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secondary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: TextEditingController(text: _formatDate(value)),
              style: TextStyle(fontSize: 12, color: primary),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.calendar_today_outlined, size: 16, color: secondary),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: secondary.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
