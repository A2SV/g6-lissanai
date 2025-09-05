import 'package:flutter/material.dart';

// 🎨 Theme constants
const Color kPrimaryColor = Color(0xFF112D4F);
const Color kAccentColor = Color(0xFFE5A642);
const Color kBackgroundColor = Colors.white;
const Color kCardBackgroundColor = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xFF333333);
const Color kLightTextColor = Color(0xFF6B7280);
const Color kGreenAccent = Color(0xFF00C853);

const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kMediumPadding = 12.0;
const double kLargePadding = 24.0;
const double kBorderRadius = 12.0;
const double kSmallBorderRadius = 8.0;

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 10),
            // 🔹 Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Row(
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
              ),
            ),
            const SizedBox(height: kDefaultPadding),

            // 🔹 Content sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  _buildAboutSection(),
                  const SizedBox(height: kDefaultPadding),

                  _buildQuickStatsSection(),
                  const SizedBox(height: kDefaultPadding),

                  _buildLearningFocusSection(),
                  const SizedBox(height: kLargePadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Profile Header
  Widget _buildProfileHeader() {
    return SizedBox(
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: Color(0xFF112D4F),
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
                            border: Border.all(
                              color: kBackgroundColor,
                              width: 2,
                            ),
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
                          SizedBox(width: kSmallPadding),
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

  // 🔹 Stats card
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
              spreadRadius: 1,
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

  // 🔹 Section card
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
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

  // 🔹 About section
  Widget _buildAboutSection() {
    return _buildSectionCard(
      title: 'About',
      icon: Icons.person_outline,
      children: [
        const Text(
          'Passionate about learning English and improving my communication skills. '
          'Currently focusing on business English and professional writing. '
          'I enjoy practicing with AI feedback and challenging myself with new vocabulary.',
          style: TextStyle(fontSize: 14, color: kTextColor, height: 1.4),
        ),
        const SizedBox(height: kMediumPadding),
        _buildInfoRow(Icons.work_outline, 'Marketing Specialist at TechCorp'),
        _buildInfoRow(Icons.school_outlined, 'Business Administration, NYU'),
        _buildInfoRow(Icons.language_outlined, 'www.sarahjohnson.com'),
        _buildInfoRow(Icons.email_outlined, 'sarah.johnson@email.com'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kLightTextColor),
          const SizedBox(width: kSmallPadding),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: kTextColor),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Quick Stats
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
          if (isButton)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSmallPadding,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(kSmallBorderRadius),
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
          else
            Text(
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

  // 🔹 Learning Focus
  Widget _buildLearningFocusSection() {
    return _buildSectionCard(
      title: 'Learning Focus',
      icon: Icons.lightbulb_outline,
      children: [
        _buildFocusRatingRow('Business English', 5),
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
}
