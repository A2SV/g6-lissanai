import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PracticeExamplePage extends StatefulWidget {
  final void Function(String text)? onCheck;
  const PracticeExamplePage({super.key, this.onCheck});

  @override
  State<PracticeExamplePage> createState() => _PracticeExamplePageState();
}

class _PracticeExamplePageState extends State<PracticeExamplePage> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Practice Example',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                              if (value != null &&
                                  (value.text?.isNotEmpty ?? false)) {
                                final newText =
                                    _controller.text + (value.text ?? '');
                                setState(() {
                                  _controller.text = newText;
                                  _controller.selection =
                                      TextSelection.collapsed(
                                        offset: newText.length,
                                      );
                                  _charCount = newText.length;
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
                                _charCount = 0;
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
                        widget.onCheck?.call(_controller.text);
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 20),
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

              const SizedBox(height: 15),

              // Sample Texts header
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF112D4F),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Try Sample Texts',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Practice with these examples that contain common errors',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF112D4F),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Sample Cards
              Column(
                children: [
                  _buildSampleCard(
                    sampleText:
                        "I am writing to apply for the position of software developer at your company. I have 3 years experience in programming and I'm very excited about this opportunity.",
                    buttonLabel: 'Load Sample 1',
                  ),
                  _buildSampleCard(
                    sampleText:
                        'Dear hiring manager, I want to introduce myself as a candidate for the marketing role. I has worked in various companies and learned many skills.',
                    buttonLabel: 'Load Sample 2',
                  ),
                  _buildSampleCard(
                    sampleText:
                        'Thank you for considering my application. I am confident that my background and enthusiasm makes me a strong candidate for this position.',
                    buttonLabel: 'Load Sample 3',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleCard({
    required String sampleText,
    required String buttonLabel,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sampleText,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF112D4F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              setState(() {
                _controller.text = sampleText;
                _controller.selection = TextSelection.collapsed(
                  offset: sampleText.length,
                );
                _charCount = sampleText.length;
              });

              FocusScope.of(context).unfocus();
            },
            child: Text(
              buttonLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
