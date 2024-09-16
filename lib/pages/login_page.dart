import 'package:flutter/material.dart';
import 'package:untitled/components/my_button.dart';
import './home_page.dart';

import '../components/my_textfield.dart';

class LoginPage extends StatefulWidget {


  final void Function()? onTap;
  LoginPage({
    super.key,
    required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailcontroller = TextEditingController();

  final TextEditingController _passwordcontroller = TextEditingController();

  bool _isLogin = false;

  String  _errorMessageLogin = '';
  final _password = "11";

  bool login(String password,String email,String password2) {
     _errorMessageLogin = '';

    if (password.isEmpty  || email.isEmpty) {
       _errorMessageLogin += " Enter a password and email";
    }
    else if (password != password2) {
       _errorMessageLogin += " bad  password  ";
     }
     else if (password == password2) {
      _errorMessageLogin += " good  password  ";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }

     return _errorMessageLogin.isEmpty;
    return  _errorMessageLogin.isEmpty;
  }

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
                      const SizedBox(height:5),


                      const SizedBox(height:25),
                      MyTextfield(
                        hintText: "PASSWORD",
                        icon: const Icon(Icons.lock_outline),
                        controller: _passwordcontroller ,
                        obsecureText: true,

                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!_isLogin && _errorMessageLogin.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0, top: 2),
                              child: Icon(
                                Icons.error,
                                color: Colors.red.shade900,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _isLogin ? '' : '$_errorMessageLogin',
                              style: TextStyle(
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height:35),
                      MyButton(text: " LOGIN" ,
                      onPressed:(){ setState(() {
                        _isLogin = login(_passwordcontroller.text,
                            _emailcontroller.text,
                            _password);
                      });
                      },),

                      const SizedBox(height:30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center ,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text("Not a member? ",

                          ),
                          GestureDetector(
                           onTap: widget.onTap,
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