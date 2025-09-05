import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lissan_ai/core/network/bloc/connectivity_bloc.dart';
import 'package:lissan_ai/core/utils/constants/auth_constants.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_bloc.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_event.dart';
import 'package:lissan_ai/features/writting_assistant/presentation/bloc/writting_state.dart';

class CheckGrammarPage extends StatefulWidget {
  final String? initialText;
  final bool autoCheck;
  final VoidCallback? onAutoCheckDone;
  const CheckGrammarPage({
    super.key,
    this.initialText,
    this.autoCheck = false,
    this.onAutoCheckDone,
  });

  

  @override
  State<CheckGrammarPage> createState() => _CheckGrammarPageState();
}

class _CheckGrammarPageState extends State<CheckGrammarPage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
      _charCount = widget.initialText!.length;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.autoCheck) {
          context.read<WrittingBloc>().add(
            CheckGrammarEvent(englishText: widget.initialText!),
          );
          widget.onAutoCheckDone?.call();
        }
      });
    }
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: BlocBuilder<ConnectivityBloc, ConnectivityState>(
        builder: (context, state) {
          if (state is ConnectivityConnected) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _controller,
                            maxLines: 5,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your text here...',
                              hintStyle: GoogleFonts.inter(
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
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF112D4F),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'characters',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF112D4F),
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () async {
                                    final value = await Clipboard.getData(
                                      'text/plain',
                                    );
                                    if (value != null) {
                                      setState(() {
                                        _controller.text += value.text ?? '';
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Icon(
                                    Icons.paste,
                                    color: Color(0xFF112D4F),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _controller.clear();
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear,
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

                    const SizedBox(height: 12),

                    // Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _charCount >= 1
                            ? const Color(0xFF112D4F)
                            : const Color.fromRGBO(17, 45, 79, 1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _charCount >= 1
                          ? () {
                              context.read<WrittingBloc>().add(
                                CheckGrammarEvent(
                                  englishText: _controller.text,
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Check Grammar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    BlocConsumer<WrittingBloc, WrittingState>(
                      listener: (context, state) {
                        if (state is GrammarError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is GrammarLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: SpinKitDoubleBounce(
                                color: Colors.grey,
                                size: 100,
                              ),
                            ),
                          );
                        }
                        if (state is GrammarLoaded) {
                          final issues = state.grammarResult.corrections;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.trending_up_rounded,
                                          color: Color(0xFF112D4F),
                                          size: 26,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Analysis Results',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF112D4F),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Score: 80/100',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // If no issues
                                if (issues.isEmpty) ...[
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: const BoxDecoration(
                                            color: Color.fromRGBO(
                                              220,
                                              252,
                                              231,
                                              1,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(16),

                                          child: Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green.shade700,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Perfect Grammar',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                              22,
                                              101,
                                              52,
                                              1,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'No errors found in your text.',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color.fromRGBO(
                                              22,
                                              163,
                                              74,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // If issues found
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${issues.length} Issue Found',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Issue List
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 200,
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: issues.length,
                                      itemBuilder: (context, index) {
                                        final correction = issues[index];
                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF112D4F,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'grammar',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              RichText(
                                                text: TextSpan(
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          '"${correction.originalPhrase}"',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const TextSpan(text: ' → '),
                                                    TextSpan(
                                                      text: correction
                                                          .correctedPhrase,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                correction.explanation,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                // Improved Version
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt_sharp,
                                      color: Colors.green,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Improved Version',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF112D4F),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        state.grammarResult.correctedText,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFF112D4F),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: state
                                                    .grammarResult
                                                    .correctedText,
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Copied to clipboard',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                            color: Color(0xFF112D4F),
                                          ),
                                          label: Text(
                                            'Copy',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF112D4F),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Writing Tips',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF112D4F),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    _writingTip(
                                      tipName:
                                          'Consider using more varied sentence structures',
                                    ),
                                    const SizedBox(height: 5),
                                    _writingTip(
                                      tipName:
                                          'Add transition words to improve flow',
                                    ),
                                    const SizedBox(height: 5),
                                    _writingTip(
                                      tipName:
                                          'Use active voice where possible',
                                    ),
                                    const SizedBox(height: 5),
                                    _writingTip(
                                      tipName:
                                          'Check for consistent tense throughout',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

Widget _writingTip({required String tipName}) {
  return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 229, 175),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.lightbulb_outline, color: Colors.amber),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          tipName,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF112D4F),
          ),
        ),
      ),
    ],
  );
}
