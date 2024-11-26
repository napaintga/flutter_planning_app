import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyButton extends ConsumerStatefulWidget {
  final String text;
  final Function() onPressed;

  const MyButton ({
    super.key,
    required this.text,
    required this.onPressed,
  } );

  @override
  ConsumerState<MyButton> createState() => _MyButtonState();
}

class _MyButtonState extends ConsumerState<MyButton> {
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
            onPressed: widget.onPressed,
            child: Text(widget.text)
        )
      ],
    );
  }
}
