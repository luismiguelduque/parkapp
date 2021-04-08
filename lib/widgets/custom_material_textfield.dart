import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class CustomMaterialTextField extends StatelessWidget {

  final String label;
  final double height;
  final double width;
  final double horizontalMargin;
  final double verticalMargin;
  final double horizontalPadding;
  final int maxLines;
  final String value;
  final Function(String value) onChanged;
  final Function(String value) onSaved;
  final Function(String value) validator;
  final TextInputType keyboardType;
  final bool numbersOnly;
  final bool obscureText;
  final bool readOnly;

  CustomMaterialTextField({
    this.label,
    this.height,
    this.width,
    this.horizontalMargin = 0,
    this.verticalMargin = 0,
    this.horizontalPadding = 0,
    this.maxLines = 1,
    this.value,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.numbersOnly=false,
    this.obscureText=false,
    this.readOnly=false,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: verticalMargin),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getTheme().backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(38)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              blurRadius: 8,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Container(
            height: height,
            child: Center(
              child: TextField(
                obscureText: obscureText,
                maxLines: maxLines,
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 16,
                ),
                cursorColor: AppTheme.getTheme().primaryColor,
                decoration: new InputDecoration(
                  errorText: null,
                  border: InputBorder.none,
                  labelText: label,
                  hintStyle: TextStyle(color: AppTheme.getTheme().disabledColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}