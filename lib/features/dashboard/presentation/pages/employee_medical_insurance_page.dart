import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'insurance_page.dart';

class EmployeeMedicalInsurancePage extends ConsumerStatefulWidget {
  const EmployeeMedicalInsurancePage({super.key});

  @override
  ConsumerState<EmployeeMedicalInsurancePage> createState() =>
      _EmployeeMedicalInsurancePageState();
}

class _EmployeeMedicalInsurancePageState
    extends ConsumerState<EmployeeMedicalInsurancePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _companyNameController = TextEditingController();
  final _insuredNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passportNoController = TextEditingController();
  final _nicController = TextEditingController();
  final _countryController = TextEditingController();
  final _contactController = TextEditingController();
  final _daysController = TextEditingController();
  final _issuedAtController = TextEditingController();
  final _receivedAmountController = TextEditingController();
  final _payableAmountController = TextEditingController();
  final _profitController = TextEditingController();

  DateTime? _effectiveDate;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _receivedAmountController.addListener(_calculateProfit);
    _payableAmountController.addListener(_calculateProfit);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _insuredNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passportNoController.dispose();
    _nicController.dispose();
    _countryController.dispose();
    _contactController.dispose();
    _daysController.dispose();
    _issuedAtController.dispose();
    _receivedAmountController.dispose();
    _payableAmountController.dispose();
    _profitController.dispose();
    super.dispose();
  }

  void _calculateProfit() {
    final double received = double.tryParse(_receivedAmountController.text) ?? 0.0;
    final double payable = double.tryParse(_payableAmountController.text) ?? 0.0;
    final double profit = received - payable;
    _profitController.text = profit.toStringAsFixed(0);
  }

  void _calculateDays() {
    if (_effectiveDate != null && _expiryDate != null) {
      final difference = _expiryDate!.difference(_effectiveDate!).inDays;
      if (difference > 0) {
        _daysController.text = difference.toString();
      } else {
        _daysController.text = '0';
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isEffective) async {
    final DateTime initial = (isEffective ? _effectiveDate : _expiryDate) ?? DateTime.now();
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
        if (isEffective) {
          _effectiveDate = picked;
        } else {
          _expiryDate = picked;
        }
        _calculateDays();
      });
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'dd/mm/yyyy';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Effective and Expiry Dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(authControllerProvider).value;

      await FirebaseFirestore.instance.collection('medical_insurance').add({
        'NameofCompany': _companyNameController.text,
        'NameofInsured': _insuredNameController.text,
        'email': _emailController.text,
        'age': _ageController.text,
        'passportNumber': _passportNoController.text,
        'nic': _nicController.text,
        'countryofTravel': _countryController.text,
        'contactNumber': _contactController.text,
        'numberOfDays': _daysController.text,
        'effectiveDate': _effectiveDate!.toIso8601String(),
        'expiryDate': _expiryDate!.toIso8601String(),
        'issuedAt': _issuedAtController.text,
        'totalReceivedAmount': double.tryParse(_receivedAmountController.text) ?? 0.0,
        'totalPayableAmount': double.tryParse(_payableAmountController.text) ?? 0.0,
        'totalProfit': double.tryParse(_profitController.text) ?? 0.0,
        'createdByUid': currentUser?.uid ?? '',
        'userEmail': currentUser?.email ?? 'Unassigned',
        'status': 'Approved',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medical Insurance booking added successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _formKey.currentState!.reset();
        _companyNameController.clear();
        _insuredNameController.clear();
        _emailController.clear();
        _ageController.clear();
        _passportNoController.clear();
        _nicController.clear();
        _countryController.clear();
        _contactController.clear();
        _daysController.clear();
        _issuedAtController.clear();
        _receivedAmountController.clear();
        _payableAmountController.clear();
        _profitController.clear();
        setState(() {
          _effectiveDate = null;
          _expiryDate = null;
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
          'Medical Insurance',
          style: TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
        elevation: 1,
      ),
      backgroundColor: isDarkMode ? const Color(0xFF070B13) : Colors.grey[50],
      body: AnimatedWorldMapBackground(
        watermarkText: 'MEDICAL INSURANCE',
        child: SafeArea(
          child: SingleChildScrollView(
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
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B4D8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.business, color: Color(0xFF00B4D8), size: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Medical Insurance Form',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // View All Button (top as shown in mockups)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InsurancePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D3557),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View All Medical Bookings',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
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
                        // Form Fields
                        if (isMobile) ...[
                          _buildTextField('Company Name *', _companyNameController, Icons.business, 'Enter Company Name', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Insured\'s Name *', _insuredNameController, Icons.person, 'Enter Name of Insured', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Client Email', _emailController, Icons.email, 'Enter Email Address', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('Age *', _ageController, Icons.badge, 'Enter Age', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Passport Number', _passportNoController, Icons.card_membership, 'Enter Passport Number', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('NIC', _nicController, Icons.credit_card, 'Enter NIC', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('Country of Travel *', _countryController, Icons.public, 'Enter Country of Travel', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Contact Number *', _contactController, Icons.phone, 'Enter Contact Number', inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Number of Days *', _daysController, Icons.calendar_today, 'Enter No of days', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildDateField('Effective Date *', _effectiveDate, () => _selectDate(context, true), inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildDateField('Expiry Date *', _expiryDate, () => _selectDate(context, false), inputBg, secondaryTextColor, primaryTextColor),
                          const SizedBox(height: 12),
                          _buildTextField('Issued At', _issuedAtController, Icons.public, 'e.g., Lahore', inputBg, secondaryTextColor, primaryTextColor, isRequired: false),
                          const SizedBox(height: 12),
                          _buildTextField('Total Received Amount *', _receivedAmountController, Icons.attach_money, 'Enter Received Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Total Payable Amount *', _payableAmountController, Icons.attach_money, 'Enter Payable Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true),
                          const SizedBox(height: 12),
                          _buildTextField('Total Profit', _profitController, Icons.attach_money, 'Auto Calculated', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true, isEnabled: false),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Company Name *', _companyNameController, Icons.business, 'Enter Company Name', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Insured\'s Name *', _insuredNameController, Icons.person, 'Enter Name of Insured', inputBg, secondaryTextColor, primaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Client Email', _emailController, Icons.email, 'Enter Email Address', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Age *', _ageController, Icons.badge, 'Enter Age', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Passport Number', _passportNoController, Icons.card_membership, 'Enter Passport Number', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('NIC', _nicController, Icons.credit_card, 'Enter NIC', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Country of Travel *', _countryController, Icons.public, 'Enter Country of Travel', inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Contact Number *', _contactController, Icons.phone, 'Enter Contact Number', inputBg, secondaryTextColor, primaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Number of Days *', _daysController, Icons.calendar_today, 'Enter No of days', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDateField('Effective Date *', _effectiveDate, () => _selectDate(context, true), inputBg, secondaryTextColor, primaryTextColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildDateField('Expiry Date *', _expiryDate, () => _selectDate(context, false), inputBg, secondaryTextColor, primaryTextColor)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Issued At', _issuedAtController, Icons.public, 'e.g., Lahore', inputBg, secondaryTextColor, primaryTextColor, isRequired: false)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Total Received Amount *', _receivedAmountController, Icons.attach_money, 'Enter Received Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('Total Payable Amount *', _payableAmountController, Icons.attach_money, 'Enter Payable Amount', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField('Total Profit', _profitController, Icons.attach_money, 'Auto Calculated', inputBg, secondaryTextColor, primaryTextColor, isNumeric: true, isEnabled: false),
                        ],

                        const SizedBox(height: 24),

                        // Save Record Button
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
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
                                    'Save Record',
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
                ],
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
