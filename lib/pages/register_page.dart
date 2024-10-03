import 'package:flutter/material.dart';
import 'package:proecfxd/components/my_button.dart';

import '../components/my_textfield.dart';

class RegisterPage extends StatefulWidget {


  final void Function()? onTap;

  const RegisterPage({
    super.key,
    required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailcontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

  final TextEditingController _confirmpasswordcontroller = TextEditingController();

  bool _isValid = false;

  String _errorMessage = '';


  bool _validatePassword(String password,String confirmpassword){
    _errorMessage = '';

    if (password.isEmpty){
      _errorMessage +=" Enter a password";
    }
    else if  (password.length<8){
      _errorMessage += ' Password must be longer than 8 characters.';
    }
    else if  (!password.contains(RegExp(r'[A-Z]'))) {
      _errorMessage += ' Uppercase letter is missing.';
    }
    else if  (!password.contains(RegExp(r'[a-z]'))) {
      _errorMessage += ' Lowercase letter is missing.';
    }
    else if  (!password.contains(RegExp(r'[0-9]'))) {
      _errorMessage += ' Digit is missing.';
    }
    else if  (!password.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]'))) {
      _errorMessage += ' Special character is missing.';
    }
    else if  (password != confirmpassword  ) {
      _errorMessage += ' Those passwords didn’t match. Try again.';
    }

    return _errorMessage.isEmpty;

  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
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
                        controller: _confirmpasswordcontroller ,
                        obsecureText: true,

                                      ),
                      const SizedBox(height:5),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!_isValid && _errorMessage.isNotEmpty )

                            Padding(
                              padding: const EdgeInsets.only(left: 5.0,top: 2),
                              child:
                               Icon(
                                Icons.error,
                                color:  Colors.red.shade900,
                              ),),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child:
                              Text(
                                  _isValid ? '' : ' $_errorMessage',
                                  style: TextStyle(color: Colors.red.shade900,
                                  ),

                              ),),



                        ],
                      ),

                      const SizedBox(height:30),

                      MyButton(text: " REGISTER" ,
                        onPressed: () {
                          setState(() {
                            _isValid = _validatePassword(_passwordcontroller.text,_confirmpasswordcontroller.text);
                          });
                        },
                      ),


                const SizedBox(height:30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text("Already have an account? ",),
                          GestureDetector(
                            onTap: widget.onTap,


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