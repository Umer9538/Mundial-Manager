import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark theme styled text field for the Mundial Manager app.
/// Features: dark background, rounded corners, label above field, white text.
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label above the field
        Text(
          widget.label,
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Text field with dark styling
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 16,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.roboto(
              color: Colors.white38,
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0x1AFFFFFF), // 10% white
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: Colors.white54,
                    size: 22,
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: Colors.white54,
                          size: 22,
                        ),
                        onPressed: widget.onSuffixIconPressed,
                      )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isFocused
                    ? Colors.white38
                    : const Color(0x26FFFFFF), // 15% white
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x26FFFFFF), // 15% white
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x4DFFFFFF), // 30% white
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30), // Red
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30), // Red
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.roboto(
              color: const Color(0xFFFF6B6B),
              fontSize: 12,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x1AFFFFFF), // 10% white
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A dropdown field styled for the dark theme
class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;

  const CustomDropdownField({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          items: items,
          onChanged: onChanged,
          validator: validator,
          initialValue: value,
          dropdownColor: const Color(0xFF1A3A5C),
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 16,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white54,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.roboto(
              color: Colors.white38,
              fontSize: 16,
            ),
            filled: true,
            fillColor: const Color(0x1AFFFFFF),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: Colors.white54,
                    size: 22,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x26FFFFFF),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x26FFFFFF),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x4DFFFFFF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF3B30),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
