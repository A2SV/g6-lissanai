import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lissan_ai/features/auth/domain/entities/user.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/auth_state.dart';
import 'package:lissan_ai/features/auth/data/models/streak_calendar_model.dart';
import 'package:lissan_ai/features/auth/data/models/streak_info_model.dart';
import 'package:lissan_ai/features/auth/data/models/week_model.dart';
import 'package:lissan_ai/features/auth/data/models/day_model.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_bloc.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_event.dart';
import 'package:lissan_ai/features/auth/presentation/bloc/streak_state.dart';

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

  StreakInfoModel? streakInfo;
  StreakCalendarModel? calendar;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(GetUserEvent());
    final bloc = context.read<StreakBloc>();
    bloc.add(GetStreakInfoEvent());
    bloc.add(GetActivityCalendarEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthErrorState) {
              return Center(child: Text(state.message));
            } else if (state is UserInfoState) {
              final user = state.user;
              return _buildProfileContent(user);
            }
            return const Center(child: Text('No user data'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 16),
          _buildStatsRow(),
          const SizedBox(height: 16),
          MultiBlocListener(
            listeners: [
              BlocListener<StreakBloc, StreakState>(
                listener: (context, state) {
                  if (state is StreakInfoLoaded) {
                    setState(
                      () => streakInfo = state.streakInfo as StreakInfoModel,
                    );
                  } else if (state is ActivityCalendarLoaded) {
                    setState(
                      () => calendar = state.calendar as StreakCalendarModel,
                    );
                  }
                },
              ),
            ],
            child: Column(
              children: [
                if (streakInfo != null) _buildStreakInfo(streakInfo!),
                const SizedBox(height: 16),
                if (calendar != null) _buildHorizontalHeatmap(calendar!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
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
            left: 16,
            right: 16,
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
                            color: const Color(0xFF00C853),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          '7',
          'Day Streak',
          streakInfo != null ? '${streakInfo!.current_streak ?? 0} days' : '-',
          valueColor: const Color(0xFFFFA000),
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          '156',
          'Hours Practiced',
          '+8 this week',
          valueColor: const Color(0xFF00C853),
        ),
        const SizedBox(width: 8),
        _buildStatCard('28', 'Achievements', '3 new'),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    String detail, {
    Color valueColor = const Color(0xFF333333),
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 2),
            Text(detail, style: TextStyle(fontSize: 11, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInfo(StreakInfoModel info) {
    return _buildStatsRow();
  }

  Widget _buildHorizontalHeatmap(StreakCalendarModel calendar) {
    if (calendar.weeks == null || calendar.weeks!.isEmpty) {
      return const SizedBox.shrink();
    }

    final weeks = calendar.weeks!
        .map(
          (week) =>
              (week as WeekModel).days!.map((e) => e as DayModel).toList(),
        )
        .toList();

    final monthLabels = <String>[];
    for (var week in weeks) {
      if (week.isNotEmpty) {
        final month = DateTime.parse(week[0].date!).month;
        final monthName = [
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
        ][month - 1];
        monthLabels.add(monthName);
      } else {
        monthLabels.add('');
      }
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 40),
              ...monthLabels.map(
                (month) => SizedBox(
                  width: 16 * 7,
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekdays
                    .map(
                      (day) => SizedBox(
                        height: 16,
                        child: Text(
                          day[0],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(width: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: weeks.map((week) {
                    return Column(
                      children: List.generate(7, (i) {
                        final day = i < week.length ? week[i] : null;
                        final color = day != null && (day.has_activity ?? false)
                            ? Colors.green.shade500
                            : Colors.grey.shade300;
                        return Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
