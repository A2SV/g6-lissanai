import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF112D4F);
const Color kCardBackgroundColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF333333);
const Color kLightTextColor = Color(0xFF6B7280);
const Color kGreenAccent = Color(0xFF00C853);

const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kMediumPadding = 12.0;
const double kBorderRadius = 12.0;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int selectedYear = DateTime.now().year;
  final List<int> years = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
  ];

  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  // Dummy activity data: [year][month][day]
  final Map<int, List<List<int>>> activityPerYear = {};

  @override
  void initState() {
    super.initState();
    for (var year in years) {
      activityPerYear[year] = List.generate(
        12,
        (month) => List.generate(
          DateTime(year, month + 1, 0).day, // days in month
          (day) => (day * 3 + month) % 5,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 10),
              _buildStatsRow(),
              const SizedBox(height: kDefaultPadding),
              _buildActivityHeatmapCard(),
              const SizedBox(height: kDefaultPadding),
              _buildQuickStatsSection(),
              const SizedBox(height: kDefaultPadding),
              _buildLearningFocusSection(),
              const SizedBox(height: kDefaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Profile Header =================
  Widget _buildProfileHeader() {
    return SizedBox(
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          Positioned(
            top: 15,
            left: kDefaultPadding,
            right: kDefaultPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: kGreenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: kMediumPadding),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hana Johnson',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'English Language Learner',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: kSmallPadding / 2),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Addis Abeba, AA',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Intermediate Level',
                            style: TextStyle(fontSize: 13, color: Colors.white),
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

  // ================= Stats Row =================
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          '47',
          'Sessions',
          '+12 this month',
          valueColor: kGreenAccent,
        ),
        const SizedBox(width: kSmallPadding),
        _buildStatCard('28', 'Achievements', '3 new'),
        const SizedBox(width: kSmallPadding),
        _buildStatCard(
          '156',
          'Hours Practiced',
          '+8 this week',
          valueColor: kGreenAccent,
        ),
        const SizedBox(width: kSmallPadding),
        _buildStatCard(
          '7',
          'Day Streak',
          '🔥 Active',
          valueColor: const Color(0xFFFFA000),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    String detail, {
    Color valueColor = kTextColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(kMediumPadding),
        decoration: BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.circular(kBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kLightTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(detail, style: TextStyle(fontSize: 11, color: valueColor)),
          ],
        ),
      ),
    );
  }

  // ================= Quick Stats =================
  Widget _buildQuickStatsSection() {
    return _buildSectionCard(
      title: 'Quick Stats',
      icon: Icons.bar_chart_outlined,
      children: [
        _buildStatDetailRow(
          Icons.timer_outlined,
          'Total Study Time',
          '156 hours',
        ),
        _buildStatDetailRow(
          Icons.military_tech_outlined,
          'Current Level',
          'Intermediate',
          isButton: true,
        ),
        _buildStatDetailRow(
          Icons.emoji_events_outlined,
          'Best Streak',
          '12 days',
        ),
        _buildStatDetailRow(Icons.leaderboard_outlined, 'Rank', '#87 globally'),
      ],
    );
  }

  Widget _buildStatDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isButton = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kLightTextColor),
          const SizedBox(width: kSmallPadding),
          Text(label, style: const TextStyle(fontSize: 14, color: kTextColor)),
          const Spacer(),
          isButton
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kSmallPadding,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kPrimaryColor,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kTextColor,
                  ),
                ),
        ],
      ),
    );
  }

  // ================= Learning Focus =================
  Widget _buildLearningFocusSection() {
    return _buildSectionCard(
      title: 'Learning Focus',
      icon: Icons.lightbulb_outline,
      children: [
        _buildFocusRatingRow('Grammar', 4),
        _buildFocusRatingRow('Pronunciation', 4),
      ],
    );
  }

  Widget _buildFocusRatingRow(String skill, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(skill, style: const TextStyle(fontSize: 14, color: kTextColor)),
          const Spacer(),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: const Color(0xFFFFA000),
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }

  // ================= Section Card Helper =================
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      margin: const EdgeInsets.only(bottom: kDefaultPadding),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: kSmallPadding),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: kMediumPadding),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActivityHeatmapCard() {
    final yearData = activityPerYear[selectedYear]!;
    final allDays = <DateTime, int>{};

    // Flatten yearData into [date -> activity level]
    for (int month = 0; month < 12; month++) {
      for (int day = 0; day < yearData[month].length; day++) {
        final date = DateTime(selectedYear, month + 1, day + 1);
        if (date.year == selectedYear) {
          allDays[date] = yearData[month][day];
        }
      }
    }

    final firstDay = DateTime(selectedYear, 1, 1);
    final lastDay = DateTime(selectedYear, 12, 31);

    // Build week-based structure
    final weeks = <List<DateTime?>>[];
    DateTime currentDay = firstDay;
    List<DateTime?> currentWeek = List.filled(7, null);

    while (currentDay.isBefore(lastDay) ||
        currentDay.isAtSameMomentAs(lastDay)) {
      currentWeek[currentDay.weekday % 7] = currentDay;
      if (currentDay.weekday == DateTime.sunday) {
        weeks.add(currentWeek);
        currentWeek = List.filled(7, null);
      }
      currentDay = currentDay.add(const Duration(days: 1));
    }
    if (currentWeek.any((d) => d != null)) {
      weeks.add(currentWeek);
    }

    // Determine which week column should have a month label
    final monthLabels = List<String?>.filled(weeks.length, null);
    for (int i = 0; i < weeks.length; i++) {
      for (var day in weeks[i]) {
        if (day != null && day.day == 1) {
          final name = _monthAbbrev(day.month);
          monthLabels[i] = name; // e.g., "Jan"
          break;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Streak - $selectedYear',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              DropdownButton<int>(
                value: selectedYear,
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
                underline: Container(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Heatmap with month labels
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month labels row (2 letters on top row)
                Row(
                  children: List.generate(weeks.length, (i) {
                    final label = monthLabels[i];
                    return Container(
                      width: 16,
                      alignment: Alignment.center,
                      child: label != null
                          ? Text(
                              label.substring(0, 2), // "Ja" from "Jan"
                              style: const TextStyle(
                                fontSize: 10,
                                color: kLightTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }),
                ),
                // Month labels second row (last char)
                Row(
                  children: List.generate(weeks.length, (i) {
                    final label = monthLabels[i];
                    return Container(
                      width: 16,
                      alignment: Alignment.center,
                      child: label != null
                          ? Text(
                              label.substring(
                                label.length - 1,
                              ), // "n" from "Jan"
                              style: const TextStyle(
                                fontSize: 10,
                                color: kLightTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  }),
                ),
                const SizedBox(height: 4),

                // Heatmap grid (with weekday labels on the left)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weekday labels (Mon, Wed, Fri only)
                    Column(
                      children: List.generate(7, (i) {
                        if (i == DateTime.monday % 7 ||
                            i == DateTime.wednesday % 7 ||
                            i == DateTime.friday % 7) {
                          return Container(
                            height: 16,
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun',
                              ][i],
                              style: const TextStyle(
                                fontSize: 9,
                                color: kLightTextColor,
                              ),
                            ),
                          );
                        }
                        return const SizedBox(height: 16);
                      }),
                    ),
                    const SizedBox(width: 4),

                    Row(
                      children: weeks.map((week) {
                        return Column(
                          children: List.generate(7, (i) {
                            final day = week[i];
                            final level =
                                day != null && allDays.containsKey(day)
                                ? allDays[day]!
                                : 0;
                            final color = [
                              Colors.grey.shade300,
                              Colors.green.shade100,
                              Colors.green.shade300,
                              Colors.green.shade500,
                              Colors.green.shade700,
                            ][level];
                            return Container(
                              margin: const EdgeInsets.all(2),
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for month abbreviations
  String _monthAbbrev(int month) {
    const names = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return names[month - 1];
  }
}
