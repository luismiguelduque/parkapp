import 'package:flutter/material.dart';

import '../utils/constants.dart';

class EmptyList extends StatelessWidget {

  EmptyList({
    this.color
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, color: color != null ? color : whiteColor, size: 35,),
            Text("Esta lista esta vacía", style: text3.copyWith(color: color != null ? color : whiteColor),),
          ],
        ),
      ),
    );
  }
}