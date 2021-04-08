import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../utils/app_theme.dart';
import '../utils/constants.dart';

class CustomTextfield extends StatefulWidget {

  final String label;
  final String inputFormatters;
  final double height;
  final double width;
  final double horizontalMargin;
  final double verticalMargin;
  final int maxLines;
  final int maxLength;
  final String value;
  final Function(String value) onChanged;
  final Function(String value) onSaved;
  final Function(String value) validator;
  final TextInputType keyboardType;
  final bool numbersOnly;
  final bool obscureText;
  final bool readOnly;
  final TextEditingController controller;


  CustomTextfield({
    this.label,
    this.height,
    this.width,
    this.horizontalMargin = 0,
    this.verticalMargin = 0,
    this.maxLines = 1,
    this.maxLength,
    this.value,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.numbersOnly=false,
    this.obscureText=false,
    this.readOnly=false,
    this.controller, 
    this.inputFormatters,
  });

  @override
  _CustomTextfieldState createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  List<TextInputFormatter> _inputFormatters;

  @override
  void initState() {
    if(widget.numbersOnly){
      _inputFormatters = [WhitelistingTextInputFormatter.digitsOnly];
    }

    if(widget.inputFormatters == 'textOnly') {
      _inputFormatters = [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z \']'))];
    }
    
    if(widget.inputFormatters == 'email') {
      _inputFormatters = [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9\.\@_-]'))];
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      margin: EdgeInsets.symmetric(horizontal: widget.horizontalMargin, vertical: widget.verticalMargin),
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
          height: widget.height,
          child: Center(
            child: TextFormField(
              maxLength: widget.maxLength,
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              inputFormatters: _inputFormatters,
              initialValue: widget.value,
              readOnly: widget.readOnly,
              onSaved: widget.onSaved,
              onChanged: widget.onChanged,
              validator: widget.validator,
              style: TextStyle(fontSize: 16,),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(

                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                errorText: null,
                border: InputBorder.none,
                labelText: widget.label,
                hintStyle: TextStyle(color: AppTheme.getTheme().disabledColor),
                errorStyle: TextStyle(
                  color: redColor,
                ),
              ),
              maxLines: widget.maxLines,
            ),
          ),
        ),
      ),
    );
  }
}
