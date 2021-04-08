import 'package:flutter/material.dart';

class CustomGeneralTextfield extends StatefulWidget {
  @override
  _CustomGeneralTextfieldState createState() => _CustomGeneralTextfieldState();
}

class _CustomGeneralTextfieldState extends State<CustomGeneralTextfield> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        decoration: InputDecoration(
          
        ),
      ),
    );
  }
}