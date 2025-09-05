import 'package:flutter/material.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/check_grammar_page.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/pages/practice_example_page.dart';

class GrammarTabView extends StatefulWidget {
  const GrammarTabView({super.key});

  @override
  State<GrammarTabView> createState() => _GrammarTabViewState();
}

class _GrammarTabViewState extends State<GrammarTabView> {
  String? _practiceText;
  bool _shouldAutoCheck = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context)!;
          tabController.addListener(() {
            if (mounted) setState(() {});
          });

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: const TabBar(
                indicatorColor: Color(0xFF112D4F),
                labelColor: Color(0xFF112D4F),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(
                    icon: Icon(Icons.spellcheck, size: 25),
                    text: 'Check Grammar',
                  ),
                  Tab(icon: Icon(Icons.school, size: 25), text: 'Sample Texts'),
                ],
              ),
            ),

            body: TabBarView(
              children: [
                CheckGrammarPage(
                  initialText: _practiceText,
                  autoCheck: _shouldAutoCheck,
                  onAutoCheckDone: () {
                    setState(() {
                      _shouldAutoCheck = false;
                      _practiceText = null;
                    });
                  },
                ),
                PracticeExamplePage(
                  onCheck: (text) {
                    setState(() {
                      _practiceText = text;
                      _shouldAutoCheck = true;
                      tabController.animateTo(0);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
