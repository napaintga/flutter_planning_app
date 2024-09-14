import 'package:flutter/material.dart';
import 'package:untitled/pages/register_page.dart';

import '../pages/login_page.dart';



class LoginOrRegister extends StatefulWidget{
  const LoginOrRegister ({
    super.key
});

  @override
  _LoginOrRegisterState createState() =>  _LoginOrRegisterState();


}
class _LoginOrRegisterState extends State<LoginOrRegister>{
  bool show_login_page = true;


  void toggle_pages(){
    setState(() {
      show_login_page = !show_login_page;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (show_login_page){
      return LoginPage(onTap: toggle_pages);
    }
    else{
      return RegisterPage(onTap: toggle_pages);
    }
  }
}