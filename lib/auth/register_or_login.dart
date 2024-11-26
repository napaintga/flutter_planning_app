import 'package:flutter/material.dart' show BuildContext, State, StatefulWidget, Widget;
import 'package:proecfxd/pages/register_page.dart';

import '../pages/login_page.dart';
import '../service/contract_service.dart';



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
      final contractServiceTask = ContractService();

      return RegisterPage(onTap: toggle_pages,  contractServiceTask: contractServiceTask,
      );
    }
  }
}