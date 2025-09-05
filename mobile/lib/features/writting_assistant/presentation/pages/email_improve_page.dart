import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/widgets/emphasis_boc.dart';

class EmailImprovePage extends StatefulWidget {
  const EmailImprovePage({super.key});

  @override
  State<EmailImprovePage> createState() => _EmailImprovePageState();
}

class _EmailImprovePageState extends State<EmailImprovePage> {
  final TextEditingController _emailController = TextEditingController();
  int _charCount = 0;
  String selectedTone = 'Formal';
  final tones = const ['Formal', 'Polite', 'Friendly'];
  String selectedType = 'Job Application';
  final types = const [
    'Job Application',
    'Application Follow-up',
    'Meeting Request',
    'Thank You Email',
    'General Inquiry',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        if (state is ConnectivityConnected) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        maxLines: 5,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText:
                              'Paste your email here  እባክዎ እዚህ ጽሁፍዎን ያስገቡ...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF9F9F9),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF9F9F9),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFF9F9F9),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _emailController.clear();
                                });
                              },
                              child: const Icon(
                                Icons.clear_outlined,
                                size: 30,
                                color: Color(0xFF112D4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Tone:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xff112d4f),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: tones.map((tone) {
                    final isSelected = selectedTone == tone;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Center(child: Text(tone)),
                          selected: isSelected,
                          selectedColor: const Color(0xff112d4f),
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color.fromARGB(255, 98, 96, 96),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedTone = tone;
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<WrittingBloc, WrittingState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ImproveEmailLoading
                            ? null
                            : () {
                                if (_emailController.text.isNotEmpty) {
                                  context.read<WrittingBloc>().add(
                                    ImproveEmailEvent(
                                      _emailController.text,
                                      selectedTone,
                                      selectedType,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter your email first',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff112d4f),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is ImproveEmailLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Improve Email',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                ),

                BlocBuilder<WrittingBloc, WrittingState>(
                  builder: (context, state) {
                    if (state is ImproveEmailLoaded &&
                        state.improvedEmail.corrections.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'Here are some ways to make your Email better',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: const Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            height: 400,
                            child: ListView.builder(
                              itemCount: state.improvedEmail.corrections.length,
                              itemBuilder: (context, index) {
                                final c =
                                    state.improvedEmail.corrections[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey.shade50,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.close_rounded,
                                            color: Color(0xFFEF4444),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: EmphasisBlock(
                                              title: 'Original',
                                              body: c.original,
                                              titleColor: const Color(
                                                0xFFEF4444,
                                              ),
                                              bgColor: const Color(0xFFFFF1F2),
                                              borderColor: const Color(
                                                0xFFFECACA,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF22C55E),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: EmphasisBlock(
                                              title: 'Improved',
                                              body: c.corrected,
                                              titleColor: const Color(
                                                0xFF22C55E,
                                              ),
                                              bgColor: const Color(0xFFF0FDF4),
                                              borderColor: const Color(
                                                0xFFBBF7D0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.info_rounded,
                                            color: Color(0xFF2563EB),
                                            size: 22,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: EmphasisBlock(
                                              title: 'Why',
                                              body: c.explanation,
                                              titleColor: const Color(
                                                0xFF2563EB,
                                              ),
                                              bgColor: const Color(0xFFEFF6FF),
                                              borderColor: const Color(
                                                0xFFBFDBFE,
                                              ),
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
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 24),

                BlocBuilder<WrittingBloc, WrittingState>(
                  builder: (context, state) {
                    if (state is ImproveEmailLoading) {
                      return const SizedBox();
                    } else if (state is EmailDraftError) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is ImproveEmailLoaded) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Improved Email',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                state.improvedEmail.subject,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                state.improvedEmail.improvedBody,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: state.improvedEmail.improvedBody,
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Improved email copied to clipboard!',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Improved Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF009688),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        } else {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.wifi_off, color: Color(0xFF112D4F), size: 180),
                Text(
                  'Please check your internet connection',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
