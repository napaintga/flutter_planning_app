import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proecfxd/pages/home_page.dart';
void main() {
    runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ',
      color: Colors.white70,
      theme: ThemeData(

        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(30, 76, 168, 1.0),
          secondary: const   Color.fromRGBO(30, 76, 168, 1.0),



        ),
        secondaryHeaderColor:const   Color.fromRGBO(30, 76, 168, 1.0),
        primaryColor: Color.fromRGBO(219, 226, 252, 1.0),

        useMaterial3: true,
        // fontFamily: 'Raleway',
      ),
      home:   HomeScreen(),

    );
  }
}


