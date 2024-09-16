import 'package:flutter/material.dart';
import 'package:untitled/auth/register_or_login.dart';
import 'package:untitled/pages/home_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ',
      color: Colors.white70,
      theme: ThemeData(

        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color.fromRGBO(219, 226, 252, 1.0),
          seedColor: const Color.fromRGBO(30, 76, 168, 1.0),
          secondary: const   Color.fromRGBO(30, 76, 168, 1.0),



      ),
        useMaterial3: true,
        // fontFamily: 'Raleway',
      ),
      home:   const LoginOrRegister(),

    );
  }
}


