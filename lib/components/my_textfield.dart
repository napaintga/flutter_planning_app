import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyTextfield extends ConsumerStatefulWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;
  final bool obsecureText;
  const MyTextfield ({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    required this.obsecureText,
  });

  @override
  ConsumerState<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends ConsumerState<MyTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obsecureText,
      decoration: InputDecoration(
        hintText:widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade900,
        ),
        prefixIcon:widget.icon,
        prefixIconColor: Colors.grey.shade900,

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color:Colors.grey.shade900),
        )
      ),

    );
  }
}
