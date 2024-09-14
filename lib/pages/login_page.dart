import 'package:flutter/material.dart';
import 'package:untitled/components/my_button.dart';

import '../components/my_textfield.dart';

class LoginPage extends StatelessWidget {


  final TextEditingController _emailcontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

  final void Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap});

  void login (){}

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center ,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                          )),
                      const SizedBox(height: 5,),
                      const Text(
                          "Please  sing in to continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          )),
                      const SizedBox(height: 50,),
                      MyTextfield(
                        hintText: "EMAIL",
                        icon: const Icon(Icons.mail_outline),
                        controller: _emailcontroller ,
                        obsecureText: false,

                      ),
                      const SizedBox(height:25),
                      MyTextfield(
                        hintText: "PASSWORD",
                        icon: const Icon(Icons.lock_outline),
                        controller: _passwordcontroller ,
                        obsecureText: true,

                      ),
                      const SizedBox(height:35),
                      MyButton(text: " LOGIN" ,
                      onPressed: login,),

                      const SizedBox(height:30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text("Not a member? ",

                          ),
                          GestureDetector(
                           onTap: onTap,


                          child: const Text("Register now",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:  Color.fromRGBO(73, 102, 151, 1.0),
                          ),
                          ),
                          ),

                        ],

                      )

                    ],
                  ),
                )

              ],
            ),
          )),
    );
  }
}