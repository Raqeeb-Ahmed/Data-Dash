# Task: Explore Ostravel Portal Admin Home for Flutter Conversion

## Plan:
- [x] Navigate to https://ostravel-portal-orignal.vercel.app/adminhome
- [x] Observe if it redirects to login or loads dashboard
  - Redirected to https://ostravel-portal-orignal.vercel.app/login
  - Logged in successfully with `admin@gmail.com` / `admin123`
- [x] Inspect elements, navigation, tables, fields
  - [x] Home Page (`/adminhome`) analyzed
- [x] Visit Analytics (`/view-analytics`)
  - [x] Visit Dashboard (`/admin-dashboard`)
  - [x] Visit Tickets (`/AdminTicketBookings`)
  - [x] Visit Umrah (`/umrahbookings`)
  - [x] Visit Hotels (`/adminHotelDet`)
  - [x] Visit Insurance (`/medicalInsurancedet`)
  - [x] Visit Marketing (`/customer-country`)
  - [x] Visit Employee Record (`/employee-record`)
  - [x] Visit Detailed Search (`/detailed-search`)
- [x] Take screenshots of main screens
- [x] Create detailed report of fields, tabs, tables, charts for Flutter conversion

## Findings:
### Home Page (`/adminhome`):
- Navigation bar items:
  1. Home (`/adminhome`)
  2. Analytics (`/view-analytics`)
  3. Dashboard (`/admin-dashboard`)
  4. Tickets (`/AdminTicketBookings`)
  5. Umrah (`/umrahbookings`)
  6. Hotels (`/adminHotelDet`)
  7. Insurance (`/medicalInsurancedet`)
  8. Marketing (`/customer-country`)
  9. Logout button
- Header: "Data Dash" / "Welcome back. Here's a real-time overview..."
- Overview cards:
  - **Total Bookings**: Shows total counts, links to `/admin-dashboard`.
  - **Total Handlers**: Shows active agents count, links to `/employee-record`.
  - **Global Reach**: Shows activations count.
  - **Universal Search**: Input box "Find Anything", links to `/detailed-search`.
- Section: **Active Destinations** with "View All" link.

### Analytics Page (`/view-analytics`):
- Header: "View Analytics" / "Live charts across all services"
- Filter by Time Range buttons: "7 Days", "30 Days", "90 Days", "YTD", "All"
- Date Range filter: "From" (date input) and "To" (date input)
- Stat cards:
  - **Total Records**: 3,772
  - **Total Received**: PKR 86,423,860
  - **Net Profit**: PKR 25,879,392
  - **Pending Amount**: PKR 3,259,395
- Charts:
  - **All Services Breakdown**: Pie/Donut chart showing Visas, Hotels, Umrah, Tickets, Insurance.
  - **Visa Status**: Pie/Donut chart showing Approved, Processing, Rejected.
  - **Monthly Bookings by Service**: Bar/Line chart showing service performance over last 12 months.

### Dashboard Page (`/admin-dashboard`):
- Header Date filter: "From" and "To" date range selectors (top right)
- Stat cards:
  - **Total Bookings**: 2,928 (Approved: 2632, Processing: 125, Rejected: 171)
  - **All Services**: 3,772 (Visas: 2928, Hotels: 51, Umrah: 33, Tickets: 760)
  - **Total Receivable**: PKR 89,683,255 (Received: PKR 86,423,860, Pending: PKR 3,259,395)
  - **Net Profit**: PKR 25,879,392 (Margin: 28.9%, Status: Healthy, Paid: 2707, Unpaid: 195, Employees: 4, Pending: PKR 3,259,395)
- Expandable Section:
  - **Services Overview Chart**: "Click to expand detailed breakdown"
- Interactive Controls:
  - Search Input: "Search all services by name, destination, employee..."
  - From & To date range inputs (`id='startDate'`, `id='endDate'`)
  - Dropdown Filters (3 selects): Likely filtering by Service Type, Payment Status, or Employee.
  - Reset button
  - Action buttons: "PDF Report" and "Export CSV"
  - Navigation buttons: "Refresh"
- Records Table:
  - Columns: `#`, `Service`, `Customer`, `Destination / Detail`, `Financial`, `Status`, `Employee`, `Actions`
  - Rows display:
    - Service name (e.g. Visa)
    - Customer name, passport/details, destination country, category (e.g. Norway, Family Visit)
    - Date of record (e.g. 2026-07-13)
    - Financial breakdown: Total Price, Received (`Rcvd`), Remaining (`Rem`)
    - Service status (e.g. Approved, Processing, Rejected)
    - Payment status (e.g. Paid, Unpaid)
    - Employee handler name
  - Action column: "View Details" (blue), "Edit" (green), "Delete" (red) buttons
- Pagination:
  - Shows page selector (e.g. "Page 1 of 378")
  - Numbered page buttons (1, 2, 3, 4, 5) and "Next"/"Previous" buttons

### Tickets Page (`/AdminTicketBookings`):
- Header controls:
  - Dropdown filter (by employee or date range preset)
  - Export buttons: "CSV" and "PDF"
- Date filter: "From" and "To" date fields
- Stat cards:
  - **Bookings**: 760
  - **Earnings**: 112,967,142.00
  - **Payable**: 107,745,142.33
  - **Profit**: 5,122,773.67
- Charts:
  - **Monthly Financials**: Earnings vs Profit chart
  - **Top 10 Destinations** chart
- Interactive Controls:
  - Search input: "Search by PNR, passenger, employee, route..."
- Employee Leaderboard:
  - Sort by selector, Toggle direction button
  - Columns: `Employee`, `Bookings`, `Earnings`, `Payable`, `Profit`, `Spark` (metric graph)
- Bookings Table:
  - Columns: `#`, `PNR`, `Passenger`, `Employee`, `Route`, `Price`, `Payable`, `Profit`, `Status`, `Date`, `Actions`
  - Row details include: PNR string, passenger name, handling employee, route details (e.g. ISB FCO → MCP ISB), financial details (Price, Payable, Profit), ticket status (e.g. Booked), and Date of booking
  - Action column: "View Details" (cyan), "Edit Booking" (blue), "Delete Booking" (red)
  - Pagination controls: "Rows per page" selector, "Showing X-Y of Z", "Page X of Y", "Next page" and "Last page" buttons

### Umrah Page (`/umrahbookings`):
- Header controls:
  - Time range selector dropdown
  - Custom Range date fields ("From" & "To")
- Stat cards:
  - **Total Received**: PKR 4,811,144
  - **Total Payable**: PKR 4,259,082
  - **Profit**: PKR 552,062
  - **Bookings**: 33
- Charts:
  - **Monthly Financials**: Payable, Profit, Received chart
  - **Top Vendors** chart
- Interactive Controls:
  - Search Input: "Search by name, passport, phone..."
  - Filter Dropdowns (2 selects)
- Bookings Table:
  - Columns: `#`, `Name`, `Phone`, `Passport`, `Vendor`, `Employee`, `Payable`, `Received`, `Profit`, `Actions`
  - Row details include: customer name, phone number, passport number, vendor name (e.g. MEEZAB AIR (CST), PAK HARMAIN TRAVELS), handling employee, financial metrics (Payable, Received, Profit)
  - Action column: "View Details" (gray), "Edit Booking" (blue), "Delete Booking" (red)
  - Pagination: "Previous" button, "Page X of Y" text indicator, "Next" button

### Hotels Page (`/adminHotelDet`):
- Header controls:
  - Search input box with search button
  - Time range filter buttons: "All", "Today", "Yesterday", "This Week", "This Month"
  - Custom Range date fields ("From" & "To")
- Stat cards:
  - **Total Received**: PKR 1842707.00
  - **Total Payable**: PKR 1226356.28
  - **Total Profit**: PKR 616349.80
- Charts:
  - **Monthly Financials**: Payable, Profit, Received chart
  - **Top Properties** chart
- Bookings Table:
  - Columns: `S. No.`, `Booking Details`, `Client`, `Financials`, `Employee`, `Actions`
  - Row details include: Hotel name, booking ID, arrival date, departure date, total nights, total rooms, client name, financials breakdown (Received, Payable, Profit), handling employee email
  - Action column: "View Details" (white), "Edit" (blue), "Delete" (red)
  - Pagination: None (displays all 51 bookings in a single scrollable list)

### Insurance Page (`/medicalInsurancedet`):
- Header controls:
  - Search input box "Search by name, passport, company..."
  - Custom range date inputs: "Start Date" and "End Date"
  - Time range filter buttons: "All Time", "Today", "This Week", "This Month"
- Quick filter buttons: **Bookings by Company** (Adamjee, CSI, DAMAN HEALTH AE, UIC, etc.)
- Stat cards:
  - **Total Received**: 127020.00
  - **Total Payable**: 88855.00
  - **Total Profit**: 38165.00
- Charts:
  - **Monthly Financials**: Payable, Profit, Received chart
  - **Top Companies** chart
- Bookings Table:
  - Columns: `#`, `Company`, `Insured Name`, `Passport No.`, `Travel Country`, `Rec. Amount`, `Pay. Amount`, `Profit`, `Actions`
  - Row details include: Company name, Insured customer name, passport number, destination country, Received Amount, Payable Amount, Profit
  - Action column (needs horizontal scrolling): "View details" (purple), "Edit booking" (blue), "Print as PDF" (teal), "Delete booking" (red)
  - Pagination: None (displays all 15 bookings inside a horizontally and vertically scrollable div)

### Marketing Page (`/customer-country`):
- Header controls:
  - Search countries input: "Search countries..."
  - Action button: "Export Summary" (blue)
- Grid display of countries:
  - Country name (e.g. Malaysia, Thailand)
  - Total number of customers (e.g. 1321, 646)
  - Action button: "Email" (indigo) with hover details: "Compose email to all [Country]"
  - Action button: Details (white/5 overlay button) which likely loads customer list for that country.
- Pagination: None (displays all countries inside the list layout, with a standard footer below it)

### Employee Record Page (`/employee-record`):
- Header controls:
  - Search input: "Search by employee email..."
  - Filter button: "All employees" (toggles showing only employees with at least one record)
- Overview metric cards:
  - **Handlers**: Total employees count
  - **Bookings (all)**: Total booking count, and breakdown of visas, tickets, and umrah bookings
  - **Active handlers**: Count of employees with at least 1 booking
- Employee Bookings Leaderboard table:
  - Columns: `Rank`, `Employee`, `Bookings`, `Approved`, `Total`, `Received`, `Pending`, `Profit`
  - From & To date range inputs
  - Sort by dropdown selector, and Toggle direction button
- Ticketing Leaderboard table:
  - Columns: `Employee`, `Bookings`, `Earnings`, `Payable`, `Profit`
  - From & To date range inputs
  - Search employee input, Sort by dropdown selector, Toggle direction button
- Grid layout of individual Employee Cards:
  - Displays employee email, total records count, and breakdown counts of Visas, Tickets, and Umrah bookings.
  - Action: "Click to expand" opens a slide-out detail panel:
    - Detail panel title: "Records for [Employee Email]" with Close button (X)
    - Action buttons: "Export CSV" and "Export PDF"
    - Tab options: VISA (Count), TICKET (Count), UMRAH (Count)
    - Selected tab stats: Bookings count, Total Received (Filtered), Total Profit (Filtered)
    - Filters: Search bar, From & To date inputs, View toggle button ("Grouped by date")
    - Interactive records list: Displays client name, routing/destination details, status, financial breakdown, and a "View Details" action button

### Detailed Search Page (`/detailed-search`):
- Header: "Universal Search" / "Instantly query across all your operations. Filter by names, ticket numbers, statuses, and more."
- Search bar input: "Start typing a name, passport, destination..."
- Category filter buttons: "All Records", "Visas", "Tickets", "Umrah", "Insurance"
- Results summary text: "Found [Count] results"
- Results list layout:
  - Displays result row item containing Type tag (e.g. VISA, TICKET, etc.), Customer Name, Passport/Ticket number, Date, Destination/Routing (e.g. ISB FCO ➔ MCP ISB), Status tag, and Financial summary columns (Payable, Received, Profit).
  - Row Action: Detail arrow button (triggers detail modal/view).







