import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class EmployeeLeaderboardPage extends StatelessWidget {
  const EmployeeLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDarkMode
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    // Mock data for leaderboard
    final employees = [
      {
        'rank': '1',
        'name': 'Zainab',
        'bookings': '1,245',
        'profit': '12.4M PKR',
        'initials': 'Z',
        'color': Colors.indigo,
      },
      {
        'rank': '2',
        'name': 'Hamza',
        'bookings': '984',
        'profit': '8.2M PKR',
        'initials': 'H',
        'color': Colors.green,
      },
      {
        'rank': '3',
        'name': 'Bilal',
        'bookings': '823',
        'profit': '5.1M PKR',
        'initials': 'B',
        'color': Colors.amber,
      },
      {
        'rank': '4',
        'name': 'Sara',
        'bookings': '720',
        'profit': '4.3M PKR',
        'initials': 'S',
        'color': Colors.pink,
      },
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final emp = employees[index];
          final rank = emp['rank'] as String;

          Color rankBadgeColor;
          if (rank == '1') {
            rankBadgeColor = Colors.amber; // Gold
          } else if (rank == '2') {
            rankBadgeColor = Colors.grey[400]!; // Silver
          } else if (rank == '3') {
            rankBadgeColor = Colors.brown[300]!; // Bronze
          } else {
            rankBadgeColor = Colors.transparent;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
              side: BorderSide(
                color: isDarkMode
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rank number / Medal
                  SizedBox(
                    width: 24,
                    child: rank == '1' || rank == '2' || rank == '3'
                        ? Icon(
                            Icons.emoji_events,
                            color: rankBadgeColor,
                            size: 20,
                          )
                        : Text(
                            rank,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: secondaryTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(width: 8),

                  // Initials Avatar
                  CircleAvatar(
                    backgroundColor: emp['color'] as Color,
                    radius: 20,
                    child: Text(
                      emp['initials'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                emp['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryTextColor,
                ),
              ),
              subtitle: Text(
                '${emp['bookings']} Bookings completed',
                style: TextStyle(fontSize: 12, color: secondaryTextColor),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    emp['profit'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.success,
                    ),
                  ),
                  const Text(
                    'Net Profit',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
