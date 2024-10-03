import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obsecureText,
      decoration: InputDecoration(
        hintText:hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade900,
        ),
        prefixIcon:icon,
        prefixIconColor: Colors.grey.shade900,

        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color:Colors.grey.shade900),
        )
      ),

    );
  }
}
