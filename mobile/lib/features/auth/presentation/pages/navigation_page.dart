import 'package:flutter/material.dart';
import 'package:lissan_ai/features/auth/presentation/pages/dashboard_page.dart';
import 'package:lissan_ai/features/auth/presentation/pages/profile_page.dart';
import 'package:lissan_ai/features/practice_speaking/presentation/pages/mock_interview_page.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/email_tab_view.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/grammar_tab_view.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    Dashboard(),
    MockInterviewPage(),
    EmailTabView(),
    GrammarTabView(),
    UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: List.generate(_pages.length, (index) {
          return Offstage(
            offstage: _selectedIndex != index,
            child: TickerMode(
              enabled: _selectedIndex == index,
              child: _pages[index],
            ),
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF112D4F),
        selectedItemColor: Colors.white,
        selectedIconTheme: const IconThemeData(size: 30),
        unselectedItemColor: Colors.grey[400],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Speaking'),
          BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Email'),
          BottomNavigationBarItem(
            icon: Icon(Icons.language_outlined),
            label: 'Grammar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
