import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';

class CustomDropdown extends StatelessWidget {

  final String label;
  final double height;
  final double width;
  final double horizontalMargin;
  final double verticalMargin;
  final double horizontalPadding;
  final List<Map> items;
  final String value;
  final Function(String value) onChanged;
  final Function(String value) onSaved;
  final Function(String value) validator;

  CustomDropdown({
    this.label,
    this.height,
    this.width,
    this.horizontalMargin = 0,
    this.verticalMargin = 0,
    this.horizontalPadding = 0,
    this.items,
    this.value,
    this.onChanged,
    this.onSaved,
    this.validator
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
              child: DropdownButtonFormField<String>(
                value: value != null ? value : null,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  errorText: null,
                  border: InputBorder.none,
                  labelText: label,
                  hintStyle: TextStyle(color: AppTheme.getTheme().disabledColor),
                  errorStyle: TextStyle(color: redColor,),
                ),
                onSaved: onSaved,
                onChanged: onChanged,
                validator: validator,
                items: items.map((Map item) {
                  return DropdownMenuItem<String>(
                    onTap: (){},
                    value: item['value'],
                    child: Text(item['label'], style: text4,),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}