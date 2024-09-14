import 'package:flutter/material.dart';
import 'package:untitled/components/my_button.dart';

import '../components/my_textfield.dart';

class RegisterPage extends StatelessWidget {


  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirnpasswordcontroller = TextEditingController();


  final void Function()? onTap;
  RegisterPage({super.key,
    required this.onTap});

  void login (){}
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,

              // borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.center ,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                          )),

                      const SizedBox(height: 50,),


                      const SizedBox(height:15),


                      MyTextfield(
                        hintText: "EMAIL",
                        icon: const Icon(Icons.mail_outline),
                        controller: _emailcontroller ,
                        obsecureText: false,
                              ),
                      const SizedBox(height:15),
                      MyTextfield(
                        hintText: "PASSWORD",
                        icon: const Icon(Icons.lock_outline),
                        controller: _passwordcontroller ,
                        obsecureText: true,

                              ),
                      const SizedBox(height:15),
                      MyTextfield(
                        hintText: "CONFIRM PASSWORD",
                        icon: const Icon(Icons.lock_outline),
                        controller: _confirnpasswordcontroller ,
                        obsecureText: true,

                                      ),
                      const SizedBox(height:15),





                      const SizedBox(height:35),

                      MyButton(text: " REGISTER" ,
                          onPressed: login,),

                      const SizedBox(height:30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text("Already have an account? ",),
                          GestureDetector(
                            onTap: onTap,


                            child: const Text("Login now",
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