import 'package:flutter/material.dart';
import '../enums/text_field_theme.dart';

class CustomtextField extends StatelessWidget {
  const CustomtextField({
    super.key,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.obscureText = false,
    this.hintText = '',
    this.autofocus = false,
    this.fillColor,
    this.elevation = 5,
    this.theme = TextFieldTheme.dark,
    this.horizontalPadding = 15,
    this.verticalPadding = 15,
    this.textInputAction = TextInputAction.done,
    required this.textEditingController,
  });
  final TextEditingController textEditingController;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool obscureText;
  final String hintText;
  final Color? fillColor;
  final double elevation;
  final TextFieldTheme theme;
  final bool autofocus;
  final double horizontalPadding;
  final double verticalPadding;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    if (theme == TextFieldTheme.dark) {
      return Card(
        elevation: elevation,
        child: TextField(
          controller: textEditingController,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          obscureText: obscureText,
          autofocus: autofocus,
          style: TextStyle(color: Colors.grey.shade100),
          cursorColor: const Color(0xffff007a),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor ?? Colors.black,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade400,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade400,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    } else {
      return Card(
        elevation: elevation,
        child: TextField(
          controller: textEditingController,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          obscureText: obscureText,
          autofocus: autofocus,
          style: TextStyle(color: Colors.grey.shade600),
          cursorColor: const Color(0xffff007a),
          decoration: InputDecoration(
            filled: false,
            fillColor: fillColor ?? Colors.transparent,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade400,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.grey.shade400,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
    }
  }
}
