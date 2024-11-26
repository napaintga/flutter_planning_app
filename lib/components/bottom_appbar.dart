

import 'package:flutter/material.dart';

import '../auth/register_or_login.dart';
import '../pages/home_page.dart';
import '../pages/profile.dart';


class MyBottomAppBar extends StatefulWidget {

  final Function() onPressed;

  const MyBottomAppBar ({
    super.key,
    required this.onPressed,
  } );
  @override
  State<MyBottomAppBar> createState() => _MyBottomAppBarState();
}

class _MyBottomAppBarState extends State<MyBottomAppBar> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      height: 70,
      color:theme.primaryColor ,
      child: Row(
        children: [
          IconButton(
            tooltip: 'exit_to_app',
            icon: const Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginOrRegister()),
              );
            },
          ),
          IconButton(
            tooltip: 'cached',
            icon: const Icon(Icons.cached_outlined),
            onPressed: widget.onPressed
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TestPage()),
              );
            },
          ),

          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.task_alt_outlined),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  )
              );
            },
          ),

        ],
      ),
    );
  }
}