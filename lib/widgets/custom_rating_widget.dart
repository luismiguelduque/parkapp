import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class CustomRatingWidget extends StatelessWidget {
  
  final double ranking;
  final double height;

  CustomRatingWidget({
    @required this.ranking,
    this.height=50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _generateStart(ranking),
    );
  }

  Widget _generateStart(double ranking){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Icon(Icons.star , color: (index < ranking) ? AppTheme.getTheme().colorScheme.primary : AppTheme.getTheme().disabledColor, size: 18,)
        );
      }),
    );
  }
}