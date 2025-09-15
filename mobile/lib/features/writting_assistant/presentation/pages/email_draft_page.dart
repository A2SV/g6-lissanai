import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';

class EmailDraftPage extends StatefulWidget {
  const EmailDraftPage({super.key});

  @override
  State<EmailDraftPage> createState() => _EmailDraftPageState();
}

class _EmailDraftPageState extends State<EmailDraftPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  String selectedTone = 'Formal';
  final tones = const ['Formal', 'Polite', 'Friendly'];

  String? selectedType;
  final types = const [
    'Job Application',
    'Application Follow-up',
    'Meeting Request',
    'Thank You Email',
    'General Inquiry',
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _controller,
                      maxLines: 5,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            'Describe your email in Amharic - ኢሜይልዎን በአማርኛ ይግለጹ, we’ll generate it',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$_charCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF112D4F),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'characters',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF112D4F),
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _controller.clear();
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

              const SizedBox(height: 20),

              // Email Type
              const Text(
                'Email Type(optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff112d4f),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: types.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select Type',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF112D4F),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF112D4F),
                ),
              ),

              const SizedBox(height: 16),

              // Tone
              const Text(
                'Tone',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff112d4f),
                ),
              ),
              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: tones.map((tone) {
                  final isSelected = selectedTone == tone;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(tone),
                      selected: isSelected,
                      selectedColor: const Color(0xFF112D4F),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedTone = tone;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Generate Button
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<WrittingBloc, WrittingState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is EmailDraftLoading
                          ? null
                          : () {
                              if (_controller.text.isNotEmpty) {
                                context.read<WrittingBloc>().add(
                                  GenerateEmailDraft(
                                    _controller.text,
                                    selectedTone,
                                    selectedType ?? '',
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff112d4f),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: state is EmailDraftLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Generate Email',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Generated Email Output
              BlocListener<WrittingBloc, WrittingState>(
                listener: (context, state) {
                  if (state is EmailDraftSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Email draft saved')),
                    );
                  } else if (state is EmailDraftError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ ${state.message}')),
                    );
                  }
                },
                child: BlocBuilder<WrittingBloc, WrittingState>(
                  builder: (context, state) {
                    if (state is WrittingInitial) {
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
                    } else if (state is EmailDraftLoaded ||
                        state is EmailDraftSaved) {
                      final emailDraft = state is EmailDraftLoaded
                          ? state.emailDraft
                          : (state as EmailDraftSaved).emailDraft;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
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
                              'Generated Email',
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
                                emailDraft.subject,
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
                                emailDraft.body,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: emailDraft.body),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Email copied to clipboard!',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Email'),
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

                            const SizedBox(height: 12),

                            // Save Button (full width)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<WrittingBloc>().add(
                                    SaveEmailDraftEvent(
                                      subject: emailDraft.subject,
                                      body: emailDraft.body,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.bookmark_add),
                                label: const Text('Save Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF112D4F),
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
              ),
            ],
          );
        
  }
}
