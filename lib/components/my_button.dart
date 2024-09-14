import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const MyButton ({
    super.key,
    required this.text,
    required this.onPressed
  } );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children: [

        ElevatedButton(
          style:ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(73, 102, 151, 1.0),
            foregroundColor: Colors.white,
          ) ,
            onPressed: onPressed,
            child: Text(text))
      ],
    );
  }
}
