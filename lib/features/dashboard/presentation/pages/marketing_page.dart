import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/marketing_provider.dart';

class MarketingPage extends ConsumerStatefulWidget {
  const MarketingPage({super.key});

  @override
  ConsumerState<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends ConsumerState<MarketingPage> {
  // Navigation State
  MarketingCountryStats? _selectedCountry;

  // Search State
  String _searchQuery = '';
  late final TextEditingController _searchController;

  // Email Pane State
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController(
    text: 'Dear {{name}},\n\n',
  );
  String _attachedFileName = 'No file chosen';
  bool _showAll = false;
  final TextEditingController _rangeFromController = TextEditingController(
    text: '1',
  );
  final TextEditingController _rangeToController = TextEditingController(
    text: '10',
  );

  // Selected customer IDs inside the Send Email pane
  final Set<String> _selectedCustomerIds = {};

  final Map<String, String> _flags = {
    'Malaysia': '🇲🇾',
    'Thailand': '🇹🇭',
    'Indonesia': '🇮🇩',
    'Singapore': '🇸🇬',
    'Japan': '🇯🇵',
    'Nepal': '🇳🇵',
    'Azerbaijan': '🇦🇿',
    'United States': '🇺🇸',
    'Uzbekistan': '🇺🇿',
    'Bahrain': '🇧🇭',
    'Spain': '🇪🇸',
    'Sri Lanka': '🇱🇰',
    'United Kingdom': '🇬🇧',
    'Netherlands': '🇳🇱',
    'France': '🇫🇷',
    'Turkey': '🇹🇷',
    'Hungary': '🇭🇺',
    'Sweden': '🇸🇪',
    'Greece': '🇬🇷',
    'Italy': '🇮🇹',
    'Belgium': '🇧🇪',
    'Pakistan': '🇵🇰',
    'United Arab Emirates': '🇦🇪',
    'Tajikistan': '🇹🇯',
    'Egypt': '🇪🇬',
    'Norway': '🇳🇴',
    'Qatar': '🇶🇦',
    'Poland': '🇵🇱',
    'South Korea': '🇰🇷',
    'South Africa': '🇿🇦',
    'Austria': '🇦🇹',
    'Morocco': '🇲🇦',
    'Switzerland': '🇨🇭',
    'Vietnam': '🇻🇳',
    'Germany': '🇩🇪',
    'Canada': '🇨🇦',
    'Kazakhstan': '🇰🇿',
    'China': '🇨🇳',
    'Uganda': '🇺🇬',
    'Kyrgyzstan': '🇰🇬',
    'Philippines': '🇵🇭',
    'Zimbabwe': '🇿🇼',
    'Denmark': '🇩🇰',
    'Hong Kong': '🇭🇰',
    'Finland': '🇫🇮',
    'Zambia': '🇿🇲',
    'Ireland': '🇮🇪',
    'Luxembourg': '🇱🇺',
    'Costa Rica': '🇨🇷',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _rangeFromController.dispose();
    _rangeToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(marketingProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? Colors.white
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final cardBg = isDarkMode
        ? const Color(0x770B0F19)
        : Colors.white.withValues(alpha: 0.90);
    final borderColor = isDarkMode
        ? const Color(0x18FFFFFF)
        : const Color(0x1F000000);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        child: SafeArea(
          child: _selectedCountry == null
              ? _buildCountryListPane(
                  list,
                  primaryTextColor,
                  secondaryTextColor,
                  cardBg,
                  borderColor,
                  isDarkMode,
                )
              : _buildSendEmailPane(
                  primaryTextColor,
                  secondaryTextColor,
                  cardBg,
                  borderColor,
                  isDarkMode,
                ),
        ),
      ),
    );
  }

  // ── PANE 1: Customers by Country List ──
  Widget _buildCountryListPane(
    List<MarketingCountryStats> list,
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
    bool isDarkMode,
  ) {
    // Filter country list by search query
    final filteredCountries = list.where((c) {
      return c.countryName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final isMobile = MediaQuery.of(context).size.width < 650;

    final Widget headerTitleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customers by Country',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          'View customer groups by country and launch email campaigns',
          style: TextStyle(fontSize: 11, color: secondaryColor),
        ),
      ],
    );

    final Widget searchBox = Container(
      width: isMobile ? double.infinity : 180,
      height: 34,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(Icons.search, size: 14, color: secondaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: _searchController,
              style: TextStyle(fontSize: 11, color: primaryColor),
              decoration: InputDecoration(
                hintText: 'Search countries...',
                hintStyle: TextStyle(fontSize: 11, color: secondaryColor),
                border: InputBorder.none,
                filled: false,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                });
              },
            ),
          ),
        ],
      ),
    );

    final int crossAxisCount = isMobile
        ? 2
        : (MediaQuery.of(context).size.width >= 900 ? 4 : 3);
    final double childAspectRatio = isMobile ? 1.8 : 2.2;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerTitleColumn,
                    const SizedBox(height: 10),
                    searchBox,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: headerTitleColumn),
                    const SizedBox(width: 16),
                    searchBox,
                  ],
                ),
        ),

        // Grid of Country Cards (Two Columns responsive)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: filteredCountries.length,
            itemBuilder: (context, idx) {
              final c = filteredCountries[idx];
              final flag = _flags[c.countryName] ?? '🏳️';
              return _buildCountryCard(
                c,
                flag,
                cardBg,
                borderColor,
                primaryColor,
                secondaryColor,
                isDarkMode,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCard(
    MarketingCountryStats c,
    String flag,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
    Color secondaryColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c.countryName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCountry = c;
                    _selectedCustomerIds.clear();
                    _subjectController.clear();
                    _bodyController.text = 'Dear {{name}},\n\n';
                    _attachedFileName = 'No file chosen';
                    _showAll = false;
                    _rangeFromController.text = '1';
                    _rangeToController.text = '10';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.mail_outline, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${c.customerCount} customers',
                style: TextStyle(
                  fontSize: 10,
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => _showCountryCustomersPreview(c, flag, isDarkMode),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Show Preview Accordion/Modal ──
  void _showCountryCustomersPreview(
    MarketingCountryStats c,
    String flag,
    bool isDarkMode,
  ) {
    final primaryColor = isDarkMode ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : AppColors.textSecondaryLight;
    final modalBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0x18FFFFFF)
        : const Color(0x1F000000);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: modalBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${c.countryName} Customers Preview',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: c.customers.length.clamp(0, 4),
              itemBuilder: (context, index) {
                final cust = c.customers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0x33FFFFFF)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cust.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              cust.email,
                              style: TextStyle(
                                fontSize: 9,
                                color: secondaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cust.phone,
                            style: TextStyle(
                              fontSize: 9,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _selectedCountry = c;
                  _selectedCustomerIds.clear();
                  _subjectController.clear();
                  _bodyController.text = 'Dear {{name}},\n\n';
                  _attachedFileName = 'No file chosen';
                  _showAll = false;
                  _rangeFromController.text = '1';
                  _rangeToController.text = '10';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text(
                'Send Emails',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── PANE 2: Send Email Pane ──
  Widget _buildSendEmailPane(
    Color primaryColor,
    Color secondaryColor,
    Color cardBg,
    Color borderColor,
    bool isDarkMode,
  ) {
    final c = _selectedCountry!;

    // Range Calculation
    int from = int.tryParse(_rangeFromController.text) ?? 1;
    int to = int.tryParse(_rangeToController.text) ?? 10;

    // Bounds clamping
    if (from < 1) from = 1;
    if (to > c.customers.length) to = c.customers.length;
    if (from > to) from = to;

    final displayedCustomers = _showAll
        ? c.customers
        : c.customers.sublist(from - 1, to);

    // Check if all displayed are selected
    final bool allSelected =
        displayedCustomers.isNotEmpty &&
        displayedCustomers.every(
          (cust) => _selectedCustomerIds.contains(cust.id),
        );

    final isMobile = MediaQuery.of(context).size.width < 650;
    final Widget backButton = OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedCountry = null;
        });
      },
      icon: const Icon(Icons.arrow_back, size: 14, color: Colors.blueAccent),
      label: const Text(
        'Back',
        style: TextStyle(fontSize: 12, color: Colors.blueAccent),
      ),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );

    final Widget headingText = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: primaryColor.withValues(alpha: 0.7),
        ),
        children: [
          const TextSpan(text: 'Send Email to Customers in '),
          TextSpan(
            text: c.countryName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );

    final List<Widget> rangeInputs = [
      const Text(
        'From:',
        style: TextStyle(fontSize: 11, color: Colors.white70),
      ),
      const SizedBox(width: 4),
      SizedBox(
        width: 50,
        height: 30,
        child: TextField(
          controller: _rangeFromController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 11, color: primaryColor),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onChanged: (v) {
            setState(() {});
          },
        ),
      ),
      const SizedBox(width: 8),
      const Text('To:', style: TextStyle(fontSize: 11, color: Colors.white70)),
      const SizedBox(width: 4),
      SizedBox(
        width: 50,
        height: 30,
        child: TextField(
          controller: _rangeToController,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 11, color: primaryColor),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onChanged: (v) {
            setState(() {});
          },
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: [
        // Back Button & Heading
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [backButton, const SizedBox(height: 10), headingText],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [backButton, headingText],
              ),
        const SizedBox(height: 14),

        // Composition Fields Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject Input
              const Text(
                'Subject',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _subjectController,
                style: TextStyle(fontSize: 12, color: primaryColor),
                decoration: InputDecoration(
                  hintText: 'Subject',
                  hintStyle: TextStyle(fontSize: 12, color: secondaryColor),
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Body Input
              const Text(
                'Body (use {{name}} to personalize)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _bodyController,
                style: TextStyle(fontSize: 12, color: primaryColor),
                maxLines: 6,
                minLines: 4,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Attach File Row
              const Text(
                'Attach File (Image/PDF)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _attachedFileName = 'promo_details.pdf';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Choose File',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _attachedFileName,
                      style: TextStyle(fontSize: 11, color: secondaryColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _sendEmails(displayedCustomers),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Send Emails',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _subjectController.clear();
                        _bodyController.text = 'Dear {{name}},\n\n';
                        _attachedFileName = 'No file chosen';
                        _selectedCustomerIds.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF475569),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Range selector / Display Filter Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _showAll,
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _showAll = v;
                              });
                            }
                          },
                        ),
                        const Text(
                          'Show All',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        const Spacer(),
                        Text(
                          '(Displaying $from - $to of ${c.customerCount})',
                          style: TextStyle(fontSize: 11, color: secondaryColor),
                        ),
                      ],
                    ),
                    if (!_showAll) ...[
                      const SizedBox(height: 8),
                      Row(children: rangeInputs),
                    ],
                  ],
                )
              : Row(
                  children: [
                    Checkbox(
                      value: _showAll,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _showAll = v;
                          });
                        }
                      },
                    ),
                    const Text(
                      'Show All',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                    const Spacer(),
                    if (!_showAll) ...[
                      ...rangeInputs,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '(Displaying $from - $to of ${c.customerCount})',
                      style: TextStyle(fontSize: 11, color: secondaryColor),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 14),

        // Customer Selection Table Card
        LayoutBuilder(
          builder: (context, constraints) {
            final double tableWidth = constraints.maxWidth < 500
                ? 550
                : constraints.maxWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  columnWidths: const {
                    0: FixedColumnWidth(40), // Checkbox
                    1: FixedColumnWidth(30), // Index
                    2: FlexColumnWidth(3), // Name
                    3: FlexColumnWidth(4), // Email
                    4: FlexColumnWidth(2), // Phone
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: borderColor,
                      width: 0.3,
                    ),
                    bottom: BorderSide(color: borderColor, width: 0.5),
                  ),
                  children: [
                    // Table Header Row
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0x11FFFFFF)
                            : Colors.grey.withValues(alpha: 0.05),
                      ),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Checkbox(
                            value: allSelected,
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  if (v) {
                                    for (var cust in displayedCustomers) {
                                      _selectedCustomerIds.add(cust.id);
                                    }
                                  } else {
                                    for (var cust in displayedCustomers) {
                                      _selectedCustomerIds.remove(cust.id);
                                    }
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Table Body rows
                    ...displayedCustomers.asMap().entries.map((entry) {
                      final idx = (_showAll ? 0 : from - 1) + entry.key + 1;
                      final cust = entry.value;
                      final isChecked = _selectedCustomerIds.contains(cust.id);
                      return TableRow(
                        children: [
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Checkbox(
                              value: isChecked,
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    if (v) {
                                      _selectedCustomerIds.add(cust.id);
                                    } else {
                                      _selectedCustomerIds.remove(cust.id);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                '$idx',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                cust.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                cust.email,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                cust.phone,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: secondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Send Email Execution (Mock) ──
  void _sendEmails(List<MarketingCustomerModel> displayedList) {
    if (_selectedCustomerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one customer to send emails to.',
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email subject.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Success SnackBar showing exact number of selected emails
    final count = _selectedCustomerIds.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emails successfully sent to $count selected customers!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    // Reset email compose pane
    setState(() {
      _subjectController.clear();
      _bodyController.text = 'Dear {{name}},\n\n';
      _attachedFileName = 'No file chosen';
      _selectedCustomerIds.clear();
      _selectedCountry = null; // Go back to list
    });
  }
}
