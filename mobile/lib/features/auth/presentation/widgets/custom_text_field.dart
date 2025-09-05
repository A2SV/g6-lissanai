import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final bool obscure;
  final bool enabled;
  const CustomTextField({
    required this.controller,
    required this.title,
    required this.icon,
    required this.hintText,
    required this.enabled,
    this.obscure = false,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: widget.title == 'Email'
              ? TextInputType.emailAddress
              : null,
          enabled: widget.enabled,
          obscureText: _obscureText,
          controller: widget.controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            prefixIcon: Icon(widget.icon, color: const Color(0xFFC9C9C9)),
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Color(0xFFC9C9C9)),
            fillColor: const Color(0xFFFCFCFC),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD9D8D8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD9D8D8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD9D8D8)),
            ),

            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFC9C9C9),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '${widget.title} is required';
            }
            if (widget.title == 'Password' && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (widget.title == 'Email' &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }
}
